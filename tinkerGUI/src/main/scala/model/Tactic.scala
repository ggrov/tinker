package tinkerGUI.model

import quanto.util.json.JsonObject

/** A tactic in the psgraph.
  *
  * There are two types of tactics : [[AtomicTactic]]s and [[GraphTactic]]s each of them have their own sub-classes.
  *
  * A tactic always have an GUI id (name) used inside the gui model and also on the graph
  * (printed on the nodes linked with this tactic).
  *
  * A tactic has also arguments (used for the evaluation, and also printed on the graph's nodes)
  * and occurrences (used to know which graph's node is linked with this tactic).
  *
  * @param name Name / id of the tactic.
  */
abstract class Tactic(var name:String) extends HasArguments with HasOccurrences{

  /** Method printing the Json representation of a tactic */
  def toJson:JsonObject
}
