package tinkerGUI.model

import quanto.util.json._

class Argument(var arg: Array[String]) {
	def toJsonArray : JsonArray = {
		var arg2 : Array[JsonString] = Array()
		arg.foreach { a =>
			arg2 = arg2 :+ JsonString(a)
		}
		return JsonArray(arg2)
	}
}