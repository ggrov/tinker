package tinkerGUI.controllers

import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{GraphTacticNotFoundException, SubgraphNotFoundException}

import scala.swing._
import scala.swing.event.ButtonClicked
import quanto.util.json._
import tinkerGUI.utils.ArgumentParser

class GraphInspectorController(model: PSGraph) extends Publisher {

	private var tacticToShow = ""
	private var indexToShow = 0
	private var tacticTotal = 0

	val indexOnTotal = new Label((indexToShow +1) + " / " + tacticTotal)

	var gtList = model.gtCollection.keys.toList

	def getSubgraphView = QuantoLibAPI.getSubgraphPreview

	def inspect(name:String){
		if(name == "Select a tactic"){
			publish(HidePreviewEvent())
		} else {
			try{
				tacticToShow = name
				indexToShow = 0
				tacticTotal = model.getSizeGT(name)
				indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
				showPreview()
			} catch {
				case e:GraphTacticNotFoundException => publish(HidePreviewEvent())
			}
		}
	}

	private def showPreview(){
		try{
			QuantoLibAPI.updateSubgraphPreviewFromJson(model.getSubgraphGT(tacticToShow, indexToShow))
			publish(UpdateSelectedTacticToInspectEvent(tacticToShow))
			publish(ShowPreviewEvent(true))
		} catch {
			case e:GraphTacticNotFoundException => publish(HidePreviewEvent())
			case e:SubgraphNotFoundException =>
				indexOnTotal.text = indexToShow + " / " + tacticTotal
				publish(UpdateSelectedTacticToInspectEvent(tacticToShow))
				publish(ShowPreviewEvent(false))
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
		Service.addSubgraph(tacticToShow)
	}

	listenTo(Service)
	reactions += {
		/*case OneVertexSelectedEventAPI(_, typ, value) =>
			typ match {
				case "T_Graph" =>
					val name = ArgumentParser.separateNameFromArgument(value)._1
					tacticToShow = name
					indexToShow = 0
					tacticTotal = model.getSizeGT(name)
					indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
					showPreview()
				case "G" | "G_Break" | "T_Atomic" | "T_Identity" => publish(HidePreviewEvent())
			}
		case NothingSelectedEvent() | NothingSelectedEventAPI() | OneEdgeSelectedEventAPI(_,_,_,_) => publish(HidePreviewEvent())*/
		case GraphTacticListEvent() =>
			gtList = model.gtCollection.keys.toList
			publish(UpdateGTListEvent())
	}
}