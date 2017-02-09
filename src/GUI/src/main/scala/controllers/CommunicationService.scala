package tinkerGUI.controllers

import tinkerGUI.controllers.events.{ConnectedToCoreEvent, EvalOptionSelectedEvent}

import quanto.util.json._
import tinkerGUI.utils.TinkerDialog

import scala.swing._
import scala.concurrent._
import scala.collection.mutable.ArrayBuffer
import scala.util.{Success, Failure}
import java.net._
import java.io._
import ExecutionContext.Implicits.global

/** Object listing the potential protocol states.*/
object CommunicationState extends Enumeration {
	val WaitingForUpdate, NotConnected, WaitingForEvalOptions, WaitingForUserChoice, WaitingForInit = Value
}

/** Service establishing and managing connection with core.*/
object CommunicationService extends Publisher {

	/** Connection status.*/
	var connected = false

	/** Ongoing connection status.*/
	var connecting = false

	/** Gui side socket.*/
	var gui: ServerSocket = null

	/** Core side socket.*/
	var prover: Socket = null

	/** Evaluation status.*/
	var state:CommunicationState.Value = CommunicationState.NotConnected

  /** Potential socket used for connection. */
  var initConnection:Future[Socket] = null

	/** Method closing the connection.
		*
		*/
	def closeConnection() {
		if(connected){
			gui.close()
			prover.close()
			connected = false
			state = CommunicationState.NotConnected
			Service.evalCtrl.setInEval(false)
			publish(ConnectedToCoreEvent(connected, connecting))
		}
	}

  /** Method interrupting the connection request.
    *
    */
  def interruptConnection() {
    if(connecting){
      // closing socket, and activating failure implemented in open connection
      gui.close()
      println("GUI speaking : interrupting connection !")
    }
  }

	/** Method opening a connection.
		*
		* It will launch a socket and wait for a connection on it.
		* A successful connection will launch the [[listen]] method.
		*/
	def openConnection() {
		if(!connecting){
			connecting = true
			gui = new ServerSocket(1790)
			initConnection = future {
				println("GUI speaking : connecting ...")
				gui.accept
			}
			publish(ConnectedToCoreEvent(connected, connecting))
      initConnection onComplete {
				case Success(c) =>
					connecting = false
					prover = c
					println("GUI speaking : connected !")
					connected = true
					publish(ConnectedToCoreEvent(connected, connecting))
					state = CommunicationState.WaitingForInit
					listen()
				case Failure(t) =>
					connecting = false
					publish(ConnectedToCoreEvent(connected, connecting))
					println("GUI speaking : Not connected : " + t.getMessage)
			}
		}

	}

	/** Method listening for incoming messages.
		*
		* As soon as a message arrives in the buffered reader, the [[getMessage]] method is launched.
		*/
	def listen() {
		if(connected){
			println("listening ...")
			val in = new BufferedReader(new InputStreamReader(prover.getInputStream))
			val input : Future[String] = future {
				in.readLine
			}
			input onComplete {
				case Success(s) => getMessage(in, s)
				case Failure (t) => println("An error occured : "+t.getMessage)
			}
		}
	}

	/** Method getting a complete message from a buffered reader.
		*
		* The message is fetched while there are strings in the buffered reader.
		* When it is finish the [[parseAndExecute]] method is launched, and the [[listen]] method after that.
		*
		* @param in Buffered Reader were the message is incoming.
		* @param firstLine Message's first line that came in the reader.
		*/
	def getMessage(in: BufferedReader, firstLine: String){
		if(connected){
			val b = new StringBuilder()
			b.append(firstLine)
			while(in.ready){
				b.append("\n")
				b.append(in.readLine)
			}
			try {
				val j = Json.parse(b.toString())
				println(b.toString())
				parseAndExecute(j)
			} catch {
				case e:JsonParseException =>
					sendErrorResponse("RSP_MESSAGE_ERROR", "bad json, message : "+e.getMessage)
					println(e.getMessage)
					println(b.toString())
			}
			listen()
		}
	}

	/** Method parsing a json message and executing the command it contains.
		*
		* @param j Json message.
		*/
	def parseAndExecute(j: Json) {
		j ? "cmd" match {
			// if no command found
			case cmd: Json if cmd == JsonNull => sendErrorResponse("RSP_MESSAGE_ERROR", "no command")
			// if command found
			case cmd: Json => cmd.stringValue match {
				case "CMD_SHOW_GUI" => // deprecated
					Service.showTinkerGUI(true)
				case "CMD_HIDE_GUI" => // deprecated
					Service.showTinkerGUI(false)
				case "CMD_INIT_PSGRAPH" => // command initialising evaluation : i.e. synchronising psgraph and goal between both sides
					if(state == CommunicationState.WaitingForInit){
						j ? "psgraph" match {
							case psgraph: Json if psgraph == JsonNull => sendErrorResponse("RSP_ERROR_INIT_PSGRAPH", "no psgraph")
							case psgraph: JsonBool =>
								j ? "goal" match {
									case goal: Json if goal == JsonNull => sendErrorResponse("RSP_ERROR_INIT_PSGRAPH", "no goal")
									case goal: JsonBool =>
										val rsppsgraph = if(psgraph.boolValue) JsonArray() else JsonArray(Service.model.updateJsonPSGraph())
										val rspgoal =
											if(goal.boolValue) JsonArray()
											else JsonArray(JsonString(Service.evalCtrl.goal), JsonArray(Service.evalCtrl.assms.foldLeft(Array[JsonString]()){case(a,s)=>a:+JsonString(s)}))
										send(JsonObject("cmd"->"RSP_INIT_PSGRAPH","psgraph"->rsppsgraph,"goal"->rspgoal))
										state = CommunicationState.WaitingForUpdate
								}
						}
					}
				case "CMD_UPDATE_PSGRAPH" => // command updating graph after evaluation step
					Service.evalCtrl.setInEval(true)
					getEvalPSGraph(j ? "eval_psgraph", "UPDATE_PSGRAPH")
					getEvalOptions(j ? "eval_options", "UPDATE_PSGRAPH")
					getEvalLog(j ? "log_info", "UPDATE_PSGRAPH")
				case "RSP_EXCEPTION" => // command for exception
					getEvalLog(j ? "log_info", "EXCEPTION")
					if (state == CommunicationState.WaitingForUpdate || state == CommunicationState.WaitingForInit) {
						j ? "if_interrupt" match {
							case interrupt: Json if interrupt == JsonNull => sendErrorResponse("RSP_ERROR_EXCEPTION","no if_interrupt")
							case interrupt: JsonBool =>
								state = CommunicationState.WaitingForEvalOptions
								if(interrupt.boolValue) {
									TinkerDialog.openInformationDialog("Proof failed, check log for more information and/or backtrack.")
									getEvalOptions(JsonArray(JsonString("OPT_EVAL_STOP"),JsonString("OPT_EVAL_UNDO"),JsonString("OPT_EVAL_BACKTRACK")), "EXCEPTION")
								} else {
									getEvalOptions(JsonArray(JsonString("OPT_EVAL_STOP"),JsonString("OPT_EVAL_UNDO")), "EXCEPTION")
								}
						}
					}
				case "CMD_CLOSE_CONNECT" => // command closing the connection
					Service.evalCtrl.setInEval(false)
					sendErrorResponse("RSP_CLOSE_CONNECT", "closing connection")
					closeConnection()
				case "CMD_END_EVAL_SESSION" => // ending eval, but keeping connection
					println("receive cmd CMD_END_EVAL_SESSION: reset state")
					Service.evalCtrl.setInEval(false)
					state = CommunicationState.WaitingForInit
				case _ => // unsupported command
					sendErrorResponse("RSP_ERROR_BAD_CMD", "")

			}
		}
	}

	/** Method retrieving a psgraph model from a json input and loading as new model for the app.
		*
		* @param j Json psgraph model.
		* @param context Context for error handling, e.g. UPDATE_PSGRAPH.
		*/
	def getEvalPSGraph(j:Json, context:String) {
		if(state == CommunicationState.WaitingForUpdate){
			j match {
				// if eval field not found
				case eval: Json if eval == JsonNull => sendErrorResponse("RSP_ERROR_"+context, "no eval psgraph")
				// if eval field found
				case eval: JsonObject =>
					// loading eval model in gui
					Service.evalCtrl.loadJson(eval)
					// setting the backup model to empty
					Service.evalCtrl.tmpEvalPSGraph = JsonObject()
					// changing state
					state = CommunicationState.WaitingForEvalOptions
				case _ => sendErrorResponse("RSP_ERROR_"+context, "bad eval psgraph format")
			}
		}
	}

	/** Method retrieving the available evaluation options from a json input and enabling them on the view.
		*
		* Also set up a listener to get the user choice when they click on a option button, and send it to the core.
		*
		* @param j Json array containing the evaluation options.
		* @param context Context for error handling, e.g. UPDATE_PSGRAPH.
		*/
	def getEvalOptions(j:Json, context:String) {
		if (state == CommunicationState.WaitingForEvalOptions) {
			j match {
				// if options not found
				case options: Json if options == JsonNull => sendErrorResponse("RSP_ERROR_"+context, "no eval options")
				// options found
				case options: JsonArray =>
					val opts = options.vectorValue.foldLeft(ArrayBuffer[String]()) {
						case (a, s: JsonString) => a :+ s.stringValue
						case (a, _) => a
					}
					// enable in view
					Service.evalCtrl.enableEvalOptions(opts)
					// change state
					state = CommunicationState.WaitingForUserChoice
					// future for user interaction
					listenTo(Service.evalCtrl)
					reactions += {
						case EvalOptionSelectedEvent(opt, node) =>
							// check if correct state
							if (state == CommunicationState.WaitingForUserChoice) {
								// send option chosen
								val cmd = "RSP_"+context
								send(JsonObject("cmd" -> cmd, "option" -> JsonString(opt), "node" -> JsonString(node)))
								// change state
								state = CommunicationState.WaitingForUpdate
							}
					}
				case _ => sendErrorResponse("RSP_ERROR_"+context, "bad eval options format")
			}
		}
	}

	/** Method retrieving logging informations from a json input and printing them in the evaluation log stack.
		*
		* @param j Json object containing the logging messages.
		* @param context Context for error handling, e.g. UPDATE_PSGRAPH.
		*/
	def getEvalLog(j:Json, context:String) {
		j match {
			case logs: Json if logs == JsonNull => sendErrorResponse("RSP_ERROR_"+context, "no log info")
			case logs: JsonObject =>
				Service.evalCtrl.logStack.addToLog(logs.mapValue.map{
					case (k,v) =>
						k -> v.asArray.map {
							case (s: JsonString) => s.stringValue
							case _ => "<< Message parse error, wrong type >>"
						}
				})
			case _ => sendErrorResponse("RSP_ERROR_"+context, "bad log info format")
		}
	}

	/** Method sending a string message to the core.
		*
		* @param msg String message.
		*/
	def send(msg: String){
		if(connected){
			val out = new PrintStream(prover.getOutputStream)
			out.println(msg)
			out.flush()
		}
	}

	/** Method sending a json message to the core.
		*
		* @param j Json message.
		*/
	def send(j:Json){
		if(connected){
			val out = new PrintStream(prover.getOutputStream)
			j.writeTo(out)
			out.flush()
		}
	}

	/** Shortcut method to send a Json error message.
		*
		* @param c Command name.
		* @param m Command argument/message.
		*/
	def sendErrorResponse(c:String, m:String){
		send(JsonObject("cmd" -> c, "error" -> m))
	}

	/** Method to notify the core of a change in the psgraph.
		*
		* @param psgraph Json of the new psgraph.
		* @param evalPath Evaluation path before the changes.
		*/
	def sendPSGraphChange(psgraph:Json, evalPath:JsonArray): Unit ={
		if(state == CommunicationState.WaitingForUserChoice){
			send(JsonObject("cmd" -> "CMD_CHANGE_PSGRAPH", "eval_psgraph" -> psgraph, "eval_path" -> evalPath))
			state = CommunicationState.WaitingForUpdate
		}
	}
	
}