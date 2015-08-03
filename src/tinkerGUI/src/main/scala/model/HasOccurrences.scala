package tinkerGUI.model

import quanto.util.json._

/** Tactic behaviour for having occurrences
	*
	* An occurrence represents the fact that a node on a graph is linked with a tactic. It is a tuple with
	* one string representing the graph in which the occurrence is, one integer for the subgraph index,
	* and one string being the node id.
	*/
trait HasOccurrences {
	
	/** Occurrence array of a tactic. */
	var occurrences: Set[(String, Int, String)] = Set()

	/** Method to add an occurrence to a tactic.
		*
		* @param o Occurrence, a graph/index/node tuple.
		*/
	def addOccurrence(o: (String, Int, String)){
		occurrences += o
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
		var occToRemove:Set[(String,Int,String)] = Set()
		for(o<-occurrences if o._1 == id) {
			occToRemove += o
		}
		for(o<-occToRemove) occurrences -= o
	}

	/** Method to change a set of occurrences from a tactic, depending on the graph id.
		*
		* @param name Initial name of the graph.
		* @param newName Finale name of the graph.
		*/
	def changeOccurrences(name:String, newName:String){
		var occToRemove:Set[(String,Int,String)] = Set()
		var occToAdd:Set[(String,Int,String)] = Set()
		for(o<-occurrences if o._1 == name) {
			occToAdd += Tuple3(newName, o._2, o._3)
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
		occurrences.foldLeft(JsonArray()){case (a,o) => a :+ JsonArray(JsonString(o._1),JsonInt(o._2),JsonString(o._3))}
	}

	/** Method to replace the occurrence list with a new list.
		*
		* @param newOccs New occurrence list.
		*/
	def updateOccurrences(newOccs:Set[(String, Int, String)]) {
		occurrences = newOccs
	}

	/** Method to completely erase the occurrence list.
		*
		*/
	def eraseOccurrences() {
		occurrences = Set()
	}

	/** Method to get the list of node ids in a graph where the tactic has an occurrence.
		*
		* @param graph Graph id.
		* @return List of node ids.
		*/
	def getOccurrencesInGraph(graph:String, index:Int):Set[String] = {
		occurrences.foldLeft(Set[String]()){(s,t)=>if(t._1==graph && t._2==index) s+t._3 else s}
	}
}