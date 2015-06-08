package tinkerGUI.model

import quanto.util.json._
import scala.collection.mutable.ArrayBuffer

/** Exception class for not finding a subgraph in the graph tactic
	*
	* @param msg Custom message.
	*/
case class SubgraphNotFoundException(msg:String) extends Exception(msg)

/** A graph tactic in the psgraph.
	*
	* A graph tactic is identified by a unique name in the gui and in the core of tinker.
	* It also has a string defining its branching type, e.g. OR and ORELSE.
	*
	* @param name Id of the graph tactic.
	* @param branchType Branch type of the graph tactic.
	*/
class GraphTactic(name: String, var branchType: String) extends Tactic(name) {

	/** Collection of subgraphs. */
	var graphs : ArrayBuffer[JsonObject] = ArrayBuffer()

	/** List of child graph tactics */
	var children:ArrayBuffer[GraphTactic] = ArrayBuffer()

	/** Method to add/replace a subgraph in the graph tactic.
		*
		* If the specified index is unused in [[graphs]] the subgraph is simply append at the end.
		*
		* @param j Json object representing the graph.
		* @param index Position in which to add the subgraph.
		*/
	def addSubgraph(j: JsonObject, index: Int){
		if(graphs.isDefinedAt(index)){
			graphs(index) = j
		}
		else{
			graphs = graphs :+ j
		}
	}

	/** Method to remove a subgraph from the graph tactic.
		*
		* @param index Position of the subgraph to remove.
		*/
	def delSubgraph(index: Int) {
		graphs -= graphs(index)
	}

	/** Method to get the Json object of a subgraph.
		*
		* @param index Position of the desired subgraph.
		* @throws tinkerGUI.model.SubgraphNotFoundException If the graph tactic does not have a subgraph at this index.
		* @return Json object of the subgraph.
		*/
	@throws (classOf[SubgraphNotFoundException])
	def getSubgraph(index: Int):JsonObject = {
		if (graphs.isDefinedAt(index)) graphs(index)
		else throw new SubgraphNotFoundException("No subgraph for graph tactic "+name+" at index "+index)
	}

	/** Method to get the size of the graph tactic, i.e. its number of subgraph.
		*
		* @return Number of subgraph of the graph tactic.
		*/
	def getSize: Int = {
		graphs.size
	}

	/** Method to generate a Json object of the graph tactic.
		*
		* @return Json object of the graph tactic.
		*/
	def toJson : JsonObject = {
		JsonObject("name" -> name, "branchType" -> branchType, "graphs" -> JsonArray(graphs), "args" -> argumentsToJson, "occurrences"->occurrencesToJson)
	}

	/** Method to add a child to the graph tactic.
		*
		* @param t Child graph tactic.
		*/
	def addChild(t:GraphTactic) {
		children = children :+ t
	}

	/** Method to remove a child from the graph tactic.
		*
		* @param t Child graph tactic.
		*/
	def removeChild(t:GraphTactic) {
		children -= t
	}
}