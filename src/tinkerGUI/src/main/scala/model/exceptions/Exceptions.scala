package tinkerGUI.model.exceptions

/** Exception class for not finding an atomic tactic in the tactic collection.
	*
	* @param msg Custom message.
	*/
class AtomicTacticNotFoundException(val msg:String) extends Exception(msg)

/** Exception class for not finding an graph tactic in the tactic collection.
	*
	* @param msg Custom message.
	*/
class GraphTacticNotFoundException(val msg:String) extends Exception(msg)

/** Exception class for not finding a subgraph in a graph tactic.
	*
	* @param msg Custom message.
	*/
class SubgraphNotFoundException(val msg:String) extends Exception(msg)