package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.PSGraph

object Service extends Publisher {
	val mainCtrl = new MainGUIController()
	val graphEditCtrl = new GraphEditController()
	val eltEditCtrl = new ElementEditController()
	val menuCtrl = new MenuController()
	val editControlsCtrl = new EditControlsController()
	val model = new PSGraph()

	def changeGraphEditMouseState(state: String){
		graphEditCtrl.changeMouseState(state)
	}

	def addSubgraph(eltName: String){
		if (model.currentGraph == eltName){
			model.currentIndex += 1
		}
		else {
			model.currentGraph = eltName
		}
		QuantoLibAPI.newGraph()
		publish(NothingSelectedEvent())
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphEventAPI(graph) =>
			model.saveSomeGraph(graph)
	}
}