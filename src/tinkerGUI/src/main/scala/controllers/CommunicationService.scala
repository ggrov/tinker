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
			// in = new BufferedReader(new InputStreamReader(client.getInputStream)).readLine
			// // out = new PrintStream(client.getOutputStream)
			// println("Server received : "+in)
		}
	}

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
			//try {
				println("message : "+b.toString)
				val j = Json.parse(b.toString())
				parseAndExecute(j)
		//	}
			//catch {
			//	case e: Exception => println(b.toString+" -> diz iz no Json : "+e.getMessage)
			//}
			listen()
		}
	}

	/** Method parsing a json message and executing the command it contains.
		*
		* @param j Json message.
		*/
	def parseAndExecute(j: Json){
		j ? "cmd" match {
			// if no command found
			case cmd: Json if cmd == JsonNull => sendSimpleResponse("RSP_ERROR_NO_CMD", "")
			// if command found
			case cmd: Json =>
				cmd ? "name" match {
				// if no name found
				case name: Json if name == JsonNull => sendSimpleResponse("RSP_ERROR_NO_CMD_NAME", "")
				// if no name found
				case name: Json => name.stringValue match{
					//show and hide tinker gui from the tinker core
					case "CMD_SHOW_GUI" =>
						Service.showTinkerGUI(true)
					case "CMD_HIDE_GUI" =>
						Service.showTinkerGUI(false)
					// initialisation command
					case "CMD_INIT_PSGRAPH" =>
						Service.evalCtrl.setInEval(true)
						// if correct state
						if(state == CommunicationState.WaitingForPsgraph){
							// get psgraph
							/*j ? "psgraph" match {
								// if psgraph not found
								case psgraph: Json if psgraph == JsonNull => sendSimpleResponse("RSP_ERROR_INIT_PSGRAPH", "no psgraph field")
								// if psgraph found
								case psgraph:Json =>
									// loading in model
									// Service.evalCtrl.loadJson(psgraph)
									// preparing current eval graph variables
									var tactic:String = ""
									var i:Int = 0
									var parents:Array[String] = Array()
									var graph:JsonObject = JsonObject()
                  println ("end of loading psgraph")*/
									// get eval field
									j ? "eval_psgraph" match {
										// if eval field not found
										case eval: Json if eval == JsonNull => sendSimpleResponse("RSP_ERROR_INIT_PSGRAPH", "no eval field")
										// if eval field found
										case eval: Json =>
											// loading in model
											//println(eval)
											Service.evalCtrl.loadJson(eval)
											/*// get current name
											eval ? "current" match {
												// error send if name not found
												case currentTacticName: Json if currentTacticName == JsonNull => sendSimpleResponse("RSP_ERROR_INIT_PSGRAPH", "no current name field in eval")
												case currentTacticName: Json =>
													tactic = currentTacticName.asArray.head.stringValue
													parents = currentTacticName.asArray.tail.foldRight(Array[String]()){ case (p,a) => a :+ p.stringValue}
											}
											// get current index
											eval ? "current_index" match {
												// error send if index not found
												case currentTacticIndex: Json if currentTacticIndex == JsonNull => sendSimpleResponse("RSP_ERROR_INIT_PSGRAPH", "no current index field in eval")
												case currentTacticIndex: Json => i = currentTacticIndex.intValue
											}
											// get current graph (should be main[0] at first)

											eval ? "graphs" match {
												// error send if graphs array not found
												case graphs:Json if graphs == JsonNull => sendSimpleResponse("RSP_ERROR_INIT_PSGRAPH", "no graphs field in eval")
												case graphs:JsonArray =>
													//var graphList = graphs.vectorValue
													var gr:Option[Json] = None
													graphs.vectorValue.foreach{g =>
														if((g ? "name").stringValue == tactic){
															gr = (g ? "graphs").get(i)
														}
													}
													gr match {
														case Some(g:Json) => graph = g.asObject
														// error send if not found
														case _ => sendSimpleResponse("RSP_ERROR_INIT_PSGRAPH", "could not find graph to display in eval")
													}
											}*/

									}

									// display current graph on view
									// Service.evalCtrl.displayEvalGraph(tactic, i, parents)

									// change state
									state = CommunicationState.WaitingForEvalOptions
									// send respond command
									sendSimpleResponse("RSP_INIT_PSGRAPH", "WaitingForEvalOptionFromUser")
							//}
						}
						// check if correct state
						if(state == CommunicationState.WaitingForEvalOptions){
							// get options
							cmd ? "args" match {
								// if arguments not found
								case args: Json if args == JsonNull => sendSimpleResponse("RSP_ERROR_ARGS", "arguments not found")
								// arguments found
								case args: JsonArray =>
									// getting first argument, should be list of eval options
									args.vectorValue.head match {
										// if nothing found
										case options: Json if options == JsonNull => sendSimpleResponse("RSP_ERROR_ARGS", "expected arguments but list is empty")
										// if array found, good format
										case options: JsonArray =>
											// get options as vector
											var opts = ArrayBuffer[String]()
											options.vectorValue.foreach {
												case option: JsonString =>
													opts = opts :+ option.stringValue
												// if not string
												case _ =>
													sendSimpleResponse("RSP_ERROR_EVAL_PSGRAPH", "expected list of string as first argument")
											}
											// enable in view
											Service.evalCtrl.enableEvalOptions(opts)
											// change state
											state = CommunicationState.WaitingForUserChoice
											// future for user interaction
											listenTo(Service.evalCtrl)
											reactions+={
												case EvalOptionSelectedEvent(opt, node) =>
													// check if correct state
													if(state == CommunicationState.WaitingForUserChoice){
														// send option chosen
														send(JsonObject("cmd" -> JsonObject("name" -> "RSP_EVAL_PSGRAPH", "args" -> JsonArray(Vector(JsonString(opt), JsonString(node))))))
														// change state
														state = CommunicationState.WaitingForPsgraphUpdate
													}
											}

									}
							}
						}
					// update command
					case "CMD_UPDATE_PSGRAPH" =>
						// check if correct state
						if(state == CommunicationState.WaitingForPsgraphUpdate){
							// preparing current eval graph variables
							/*var tactic:String = ""
							var i:Int = 0
							var parents:Array[String] = Array()
							var graph:JsonObject = JsonObject()*/
							// get eval field
							j ? "eval_psgraph" match {
								// if eval field not found
								case eval: Json if eval == JsonNull => sendSimpleResponse("RSP_ERROR_UPDATE_PSGRAPH", "no eval field")
								// if eval field found
								case eval: Json =>
									Service.evalCtrl.loadJson(eval)
									// get current name
									/*eval ? "current" match {
										// error send if name not found
										case currentTacticName: Json if currentTacticName == JsonNull => sendSimpleResponse("RSP_ERROR_UPDATE_PSGRAPH", "no current name field in eval")
										case currentTacticName: Json =>
											tactic = currentTacticName.asArray.head.stringValue
											parents = currentTacticName.asArray.tail.foldRight(Array[String]()){ case (p,a) => a :+ p.stringValue}
									}
									// get current index
									eval ? "current_index" match {
										// error send if index not found
										case currentTacticIndex: Json if currentTacticIndex == JsonNull => sendSimpleResponse("RSP_ERROR_UPDATE_PSGRAPH", "no current index field in eval")
										case currentTacticIndex: Json => i = currentTacticIndex.intValue
									}
									// get current graph (should be main[0] at first)
									eval ? "graphs" match {
										// error send if graphs array not found
										case graphs:Json if graphs == JsonNull => sendSimpleResponse("RSP_ERROR_UPDATE_PSGRAPH", "no graphs field in eval")
										case graphs:JsonArray =>
											//var graphList = graphs.vectorValue
											var gr:Option[Json] = None
											graphs.vectorValue.foreach{g =>
												if((g ? "name").stringValue == tactic){
													gr = (g ? "graphs").get(i)
												}
											}
											gr match {
												case Some(g:Json) => graph = g.asObject
												// error send if not found
												case _ => sendSimpleResponse("RSP_ERROR_UPDATE_PSGRAPH", "could not find graph to display in eval")
											}
									}*/

							}

							// display current graph on view
							//Service.evalCtrl.displayEvalGraph(tactic, i, graph, parents)

							// change state
							state = CommunicationState.WaitingForEvalOptions
							// send respond command
							sendSimpleResponse("RSP_UPDATE_PSGRAPH", "WaitingForEvalOptionFromUser")
						}
						// check if correct state
						if(state == CommunicationState.WaitingForEvalOptions){
							// get options
							cmd ? "args" match {
								// if arguments not found
								case args: Json if args == JsonNull => sendSimpleResponse("RSP_ERROR_ARGS", "arguments not found")
								// arguments found
								case args: JsonArray =>
									// getting first argument, should be list of eval options
									args.vectorValue.head match {
										// if nothing found
										case options: Json if options == JsonNull => sendSimpleResponse("RSP_ERROR_ARGS", "expected arguments but list is empty")
										// if array found, good format
										case options: JsonArray =>
											// get options as vector
											//var optsTmp = options.vectorValue
											var opts = ArrayBuffer[String]()
											options.vectorValue.foreach {
												case option: JsonString =>
													opts = opts :+ option.stringValue
												// if not string
												case _ =>
													sendSimpleResponse("RSP_ERROR_EVAL_PSGRAPH", "expected list of string as first argument")
											}
											// enable in view
											Service.evalCtrl.enableEvalOptions(opts)
											// change state
											state = CommunicationState.WaitingForUserChoice
											// future for user interaction
											listenTo(Service.evalCtrl)
											reactions+={
												case EvalOptionSelectedEvent(opt, node) =>
													// check if correct state
													if(state == CommunicationState.WaitingForUserChoice){
														// send option chosen
														send(JsonObject("cmd" -> JsonObject("name" -> "RSP_EVAL_PSGRAPH", "args" -> JsonArray(Vector(JsonString(opt), JsonString(node))))))
														// change state
														state = CommunicationState.WaitingForPsgraphUpdate
													}
											}

									}
							}
						}
					// close connection command
					case "CMD_CLOSE_CONNECT" =>
						Service.evalCtrl.setInEval(false)
						sendSimpleResponse("RSP_CLOSE_CONNECT", "closing connection")
						/*prover.close
						gui.close
						connected = false*/
						closeConnection()
          // end of the eval session, but keep the current socket connection
          case "CMD_END_EVAL_SESSION" =>
            println ("receive cmd CMD_END_EVAL_SESSION: reset state")
						Service.evalCtrl.setInEval(false)
            state = CommunicationState.WaitingForPsgraph
          // unsupported command
          case _ =>
						sendSimpleResponse("RSP_ERROR_BAD_CMD", "")
            // reset status
            state = CommunicationState.WaitingForPsgraph
				}
			}
			case _ =>
          sendSimpleResponse("RSP_ERROR_NO_CMD", "")
          state = CommunicationState.WaitingForPsgraph
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

	/** Shortcut method to send a Json message with standard format :
		*
		* {"cmd":{"name":"commandName","args":["commandMessage"]}}
		*
		* @param c Command name.
		* @param m Command argument/message.
		*/
	def sendSimpleResponse(c:String, m:String){
		send(JsonObject("cmd" -> JsonObject("name" -> c, "args" -> JsonArray(Vector(JsonString(m))))))
	}
	
}