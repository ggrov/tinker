package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.PSGraph

class MainGUIController() extends Publisher {
	val model = new PSGraph()
	def getTitle = QuantoLibAPI.getTitle
	var prevTitle = QuantoLibAPI.getTitle
	listenTo(QuantoLibAPI)
	reactions += {
		case DocumentTitleEventAPI(title) =>
			if(prevTitle != title){
				publish(DocumentTitleEvent(title))
			}
		case GraphEventAPI(graph) =>
			model.saveSomeGraph(graph)
	}
}