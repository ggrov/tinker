package tinkerGUI.model

import quanto.util.json._
import java.io.{FileNotFoundException, IOException, File}
import scala.collection.mutable.ArrayBuffer

class PSGraph() {
	var isMain = true
	var currentTactic: GraphTactic = new GraphTactic("", true)
	var currentIndex = 0
	var atomicTactics: Array[AtomicTactic] = Array(new AtomicTactic("simp", "simplify"))
	var graphTactics: ArrayBuffer[GraphTactic] = ArrayBuffer()
	var mainGraph: JsonObject = JsonObject()

	var jsonPSGraph: JsonObject = JsonObject()
	var file: Option[File] = None

	def updateJsonPSGraph {
		var current = ""
		var graphTacticsJson: Array[JsonObject] = Array()
		var atomicTacticsJson: Array[JsonObject] = Array()
		if(isMain) {current = "main"}
		else {current = currentTactic.name}
		graphTactics.foreach{ t =>
			graphTacticsJson = graphTacticsJson :+ t.toJson
		}
		atomicTactics.foreach{ t =>
			atomicTacticsJson = atomicTacticsJson :+ t.toJson
		}
		jsonPSGraph = JsonObject("current" -> current, "current_index" -> currentIndex, "graph" -> mainGraph, "graph_tactics" -> JsonArray(graphTacticsJson), "atomic_tactics" -> JsonArray(atomicTacticsJson))
		println(jsonPSGraph)
	}

	def lookForTactic(tactic: String): Option[GraphTactic] = {
		graphTactics.foreach{ t =>
			if(t.name == tactic) return Some(t)
		}
		return None
	}

	def newSubGraph(tactic: String, isOr: Boolean){
		isMain = false
		if(tactic == currentTactic.name){
			currentIndex = currentTactic.getSize
		}
		else{
			lookForTactic(tactic) match {
				case Some(t:GraphTactic) =>
					currentTactic = t
					currentIndex = t.getSize
				case None =>
					currentTactic = new GraphTactic(tactic, isOr)
					currentIndex = 0
					graphTactics = graphTactics :+ currentTactic
			}
		}
	}

	def delSubGraph(tactic: String, index: Int) {
		lookForTactic(tactic) match {
			case Some(t:GraphTactic) =>
				t.delGraph(index)
			case None =>
		}
	}

	def deleteTactic(tactic: String) {
		lookForTactic(tactic) match {
			case Some(t:GraphTactic) =>
				graphTactics = graphTactics - t
			case None =>
		}
	}

	def changeCurrent(tactic: String, index: Int): Boolean = {
		if(tactic == "main"){
			isMain = true
			currentIndex = 0
			return true
		}
		else {
			lookForTactic(tactic) match {
				case Some(t: GraphTactic) =>
					isMain = false
					currentTactic = t
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
					currentTactic.addJsonToGraphs(g, currentIndex)
				}
			case _ =>
		}
		updateJsonPSGraph
	}

	def getCurrentJson(): Option[JsonObject] = {
		if(isMain) Some(mainGraph)
		else currentTactic.getGraphJson(currentIndex)
	}

	def getSizeOfTactic(tactic: String): Int = {
		if(tactic == "main") 1
		else {
			lookForTactic(tactic) match {
				case Some(t: GraphTactic) => t.getSize
				case None => -1
			}
		}
	}

	def getSpecificJson(tactic: String, index: Int): Option[JsonObject] = {
		if(tactic == "main"){
			return Some(mainGraph)
		}
		else {
			lookForTactic(tactic) match {
				case Some(t: GraphTactic) => t.getGraphJson(index)
				case None => return None
			}
		}
	}

	def graphTacticSetIsOr(tactic: String, isOr: Boolean){
		lookForTactic(tactic) match {
			case Some(t: GraphTactic) => t.isOr = isOr
			case None =>
		}
	}

	def isGraphTacticOr(tactic: String): Boolean = {
		lookForTactic(tactic) match {
			case Some(t:GraphTactic) => t.isOr
			case None => true
		}
	}

	def updateTacticName(oldVal: String, newVal: String) {
		lookForTactic(oldVal) match {
			case Some(t: GraphTactic) => t.name = newVal
			case None =>
		}
	}

	def createGraphTactic(tactic: String, isOr: Boolean){
		graphTactics = graphTactics :+ new GraphTactic(tactic, isOr)
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