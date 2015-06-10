package tinkerGUI.model

import quanto.util.json._
import scala.collection.mutable.ArrayBuffer

/** Tactic behaviour for having occurrences
	*
	* An occurrence represents the fact that a node on a graph is linked with a tactic. It is a tuple with
	* one string representing the graph in which the occurrence is, one integer for the graph id,
	* and one string being the node id.
	*/
trait HasOccurrences {
	
	/** Occurrence array of a tactic. */
	var occurrences: ArrayBuffer[(String, Int, String)] = ArrayBuffer()

	/** Method to add an occurrence to a tactic.
		*
		* @param o Occurrence, a graph/index/node tuple.
		*/
	def addOccurrence(o: (String, Int, String)){
		occurrences = occurrences :+ o
	}

	/** Method to remove an occurrence from a tactic.
		*
		* @param o Occurrence to be removed.
		*/
	def removeOccurrence(o: (String, Int, String)) {
		occurrences -= o
	}

	/** Method to remove a set of occurrences from a tactic, depending on the graph id.
		*
		* @param id Graph id.
		*/
	def removeOccurrence(id:String){
		var occToRemove:ArrayBuffer[(String,Int,String)] = ArrayBuffer()
		for(o<-occurrences if o._1 == id) {
			occToRemove += o
		}
		for(o<-occToRemove) occurrences -= o
	}

	/** Method to change a set of occurrences from a tactic, depending on the graph id.
		*
		* @param id Initial gui id of the graph.
		* @param newId Finale gui id of the graph.
		*/
	def changeOccurrences(id:String, newId:String){
		var occToRemove:ArrayBuffer[(String,Int,String)] = ArrayBuffer()
		var occToAdd:ArrayBuffer[(String,Int,String)] = ArrayBuffer()
		for(o<-occurrences if o._1 == id) {
			occToAdd += Tuple3(newId, o._2, o._3)
			occToRemove += o
		}
		for(o<-occToRemove) occurrences -= o
		for(o<-occToAdd) occurrences += o

	}

	/** Method to generate a Json array of the occurrences of a tactic.
		* 
		* @return Json array of the occurrences.
		*/
	def occurrencesToJson(): JsonArray = {
		var arr: ArrayBuffer[JsonArray] = ArrayBuffer()
		occurrences.foreach { occ =>
			arr = arr :+ JsonArray(Array(JsonString(occ._1),JsonInt(occ._2),JsonString(occ._3)))
		}
		JsonArray(arr)
	}

	/** Method to replace the occurrence list with a new list.
		*
		* @param newOccs New occurrence list.
		*/
	def updateOccurrences(newOccs:ArrayBuffer[(String, Int, String)]) {
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
	def getOccurrencesInGraph(graph:String, index:Int):Array[String] = {
		var arr:Array[String] = Array()
		occurrences.foreach{ o =>
			if(o._1 == graph && o._2 == index) arr = arr :+ o._3
		}
		arr
	}
}