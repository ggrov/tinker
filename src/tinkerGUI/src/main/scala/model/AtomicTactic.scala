package tinkerGUI.model

import quanto.util.json._
import tinkerGUI.model.exceptions.BadJsonInputException

/** An atomic tactic in the psgraph.
	*
	* An atomic tactic has two fields : a tactic name and a tactic value.
	* The tactic name identifies the tactic.
	* The tactic value is a ML code defining the tactic for the core, an empty value means it is assumed that the core already has a definition.
	*
	* @param name Tactic name.
	* @param tactic Tactic value.
	*/
class AtomicTactic(var name: String, var tactic: String) extends HasOccurrences {

	/** Method to generate a Json object of the atomic tactic.
		*
		* @return Json object of the atomic tactic.
		*/
	def toJson: JsonObject = JsonObject("name" -> name, "tactic" -> tactic)
}

/** Companion object for the AtomicTactic class.
	*
	* Provides multiple constructors for this class.
	*/
object AtomicTactic {
	/** Creates a new atomic tactic with two input strings.
		*
		* @param name Tactic name.
		* @param tactic Tactic value.
		* @return New instance of an atomic tactic.
		*/
	def apply(name:String,tactic:String) = {
		new AtomicTactic(name,tactic)
	}

	/** Creates a new atomic tactic with one Json input.
		*
		* @param j Json object representing the tactic.
		* @return New instance of an atomic tactic.
		* @throws BadJsonInputException if the input's structure is not correct.
		*/
	def apply(j:JsonObject) = {
		j ? "name" match {
			case n:JsonString =>
				j ? "tactic" match {
					case t: JsonString =>
						new AtomicTactic(n.stringValue, t.stringValue)
					case t: Json => throw new BadJsonInputException("New atomic tactic : expected JsonString for tactic field, got " + t.getClass)
				}
			case n:Json => throw new BadJsonInputException("New atomic tactic : expected JsonString for name field, got " + n.getClass)
		}
	}
}