package tinkerGUI.model

import quanto.util.json._

trait HasOccurences {
	var occs: Array[Array[String]] = Array()

	def addOccurence(o: Array[String]){
		occs = occs :+ o
	}

	def occurencesToJson(): JsonArray = {
		var arr1: Array[JsonString] = Array()
		var arr2: Array[JsonArray] = Array()
		occs.foreach { occ =>
			occ.foreach { s =>
				arr1 = arr1 :+ JsonString(s)
			}
			arr2 = arr2 :+ JsonArray(arr1)
			arr1 = Array()
		}
		return JsonArray(arr2)
	}

	def updateOccurences(newOccs:Array[Array[String]]) {
		occs = newOccs
	}

	def removeOccurence(o: Array[String]) {

	}

	def eraseOccurences() {
		occs = Array()
	}
}