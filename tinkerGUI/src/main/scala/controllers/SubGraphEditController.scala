package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.ButtonClicked
import quanto.util.json._

class SubGraphEditController() extends Publisher {

	private var tacticToShow = ""
	private var indexToShow = 0
	private var tacticTotal = 0

	val indexOnTotal = new Label((indexToShow +1) + " / " + tacticTotal)

	def getSubgraphView = QuantoLibAPI.getSubgraphPreview

	private def showPreview(){
		val jsonSubGraph = Service.getSpecificJsonFromModel(tacticToShow, indexToShow)
		jsonSubGraph match {
			case Some(j: JsonObject) =>
				QuantoLibAPI.updateSubgraphPreviewFromJson(j)
				publish(ShowPreviewEvent())
			case None => 
				publish(HidePreviewEvent())
		}
	}

	def showNext() {
		if(indexToShow < tacticTotal-1){
			indexToShow += 1
			indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
			showPreview()
		}
	}

	def showPrev() {
		if(indexToShow > 0){
			indexToShow -= 1
			indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
			showPreview()
		}
	}

	def edit() {
		Service.editSubGraph(tacticToShow, indexToShow)
	}

	def delete() {
		if(tacticTotal == 1){
			publish(HidePreviewEvent())
			Service.deleteSubGraph(tacticToShow, indexToShow)
		}
		else {
			Service.deleteSubGraph(tacticToShow, indexToShow)
			tacticTotal = tacticTotal - 1
			if(indexToShow != 0) indexToShow = indexToShow - 1
			indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
			showPreview()
		}
	}
	def add(){
		Service.addSubgraph(tacticToShow, Service.isNestedOr(tacticToShow))
	}

	listenTo(QuantoLibAPI)
	listenTo(Service)
	listenTo(Service.eltEditCtrl)
	reactions += {
		case OneVertexSelectedEventAPI(_, typ, value) =>
			typ match {
				case "RT_NST" =>
					val name = ArgumentParser.separateNameFromArgument(value)._1
					tacticToShow = name
					indexToShow = 0
					tacticTotal = Service.getSizeOfTactic(name)
					indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
					showPreview()
				case "RT_ATM" | "RT_ID" => publish(HidePreviewEvent())
			}
		case NothingSelectedEvent() | NothingSelectedEventAPI() | OneEdgeSelectedEventAPI(_,_,_,_) => publish(HidePreviewEvent())
	}
}