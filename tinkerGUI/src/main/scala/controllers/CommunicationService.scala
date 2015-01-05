package tinkerGUI.controllers

import java.net._
import java.io._
import scala.io._
import scala.concurrent._
import scala.swing._
import ExecutionContext.Implicits.global
import scala.util.{Success, Failure}
import quanto.util.json._
import scala.collection.mutable.ArrayBuffer

object CommunicationState extends Enumeration {
	val WaitingForPsgraph, NotConnected, WaitingForEvalOptions, WaitingForUserChoice, WaitingForPsgraphUpdate = Value
}

object CommunicationService extends Publisher {
	var connected = false
	var gui: ServerSocket = null
	var prover: Socket = null
	var state:CommunicationState.Value = CommunicationState.NotConnected
	reInitConnection

	def reInitConnection {
		connected = false
		gui = new ServerSocket(1790)
		val init: Future[Socket] = future {
			println("GUI speaking : connecting ...")
			gui.accept
		}

		init onComplete {
			case Success(c) =>
				prover = c
				println("GUI speaking : connected !")
				connected = true
				state = CommunicationState.WaitingForPsgraph
				listen
			case Failure(t) =>
				println("GUI speaking : Not connected, an error has occured: " + t.getMessage)
		}
	}

	def listen {
		if(connected){
			println("listening ...")
			var in = new BufferedReader(new InputStreamReader(prover.getInputStream))
			var input : Future[String] = future {
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

	def getMessage(in: BufferedReader, firstLine: String){
		if(connected){
			val b = new StringBuilder()
			b.append(firstLine)
			while(in.ready){
				b.append("\n")
				b.append(in.readLine)
			}
			try { 
				println(b.toString); 
				val j = Json.parse(b.toString); 
				parseAndExecute(j)
			}
			catch {
				case e: Exception => println(b.toString+" -> diz iz no Json : "+e.getMessage)
			}
			listen
		}
	}

	def parseAndExecute(j: Json){
		(j ? "cmd") match {
			// if no command found
			case cmd: Json if(cmd == JsonNull) => send(JsonObject("cmd" -> "RSP_ERROR_NO_CMD"))
			// if command found
			case cmd: Json => cmd.stringValue match {
				// initialisation command
				case "CMD_INIT_PSGRAPH" =>
					// if correct state
					if(state == CommunicationState.WaitingForPsgraph){
						// get psgraph
						(j ? "psgraph") match {
							// if psgraph not found
							case psgraph: Json if(psgraph == JsonNull) => 
								send(JsonObject("cmd" -> "RSP_ERROR_INIT_PSGRAPH", "msg" -> "no psgraph field"))
							// if psgraph found
							case psgraph:Json =>
								// loading in model
								Service.loadJson(psgraph)
								// preparing current eval graph variables
								var tactic:String = ""
								var i:Int = 0
								var graph:JsonObject = JsonObject()
								// get eval field
								(j ? "eval_psgraph") match {
									// if eval field not found
									case eval: Json if(eval == JsonNull) => 
										send(JsonObject("cmd" -> "RSP_ERROR_INIT_PSGRAPH", "msg" -> "no eval field"))
									// if eval field found
									case eval: Json =>
										// get current name
										(eval ? "name_current") match {
											// error send if name not found
											case name: Json if(name == JsonNull) => send(JsonObject("cmd" -> "RSP_ERROR_INIT_PSGRAPH", "msg" -> "no current name field in eval"))
											case name: Json => tactic = name.stringValue
										}
										// get current index
										(eval ? "index_current") match {
											// error send if index not found
											case index: Json if(index == JsonNull) => send(JsonObject("cmd" -> "RSP_ERROR_INIT_PSGRAPH", "msg" -> "no current index field in eval"))
											case index: Json => i = index.intValue
										}
										// get current graph (should be main[0] at first)
										(eval ? "graphs") match {
											// error send if graphs array not found
											case graphs:Json if(graphs == JsonNull) => send(JsonObject("cmd" -> "RSP_ERROR_INIT_PSGRAPH", "msg" -> "no graphs field in eval"))
											case graphs:JsonArray =>
												var graphList = graphs.vectorValue
												var gr:Option[Json] = None;
												graphList.foreach{g =>
													if((g ? "name").stringValue == tactic){
														gr = (g ? "graphs").get(i)
													}
												}
												gr match {
													case Some(g:Json) => graph = g.asObject
													// error send if not found
													case _ => send(JsonObject("cmd" -> "RSP_ERROR_INIT_PSGRAPH", "msg" -> "could not find graph to display in eval"))
												}
										}
								}
								// display current graph on view
								Service.displayEvalGraph(tactic, i, graph)
								// change state
								state = CommunicationState.WaitingForEvalOptions
								// send respond command
								send(JsonObject("cmd" -> "RSP_INIT_PSGRAPH", "status" -> "WaitingForEvalOptions"))
						}
					}
				// evaluation command
				case "CMD_EVAL_PSGRAPH" =>
					// check if correct state
					if(state == CommunicationState.WaitingForEvalOptions){
						// get options
						(j ? "options") match {
							// if options not found
							case options: Json if(options == JsonNull) =>
								send(JsonObject("cmd" -> "RSP_ERROR_EVAL_PSGRAPH", "msg" -> "no options field"))
							// if options found
							case options: JsonArray =>
								// get optios as vector
								var optsTmp = options.vectorValue
								var opts = ArrayBuffer[String]()
								optsTmp.foreach{ o =>
									opts = opts :+ o.stringValue
								}
								// enable in view
								Service.enableEvalOptions(opts)
								// change state
								state = CommunicationState.WaitingForUserChoice
								// future for user interaction
								listenTo(Service)
								reactions+={
									case UserSelectedEvalOptionEvent(opt) =>
										// check if correct state
										if(state == CommunicationState.WaitingForUserChoice){
											// send option chosen
											send(JsonObject("cmd" -> "RSP_EVAL_PSGRAPH", "opt" -> opt))
											// change state
											state = CommunicationState.WaitingForPsgraphUpdate
										}
								}
								// var choice : Future[String] = future {
								// 	Service.userEvalChoice
								// }
								// choice onComplete {
								// 	case Success(opt) => 
								// 		// check if correct state
								// 		if(state == CommunicationState.WaitingForUserChoice){
								// 			// send option chosen
								// 			send(JsonObject("cmd" -> "RSP_EVAL_PSGRAPH", "opt" -> opt))
								// 			// change state
								// 			state = CommunicationState.WaitingForPsgraphUpdate
								// 		}
								// 	case Failure(t) => println("An error occured : "+t.getMessage)
								// }
						}
					}
				// update command
				case "CMD_UPDATE_PSGRAPH" =>
					// check if correct state
					if(state == CommunicationState.WaitingForPsgraphUpdate){
						// same protocol used in initialisation
						var tactic:String = ""
						var i:Int = 0
						var graph:JsonObject = JsonObject()
						(j ? "eval") match {
							case eval: Json if(eval == JsonNull) => 
								send(JsonObject("cmd" -> "RSP_ERROR_DISPLAY_PSGRAPH", "msg" -> "no eval field"))
							case eval: Json =>
								(eval ? "name_current") match {
									case name: Json if(name == JsonNull) => send(JsonObject("cmd" -> "RSP_ERROR_DISPLAY_PSGRAPH", "msg" -> "no current name field in eval"))
									case name: Json => tactic = name.stringValue
								}
								(eval ? "index_current") match {
									case index: Json if(index == JsonNull) => send(JsonObject("cmd" -> "RSP_ERROR_DISPLAY_PSGRAPH", "msg" -> "no current index field in eval"))
									case index: Json => i = index.intValue
								}
								(eval ? "graphs") match {
									case graphs:Json if(graphs == JsonNull) => send(JsonObject("cmd" -> "RSP_ERROR_DISPLAY_PSGRAPH", "msg" -> "no graphs field in eval"))
									case graphs:JsonArray =>
										var graphList = graphs.vectorValue
										var gr:Option[Json] = None;
										graphList.foreach{g =>
											if((g ? "name").stringValue == tactic){
												gr = (g ? "graphs").get(i)
											}
										}
										gr match {
											case Some(g:Json) => graph = g.asObject
											case _ => send(JsonObject("cmd" -> "RSP_ERROR_DISPLAY_PSGRAPH", "msg" -> "could not find graph to display in eval"))
										}
								}
						}
						Service.displayEvalGraph(tactic, i, graph)
						state = CommunicationState.WaitingForEvalOptions
						send(JsonObject("cmd" -> "RSP_DISPLAY_PSGRAPH", "status" -> "WaitingForEvalOptions"))
					}
				// close connection command
				case "CMD_CLOSE_CONNECT" =>
					send(JsonObject("cmd" -> "RSP_CLOSE_CONNECT", "status" -> "closing connection"))
					prover.close
					gui.close
					connected = false
					reInitConnection
				// unsupported command
				case _ => 
					send(JsonObject("cmd" -> "RSP_ERROR_BAD_CMD"))
			}
			case _ =>
		}
	}

	def send(msg: String){
		if(connected){
			var out = new PrintStream(prover.getOutputStream)
			out.println(msg)
			out.flush
		}
	}

	def send(j:Json){
		if(connected){
			var out = new PrintStream(prover.getOutputStream)
			j.writeTo(out)
			out.flush
		}
	}
	
}