package tinkerGUI.model

import quanto.util.json._
import java.io.{FileNotFoundException, IOException, File}

class PSGraph() {
	var currentGraph = "main"
	var currentIndex = 0
	var atomicTactics: Array[JsonObject] = Array((JsonObject("name" -> "simp", "tactic" -> "simplify")),(JsonObject("name" -> "imp", "tactic" -> "imply")))
	var graphTactics: Array[JsonObject] = Array()
	var mainGraph: JsonObject = JsonObject()

	var jsonPSGraph: JsonObject = JsonObject()
	var file: Option[File] = None

	def updateJsonPSGraph {
		jsonPSGraph = JsonObject("current" -> currentGraph, "current_index" -> currentIndex, "graph" -> mainGraph, "graph_tactics" -> JsonArray(graphTactics), "atomic_tactics" -> JsonArray(atomicTactics))
		println(jsonPSGraph)
	}		

	def saveSomeGraph(graph: Json) {
		// save a graph into our json object according to the currentGraph String
		// we get the graph object from the API file
		// if current graph is "main" we save it in the main graph field
		// else we save it in the p_tactics field
		graph match {
			case g: JsonObject =>
				if(currentGraph == "main"){
					mainGraph = g
				}
			case _ =>
		}
		updateJsonPSGraph
	}

	def loadJsonGraph(f: File) {
		// load a saved file in our json object
	}

	def saveFile(fopt: Option[File] = None) {
		// write our json object in a file
		// if no file is specified, we take the file variable
		// fopt.orElse(file).map { f =>
		// 	try {

		// 	}
		// 	catch {

		// 	}
		// }
	}
}