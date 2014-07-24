package tinkerGUI.model

import scala.swing._
import quanto.util.json._
import java.io.{FileNotFoundException, IOException, File}
import scala.collection.mutable.ArrayBuffer
import tinkerGUI.controllers.TinkerDialog
import tinkerGUI.controllers.ArgumentParser
import tinkerGUI.controllers.Service

class PSGraph() {
	var isMain = true
	var currentTactic: GraphTactic = new GraphTactic("", true)
	var currentIndex = 0
	var atomicTactics: ArrayBuffer[AtomicTactic] = ArrayBuffer()
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
			case None => throwError("<html>The program tried to delete a subgraph of tactic : "+tactic+", at index : "+(index+1)+".<br>But no such tactic could be found.</html>")
		}
	}

	def deleteTactic(tactic: String) {
		lookForTactic(tactic) match {
			case Some(t:GraphTactic) =>
				graphTactics = graphTactics - t
			case Some(t:AtomicTactic) =>
				atomicTactics = atomicTactics - t
			case Some(t:HasArguments) =>
			case None => throwError("<html>The program tried to delete the tactic : "+tactic+".<br>But no such tactic could be found.</html>")
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

	def saveCurrentGraph(graph: Json) {
		graph match {
			case g: JsonObject =>
				if(isMain){
					mainGraph = g
				}
				else {
					currentTactic.addJsonToGraphs(g, currentIndex)
				}
			case _ => throwError("<html>The program tried to save a graph, </br>but the object received is not in JSON format.</html>")
		}
		updateJsonPSGraph
	}

	def saveGraphSpecificTactic(tactic: String, graph: Json){
		graph match {
			case g: JsonObject =>
				lookForGraphTactic(tactic) match {
					case Some(t: GraphTactic) => t.addJsonToGraphs(g, t.getSize)
					case None => throwError("<html>The program tried to save a graph in tactic : "+tactic+" , </br>but it could not be found.</html>")
				}
			case _ => throwError("<html>The program tried to save a graph, </br>but the object received is not in JSON format.</html>")
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
			case None => throwError("<html>The program tried to change a graph tactic, </br>but the given tactic name was not found.</html>")
		}
	}

	def isGraphTacticOr(tactic: String): Boolean = {
		lookForGraphTactic(tactic) match {
			case Some(t:GraphTactic) => t.isOr
			case None => false
		}
	}

	def updateTacticName(oldVal: String, newVal: String, isGraphTactic: Boolean) {
		lookForTactic(oldVal) match {
			case Some(old: GraphTactic) => old.name = newVal
			case Some(old: AtomicTactic) => 
				val oldArg = ArgumentParser.argumentsToString(old.argumentsToArrays)
				lookForAtomicTactic(newVal) match {
					case Some(n:AtomicTactic) =>
						val newArg = ArgumentParser.argumentsToString(n.argumentsToArrays)
						if(oldArg != newArg){
							val mergeAction1 = new Action("Merge tactics to "+newVal+"("+oldArg+")"){
								def apply(){
									println("hello1")
									updateJsonGraphs(newVal+"("+newArg+")", newVal+"("+oldArg+")")
									updateJsonGraphs(oldVal+"("+oldArg+")", newVal+"("+oldArg+")")
									n.arg = old.arg
									deleteTactic(old.name)
									TinkerDialog.close()
								}
							}
							val mergeAction2 = new Action("Merge tactics to "+newVal+"("+newArg+")"){
								def apply(){
									println("hello2")
									updateJsonGraphs(oldVal+"("+oldArg+")", newVal+"("+newArg+")")
									deleteTactic(old.name)
									TinkerDialog.close()
								}
							}
							val dontMerge = new Action("Do not merge tactics"){
								def apply(){
									TinkerDialog.close()
								}
							}
							TinkerDialog.openConfirmationDialog("<html>The new name you specified is already taken.</br>What would you want to do ?</html>", Array(mergeAction1, mergeAction2, dontMerge))
						}
						else {
							println("hello3")
							updateJsonGraphs(oldVal+"("+oldArg+")", newVal+"("+newArg+")")
							deleteTactic(old.name)
						}
					case None =>
						println("hello4")
						updateJsonGraphs(oldVal+"("+oldArg+")", newVal+"("+oldArg+")")
						old.name = newVal
				}
			case Some(old: HasArguments) => 
			case None => 
				if(!isGraphTactic){
					createAtomicTactic(newVal)
				}
		}
	}

	def updateTacticArguments(tactic: String, args: Array[Array[String]]){
		lookForTactic(tactic) match {
			case Some(t: HasArguments) =>
				val oldArg = ArgumentParser.argumentsToString(t.argumentsToArrays)
				t.eraseArguments()
				args.foreach{ a =>
					t.addArgument(a)
				}
				val newArg = ArgumentParser.argumentsToString(t.argumentsToArrays)
				println("hello5")
				updateJsonGraphs(tactic+"("+oldArg+")", tactic+"("+newArg+")")
			case None => 
		}
	}

	def createGraphTactic(tactic: String, isOr: Boolean){
		graphTactics = graphTactics :+ new GraphTactic(tactic, isOr)
	}

	def createAtomicTactic(name: String): Array[Array[String]] = {
		lookForAtomicTactic(name) match {
			case Some(t:AtomicTactic) =>
				t.argumentsToArrays
			case None => 
				val t = new AtomicTactic(name, "")
				atomicTactics += t
				t.argumentsToArrays
		}
	}

	def getAtomicTacticValue(tactic: String): String = {
		lookForAtomicTactic(tactic) match {
			case Some(t:AtomicTactic) => t.tactic
			case None => ""
		}
	}

	def setAtomicTacticValue(name: String, value: String){
		lookForAtomicTactic(name) match {
			case Some(t:AtomicTactic) => t.tactic = value
			case None => throwError("<html>The program tried to change a tactic : "+name+", <br>but the given tactic name was not found.</html>")
		}
	}

	def throwError(text: String) = TinkerDialog.openErrorDialog(text)

	def updateJsonGraphs(oldVal: String, newVal: String) {
		println("replace "+oldVal+ " to "+newVal)
		mainGraph = Json.parse(mainGraph.toString.replace(oldVal, newVal)) match {
			case j: JsonObject => j
			case _ => JsonObject()
		}
		// println(mainGraph)
		updateJsonPSGraph
		Service.refreshGraph
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