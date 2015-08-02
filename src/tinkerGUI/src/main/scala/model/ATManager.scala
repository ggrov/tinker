package tinkerGUI.model

import quanto.util.json.{Json, JsonObject, JsonArray}
import tinkerGUI.model.exceptions.{BadJsonInputException, AtomicTacticNotFoundException}

/** A manager for the atomic tactics of a psgraph.
	*
	* Will register the atomic tactics in a map and manage their creation and update.
	* Also provides accessors for the atomic tactics values.
	*/
trait ATManager {

	/** The collection of atomic tactics.*/
	var atCollection:Map[String,AtomicTactic] = Map()
	
	/** Method creating an atomic tactic if the id is available.
	 *
	 * @param name Gui name of the atomic tactic.
	 * @param value Value the atomic tactic.
	 * @return Boolean notifying of successful creation or not (should be used to handle duplication).
	 */
	def createAT(name:String,value:String): Boolean = {
		if(atCollection contains name){
			false
		} else {
			atCollection += name -> AtomicTactic(name, value)
			true
		}
	}

	/** Method to update an atomic tactic name and value, only if it has less than two occurrences.
	 *
	 * @param name Name before change.
	 * @param newName New name.
	 * @param newValue New value.
	 * @return Boolean notifying of successful change or not (should be used to handle duplication).
	 * @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
	 */
	def updateAT(name:String, newName:String, newValue:String):Boolean = {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				if(t.occurrences.size < 2){
					t.name = newName
					t.tactic = newValue
					if(name != newName){
						atCollection += (newName -> t)
						atCollection -= name
					}
					true
				} else {
					false
				}
			case _ =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method to update an atomic tactic name, only if it has less than two occurrences.
		*
		* @param name Name before change.
		* @param newName New name.
		* @return Boolean notifying of successful change or not (should be used to handle duplication).
		* @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	def updateAT(name:String, newName:String):Boolean = {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				if(t.occurrences.size < 2){
					t.name = newName
					if(name != newName){
						atCollection += (newName -> t)
						atCollection -= name
					}
					true
				} else {
					false
				}
			case _ =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method to force the update of an atomic tactic name and value, i.e. update no matter what is the number of occurrences.
	 *
	 * @param name Name before change.
	 * @param newName New name.
	 * @param newValue New value.
	 * @param graph Current graph id.
	 * @param index Current graph index.
	 * @return List of node id linked with this atomic tactic in the current graph (should be used to update the graph view).
	 * @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
	 */
	def updateForceAT(name:String, newName:String, newValue:String, graph:String, index:Int):Set[String] = {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				t.name = newName
				t.tactic = newValue
				if (name != newName) {
					atCollection += (newName -> t)
					atCollection -= name
				}
				t.getOccurrencesInGraph(graph, index)
			case _ =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method to force the update of an atomic tactic name, i.e. update no matter what is the number of occurrences.
		*
		* @param name Name before change.
		* @param newName New name.
		* @param graph Current graph id.
		* @param index Current graph index.
		* @return List of node id linked with this atomic tactic in the current graph (should be used to update the graph view).
		* @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	def updateForceAT(name:String, newName:String, graph:String, index:Int):Set[String] = {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				t.name = newName
				if (name != newName) {
					atCollection += (newName -> t)
					atCollection -= name
				}
				t.getOccurrencesInGraph(graph, index)
			case _ =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method deleting an atomic tactic from the tactic collection.
		*
		* @param name Name of the atomic tactic to remove.
		*/
	def deleteAT(name:String) {
		atCollection -= name
	}

	/** Method to get the tactic value of an atomic tactic.
	 *
	 * @param name Name of the atomic tactic.
	 * @return Tactic value.
	 * @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
	 */
	def getTacticValue(name:String):String = {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				t.tactic
			case _ =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method to set the tactic value of an atomic tactic.
		*
		* @param name Name of the atomic tactic.
		* @param newValue New value for the atomic tactic.
		* @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	def setTacticValue(name:String,newValue:String) {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				t.tactic = newValue
			case _ =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method to generate a Json array of the atomic tactic collection.
		*
		* @return Json array of the collection of atomic tactics.
		*/
	def toJsonAT:JsonArray = {
		atCollection.foldLeft(JsonArray()){(a,t)=>a:+t._2.toJson}
	}

	/** Method to generate a Json object of the graph tactics' occurrences.
		*
		* @return Json object of the graph tactics occurrences.
		*/
	def toJsonATOccurrences:JsonObject = {
		JsonObject(atCollection map {case(k,v) => k -> v.occurrencesToJson() })
	}

	/** Method to add an occurrence in an atomic tactic.
		*
		* @param name Name of the atomic tactic.
		* @param graph Graph id in which the occurrence is.
		* @param index Graph index in which the occurrence is.
		* @param node Node id of the occurrence.
		* @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	def addATOccurrence(name:String, graph:String, index:Int, node:String) {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				t.addOccurrence(Tuple3(graph,index,node))
			case None =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method to remove an occurrence from an atomic tactic.
		*
		* @param name Name of the atomic tactic.
		* @param graph Graph id in which the occurrence was.
		* @param index Graph index in which the occurrence was.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the atomic tactic.
		* @throws AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	def removeATOccurrence(name:String, graph:String, index:Int, node:String):Boolean = {
		atCollection get name match {
			case Some(t:AtomicTactic) =>
				t.removeOccurrence(Tuple3(graph,index,node))
				t.occurrences.isEmpty
			case None =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method to get the number of occurrences of a atomic tactic.
		*
		* @param name Name of the atomic tactic.
		* @throws AtomicTacticNotFoundException If the atomic tactic was not found.
		* @return Number of occurrences of the atomic tactic.
		*/
	def getATNumberOfOccurrences(name:String):Int = {
		atCollection get name match {
			case Some(t: AtomicTactic) =>
				t.occurrences.size
			case None =>
				throw new AtomicTacticNotFoundException(name)
		}
	}

	/** Method loading a collection of atomic tactics from a json array.
		*
		* Note that loading an existing atomic tactic (with the same name) will override its value and occurrences.
		*
		* @param j Json input.
		* @throws BadJsonInputException If input's structure is not correct.
		*/
	def loadATFromJson(j: JsonArray) {
		try {
			j.foreach {
				case o:JsonObject =>
					val at = AtomicTactic(o)
					atCollection += at.name -> at
				case o:Json => throw new BadJsonInputException("New atomic tactic : expected json object, got "+o.getClass)
			}
		} catch {
			case e:BadJsonInputException => throw e
		}
	}
}