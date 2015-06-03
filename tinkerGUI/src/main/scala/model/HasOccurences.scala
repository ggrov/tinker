package tinkerGUI.model

import quanto.util.json._
import scala.collection.mutable.ArrayBuffer

trait HasOccurrences {
	var occs: ArrayBuffer[Tuple2[String,String]] = ArrayBuffer()

	def addOccurrence(o: Tuple2[String,String]){
		occs = occs :+ o
	}

	def removeOccurrence(o: Tuple2[String,String]) {
		occs -= o
	}

	def occurencesToJson(): JsonArray = {
		var arr1: ArrayBuffer[JsonString] = ArrayBuffer()
		var arr2: ArrayBuffer[JsonArray] = ArrayBuffer()
		occs.foreach { occ =>
			arr1 = arr1 :+ JsonString(occ._1)
			arr1 = arr1 :+ JsonString(occ._2)
			arr2 = arr2 :+ JsonArray(arr1)
			arr1 = ArrayBuffer()
		}
		return JsonArray(arr2)
	}

	def updateOccurrences(newOccs:ArrayBuffer[Tuple2[String,String]]) {
		occs = newOccs
	}

	def eraseOccurrences() {
		occs = ArrayBuffer()
	}

	def getOccurrencesInGraph(graph:String):Array[String] = {
		var arr:Array[String] = Array()
		occs.foreach{ o =>
			if(o._1 == graph) arr = arr :+ o._2
		}
		arr
	}
}