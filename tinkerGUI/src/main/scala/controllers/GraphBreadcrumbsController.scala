package tinkerGUI.controllers

import scala.swing._

class GraphBreadcrumbsController() extends Publisher {
	def addCrumb(crumb: String){
		publish(AddCrumEvent(crumb))
	}

	def changeGraph(gr: String): Boolean = {
		Service.editSubGraph(gr, 0)
	}

	def rebuildParent(p: Array[String]){
		publish(RebuildBreadcrumParentEvent(p))
	}
}