package tinkerGUI.controllers

import scala.swing._

class GraphBreadcrumbsController() extends Publisher {
	def addCrumb(crumb: String, parents:Option[Array[String]] = None){
		parents match {
			case Some(p:Array[String]) =>
				publish(RebuildBreadcrumbParentEvent(p.reverse))
			case None =>  // do nothing
		}
		publish(AddCrumbEvent(crumb))
	}
}