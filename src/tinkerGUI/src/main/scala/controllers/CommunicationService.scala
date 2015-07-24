package tinkerGUI.controllers

import tinkerGUI.controllers.events.{ConnectedToCoreEvent, EvalOptionSelectedEvent}

import quanto.util.json._

import scala.swing._
import scala.concurrent._
import scala.collection.mutable.ArrayBuffer
import scala.util.{Success, Failure}
import java.net._
import java.io._
import ExecutionContext.Implicits.global

/** Object listing the potential evaluation statuses.*/
object CommunicationState extends Enumeration {
	val WaitingForPsgraph, NotConnected, WaitingForEvalOptions, WaitingForUserChoice, WaitingForPsgraphUpdate = Value
}

/** Service establishing and managing the connection with the core.*/
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
	//reInitConnection

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
			publish(ConnectedToCoreEvent(connected))
		}
	}

	/** Method opening a connection.
		*
		* It will launch a socket and wait for a connection on it.
		* A successful connection will launch the 'listen' method.
		*/
	def openConnection() {
		if(!connecting){
			connecting = true
			gui = new ServerSocket(1790)
			val init: Future[Socket] = future {
				println("GUI speaking : connecting ...")
				gui.accept
			}
			init onComplete {
				case Success(c) =>
					connecting = false
					prover = c
					println("GUI speaking : connected !")
					connected = true
					publish(ConnectedToCoreEvent(connected))
					state = CommunicationState.WaitingForPsgraph
					listen()
				case Failure(t) =>
					connecting = false
					println("GUI speaking : Not connected, an error has occured: " + t.getMessage)
			}
		}

	}

	/** Method listening for incoming messages.
		*
		* As soon as a message arrives in the buffered reader, the 'getMessage' method is launched.
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

	var i = 0

	/** Method getting a complete message from a buffered reader.
		*
		* The message is fetched while there are strings in the buffered reader.
		* When it is finish the 'parseAndExecute' method is launched, and the 'listen' method after that.
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
					sendErrorResponse("RSP_MESSAGE_ERROR", "bad json")
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
				case "CMD_SHOW_GUI" =>
					Service.showTinkerGUI(true)
				case "CMD_HIDE_GUI" =>
					Service.showTinkerGUI(false)
				case "CMD_INIT_PSGRAPH" =>
					println("init psgraph")
					Service.evalCtrl.setInEval(true)
					println("eval psgraph")
					getEvalPSGraph(j ? "eval_psgraph")
					println("eval options")
					getEvalOptions(j ? "eval_options")
					println("log info")
					getEvalLog(j ? "log_info")
				case "CMD_UPDATE_PSGRAPH" =>
					println("update psgraph")
					Service.evalCtrl.setInEval(true)
					println("eval psgraph")
					getEvalPSGraph(j ? "eval_psgraph")
					println("eval options")
					getEvalOptions(j ? "eval_options")
					println("log info")
					getEvalLog(j ? "log_info")
				case "RSP_ERROR_CHANGE_PSGRAPH" =>
					if (state == CommunicationState.WaitingForPsgraph) {
						j ? "eval_psgraph" match {
							case eval: Json if eval == JsonNull => // send back error
							case eval: JsonObject =>
								Service.evalCtrl.tmpEvalPSGraph = eval
								Service.evalCtrl.enableEvalOptions(ArrayBuffer())
								state = CommunicationState.WaitingForUserChoice
						}
					}
				// close connection command
				case "CMD_CLOSE_CONNECT" =>
					Service.evalCtrl.setInEval(false)
					sendErrorResponse("RSP_CLOSE_CONNECT", "closing connection")
					/*prover.close
					gui.close
					connected = false*/
					closeConnection()
				// end of the eval session, but keep the current socket connection
				case "CMD_END_EVAL_SESSION" =>
					println("receive cmd CMD_END_EVAL_SESSION: reset state")
					Service.evalCtrl.setInEval(false)
					state = CommunicationState.WaitingForPsgraph
				// unsupported command
				case _ =>
					sendErrorResponse("RSP_ERROR_BAD_CMD", "")
					// reset status
					state = CommunicationState.WaitingForPsgraph

			}
		}
	}

	def getEvalPSGraph(j:Json) {
		if(state == CommunicationState.WaitingForPsgraph){
			j match {
				// if eval field not found
				case eval: Json if eval == JsonNull => sendErrorResponse("RSP_ERROR_UPDATE_PSGRAPH", "no eval psgraph")
				// if eval field found
				case eval: JsonObject =>
					// loading eval model in gui
					Service.evalCtrl.loadJson(eval)
					Service.evalCtrl.tmpEvalPSGraph = JsonObject()
					// changing state
					state = CommunicationState.WaitingForEvalOptions
				case _ => sendErrorResponse("RSP_ERROR_UPDATE_PSGRAPH", "bad eval psgraph format")
			}
		}
	}

	def getEvalOptions(j:Json) {
		if (state == CommunicationState.WaitingForEvalOptions) {
			j match {
				// if options not found
				case options: Json if options == JsonNull => sendErrorResponse("RSP_ERROR_UPDATE_PSGRAPH", "no eval options")
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
								send(JsonObject("cmd" -> "RSP_UPDATE_PSGRAPH", "option" -> JsonString(opt), "node" -> JsonString(node)))
								// change state
								state = CommunicationState.WaitingForPsgraph
							}
					}
				case _ => sendErrorResponse("RSP_ERROR_UPDATE_PSGRAPH", "bad eval options format")
			}
		}
	}

	def getEvalLog(j:Json) {
		j match {
			case logs: Json if logs == JsonNull => sendErrorResponse("RSP_ERROR_UPDATE_PSGRAPH", "no log info")
			case logs: JsonObject =>
				Service.evalCtrl.logStack.addToLog(logs.mapValue.map{
					case (k,v) =>
						k -> v.asArray.map {
							case (s: JsonString) => s.stringValue
							case _ => "<< Message parse error, wrong type >>"
						}
				})
			case _ => sendErrorResponse("RSP_ERROR_UPDATE_PSGRAPH", "bad log info format")
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
			state = CommunicationState.WaitingForPsgraph
		}
	}
	
}