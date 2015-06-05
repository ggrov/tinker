package tinkerGUI.model

import quanto.util.json.{JsonObject, JsonArray}
import tinkerGUI.controllers.TinkerDialog

/** Exception class for not finding a tactic in the collection
	*
	* @param msg Custom message
	*/
case class AtomicTacticNotFoundException(msg:String) extends Exception(msg)

/** A manager for the atomic tactics of a psgraph.
	*
	* Will register the atomic tactics in a map and manage their creation and update.
	* Also provides accessors for the atomic tactics values.
	*/
trait ATManager {

	/** The collection of atomic tactics.*/
	protected var atCollection:Map[String,AtomicTactic] = Map()
	
	/** Method creating an atomic tactic if the id is available.
	 *
	 * @param id Gui id/name of the atomic tactic.
	 * @param tactic Core id of the atomic tactic.
	 * @param args List of arguments for the atomic tactic.
	 * @return Boolean notifying of successful creation or not (should be used to handle duplication).
	 */
	def createAT(id:String,tactic:String,args:Array[Array[String]]): Boolean = {
		if(atCollection contains id){
			false
		} else {
			val t: AtomicTactic = new AtomicTactic(id, tactic)
			t.replaceArguments(args)
			atCollection += id -> t
			true
		}
	}

	/** Method to update an atomic tactic, only if it has less than two occurrences.
	 *
	 * Displays an error dialog if the atomic tactic is not found.
	 * @param id Gui id before change.
	 * @param newId New gui id value.
	 * @param newTactic New core id value.
	 * @param newArgs New list of arguments.
	 * @return Boolean notifying of successful change or not (should be used to handle duplication).
	 * @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic is not in the collection.
	 */
	@throws (classOf[AtomicTacticNotFoundException])
	def updateAT(id:String, newId:String, newTactic:String, newArgs:Array[Array[String]]):Boolean = {
		atCollection get id match {
			case Some(t:AtomicTactic) =>
				if(t.occurrences.size < 2){
					t.name = newId
					t.tactic = newTactic
					t.args = newArgs
					if(id != newId){
						atCollection += (newId -> t)
						atCollection -= id
					}
					true
				} else {
					false
				}
			case _ =>
				throw new AtomicTacticNotFoundException("Atomic tactic "+id+" not found")
		}
	}

	/** Method to force the update of an atomic tactic, i.e. update no matter what is the number of occurrences.
	 *
	 * Displays an error dialog if the atomic tactic is not found.
	 * @param id Gui id before change.
	 * @param newId New gui id value.
	 * @param newTactic New core id value.
	 * @param newArgs New list of arguments.
	 * @param graph Current graph id.
	 * @return List of node id linked with this atomic tactic in the current graph (should be used to update the graph view).
	 * @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic is not in the collection.
	 */
	@throws (classOf[AtomicTacticNotFoundException])
	def updateForceAT(id:String, newId:String, newTactic:String, newArgs:Array[Array[String]], graph:String):Array[String] = {
		atCollection get id match {
			case Some(t:AtomicTactic) =>
				t.name = newId
				t.tactic = newTactic
				t.args = newArgs
				if (id != newId) {
					atCollection += (newId -> t)
					atCollection -= id
				}
				t.getOccurrencesInGraph(graph)
			case _ =>
				throw new AtomicTacticNotFoundException("Atomic tactic "+id+" not found")
		}
	}

	/** Method deleting an atomic tactic from the tactic collection.
		*
		* @param id Gui id of the atomic tactic to remove.
		*/
	def deleteAT(id:String) {
		atCollection -= id
	}

	/** Method to get the full name (name + arguments) of an atomic tactic.
		*
		* Displays an error dialog if the atomic tactic is not found.
		* @param id Gui id of the atomic tactic.
		* @return Full name or "Not Found" in case the atomic tactic could not be found.
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	@throws (classOf[AtomicTacticNotFoundException])
	def getATFullName(id:String):String = {
		atCollection get id match {
			case Some(t:AtomicTactic) =>
				t.name+"("+t.argumentsToString()+")"
			case None =>
				throw new AtomicTacticNotFoundException("Atomic tactic "+id+" not found")
		}
	}

	/** Method to get the core id of an atomic tactic.
	 *
	 * Displays an error dialog if the atomic tactic is not found.
	 * @param id Gui id of the atomic tactic.
	 * @return Core id or "Not Found" in case the atomic tactic could not be found.
	 * @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic is not in the collection.
	 */
	@throws (classOf[AtomicTacticNotFoundException])
	def getATCoreId(id:String):String = {
		atCollection get id match {
			case Some(t:AtomicTactic) =>
				t.tactic
			case _ =>
				throw new AtomicTacticNotFoundException("Atomic tactic "+id+" not found")
		}
	}

	/** Method to generate a Json array of the atomic tactic collection
		*
		* @return Json array of the collection of atomic tactics.
		*/
	def toJsonAT:JsonArray = {
		var arr:Array[JsonObject] = Array()
		atCollection.foreach{ case(k,v) =>
			arr = arr :+ v.toJson
		}
		JsonArray(arr)
	}

	/** Method to add an occurrence in an atomic tactic.
		*
		* Displays an error dialog if the atomic tactic is not found.
		* @param id Gui id of the atomic tactic.
		* @param graph Graph in which the occurrence is.
		* @param node Node id of the occurrence.
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	@throws (classOf[AtomicTacticNotFoundException])
	def addATOccurrence(id:String, graph:String, node:String) {
		atCollection get id match {
			case Some(t:AtomicTactic) =>
				t.addOccurrence(Tuple2(graph,node))
			case None =>
				throw new AtomicTacticNotFoundException("Atomic tactic "+id+" not found")
		}
	}

	/** Method to remove an occurrence from an atomic tactic.
		*
		* Displays an error dialog if the atomic tactic is not found.
		* @param id Gui id of the atomic tactic.
		* @param graph Graph in which the occurrence was.
		* @param node Node id of the occurrence to remove.
		* @return Boolean notifying if it was the last occurrence of the atomic tactic.
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		*/
	@throws (classOf[AtomicTacticNotFoundException])
	def removeATOccurrence(id:String, graph:String, node:String):Boolean = {
		atCollection get id match {
			case Some(t:AtomicTactic) =>
				t.removeOccurrence(Tuple2(graph,node))
				t.occurrences.isEmpty
			case None =>
				throw new AtomicTacticNotFoundException("Atomic tactic "+id+" not found")
		}
	}
}