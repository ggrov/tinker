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
				listen
			case Failure(t) =>
				println("Server speaking : Not connected, an error has occured: " + t.getMessage)
		}
	}

	def listen {
		var in: String = null
		send("SRV_LISTENING")
		while(connected){
			in = new BufferedReader(new InputStreamReader(client.getInputStream)).readLine
			// out = new PrintStream(client.getOutputStream)
			println("Server received : "+in)
			try { val j = Json.parse(in) ; parseAndExecute(j) }
			catch { case e: Exception => println("diz iz no Json : "+e.getMessage)}
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