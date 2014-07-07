package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.PSGraph
import quanto.util.json._

object Service extends Publisher {
	val mainCtrl = new MainGUIController()
	val graphEditCtrl = new GraphEditController()
	val eltEditCtrl = new ElementEditController()
	val menuCtrl = new MenuController()
	val editControlsCtrl = new EditControlsController()
	val graphBreadcrumsCtrl = new GraphBreadcrumsController()
	val subGraphEditCtrl = new SubGraphEditController()
	val model = new PSGraph()

	def changeGraphEditMouseState(state: String){
		graphEditCtrl.changeMouseState(state)
	}

	def addSubgraph(eltName: String, isOr: Boolean){
		model.newSubGraph(eltName, isOr)
		QuantoLibAPI.newGraph()
		graphBreadcrumsCtrl.addCrum(eltName)
		publish(NothingSelectedEvent())
	}

	def deleteSubGraph(eltName: String, index: Int){
		model.delSubGraph(eltName, index)
	}

	def changeViewedGraph(gr: String): Boolean = {
		publish(NothingSelectedEvent())
		if(model.changeCurrent(gr, 0)){
			QuantoLibAPI.loadFromJson(model.getCurrentJson())
			return true
		}
		return false
	}

	def getSpecificJsonFromModel(name: String, index: Int) = model.getSpecificJson(name, index)
	def getSizeOfTactic(name: String) = model.getSizeOfTactic(name)
	def setIsOr(name: String, isOr: Boolean) = model.graphTacticSetIsOr(name, isOr)
	def isNestedOr(name: String) = model.isGraphTacticOr(name)

	def editSubGraph(name: String, index: Int){
		if(model.changeCurrent(name, index)){
			publish(NothingSelectedEvent())
			getSpecificJsonFromModel(name, index) match {
				case Some(j: JsonObject) => QuantoLibAPI.loadFromJson(j)
				case None =>
			}
			graphBreadcrumsCtrl.addCrum(name)
		}
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphEventAPI(graph) =>
			model.saveSomeGraph(graph)
	}
}