package tinkerGUI.model.exceptions

/** Generic exception class for the model.
	*
	* @param msg Custom message.
	*/
abstract class PSGraphModelException(val msg:String) extends Exception(msg)

/** Exception class for reserved name in model.
	*
	* @param name Value reserved to specific object in model.
	*/
class ReservedNameException(val name:String) extends PSGraphModelException(name+" is a reserved value.")

/** Exception class for not finding an atomic tactic in the tactic collection.
	*
	* @param name Tactic name.
	*/
class AtomicTacticNotFoundException(val name:String) extends PSGraphModelException("Atomic tactic "+name+" was not found.")

/** Exception class for not finding an graph tactic in the tactic collection.
	*
	* @param name Tactic name.
	*/
class GraphTacticNotFoundException(val name:String) extends PSGraphModelException("Graph tactic "+name+" was not found.")

/** Exception class for not finding a subgraph in a graph tactic.
	*
	* @param name Graph name.
	* @param index Graph index.
	*/
class SubgraphNotFoundException(val name:String, val index:Int) extends PSGraphModelException("No subgraph found at index "+index+" of tactic "+name+".")