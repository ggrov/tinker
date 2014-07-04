package tinkerGUI.model

import quanto.util.json._

class AtomicTactic(var name: String, var tactic: String) extends HasArguments {
	def toJson: JsonObject = {
		return JsonObject("name" -> name, "tactic" -> tactic, "args" -> argumentsToJson)
	}
}