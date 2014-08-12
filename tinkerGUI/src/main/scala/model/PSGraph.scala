package tinkerGUI.model

import scala.swing._
import quanto.util.json._
import scala.collection.mutable.ArrayBuffer
import tinkerGUI.controllers.TinkerDialog
import tinkerGUI.controllers.Service
import tinkerGUI.utils.ArgumentParser

class PSGraph() {
	var isMain = true
	var currentTactic: GraphTactic = new GraphTactic("", true)
	var currentIndex = 0
	var atomicTactics: ArrayBuffer[AtomicTactic] = ArrayBuffer()
	var graphTactics: ArrayBuffer[GraphTactic] = ArrayBuffer()
	var mainGraph: JsonObject = JsonObject()
	var goalTypes = ""

	var jsonPSGraph: JsonObject = JsonObject()

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
		jsonPSGraph = JsonObject("current" -> current, "current_index" -> currentIndex, "graph" -> mainGraph, "graph_tactics" -> JsonArray(graphTacticsJson), "atomic_tactics" -> JsonArray(atomicTacticsJson), "goal_types" -> goalTypes)
		// println("---------------------------------------------------")
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

	def newSubGraph(tactic: String){
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
					currentTactic = new GraphTactic(tactic, true)
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

	def updateTacticName(oldVal: String, newVal: String): String = {
		// OLD CODE, COULD BE REUSED WHEN FINAL PROTOCOL IS FIXED
		// lookForTactic(oldVal) match {
		// 	case Some(old: GraphTactic) => old.name = newVal
		// 	case Some(old: AtomicTactic) => 
		// 		val oldArg = ArgumentParser.argumentsToString(old.argumentsToArrays)
		// 		lookForAtomicTactic(newVal) match {
		// 			case Some(n:AtomicTactic) =>
		// 				val newArg = ArgumentParser.argumentsToString(n.argumentsToArrays)
		// 				if(oldArg != newArg){
		// 					val mergeAction1 = new Action("Merge tactics to "+newVal+"("+oldArg+")"){
		// 						def apply(){
		// 							updateValueInJsonGraphs("\""+newVal+"("+newArg+")\"", "\""+newVal+"("+oldArg+")\"")
		// 							updateValueInJsonGraphs("\""+oldVal+"("+oldArg+")\"", "\""+newVal+"("+oldArg+")\"")
		// 							n.arg = old.arg
		// 							deleteTactic(old.name)
		// 							TinkerDialog.close()
		// 						}
		// 					}
		// 					val mergeAction2 = new Action("Merge tactics to "+newVal+"("+newArg+")"){
		// 						def apply(){
		// 							updateValueInJsonGraphs("\""+oldVal+"("+oldArg+")\"", "\""+newVal+"("+newArg+")\"")
		// 							deleteTactic(old.name)
		// 							TinkerDialog.close()
		// 						}
		// 					}
		// 					val dontMerge = new Action("Do not merge tactics"){
		// 						def apply(){
		// 							TinkerDialog.close()
		// 						}
		// 					}
		// 					TinkerDialog.openConfirmationDialog("<html>The new name you specified is already taken.</br>What would you want to do ?</html>", Array(mergeAction1, mergeAction2, dontMerge))
		// 				}
		// 				else {
		// 					updateValueInJsonGraphs("\""+oldVal+"("+oldArg+")\"", "\""+newVal+"("+newArg+")\"")
		// 					deleteTactic(old.name)
		// 				}
		// 			case None =>
		// 				updateValueInJsonGraphs("\""+oldVal+"("+oldArg+")\"", "\""+newVal+"("+oldArg+")\"")
		// 				old.name = newVal
		// 		}
		// 	case Some(old: HasArguments) => 
		// 	case None => 
		// 		if(!isGraphTactic){
		// 			createAtomicTactic(newVal)
		// 		}
		// }
		var res = oldVal
		lookForTactic(oldVal) match {
			case Some(old:GraphTactic) => 
				lookForTactic(newVal) match {
					case Some(t:HasArguments) =>
						val actualNewVal = generateNewName(newVal,0)
						val agree = new Action("Ok"){
							def apply(){
								TinkerDialog.close()
							}
						}
						TinkerDialog.openConfirmationDialog("<html> The new name you specified is already taken,<br>the name "+actualNewVal+" will be used.", Array(agree))
						old.name = actualNewVal
					case None => old.name = newVal
				}
				res = old.name
			case Some(old: AtomicTactic) =>
				lookForTactic(newVal) match {
					case Some(t:HasArguments) =>
						val actualNewVal = generateNewName(newVal,0)
						val agree = new Action("Ok"){
							def apply(){
								TinkerDialog.close()
							}
						}
						TinkerDialog.openConfirmationDialog("<html> The new name you specified is already taken,<br>the name "+actualNewVal+" will be used.", Array(agree))
						old.name = actualNewVal
					case None => old.name = newVal
				}
				res = old.name
			case Some(t:HasArguments) =>
			case None =>
				throwError("<html>The program tried to edit the name of tactic "+oldVal+" to "+newVal+"<br> but tactic was not found.</html>")
		}
		return res
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
				updateValueInJsonGraphs("\""+tactic+"("+oldArg+")\"", "\""+tactic+"("+newArg+")\"")
			case None => 
		}
	}

	def createGraphTactic(tactic: String, isOr: Boolean){
		graphTactics = graphTactics :+ new GraphTactic(tactic, isOr)
	}

	def createAtomicTactic(name: String, tactic: Option[String] = None) {
		lookForAtomicTactic(name) match {
			case Some(t:AtomicTactic) =>
				throwError("The program tried to create an already existing tactic.")
			case None =>
				tactic match {
					case Some(s:String) => atomicTactics += new AtomicTactic(name, s)
					case None => atomicTactics += new AtomicTactic(name, "")
				}
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

	def updateValueInJsonGraphs(oldVal: String, newVal: String) {
		mainGraph = Json.parse(mainGraph.toString.replace(oldVal, newVal)) match {
			case j: JsonObject => j
			case _ =>
				throwError("Error when parsing graph to Json Object.")
				mainGraph
		}
		graphTactics.foreach { t =>
			t.graphs.foreach { g =>
				t.graphs -= g
				Json.parse(g.toString.replace(oldVal, newVal)) match {
					case j: JsonObject => t.graphs += j
					case _ =>
						throwError("Error when parsing graph to Json Object.")
						t.graphs += g
				}
			}
		}
		updateJsonPSGraph
		Service.refreshGraph
	}

	def getTacticArguments(tactic: String): Array[Array[String]] = {
		lookForTactic(tactic) match {
			case Some(t: HasArguments) => t.argumentsToArrays
			case None => 
				throwError("<html>Program tried to access tactic "+tactic+"<br> but could not find it</html>")
				Array[Array[String]]()
		}
	}

	def generateNewName(n: String, sufix: Int): String = {
		var name = n
		if(sufix != 0) {name = (n+"-"+sufix)}
		lookForTactic(name) match {
			case None => name
			case Some(t:HasArguments) => generateNewName(n, sufix+1)
		}
	}

	def loadJsonGraph(j: Json) {
		val current = (j / "current").stringValue
		currentIndex  = (j / "current_index").intValue
		goalTypes = (j / "goal_types").stringValue
		mainGraph = (j / "graph").asObject
		atomicTactics = ArrayBuffer()
		graphTactics = ArrayBuffer()
		(j / "atomic_tactics").asArray.foreach{ tct =>
			val name = (tct / "name").stringValue
			val tactic = (tct / "tactic").stringValue
			var args = Array[Array[String]]()
			(tct / "args").asArray.foreach{ a =>
				var arg = Array[String]()
				a.asArray.foreach{ s => arg = arg :+ s.stringValue}
				args = args :+ arg
			}
			createAtomicTactic(name, Some(tactic))
			updateTacticArguments(name, args)
		}
		(j / "graph_tactics").asArray.foreach { tct => 
			val name = (tct / "name").stringValue
			val isOr = (tct / "isOr").boolValue
			var args = Array[Array[String]]()
			(tct / "args").asArray.foreach{ a =>
				var arg = Array[String]()
				a.asArray.foreach{ s => arg = arg :+ s.stringValue}
				args = args :+ arg
			}
			createGraphTactic(name, isOr)
			updateTacticArguments(name, args)
			(tct / "graphs").asArray.foreach{ gr =>
				saveGraphSpecificTactic(name, gr)
			}
		}
		if(current == "main"){
			isMain = true
		}
		else {
			isMain = false
			lookForGraphTactic(current) match {
				case Some(t: GraphTactic) => currentTactic = t
				case None => throwError("<html>Error while loading Json, tried to set current tactic to "+current+"<br< but it could not be found.</html>")
			}
		}
	}
}