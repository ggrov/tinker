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

	def changeGraphEditMouseState(state: String){
		graphEditCtrl.changeMouseState(state)
	}

	def addSubgraph(eltName: String, isOr: Boolean){
		model.newSubGraph(eltName, isOr)
		QuantoLibAPI.newGraph()
		graphNavCtrl.viewedGraphChanged(model.isMain, true)
		graphBreadcrumsCtrl.addCrum(eltName)
		publish(NothingSelectedEvent())
	}

	def deleteSubGraph(eltName: String, index: Int){
		model.delSubGraph(eltName, index)
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

	def getSpecificJsonFromModel(name: String, index: Int) = model.getSpecificJson(name, index)
	def getSizeOfTactic(name: String) = model.getSizeOfTactic(name)
	def setIsOr(name: String, isOr: Boolean) = model.graphTacticSetIsOr(name, isOr)
	def isNestedOr(name: String) = model.isGraphTacticOr(name)

	def getCurrentIndex = model.currentIndex
	def getCurrentSize = model.currentGraph.graphs.size
	def getCurrent = model.currentGraph.name

	def editSubGraph(name: String, index: Int){
		if(model.changeCurrent(name, index)){
			publish(NothingSelectedEvent())
			getSpecificJsonFromModel(name, index) match {
				case Some(j: JsonObject) =>
					QuantoLibAPI.loadFromJson(j)
					graphNavCtrl.viewedGraphChanged(model.isMain, false)
				case None =>
			}
			graphBreadcrumsCtrl.addCrum(name)
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