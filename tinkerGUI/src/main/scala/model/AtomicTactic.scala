package tinkerGUI.model

import quanto.util.json._

/** An atomic tactic in the psgraph.
	*
	* An atomic tactic has two ids : a core id (tactic) and a gui id (name).
	* The core id is used by the core of tinker in order run the evaluation with the prover.
	* The gui id is used by this gui to identified tactics in the model and is also the name of the tactics printed on the graph's nodes.
	*
	* @param name Gui id of the atomic tactic.
	* @param tactic Core id of the atomic tactic.
	*/
class AtomicTactic(var name: String, var tactic: String) extends HasArguments with HasOccurrences {

	/** Method to generate a Json object of the atomic tactic.
		*
		* @return Json object of the atomic tactic.
		*/
	def toJson: JsonObject = JsonObject("name" -> name, "tactic" -> tactic, "args" -> argumentsToJson)
}