package tinkerGUI.model

import quanto.util.json._

class GraphTactic(var name: String, var isOr: Boolean) extends HasArguments {
	var graphs : Array[JsonObject] = Array()

	def addJsonToGraphs(j: JsonObject, index: Int){
		if(graphs.isDefinedAt(index)){
			graphs(index) = j
		}
		else{
			graphs = graphs :+ j
		}
	}

	def getGraphJson(index: Int): JsonObject = {
		return graphs(index)
	}

	def getSize: Int = {
		return graphs.size 
	}

	def toJson : JsonObject = {
		return JsonObject("name" -> name, "isOr" -> isOr, "graphs" -> JsonArray(graphs), "args" -> argumentsToJson)
	}
}