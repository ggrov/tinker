// TODO : when updating a graph tactic name, change occurrences of child tactics

package tinkerGUI.model

import tinkerGUI.utils.ArgumentParser
import quanto.util.json._
import scala.collection.mutable.ArrayBuffer

/** Model of a proof-strategy graph.
	*
	*/
class PSGraph() extends ATManager with GTManager {

	/** Boolean to know if the currently viewed is the main one. */
	var isMain = true

	/** Currently viewed graph tactic, if not the main one. */
	var currentTactic: GraphTactic = new GraphTactic("","")

	/** Currently viewed graph index, always 0 for the main one. */
	var currentIndex = 0

	/** Json representing the main one. */
	var mainGraph: JsonObject = JsonObject()

	/** Children graph tactic of main. */
	var childrenMain:ArrayBuffer[GraphTactic] = ArrayBuffer()

	/** Goal types string of the psgraph. */
	var goalTypes = ""

	/** Json representation of the psgraph. */
	var jsonPSGraph: JsonObject = JsonObject()

	/** Method to force the update of an atomic tactic.
		*
		* @param name Gui id of the atomic tactic.
		* @param newName New gui id of the atomic tactic.
		* @param newTactic New core id of the atomic tactic.
		* @param newArgs New arguments of the atomic tactic.
		* @return List of the node ids to update on the current graph.
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic was not found.
		* @throws quanto.util.json.JsonAccessException If updating the values in the json graphs fails.
		*/
	@throws (classOf[AtomicTacticNotFoundException])
	@throws (classOf[JsonAccessException])
	def updateForceAT(name: String, newName:String, newTactic: String, newArgs:String):Array[String] = {
		val graph = if (isMain) "main" else currentTactic.name
		try{
			val oldArgs = atCollection get name match {
				case Some(t:AtomicTactic) => t.argumentsToString()
				case None => throw new AtomicTacticNotFoundException("Atomic tactic "+name+" not found")
			}
			val nodeIds = updateForceAT(name,newName,newTactic,newArgs,graph,currentIndex)
			if(name != newName) updateValueInJsonGraphs(name, newName)
			if(oldArgs != newArgs) updateValueInJsonGraphs(newName+"("+oldArgs+")", newName+"("+newArgs+")")
			nodeIds
		} catch {
			case e:AtomicTacticNotFoundException => throw e
			case e:JsonAccessException => throw e
		}
	}

	/** Method to force the update of a graph tactic.
		*
		* @param name Gui id of the graph tactic.
		* @param newName New gui id of the graph tactic.
		* @param newBranchType New branch type of the graph tactic.
		* @param newArgs New arguments of the graph tactic.
		* @return List of the node ids to update on the current graph.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found.
		* @throws quanto.util.json.JsonAccessException If updating the values in the json graphs fails.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	@throws (classOf[JsonAccessException])
	def updateForceGT(name: String, newName:String, newBranchType: String, newArgs:String):Array[String] = {
		val graph = if (isMain) "main" else currentTactic.name
		try {
			val oldArgs = gtCollection get name match {
				case Some(t:GraphTactic) => t.argumentsToString()
				case None => throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
			}
			val nodeIds = updateForceGT(name,newName,newBranchType,newArgs,graph,currentIndex)
			if(name != newName) updateValueInJsonGraphs(name, newName)
			if(oldArgs != newArgs) updateValueInJsonGraphs(newName+"("+oldArgs+")", newName+"("+newArgs+")")
			nodeIds
		} catch {
			case e:GraphTacticNotFoundException => throw e
			case e:JsonAccessException => throw e
		}
	}

	/** Method to add an occurrence in an atomic tactic.
		*
		* @param name Gui id of the atomic tactic.
		* @param node Node id of the occurrence.
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic was not found.
		*/
	@throws (classOf[AtomicTacticNotFoundException])
	def addATOccurrence(name:String,node:String) {
		val graph = if(isMain) "main" else currentTactic.name
		try {
			addATOccurrence(name, graph, currentIndex, node)
		} catch {
			case e:AtomicTacticNotFoundException => throw e
		}
	}

	/** Method to remove an occurrence from an atomic tactic.
		*
		* @param name Gui id of the atomic tactic.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the atomic tactic.
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic was not found.
		*/
	@throws (classOf[AtomicTacticNotFoundException])
	def removeATOccurrence(name:String,node:String):Boolean = {
		val graph = if(isMain) "main" else currentTactic.name
		try{
			removeATOccurrence(name,graph,currentIndex, node)
		} catch {
			case e:AtomicTacticNotFoundException => throw e
		}
	}

	/** Method to add an occurrence in a graph tactic.
		*
		* Also register the graph as a child of the current graph tactic.
		* @param name Gui id of the graph tactic.
		* @param node Node id of the occurrence.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def addGTOccurrence(name:String,node:String){
		val graph = if(isMain) "main" else currentTactic.name
		try {
			addGTOccurrence(name,graph,currentIndex,node)
			gtCollection get name match{
				case Some(t:GraphTactic) =>
					if(isMain) childrenMain = childrenMain :+ t
					else currentTactic.addChild(t)
				case None =>
					throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
			}
		} catch {
			case e:GraphTacticNotFoundException => throw e
		}
	}

	/** Method to remove an occurrence of a graph tactic.
		*
		* Also removes the graph from the children list of the current graph tactic.
		* @param name Gui id of the graph tactic.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the graph tactic.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def removeGTOccurrence(name:String,node:String):Boolean = {
		val graph = if(isMain) "main" else currentTactic.name
		try {
			val res = removeGTOccurrence(name,graph,currentIndex,node)
			gtCollection get name match{
				case Some(t:GraphTactic) =>
					if(isMain) childrenMain -= t
					else currentTactic.removeChild(t)
				case None =>
					throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
			}
			res
		} catch {
			case e:GraphTacticNotFoundException => throw e
		}
	}

	/** Method to update the Json representation of the psgraph.
		*
		*/
	def updateJsonPSGraph() {
		val current = if(isMain) "main" else currentTactic.name
		jsonPSGraph = JsonObject("current" -> current,
			"current_index" -> currentIndex,
			"graph" -> mainGraph,
			"graph_tactics" -> toJsonGT,
			"atomic_tactics" -> toJsonAT,
			"goal_types" -> goalTypes)
		// println("---------------------------------------------------")
		// println(jsonPSGraph)
	}

	/** Method to register a new subgraph and set it as current.
		*
		* @param tactic Gui id of the graph tactic from which to add the new subgraph.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def newSubgraph(tactic: String){
		isMain = false
		if(tactic == currentTactic.name){
			currentIndex = currentTactic.getSize
		}
		else{
			gtCollection get tactic match {
				case Some(t:GraphTactic) =>
					currentTactic = t
					currentIndex = t.getSize
				case None =>
					throw new GraphTacticNotFoundException("Graph tactic "+tactic+" not found")
			}
		}
	}

	/** Method to switch the currently viewed graph.
		*
		* @param tactic New current graph tactic.
		* @param index New current index.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def changeCurrent(tactic: String, index: Int) {
		if(tactic == "main"){
			isMain = true
			currentIndex = 0
		}
		else {
			gtCollection get tactic match {
				case Some(t: GraphTactic) =>
					isMain = false
					currentTactic = t
					currentIndex = index
				case None => throw new GraphTacticNotFoundException("Graph tactic "+tactic+" not found")
			}
		}
	}

	/** Method to save the current graph Json representation.
		*
		* @param graph Json representation of the graph.
		* @throws quanto.util.json.JsonAccessException If the graph is not a Json object.
		*/
	@throws (classOf[JsonAccessException])
	def saveGraph(graph: Json) {
		graph match {
			case g: JsonObject =>
				if(isMain){
					mainGraph = g
				}
				else {
					currentTactic.addSubgraph(g, currentIndex)
				}
			case _ => throw new JsonAccessException("Expected: JsonObject, got: "+graph.getClass, graph)
		}
		updateJsonPSGraph()
	}

	/** Method to save the Json representation of a specific graph.
		*
		* @param tactic Graph tactic of the graph.
		* @param graph Json representation of the graph.
		* @param index Index of the graph in the graph tactic.
		* @throws quanto.util.json.JsonAccessException If the graph is not a Json object.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found.
		*/
	@throws (classOf[JsonAccessException])
	@throws (classOf[GraphTacticNotFoundException])
	def saveGraph(tactic: String, graph: Json, index:Int){
		graph match {
			case g: JsonObject =>
				if(tactic == "main") mainGraph = g
				else try{
					addSubgraphGT(tactic, g, index)
				} catch {
					case e:GraphTacticNotFoundException => throw e
				}
			case _ => throw new JsonAccessException("Expected: JsonObject, got: "+graph.getClass, graph)
		}
		updateJsonPSGraph()
	}

	/** Method to get the current graph Json object.
		*
		* @throws tinkerGUI.model.SubgraphNotFoundException If the graph was not found.
		* @return Json object of the graph.
		*/
	@throws (classOf[SubgraphNotFoundException])
	def getCurrentJson: JsonObject = {
		if(isMain) mainGraph
		else try {
			currentTactic.getSubgraph(currentIndex)
		} catch {
			case e:SubgraphNotFoundException => throw e
		}
	}

	/** Method switching a string with another inside all graphs' json except the current one.
		*
		* @param oldVal String to replace.
		* @param newVal String to insert.
		* @throws quanto.util.json.JsonAccessException If the resulting graph is not a Json object.
		*/
	@throws (classOf[JsonAccessException])
	def updateValueInJsonGraphs(oldVal: String, newVal: String) {
		if(isMain){
			gtCollection.foreach { case (k, v) =>
					v.graphs.foreach { case g =>
						v.graphs -= g
						Json.parse(g.toString().replace(oldVal,newVal)) match {
							case j: JsonObject => v.graphs += j
							case j: Json =>
								v.graphs += g
								throw new JsonAccessException("Expected: JsonObject, got: "+j.getClass, j)
						}
					}
			}
		} else {
			mainGraph = Json.parse(mainGraph.toString().replace(oldVal, newVal)) match {
				case j: JsonObject => j
				case j: Json =>
					throw new JsonAccessException("Expected: JsonObject, got: "+j.getClass, j)
			}
			gtCollection.foreach { case(k,v) =>
				v.graphs.foreach { case g =>
					if(k != currentTactic.name && v.graphs.indexOf(g) != currentIndex) {
						v.graphs -= g
						Json.parse(g.toString().replace(oldVal,newVal)) match {
							case j: JsonObject => v.graphs += j
							case j: Json =>
								v.graphs += g
								throw new JsonAccessException("Expected: JsonObject, got: "+j.getClass, j)
						}
					}
				}
			}
		}
		updateJsonPSGraph()
	}

	/** Method to load a new model from a Json object.
		*
		* This method overwrites the all model, hence it should be saved before calling it.
		* @param j Json input.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If a graph tactic is not found after importing the data.
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If a atomic tactic is not found after importing the data.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	@throws (classOf[AtomicTacticNotFoundException])
	def loadJsonGraph(j: Json) {
		atCollection = Map()
		gtCollection = Map()
		val current = (j / "current").stringValue
		currentIndex  = (j / "current_index").intValue
		goalTypes = (j / "goal_types").stringValue
		mainGraph = (j / "graph").asObject
		try{
			(j / "atomic_tactics").asArray.foreach{ tct =>
				val name = (tct / "name").stringValue
				val tactic = (tct / "tactic").stringValue
				var args = Array[Array[String]]()
				(tct / "args").asArray.foreach{ a =>
					var arg = Array[String]()
					a.asArray.foreach{ s => arg = arg :+ s.stringValue}
					args = args :+ arg
				}
				createAT(name, tactic , args)
				(tct / "occurrences").asArray.foreach{ a =>
					addATOccurrence(name,a.asArray.get(0).stringValue,a.asArray.get(1).intValue,a.asArray.get(2).stringValue)
				}
			}
			(j / "graph_tactics").asArray.foreach { tct =>
				val name = (tct / "name").stringValue
				val branchType = (tct / "branchType").stringValue
				var args = Array[Array[String]]()
				(tct / "args").asArray.foreach{ a =>
					var arg = Array[String]()
					a.asArray.foreach{ s => arg = arg :+ s.stringValue}
					args = args :+ arg
				}
				createGT(name, branchType, args)
				var i = 0
				(tct / "graphs").asArray.foreach{ gr =>
					saveGraph(name, gr, i)
					i+=1
				}
				(tct / "occurrences").asArray.foreach{ a =>
					addGTOccurrence(name,a.asArray.get(0).stringValue,a.asArray.get(1).intValue,a.asArray.get(2).stringValue)
				}
			}
			rebuildHierarchy()
		} catch {
			case e:GraphTacticNotFoundException => throw e
			case e:AtomicTacticNotFoundException => throw e
		}
		if(current == "main"){
			isMain = true
		}
		else {
			isMain = false
			gtCollection get current match {
				case Some(t: GraphTactic) => currentTactic = t
				case None => throw new GraphTacticNotFoundException("Graph tactic "+current+" not found")
			}
		}
	}

	/** Method to find the children of every graph tactic, including the main graph.
		*
		* @throws tinkerGUI.model.GraphTacticNotFoundException If one of the children was not found.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def rebuildHierarchy(){
		childrenMain = ArrayBuffer()
		(mainGraph ? "node_vertices").asObject.foreach {
			case (k, v) if ((v / "data").asObject / "type").stringValue == "T_Graph" =>
				val name = ArgumentParser.separateNameFromArgument((v / "data" / "subgraph").stringValue)._1
				gtCollection get name match {
					case Some(t:GraphTactic) => childrenMain = childrenMain :+ t
					case None => throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
				}
			case _ => // do nothing
		}
		try{
			childrenMain.foreach{ c => buildPartialHierarchy(c)}
		} catch {
			case e:GraphTacticNotFoundException => throw e
		}
	}

	/** Method to find the children of a graph tactic, and their children as well.
		*
		* @param parent Gui id of the graph tactic.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If one of the children was not found.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def buildPartialHierarchy(parent:GraphTactic) {
		if(parent.children.isEmpty){
			parent.graphs.foreach {g =>
				(g ? "node_vertices").asObject.foreach {
					case (k, v) if ((v / "data").asObject / "type").stringValue == "T_Graph" =>
						val name = ArgumentParser.separateNameFromArgument((v / "data" / "subgraph").stringValue)._1
						gtCollection get name match {
							case Some(t:GraphTactic) => childrenMain = childrenMain :+ t
							case None => throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
						}
					case _ => // do nothing
				}
			}
			parent.children.foreach{ c => buildPartialHierarchy(c)}
		}
	}
}