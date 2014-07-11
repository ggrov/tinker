package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.PSGraph
import quanto.util.json._

object Service extends Publisher {
	val model = new PSGraph()
	val mainCtrl = new MainGUIController()
	val graphEditCtrl = new GraphEditController()
	val eltEditCtrl = new ElementEditController()
	val menuCtrl = new MenuController()
	val editControlsCtrl = new EditControlsController()
	val graphBreadcrumsCtrl = new GraphBreadcrumsController()
	val subGraphEditCtrl = new SubGraphEditController()
	val graphNavCtrl = new GraphNavigationController()
	val hierTreeCtrl = new HierarchyTreeController()

	def changeGraphEditMouseState(state: String){
		graphEditCtrl.changeMouseState(state)
	}

	def addSubgraph(tactic: String, isOr: Boolean){
		model.newSubGraph(tactic, isOr)
		QuantoLibAPI.newGraph()
		graphNavCtrl.viewedGraphChanged(model.isMain, true)
		graphBreadcrumsCtrl.addCrum(tactic)
		publish(NothingSelectedEvent())
	}

	def deleteSubGraph(tactic: String, index: Int){
		model.delSubGraph(tactic, index)
	}

	def deleteTactic(tactic: String){
		model.deleteTactic(tactic)
	}

	def changeViewedGraph(gr: String): Boolean = {
		publish(NothingSelectedEvent())
		if(model.changeCurrent(gr, 0)){
			model.getCurrentJson() match {
				case Some(j: JsonObject) => 
					QuantoLibAPI.loadFromJson(j)
					graphNavCtrl.viewedGraphChanged(model.isMain, false)
					return true
				case None => return false
			}
		}
		return false
	}

	def getSpecificJsonFromModel(tactic: String, index: Int) = model.getSpecificJson(tactic, index)
	def getSizeOfTactic(tactic: String) = model.getSizeOfTactic(tactic)
	def setIsOr(tactic: String, isOr: Boolean) = model.graphTacticSetIsOr(tactic, isOr)
	def isNestedOr(tactic: String) = model.isGraphTacticOr(tactic)

	def getCurrentIndex = model.currentIndex
	def getCurrentSize = model.currentTactic.graphs.size
	def getCurrent = model.currentTactic.name

	def editSubGraph(tactic: String, index: Int){
		if(model.changeCurrent(tactic, index)){
			publish(NothingSelectedEvent())
			getSpecificJsonFromModel(tactic, index) match {
				case Some(j: JsonObject) =>
					QuantoLibAPI.loadFromJson(j)
					graphNavCtrl.viewedGraphChanged(model.isMain, false)
				case None =>
			}
			graphBreadcrumsCtrl.addCrum(tactic)
		}
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphEventAPI(graph) =>
			model.saveSomeGraph(graph)
			graphNavCtrl.disableAdd = false
	}

	def checkNodeName(n: String, sufix: Int, create: Boolean): String = {
		var name = n
		if(sufix != 0) name = (n+"-"+sufix)
		model.lookForTactic(name) match {
			case None =>
				if(create) model.createGraphTactic(name, true)
				name
			case Some(t:Any) =>
				checkNodeName(n, (sufix+1), create)
		}
	}

	def updateTacticName(oldVal: String, newVal: String) = model.updateTacticName(oldVal, newVal)
}