package tinkerGUI.controllers

import scala.swing._

class GraphBreadcrumsController() extends Publisher {
	def addCrum(crum: String){
		publish(AddCrumEvent(crum))
	}

	def changeGraph(gr: String): Boolean = {
		return Service.editSubGraph(gr, 0)
	}
}