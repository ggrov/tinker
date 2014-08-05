package tinkerGUI.controllers

import java.net._
import java.io._
import scala.io._
import scala.concurrent._
import ExecutionContext.Implicits.global
import scala.util.{Success, Failure}

object CommunicationService {
	var connected = false
	val server = new ServerSocket(1790)
	var client: Socket = null

	val init: Future[Socket] = future {
		println("Server speaking : connecting ...")
		server.accept
	}

	init onComplete {
		case Success(c) =>
			client = c
			println("Server speaking : connected !")
			connected = true
			val in = new BufferedReader(new InputStreamReader(client.getInputStream)).readLine
			val out = new PrintStream(client.getOutputStream)
			println("Server received : "+in)
			out.println("Hello to client from server")
			out.flush
		case Failure(t) =>
			println("Server speaking : Not connected, an error has occured: " + t.getMessage)
	}


	// def init = Future {
	// 	try{
	// 		println("Server initialized")

	// 		// server.setSoTimeout(5000)
	// 		client = server.accept
	// 		connected = true
	// 		val in = new BufferedReader(new InputStreamReader(client.getInputStream)).readLine
	// 		val out = new PrintStream(client.getOutputStream)

	// 		println("Server received:" + in)
	// 		out.println("Server: Message received - " + in)
	// 		out.flush

	// 		if (in.equals("CMD_CLOSE")) client.close; server.close; println("Server closing:")
	// 	}
	// 	catch {
	// 		// case e: SocketTimeoutException => TinkerDialog.openErrorDialog("Timeout exception when launching communication with core."); connected = false
	// 		case e: Exception => TinkerDialog.openErrorDialog("Unexpected error when launching communication with core."); println(e.getStackTrace); System.exit(1)
	// 	}
	// }

	// init onSuccess {
	// 	// actions to run when connection made
	// }


	
}