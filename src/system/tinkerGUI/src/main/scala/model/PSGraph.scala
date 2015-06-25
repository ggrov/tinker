package tinkerGUI.model

import tinkerGUI.model.exceptions.{GraphTacticNotFoundException, SubgraphNotFoundException, AtomicTacticNotFoundException}
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

	/** Current parent list.*/
	var currentParents:Array[String] = Array()

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
		* @throws AtomicTacticNotFoundException If the atomic tactic was not found.
		* @throws JsonAccessException If updating the values in the json graphs fails.
		*/
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
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		* @throws JsonAccessException If updating the values in the json graphs fails.
		*/
	def updateForceGT(name: String, newName:String, newBranchType: String, newArgs:String):Array[String] = {
		val graph = if (isMain) "main" else currentTactic.name
		try {
			val oldArgs = gtCollection get name match {
				case Some(t:GraphTactic) => t.argumentsToString()
				case None => throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
			}
			val nodeIds = updateForceGT(name,newName,newBranchType,newArgs,graph,currentIndex)
			if(name != newName) {
				updateValueInJsonGraphs(name, newName)
				for((k,v)<-gtCollection) v.changeOccurrences(name, newName)
				for((k,v)<-atCollection) v.changeOccurrences(name, newName)
			}
			if(oldArgs != newArgs) updateValueInJsonGraphs(newName+"("+oldArgs+")", newName+"("+newArgs+")")
			nodeIds
		} catch {
			case e:GraphTacticNotFoundException => throw e
			case e:JsonAccessException => throw e
		}
	}

	/** Method to update a graph tactic.
		*
		* Also changes the occurrences of all other tactics if necessary.
		* @param name Gui id of the graph tactic.
		* @param newName New gui id of the graph tactic.
		* @param newBranchType New branch type value.
		* @param newArgs New list of arguments, in a string format.
		* @return Boolean notifying of successful change or not (should be used to handle duplication).
		* @throws GraphTacticNotFoundException If the graph tactic was not in the collection.
		*/
	override def updateGT(name:String, newName:String, newBranchType:String, newArgs:String):Boolean = {
		try{
			if(name != newName){
				for((k,v)<-gtCollection) v.changeOccurrences(name, newName)
				for((k,v)<-atCollection) v.changeOccurrences(name, newName)
			}
			super.updateGT(name, newName, newBranchType, newArgs)
		} catch {
			case e:GraphTacticNotFoundException => throw e
		}
	}

	/** Method to add an occurrence in an atomic tactic.
		*
		* @param name Gui id of the atomic tactic.
		* @param node Node id of the occurrence.
		* @throws AtomicTacticNotFoundException If the atomic tactic was not found.
		*/
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
		* Deletes the tactic's data from the model if it is the last occurrence.
		* @param name Gui id of the atomic tactic.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the atomic tactic.
		* @throws AtomicTacticNotFoundException If the atomic tactic was not found.
		*/
	def removeATOccurrence(name:String,node:String):Boolean = {
		val graph = if(isMain) "main" else currentTactic.name
		try{
			if(removeATOccurrence(name,graph,currentIndex, node)){
				deleteAT(name)
				true
			} else {
				false
			}
		} catch {
			case e:AtomicTacticNotFoundException => throw e
		}
	}

	/** Method to remove an occurrence from an atomic tactic.
		*
		* Does not delete the tactic's data from the modele if it is the last occurrence.
		* @param name Gui id of the atomic tactic.
		* @param node Node id of the occurrence to remove.
		* @throws AtomicTacticNotFoundException If the atomic tactic was not found.
		*/
	def removeATOccurrenceNoDelete(name:String,node:String) {
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
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		*/
	def addGTOccurrence(name:String,node:String){
		val graph = if(isMain) "main" else currentTactic.name
		try {
			super.addGTOccurrence(name,graph,currentIndex,node)
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

	/** Method to add an occurrence of a graph tactic.
		*
		* @param name Gui id of the graph tactic.
		* @param graph Graph id in which the occurrence is.
		* @param index Graph index in which the occurrence is.
		* @param node Node id of the occurrence.
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		*/
	override def addGTOccurrence(name:String, graph:String, index:Int, node:String) {
		try {
			super.addGTOccurrence(name,graph,currentIndex,node)
			gtCollection get name match{
				case Some(t:GraphTactic) =>
					if(graph=="main") childrenMain = childrenMain :+ t
					else gtCollection get graph match{
						case Some(p:GraphTactic) =>
							p.addChild(t)
						case None =>
							throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
					}
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
		* And deletes the tactic's data from the model if it is the last occurrence.
		* @param name Gui id of the graph tactic.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the graph tactic.
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		*/
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
			if(res){
				deleteGT(name)
				true
			} else {
				false
			}
		} catch {
			case e:GraphTacticNotFoundException => throw e
		}
	}

	/** Method to remove an occurrence of a graph tactic.
		*
		* Also removes the graph from the children list of the current graph tactic.
		* And does not delete the tactic's data from the model if it is the last occurrence.
		* @param name Gui id of the graph tactic.
		* @param node Node id of the occurrence to remove.
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		*/
	def removeGTOccurrenceNoDelete(name:String,node:String) {
		val graph = if(isMain) "main" else currentTactic.name
		try {
			removeGTOccurrence(name,graph,currentIndex,node)
			gtCollection get name match{
				case Some(t:GraphTactic) =>
					if(isMain) childrenMain -= t
					else currentTactic.removeChild(t)
				case None =>
					throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
			}
		} catch {
			case e:GraphTacticNotFoundException => throw e
		}
	}

	/** Method to delete a graph tactic from the tactic collection.
		*
		* This method overrides [[tinkerGUI.model.GTManager.deleteGT]] but still invokes it.
		* It also remove all occurrences (in the atomic and graph tactic collections) which refers to this graph tactic id.
		* @param name Gui id of the graph tactic to delete.
		*/
	override def deleteGT(name:String) {
		super.deleteGT(name)
		for((k,v) <- gtCollection) {
			v.removeOccurrence(name)
			if(v.occurrences.isEmpty) deleteGT(k)
		}
		for((k,v) <- atCollection) {
			v.removeOccurrence(name)
			if(v.occurrences.isEmpty) deleteAT(k)
		}
	}

	/** Method to get the current tactic name.
		*
		* @return Tactic name/id.
		*/
	def getCurrentGTName: String = {
		if(isMain) "main" else currentTactic.name
	}

	/** Method to update the Json representation of the psgraph.
		*
		*/
	def updateJsonPSGraph() {
		val current = JsonArray((currentParents :+ getCurrentGTName).reverse)
		val gtOccArray = toJsonGTOccurrences
		val atOccArray = toJsonATOccurrences
		jsonPSGraph = JsonObject("current" -> current,
			"current_index" -> currentIndex,
			"graph" -> mainGraph,
			"graph_tactics" -> toJsonGT,
			"atomic_tactics" -> toJsonAT,
			"goal_types" -> goalTypes,
			"occurrences" -> JsonObject("atomic_tactics" -> atOccArray, "graph_tactics" -> gtOccArray))
		// println("---------------------------------------------------")
		// println(jsonPSGraph)
	}

	/** Method resetting the model.
		*
		*/
	def reset() {
		currentIndex = 0
		mainGraph = JsonObject()
		goalTypes = ""
		isMain = true
		currentTactic = new GraphTactic("","")
		currentParents = Array()
		jsonPSGraph = JsonObject()
		childrenMain.clear()
		gtCollection = Map()
		atCollection = Map()
	}

	/** Method to register a new subgraph and set it as current.
		*
		* @param tactic Gui id of the graph tactic from which to add the new subgraph.
		* @param parents Optional list of parents to update the current parents list.
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		*/
	def newSubgraph(tactic: String, parents:Option[Array[String]] = None){
		isMain = false
		if(tactic == currentTactic.name){
			currentIndex = currentTactic.getSize
		}
		else{
			gtCollection get tactic match {
				case Some(t:GraphTactic) =>
					parents match {
						case Some(p:Array[String]) =>
							currentParents = p
						case None => currentParents = currentParents :+ getCurrentGTName
					}
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
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		*/
	def changeCurrent(tactic: String, index: Int, parents:Option[Array[String]] = None) {
		if(tactic == "main"){
			isMain = true
			currentIndex = 0
			currentParents = Array()
			currentTactic = new GraphTactic("","")
		}
		else {
			if(tactic == currentTactic.name){
				currentIndex = index
				parents match {
					case Some(p: Array[String]) =>
						currentParents = p
					case None =>
				}
			}
			else {
				gtCollection get tactic match {
					case Some(t: GraphTactic) =>
						parents match {
							case Some(p:Array[String]) =>
								currentParents = p
							case None =>
								currentParents = currentParents :+ getCurrentGTName
						}
						isMain = false
						currentTactic = t
						currentIndex = index
					case None => throw new GraphTacticNotFoundException("Graph tactic "+tactic+" not found")
				}
			}
		}
	}

	/** Method to save the current graph Json representation.
		*
		* @param graph Json representation of the graph.
		* @throws quanto.util.json.JsonAccessException If the graph is not a Json object.
		*/
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
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		*/
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
		* @throws SubgraphNotFoundException If the graph was not found.
		* @return Json object of the graph.
		*/
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
		* @throws JsonAccessException If the resulting graph is not a Json object.
		*/
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
		* @throws GraphTacticNotFoundException If a graph tactic is not found after importing the data.
		* @throws AtomicTacticNotFoundException If a atomic tactic is not found after importing the data.
		*/
	def loadJsonGraph(j: Json) {
		atCollection = Map()
		gtCollection = Map()
		val current = (j / "current").asArray.head.stringValue
		currentParents = (j / "current").asArray.tail.foldRight(Array[String]()){ case (p,a) => a :+ p.stringValue}
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
			}
			(j / "occurrences").asObject match { case occ:JsonObject =>
				(occ / "atomic_tactics").asObject.foreach { case(k,v) =>
					v.asArray.foreach { occ =>
						val o = occ.asArray
						super.addATOccurrence(k,o.get(0).stringValue,o.get(1).intValue,o.get(2).stringValue)
					}
				}
				(occ / "graph_tactics").asObject.foreach { case(k,v) =>
					v.asArray.foreach { occ =>
						val o = occ.asArray
						super.addGTOccurrence(k,o.get(0).stringValue,o.get(1).intValue,o.get(2).stringValue)
					}
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
		* @throws GraphTacticNotFoundException If one of the children was not found.
		*/
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
		* @throws GraphTacticNotFoundException If one of the children was not found.
		*/
	def buildPartialHierarchy(parent:GraphTactic) {
		if(parent.children.isEmpty){
			parent.graphs.foreach {g =>
				(g ? "node_vertices").asObject.foreach {
					case (k, v) if ((v / "data").asObject / "type").stringValue == "T_Graph" =>
						val name = ArgumentParser.separateNameFromArgument((v / "data" / "subgraph").stringValue)._1
						gtCollection get name match {
							case Some(t:GraphTactic) => parent.children = parent.children :+ t
							case None => throw new GraphTacticNotFoundException("Graph tactic "+name+" not found")
						}
					case _ => // do nothing
				}
			}
			parent.children.foreach{ c => buildPartialHierarchy(c)}
		}
	}
}