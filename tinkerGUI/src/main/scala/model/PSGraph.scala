package tinkerGUI.model

import quanto.util.json._
import java.io.{FileNotFoundException, IOException, File}

class PSGraph() {
	var isMain = true
	var currentGraph: GraphTactic = new GraphTactic("", true)
	var currentIndex = 0
	var atomicTactics: Array[AtomicTactic] = Array(new AtomicTactic("simp", "simplify"))
	var graphTactics: Array[GraphTactic] = Array()
	var mainGraph: JsonObject = JsonObject()

	var jsonPSGraph: JsonObject = JsonObject()
	var file: Option[File] = None

	def updateJsonPSGraph {
		var current = ""
		var graphTacticsJson: Array[JsonObject] = Array()
		var atomicTacticsJson: Array[JsonObject] = Array()
		if(isMain) {current = "main"}
		else {current = currentGraph.name}
		graphTactics.foreach{ t =>
			graphTacticsJson = graphTacticsJson :+ t.toJson
		}
		atomicTactics.foreach{ t =>
			atomicTacticsJson = atomicTacticsJson :+ t.toJson
		}
		jsonPSGraph = JsonObject("current" -> current, "current_index" -> currentIndex, "graph" -> mainGraph, "graph_tactics" -> JsonArray(graphTacticsJson), "atomic_tactics" -> JsonArray(atomicTacticsJson))
		println(jsonPSGraph)
	}

	def lookForTactic(n: String): Option[GraphTactic] = {
		graphTactics.foreach{ t =>
			if(t.name == n) return Some(t)
		}
		return None
	}

	def newSubGraph(str: String, isOr: Boolean){
		isMain = false
		if(str == currentGraph.name){
			currentIndex += currentGraph.getSize
		}
		else{
			lookForTactic(str) match {
				case Some(t:GraphTactic) =>
					currentGraph = t
					currentIndex = t.getSize
				case None =>
					currentGraph = new GraphTactic(str, isOr)
					currentIndex = 0
					graphTactics = graphTactics :+ currentGraph
			}
		}
	}

	def changeCurrent(str: String, index: Int): Boolean = {
		if(str == "main"){
			isMain = true
			currentIndex = 0
			return true
		}
		else {
			lookForTactic(str) match {
				case Some(t: GraphTactic) =>
					isMain = false
					currentGraph = t
					currentIndex = index
					return true
				case None => return false
			}
		}
	}

	def saveSomeGraph(graph: Json) {
		graph match {
			case g: JsonObject =>
				if(isMain){
					mainGraph = g
				}
				else {
					currentGraph.addJsonToGraphs(g, currentIndex)
				}
			case _ =>
		}
		updateJsonPSGraph
	}

	def getCurrentJson(): JsonObject = {
		if(isMain){
			return mainGraph
		}
		else {
			return currentGraph.getGraphJson(currentIndex)
		}
	}

	def getSizeOfTactic(name: String): Int = {
		if(name == "main") 1
		else {
			lookForTactic(name) match {
				case Some(t: GraphTactic) => t.getSize
				case None => -1
			}
		}
	}

	def getSpecificJson(name: String, index: Int): Option[JsonObject] = {
		if(name == "main"){
			return Some(mainGraph)
		}
		else {
			lookForTactic(name) match {
				case Some(t: GraphTactic) => Some(t.getGraphJson(index))
				case None => return None
			}
		}
	}

	def graphTacticSetIsOr(name: String, isOr: Boolean){
		lookForTactic(name) match {
			case Some(t: GraphTactic) => t.isOr = isOr
			case None =>
		}
	}

	def isGraphTacticOr(name: String): Boolean = {
		lookForTactic(name) match {
			case Some(t:GraphTactic) => t.isOr
			case None => true
		}
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