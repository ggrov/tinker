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
		// println(jsonPSGraph)
	}

	def lookForGraphTactic(tactic: String): Option[GraphTactic] = {
		graphTactics.foreach{ t =>
			if(t.name == tactic) return Some(t)
		}
		return None
	}

	def lookForAtomicTactic(tactic: String): Option[AtomicTactic] = {
		atomicTactics.foreach{ t =>
			if(t.name == tactic) return Some(t)
		}
		return None
	}

	def lookForTactic(tactic: String): Option[HasArguments] = {
		lookForAtomicTactic(tactic) match {
			case Some(t:AtomicTactic) => return Some(t)
			case None =>
		}
		lookForGraphTactic(tactic) match {
			case Some(t:GraphTactic) => return Some(t)
			case None =>
		}
		return None
	}

	def newSubGraph(tactic: String, isOr: Boolean){
		isMain = false
		if(tactic == currentTactic.name){
			currentIndex = currentTactic.getSize
		}
		else{
			lookForGraphTactic(tactic) match {
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
		lookForGraphTactic(tactic) match {
			case Some(t:GraphTactic) =>
				t.delGraph(index)
			case None => tinkerGUI.controllers.TinkerDialog.openErrorDialog("<html>The program tried to delete a subgraph of tactic : "+tactic+", at index : "+(index+1)+".<br>But no such tactic could be found.</html>")
		}
	}

	def deleteTactic(tactic: String) {
		lookForGraphTactic(tactic) match {
			case Some(t:GraphTactic) =>
				graphTactics = graphTactics - t
			case None => tinkerGUI.controllers.TinkerDialog.openErrorDialog("<html>The program tried to delete the tactic : "+tactic+".<br>But no such tactic could be found.</html>")
		}
	}

	def changeCurrent(tactic: String, index: Int): Boolean = {
		if(tactic == "main"){
			isMain = true
			currentIndex = 0
			return true
		}
		else {
			lookForGraphTactic(tactic) match {
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
			lookForGraphTactic(tactic) match {
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
			lookForGraphTactic(tactic) match {
				case Some(t: GraphTactic) => t.getGraphJson(index)
				case None => return None
			}
		}
	}

	def graphTacticSetIsOr(tactic: String, isOr: Boolean){
		lookForGraphTactic(tactic) match {
			case Some(t: GraphTactic) => t.isOr = isOr
			case None =>
		}
	}

	def isGraphTacticOr(tactic: String): Boolean = {
		lookForGraphTactic(tactic) match {
			case Some(t:GraphTactic) => t.isOr
			case None => true
		}
	}

	def updateTacticName(oldVal: String, newVal: String) {
		lookForTactic(oldVal) match {
			case Some(t: GraphTactic) => t.name = newVal
			case Some(t: AtomicTactic) => t.name = newVal
			case Some(t: HasArguments) => 
			case None =>
		}
	}

	def createGraphTactic(tactic: String, isOr: Boolean){
		graphTactics = graphTactics :+ new GraphTactic(tactic, isOr)
	}

	def updateTacticArguments(tactic: String, args: Array[Array[String]]){
		lookForTactic(tactic) match {
			case Some(t: HasArguments) =>
				t.eraseArguments()
				args.foreach{ a =>
					t.addArgument(a)
				}
			case None => //needs to do the same for atomic
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