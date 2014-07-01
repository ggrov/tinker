package tinkerGUI.controllers

import scala.swing._

class GraphBreadcrumsController() extends Publisher {
	def addCrum(crum: String){
		publish(AddCrumEvent(crum))
	}

	def changeGraph(gr: String){
		Service.changeViewedGraph(gr)
		// publish(DelCrumFromEvent(gr))
	}
}