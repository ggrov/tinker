package tinkerGUI.controllers

import tinkerGUI.controllers.events.GraphTacticListEvent
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{GraphTacticNotFoundException, SubgraphNotFoundException}

import scala.swing._

class InspectorController(model: PSGraph) extends Publisher {

	private var tacticToShow = ""
	private var indexToShow = 0
	private var tacticTotal = 0

	val indexOnTotal = new Label((indexToShow +1) + " / " + tacticTotal)

	var gtList = model.gtCollection.keys.toList :+ "main"

	def inspect(name:String){
		if(name == "Select a tactic"){
			publish(HidePreviewEvent())
		} else {
			try{
				tacticToShow = name
				indexToShow = 0
				tacticTotal = if(name=="main") 1 else model.getSizeGT(name)
				indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
				publish(UpdateSelectedTacticToInspectEvent(tacticToShow))
				showPreview()
			} catch {
				case e:GraphTacticNotFoundException => publish(HidePreviewEvent())
			}
		}
	}

	private def showPreview(){
		try{
			if(tacticToShow == "main"){
				QuantoLibAPI.updateSubgraphPreviewFromJson((model.mainGraph))
				publish(DisableNavigationEvent(Array("next","prev","del","add")))
			} else{
				QuantoLibAPI.updateSubgraphPreviewFromJson(model.getSubgraphGT(tacticToShow, indexToShow))
				publish(DisableNavigationEvent(Array()))
			}
			publish(ShowPreviewEvent(true))
		} catch {
			case e:GraphTacticNotFoundException => publish(HidePreviewEvent())
			case e:SubgraphNotFoundException =>
				indexOnTotal.text = indexToShow + " / " + tacticTotal
				publish(DisableNavigationEvent(Array("next","prev","del","edit")))
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
		val parents = Service.hierarchyCtrl.elementParents.getOrElse(tacticToShow,Array())
		Service.editCtrl.editSubgraph(tacticToShow, indexToShow, Some(parents))
	}

	def delete() {
		if(tacticTotal == 1){
			publish(HidePreviewEvent())
			Service.editCtrl.deleteSubgraph(tacticToShow, indexToShow)
		}
		else {
			Service.editCtrl.deleteSubgraph(tacticToShow, indexToShow)
			tacticTotal = tacticTotal - 1
			if(indexToShow != 0) indexToShow -= 1
			indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
			showPreview()
		}
	}

	def add(){
		val parents = Service.hierarchyCtrl.elementParents.getOrElse(tacticToShow,Array())
		Service.editCtrl.addSubgraph(tacticToShow,Some(parents))
	}

	listenTo(Service.editCtrl)
	listenTo(Service.evalCtrl)
	listenTo(Service.documentCtrl)
	reactions += {
		case GraphTacticListEvent() =>
			gtList = model.gtCollection.keys.toList :+ "main"
			publish(UpdateGTListEvent())
	}
}