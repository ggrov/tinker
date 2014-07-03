package tinkerGUI.model

import quanto.util.json._

class GraphTactic(var name: String, var isOr: Boolean) extends HasArguments {
	var graphs : Array[JsonObject] = Array()
}