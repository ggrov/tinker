package tinkerGUI.controllers

import scala.swing._
import quanto.util.json._

class SubGraphEditController() extends Publisher {
	listenTo(QuantoLibAPI)
	listenTo(Service)
	reactions += {
		case OneVertexSelectedEventAPI(_, typ, value) =>
			typ match {
				case "RT_NST" =>
					val jsonSubGraph = Service.getSpecificJsonFromModel(value, 0)
					jsonSubGraph match {
						case Some(j: JsonObject) =>
							val subGraphView = QuantoLibAPI.getPreviewFromJson(j)
							publish(ShowPreviewEvent(subGraphView))
						case None => 
							println("got no subgraph")
							publish(HidePreviewEvent())
					}
				case "RT_ATM" | "RT_ID" => publish(HidePreviewEvent())
			}
		case NothingSelectedEvent() | NothingSelectedEventAPI() | OneEdgeSelectedEventAPI(_,_,_,_) => publish(HidePreviewEvent())
	}
}