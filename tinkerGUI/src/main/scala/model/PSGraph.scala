package tinkerGUI.model

import quanto.util.json._
import java.io.{FileNotFoundException, IOException, File}

class PSGraph() {
	var currentGraph = "main"
	var currentIndex = 0
	var currentArray: Array[JsonObject] = Array()
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
		graph match {
			case g: JsonObject =>
				if(currentGraph == "main"){
					mainGraph = g
				}
				else {
					val tacticIndex = graphTactics.indexOf(JsonObject("name" -> currentGraph, "graphs" -> JsonArray(currentArray)))
					if(currentArray.isDefinedAt(currentIndex)){
						currentArray(currentIndex) = g
					}
					else{
						currentArray = currentArray :+ g
					}
					if(tacticIndex == -1){
						graphTactics = graphTactics :+ JsonObject("name" -> currentGraph, "graphs"-> JsonArray(currentArray))
					}
					else {
						graphTactics(tacticIndex) = JsonObject("name" -> currentGraph, "graphs"-> JsonArray(currentArray))
					}
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