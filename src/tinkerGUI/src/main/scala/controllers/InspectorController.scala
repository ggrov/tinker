package tinkerGUI.controllers

import tinkerGUI.controllers.events._
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{GraphTacticNotFoundException, SubgraphNotFoundException}

import scala.swing._

class InspectorController(model: PSGraph) extends Publisher {

	private var tacticToShow = ""
	private var indexToShow = 0
	private var tacticTotal = 0

	val indexOnTotal = new Label((indexToShow +1) + " / " + tacticTotal)

	var gtList = model.gtCollection.keys.toList :+ "main"

	var enableEdit = true
	listenTo(Service.evalCtrl)
	reactions += {
		case DisableActionsForEvalEvent(inEval) =>
			enableEdit = !inEval
			if(inEval) publish(DisableNavigationEvent(Array("add","edit","del")))
	}

	def inspect(name:String){
		if(name == "Select a tactic"){
			publish(PreviewEvent(false,false))
		} else {
			try{
				tacticToShow = name
				indexToShow = 0
				tacticTotal = if(name=="main") 1 else model.getSizeGT(name)
				indexOnTotal.text = (indexToShow + 1) + " / " + tacticTotal
				publish(UpdateSelectedTacticToInspectEvent(tacticToShow))
				showPreview()
			} catch {
				case e:GraphTacticNotFoundException => publish(PreviewEvent(false,false))
			}
		}
	}

	private def showPreview(){
		try{
			if(tacticToShow == "main"){
				QuantoLibAPI.updateSubgraphPreviewFromJson(model.mainTactic.getSubgraph(0))
				var arr = Array("next","prev","del","add")
				if (!enableEdit) arr = arr :+ "edit"
				publish(DisableNavigationEvent(arr))
			} else{
				QuantoLibAPI.updateSubgraphPreviewFromJson(model.getSubgraphGT(tacticToShow, indexToShow))
				var arr = Array[String]()
				if(!enableEdit) arr = arr :+ "edit" :+ "add" :+ "del"
				if(indexToShow <= 0) arr = arr :+ "prev"
				if(indexToShow >= tacticTotal-1) arr = arr :+ "next"
				publish(DisableNavigationEvent(arr))
			}
			publish(PreviewEvent(true,true))
		} catch {
			case e:GraphTacticNotFoundException => publish(PreviewEvent(false,false))
			case e:SubgraphNotFoundException =>
				indexOnTotal.text = indexToShow + " / " + tacticTotal
				var arr = Array("next","prev","del","edit")
				if(!enableEdit) arr = arr :+ "add"
				publish(DisableNavigationEvent(arr))
				publish(PreviewEvent(true,false))
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
			publish(PreviewEvent(true,false))
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
	listenTo(Service.libraryTreeCtrl)
	reactions += {
		case GraphTacticListEvent() =>
			gtList = model.gtCollection.keys.toList :+ "main"
			publish(UpdateGTListEvent())
	}
}