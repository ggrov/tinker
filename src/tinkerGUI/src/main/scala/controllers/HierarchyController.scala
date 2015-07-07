package tinkerGUI.controllers

import tinkerGUI.controllers.events.{CurrentGraphChangedEvent, RedrawHierarchyTreeEvent, GraphTacticListEvent}
import tinkerGUI.model.PSGraph

import scala.swing.Publisher

/** Controller managing the hierarchy in a psgraph.
	*
	* @param model Psgraph model.
	*/
class HierarchyController(model:PSGraph) extends Publisher {

	/** Map of the graph tactics' parents. Only the shortest path is stored.*/
	var elementParents : Map[String,Array[String]] = updateElementParents()

	/** Method reconstructing the graph tactics' parents list.
		*
		* @return Map of the graph tactics' parents.
		*/
	def updateElementParents():Map[String,Array[String]] = {
		//def adjust[A,B](m: Map[A,B], k: A)(f: B => B) = m.updated(k, f(m(k)))
		def rec(t:String,p:Array[String], map:Map[String,Array[String]]):Map[String,Array[String]] = {
			var m = map
			if(!m.contains(t)) m += (t->p)
			else if(m(t).size > p.size) m = m.updated(t, p)
			val children = if(t=="main") model.childrenMain else model.getChildrenGT(t)
			children.foreach{ c =>
				m = rec(c.name,p:+t, m)
			}
			m
		}
		rec("main",Array(),Map())
	}

	/** Getter for the list of children of a tactic.
		*
		* @param t Tactic id.
		* @return Children of the tactic.
		*/
	def getGTChildren(t:String) = if(t=="main") model.childrenMain else model.getChildrenGT(t)

	listenTo(Service.editCtrl)
	listenTo(Service.documentCtrl)
	listenTo(Service.evalCtrl)
	listenTo(Service.libraryTreeCtrl)
	reactions += {
		case GraphTacticListEvent() =>
			elementParents = updateElementParents()
			publish(RedrawHierarchyTreeEvent())
		case CurrentGraphChangedEvent(_,_) =>
			publish(RedrawHierarchyTreeEvent())
	}
}
