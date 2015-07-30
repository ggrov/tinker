package tinkerGUI.model

import quanto.util.json.{Json, JsonObject, JsonArray}
import tinkerGUI.model.exceptions.{BadJsonInputException, SubgraphNotFoundException, GraphTacticNotFoundException}

import scala.collection.mutable.ArrayBuffer

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
		* @return Boolean notifying of successful creation or not (should be used to handle duplication).
		*/
	def createGT(id:String,branchType:String): Boolean = {
		if (gtCollection contains id) {
			false
		} else {
			val t: GraphTactic = new GraphTactic(id, branchType)
			gtCollection += id -> t
			true
		}
	}

	/** Method to update a graph tactic, only if it has less than two occurrences.
		*
		* @param id Gui id before change.
		* @param newId New gui id value.
		* @param newBranchType New branch type value.
		* @return Boolean notifying of successful change or not (should be used to handle duplication).
		* @throws GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	def updateGT(id:String, newId:String, newBranchType:String):Boolean = {
		gtCollection get id match {
			case Some(t: GraphTactic) =>
				if (t.occurrences.size < 2) {
					t.name = newId
					t.branchType = newBranchType
					if (id != newId) {
						gtCollection += (newId -> t)
						gtCollection -= id
					}
					true
				} else {
					false
				}
			case _ =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to force the update of a graph tactic, i.e. update no matter what is the number of occurrences.
		*
		* @param id Gui id before change.
		* @param newId New gui id value.
		* @param newBranchType New branch type value.
		* @param graph Current graph id.
		* @param index Current graph index.
		* @return List of node id linked with this graph tactic in the current graph (should be used to update the graph view).
		* @throws GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	def updateForceGT(id:String, newId:String, newBranchType:String, graph:String, index:Int):Array[String] = {
		gtCollection get id match {
			case Some(t: GraphTactic) =>
				t.name = newId
				t.branchType = newBranchType
				if (id != newId) {
					gtCollection += (newId -> t)
					gtCollection -= id
				}
				t.getOccurrencesInGraph(graph, index)
			case _ =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method deleting a graph tactic from the tactic collection.
		*
		* @param id Gui id of the graph tactic to remove.
		*/
	def deleteGT(id:String) {
		gtCollection -= id
	}

	/** Method to get the branch type of a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @throws GraphTacticNotFoundException If the graph tactic is not in the collection.
		* @return Branch type.
		*/
	def getGTBranchType(id:String):String = {
		gtCollection get id match{
			case Some(t:GraphTactic) =>
				t.branchType
			case None =>
				throw new GraphTacticNotFoundException(id)
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

	/** Method to generate a Json object of the graph tactics' occurrences.
		*
		* @return Json object of the graph tactics occurrences.
		*/
	def toJsonGTOccurrences:JsonObject = {
		JsonObject(gtCollection map {case(k,v) => k -> v.occurrencesToJson() })
	}

	/** Method to add an occurrence in a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param graph Graph id in which the occurrence is.
		* @param index Graph index in which the occurrence is.
		* @param node Node id of the occurrence.
		* @throws GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	def addGTOccurrence(id:String, graph:String, index:Int, node:String) {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.addOccurrence(Tuple3(graph,index,node))
			case None =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to remove an occurrence from a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param graph Graph id in which the occurrence was.
		* @param index Graph index in which the occurrence was.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the graph tactic.
		* @throws GraphTacticNotFoundException If the graph tactic is not in the collection.
		*/
	def removeGTOccurrence(id:String, graph:String, index:Int, node:String):Boolean = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.removeOccurrence(Tuple3(graph,index,node))
				t.occurrences.isEmpty
			case None =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to get the number of occurrences of a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @throws GraphTacticNotFoundException If the graph tactic was not found.
		* @return Number of occurrences of the graph tactic.
		*/
	def getGTNumberOfOccurrences(id:String):Int = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.occurrences.size
			case None =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to add a subgraph to a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param j Json representation of the subgraph.
		* @param index Position of the subgraph in the subgraphs list.
		* @throws GraphTacticNotFoundException If the graph tactic was not found in the collection.
		*/
	def addSubgraphGT(id:String,j:JsonObject,index:Int) {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.addSubgraph(j,index)
			case None =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to delete a subgraph from a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param index Position of the subgraph to remove.
		* @throws GraphTacticNotFoundException If the graph tactic was not found in the collection.
		*/
	def delSubgraphGT(id:String, index:Int){
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.delSubgraph(index)
			case None =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to get the Json representation of a subgraph from a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @param index Position of the subgraph to get.
		* @throws GraphTacticNotFoundException If the graph tactic was not found in the collection.
		* @throws SubgraphNotFoundException If no subgraph was at this index.
		* @return Json representation of the subgraph.
		*/
	def getSubgraphGT(id:String, index:Int):JsonObject = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				try{
					t.getSubgraph(index)
				} catch {
					case e:SubgraphNotFoundException => throw e
				}
			case None =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to get the size, i.e. number of subgraphs, of a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @throws GraphTacticNotFoundException If the graph tactic was not found in the collection.
		* @return Size, i.e. number of subgraph, of the graph tactic.
		*/
	def getSizeGT(id:String):Int = {
		gtCollection get id match {
			case Some(t:GraphTactic) =>
				t.getSize
			case None =>
				throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method to get the children of a graph tactic.
		*
		* @param id Gui id of the graph tactic.
		* @throws GraphTacticNotFoundException If the graph tactic was not found in the collection.
		* @return Array of children graph tactic.
		*/
	def getChildrenGT(id:String):ArrayBuffer[GraphTactic]  ={
		gtCollection get id match {
			case Some(t:GraphTactic) => t.children
			case None => throw new GraphTacticNotFoundException(id)
		}
	}

	/** Method loading a collection of graph tactics from a json.
		*
		* Note that loading an existing graph tactic (with the same name) will override its values and occurrences.
		*
		* @param j Json input.
		* @param mainName the main tactic name
		* @return the main tactic.
		* @throws BadJsonInputException If input's structure is not correct.
		*/
	def loadGTFromJson(j: JsonArray, mainName:String):GraphTactic = {
		var main = new GraphTactic("","")
		try {
			j.foreach {
				case o:JsonObject =>
					val gt = GraphTactic(o)
					if(gt.name == mainName){
						main = gt
					} else {
						gtCollection += gt.name -> gt
					}
				case o:Json => throw new BadJsonInputException("New graph tactic : expected json object, got "+o.getClass)
			}
			main
		} catch {
			case e:BadJsonInputException => throw e
		}
	}
}