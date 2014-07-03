package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.ButtonClicked
import quanto.util.json._

class SubGraphEditController() extends Publisher {

	private var tacticToShow = ""
	private var indexToShow = 0
	private var tacticTotal = 0

	def getSubgraphView = QuantoLibAPI.getSubgraphPreview

	private def showPreview(){
		val jsonSubGraph = Service.getSpecificJsonFromModel(tacticToShow, indexToShow)
		jsonSubGraph match {
			case Some(j: JsonObject) =>
				QuantoLibAPI.updatePreviewFromJson(j)
				publish(ShowPreviewEvent())
			case None => 
				publish(HidePreviewEvent())
		}
	}

	def showNext() {
		if(indexToShow < tacticTotal-1){
			indexToShow += 1
			showPreview()
		}
	}

	def showPrev() {
		if(indexToShow > 0){
			indexToShow -= 1
			showPreview()
		}
	}

	listenTo(QuantoLibAPI)
	listenTo(Service)
	reactions += {
		case OneVertexSelectedEventAPI(_, typ, value) =>
			typ match {
				case "RT_NST" =>
					tacticToShow = value
					indexToShow = 0
					tacticTotal = Service.getSizeOfTactic(value)
					showPreview()
				case "RT_ATM" | "RT_ID" => publish(HidePreviewEvent())
			}
		case NothingSelectedEvent() | NothingSelectedEventAPI() | OneEdgeSelectedEventAPI(_,_,_,_) => publish(HidePreviewEvent())
	}
}