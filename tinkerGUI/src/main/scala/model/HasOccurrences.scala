package tinkerGUI.model

import quanto.util.json._
import scala.collection.mutable.ArrayBuffer

/** Tactic behaviour for having occurrences
	*
	* An occurrence represents the fact that a node on a graph is linked with a tactic. It is a pair of string,
	* one representing the graph in which the occurrence is, the second one being the node id.
	*/
trait HasOccurrences {
	
	/** Occurrence array of a tactic. */
	var occurrences: ArrayBuffer[(String, String)] = ArrayBuffer()

	/** Method to add an occurrence to a tactic.
		*
		* @param o Occurrence, a graph/node pair.
		*/
	def addOccurrence(o: (String, String)){
		occurrences = occurrences :+ o
	}

	/** Method to remove an occurrence from a tactic.
		*
		* @param o Occurrence to be removed.
		*/
	def removeOccurrence(o: (String, String)) {
		occurrences -= o
	}

	/** Method to generate a Json array of the occurrences of a tactic.
		* 
		* @return Json array of the occurrences.
		*/
	def occurrencesToJson(): JsonArray = {
		var arr: ArrayBuffer[JsonArray] = ArrayBuffer()
		occurrences.foreach { occ =>
			arr = arr :+ JsonArray(Array(JsonString(occ._1),JsonString(occ._2)))
		}
		JsonArray(arr)
	}

	/** Method to replace the occurrence list with a new list.
		*
		* @param newOccs New occurrence list.
		*/
	def updateOccurrences(newOccs:ArrayBuffer[(String, String)]) {
		occurrences = newOccs
	}

	/** Method to completly erase the occurrence list.
		*
		*/
	def eraseOccurrences() {
		occurrences = ArrayBuffer()
	}

	/** Method to get the list of node ids in a graph where the tactic has an occurrence.
		*
		* @param graph Graph id.
		* @return List of node ids.
		*/
	def getOccurrencesInGraph(graph:String):Array[String] = {
		var arr:Array[String] = Array()
		occurrences.foreach{ o =>
			if(o._1 == graph) arr = arr :+ o._2
		}
		arr
	}
}