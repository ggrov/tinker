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

	def lookForTactic(name: String): Option[JsonObject] = {
		graphTactics.foreach{ g =>
			if(g.mapValue.get("name").get.stringValue == name) return Some(g)
		}
		return None
	}

	def newSubGraph(str: String){
		if(str == currentGraph){
			currentIndex += 1
		}
		else{
			currentGraph = str
			lookForTactic(str) match {
				case Some(t:JsonObject) =>
					currentArray = Array()
					t.mapValue.get("graphs").get.vectorValue.foreach { v =>
						v match {
							case g:JsonObject => currentArray = currentArray :+ g
							case _ => 
						}
					}
					currentIndex = currentArray.size
				case None =>
					currentIndex = 0
					currentArray = Array()
			}
		}
	}

	def changeCurrent(str: String): Boolean = {
		if(str == "main"){
			currentGraph = str
			currentIndex = 0
			currentArray = Array()
			return true
		}
		else {
			lookForTactic(str) match {
				case Some(t: JsonObject) =>
					currentGraph = str
					currentIndex = 0
					currentArray = Array()
					t.mapValue.get("graphs").get.vectorValue.foreach { v =>
						v match {
							case g:JsonObject => currentArray = currentArray :+ g
							case _ => 
						}
					}
					return true
				case None => return false
			}
		}
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

	def getCurrentJson(): JsonObject = {
		if(currentGraph == "main"){
			return mainGraph
		}
		else {
			return currentArray(currentIndex)
		}
	}

	def getSizeOfTactic(name: String): Int = {
		if(name == "main") 1
		else {
			lookForTactic(name) match {
				case Some(t: JsonObject) =>  t.mapValue.get("graphs").get.vectorValue.size
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
				case Some(t: JsonObject) =>
					t.mapValue.get("graphs").get.vectorValue(index) match {
						case g:JsonObject => return Some(g)
						case _ => return None // in case it is JsonArray, JsonBool, JsonDouble, JsonInt, JsonNull, JsonString
					}
				case None => return None
			}
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