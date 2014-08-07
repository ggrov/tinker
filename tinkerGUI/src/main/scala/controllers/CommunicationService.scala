package tinkerGUI.controllers

import java.net._
import java.io._
import scala.io._
import scala.concurrent._
import ExecutionContext.Implicits.global
import scala.util.{Success, Failure}
import quanto.util.json._

object CommunicationService {
	var connected = false
	var server: ServerSocket = null
	var client: Socket = null
	reInitConnection

	def reInitConnection {
		server = new ServerSocket(1790)
		val init: Future[Socket] = future {
			println("Server speaking : connecting ...")
			server.accept
		}

		init onComplete {
			case Success(c) =>
				client = c
				println("Server speaking : connected !")
				connected = true
				send("SRV_LISTENING")
				listen
			case Failure(t) =>
				println("Server speaking : Not connected, an error has occured: " + t.getMessage)
		}
	}

	def listen {
		if(connected){
			var in = new BufferedReader(new InputStreamReader(client.getInputStream))
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
			try { val j = Json.parse(b.toString) ; parseAndExecute(j) }
			catch { case e: Exception => println("diz iz no Json : "+e.getMessage)}
			listen
		}
	}

	def parseAndExecute(j: Json){
		(j ? "cmd") match {
			case cmd: Json if(cmd == JsonNull) => send("no command")
			case cmd: Json => cmd.stringValue match {
				case "GET_PSGRAPH" =>
					(j ? "param") match {
						case param: JsonString =>
							param.stringValue match {
								case "goal_types" => send(Service.getGoalTypes)
								case _ => println(param.stringValue)
							}
						case param: Json if(param == JsonNull) => send(Service.getJsonPSGraph.toString)
					}
				case "CLOSE_CONNECT" =>
					client.close
					server.close
					connected = false
					reInitConnection
				case _ => send("bad command")
			}
			case _ =>
		}
	}

	def send(msg: String){
		if(connected){
			var out = new PrintStream(client.getOutputStream)
			out.println(msg)
			out.flush
		}
	}
	
}