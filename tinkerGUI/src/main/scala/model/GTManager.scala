package tinkerGUI.model

import quanto.util.json.{JsonObject, JsonArray}

/** Exception class for not finding an graph tactic in the collection.
	*
	* @param msg Custom message.
	*/
case class GraphTacticNotFoundException(msg:String) extends Exception(msg)

/** A manager for the graph tactics of a psgraph.
	*
	* Will register the graph tactics in a map and manage their creation and update.
	* Also provides accessors for the graph tactics values.
	*/
trait GTManager {

	/** The collection of graph tactics. */
	var gtCollection:Map[String, GraphTactic] = Map()

	/** Method creating an graph tactic if the id is available.
		*
		* @param id Id/name of the graph tactic.
		* @param branchType Branch type of the graph tactic.
		* @param args List of arguments for the graph tactic.
		* @return Boolean notifying of successful creation or not (should be used to handle duplication).
		*/
	def createGT(id:String,branchType:String,args:Array[Array[String]]): Boolean = {
		if(gtCollection contains id){
			false
		} else {
			val t: GraphTactic = new GraphTactic(id, branchType)
			t.replaceArguments(args)
			gtCollection += id -> t
			true
		}
	}

	/** Method creating an graph tactic if the id is available.
		*
		* @param id Id/name of the graph tactic.
		* @param branchType Branch type of the graph tactic.
		* @param args List of arguments for the graph tactic, in a string format.
		* @return Boolean notifying of successful creation or not (should be used to handle duplication).
		*/
	def createGT(id:String,branchType:String,args:String): Boolean = {
		if(gtCollection contains id){
			false
		} else {
			val t: GraphTactic = new GraphTactic(id, branchType)
			t.replaceArguments(args)
			gtCollection += id -> t
			true
		}
	}

	/** Method to update a graph tactic, only if it has less than two occurrences.
		*
		* @param id Gui id before change.
		* @param newId New gui id value.
		* @param newBranchType New branch type value.
		* @param newArgs New list of arguments.
		* @return Boolean notifying of successful change or not (should be used to handle duplication).
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def updateGT(id:String, newId:String, newBranchType:String, newArgs:Array[Array[String]]):Boolean = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				if(t.occurrences.size < 2){
					t.name = newId
					t.branchType = newBranchType
					t.replaceArguments(newArgs)
					if(id != newId){
						gtCollection += (newId -> t)
						gtCollection -= id
					}
					true
				} else {
					false
				}
			case _ =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to update a graph tactic, only if it has less than two occurrences.
		*
		* @param id Gui id before change.
		* @param newId New gui id value.
		* @param newBranchType New branch type value.
		* @param newArgs New list of arguments, in a string format.
		* @return Boolean notifying of successful change or not (should be used to handle duplication).
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def updateGT(id:String, newId:String, newBranchType:String, newArgs:String):Boolean = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				if(t.occurrences.size < 2){
					t.name = newId
					t.branchType = newBranchType
					t.replaceArguments(newArgs)
					if(id != newId){
						gtCollection += (newId -> t)
						gtCollection -= id
					}
					true
				} else {
					false
				}
			case _ =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to force the update of a graph tactic, i.e. update no matter what is the number of occurrences.
		*
		* @param id Gui id before change.
		* @param newId New gui id value.
		* @param newBranchType New branch type value.
		* @param newArgs New list of arguments.
		* @param graph Current graph id.
		* @return List of node id linked with this graph tactic in the current graph (should be used to update the graph view).
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def updateForceGT(id:String, newId:String, newBranchType:String, newArgs:Array[Array[String]], graph:String):Array[String] = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.name = newId
				t.branchType = newBranchType
				t.replaceArguments(newArgs)
				if (id != newId) {
					gtCollection += (newId -> t)
					gtCollection -= id
				}
				t.getOccurrencesInGraph(graph)
			case _ =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to force the update of a graph tactic, i.e. update no matter what is the number of occurrences.
		*
		* @param id Gui id before change.
		* @param newId New gui id value.
		* @param newBranchType New branch type value.
		* @param newArgs New list of arguments, in a string format.
		* @param graph Current graph id.
		* @return List of node id linked with this graph tactic in the current graph (should be used to update the graph view).
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def updateForceGT(id:String, newId:String, newBranchType:String, newArgs:String, graph:String):Array[String] = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.name = newId
				t.branchType = newBranchType
				t.replaceArguments(newArgs)
				if (id != newId) {
					gtCollection += (newId -> t)
					gtCollection -= id
				}
				t.getOccurrencesInGraph(graph)
			case _ =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method deleting a graph tactic from the tactic collection.
		*
		* @param id Gui id of the graph tactic to remove.
		*/
	def deleteGT(id:String) {
		gtCollection -= id
	}

	/** Method to get the full name (name + arguments) of a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @return Full name.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def getGTFullName(id:String):String = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.name+"("+t.argumentsToString()+")"
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to get the branch type of a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic is not in the collection.
		* @return Branch type.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def getGTBranchType(id:String):String = {
		gtCollection get id match{
			case Some(t:GraphTactic) =>
				t.branchType
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to get a Json array of the graph tactic collection
		*
		* @return Json array of the graph tactics.
		*/
	def toJsonGT:JsonArray = {
		var arr:Array[JsonObject] = Array()
		gtCollection.foreach{ case(k,v) =>
			arr = arr :+ v.toJson
		}
		JsonArray(arr)
	}

	/** Method to add an occurrence in a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param graph Graph in which the occurrence is.
		* @param node Node id of the occurrence.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def addGTOccurrence(id:String, graph:String, node:String) {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.addOccurrence(Tuple2(graph,node))
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to remove an occurrence from a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param graph Graph in which the occurrence was.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the graph tactic.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def removeGTOccurrence(id:String, graph:String, node:String):Boolean = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.removeOccurrence(Tuple2(graph,node))
				t.occurrences.isEmpty
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to add a subgraph to a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param j Json representation of the subgraph.
		* @param index Position of the subgraph in the subgraphs list.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def addSubgraphGT(id:String,j:JsonObject,index:Int) {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.addSubgraph(j,index)
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to delete a subgraph from a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param index Position of the subgraph to remove.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found in the collection.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def delSubgraphGT(id:String, index:Int){
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.delSubgraph(index)
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to get the Json representation of a subgraph from a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param index Position of the subgraph to get.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found in the collection.
		* @throws tinkerGUI.model.SubgraphNotFoundException If no subgraph was at this index.
		* @return Json representation of the subgraph.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	@throws (classOf[SubgraphNotFoundException])
	def getSubgraphGT(id:String, index:Int):JsonObject = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				try{
					t.getSubgraph(index)
				} catch {
					case e:SubgraphNotFoundException => throw e
				}
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}

	/** Method to get the size, i.e. number of subgraphs, of a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @throws tinkerGUI.model.GraphTacticNotFoundException If the graph tactic was not found in the collection.
		* @return Size, i.e. number of subgraph, of the graph tactic.
		*/
	@throws (classOf[GraphTacticNotFoundException])
	def getSizeGT(id:String):Int = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.getSize
			case None =>
				throw new GraphTacticNotFoundException("Graph tactic "+id+" not found")
		}
	}
}