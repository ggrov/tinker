package tinkerGUI.controllers

import scala.swing._

class SubGraphEditController() extends Publisher {
	listenTo(Service.eltEditCtrl)
	reactions += {
		case OneVertexSelectedEvent(nam, typ, value) =>
			typ match {
				case "Nested" =>
					publish(ShowPreviewEvent(QuantoLibAPI.getPreviewFromJson(Service.getSpecificJsonFromModel(value, 0))))
				case _ =>
			}
	}
}