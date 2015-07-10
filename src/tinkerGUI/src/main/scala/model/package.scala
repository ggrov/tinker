package tinkerGUI

/** ==TinkerGUI model package==
	* Provides classes dealing with the psgraph model used to run Tinker's interface.
  *
	* ==Overview==
	* The main class to use is [[tinkerGUI.model.PSGraph]] :
	* {{{
	*   import tinkerGUI.model.PSGraph
	*   ...
	*   val myPSGraphModel = new PSGraph()
	* }}}
	*
	* Using this variable allows to read and write the model, the purpose being to generate a Json object of this psgraph model that can be used by provers :
	* {{{
	*   myPSGraphModel.updateJsonPSGraph()
	*   val json = myPSGraphModel.jsonPSGraph
	* }}}
	*
	* Manipulating the model may raise exceptions, see [[tinkerGUI.model.exceptions]], although Json exceptions are handled in the [[quanto.util.json]] package.
	*
	* A psgraph model in a Json format should contain the following fields :
	*  - '''main graph''' : a Json object containing the root graph, it contains the following :
	*   - a set of '''edges''', each of them having :
	*    - an id, a string, typically ''e0'', ''e1'', ... ;
	*    - a goal type, a string holding a predicate a goal has to fulfill to pass on this edge ;
	*    - a source and a target, strings referring to a node id ;
	*   - a set of '''boundary nodes''', each of them having :
	*    - an id, a string, typically ''b0'', ''b1'', ... ;
	*    - coordinates, a pair of double ;
	*   - a set of '''tactic nodes''', each of them having :
	*    - an id, a string, typically ''v0'', ''v1'', ... ;
	*    - a type, a string referring to the type of node, typically ''T_Identity'', ''T_Atomic'' or ''T_Graph'' ;
	*    - coordinates, a pair of double ;
	*    - Atomic nodes have a field referring to an atomic tactic in the model and a field for their label ;
	*    - Graph nodes have a field referring to a graph tactic in the model and a field for their label ;
	*  - '''current tactic''' : a stack showing which tactic in the hierarchy is currently used, the stack contains the said tactic and its parents in the hierarchy ;
	*  - '''current index''' : an integer indicating which subgraph in the current tactic is used ;
	*  - '''graph tactics''' : a set of all the graph tactics used by this psgraph, each of them contain the following fields :
	*   - '''name''' : a string identifying the tactic ;
	*   - '''branch type''' : a string identifying the type of branching this tactic uses, typically ''OR'' or ''ORELSE'' ;
	*   - '''arguments''' : a set containing the arguments of this tactic, each argument is a set of string ;
	*   - '''graphs''' : a set of subgraphs this tactic contains, their format is the same as the root graph ;
	*  - '''atomic tactics''' : a set of all the atomic tactics used by this psgraph, each of them contain the following fields :
	*   - '''name''' : same as a graph tactic's name field ;
	*   - '''arguments''' : same as a graph tactic's arguments field ;
	*   - '''tactic''' : a string identifying the atomic tactic in the prover ;
	*  - '''occurrences''' : a set of occurrences per tactic, referring to their uses in the model, an occurrence is a triple with a graph tactic name (or ''main''
	*  if it is in the root graph), a subgraph index, and a node id, occurrences are subdivided into atomic tactics occurrences and graph tactics occurrences.
  */
package object model {

}
