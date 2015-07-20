package tinkerGUI.controllers

import tinkerGUI.controllers.events.DisableNavigationEvent
import tinkerGUI.model.PSGraph

import scala.swing._

class GraphNavigationController(model:PSGraph) extends Publisher {
	var currentIndex = 0
	var currentTotal = 0
	val indexOnTotal = new Label("1 / 1")

	def viewedGraphChanged(isMain: Boolean, isNew: Boolean){
		currentTotal = if(isMain) 1 else model.getSizeGT(model.getCurrentGTName)
		currentIndex = model.currentIndex
		if(isNew) {
			indexOnTotal.text = (currentIndex+1) + " / " + (currentTotal+1)
			var arr = Array("next","add")
			if(isMain) arr = arr :+ "prev" :+ "del"
			else if(currentIndex==0) arr = arr :+ "prev"
			publish(DisableNavigationEvent(arr))
		}
		else {
			indexOnTotal.text = (currentIndex+1) + " / " + currentTotal
			var arr = Array[String]()
			if(isMain) arr = arr :+ "prev" :+ "next" :+ "add" :+ "del"
			else {
				if(currentIndex <= 0) arr = arr :+ "prev"
				if(currentIndex >= currentTotal-1) arr = arr :+ "next"
			}
			publish(DisableNavigationEvent(arr))
		}
	}

	def showPrev() {
		if(currentIndex > 0){
			Service.editCtrl.editSubgraph(model.getCurrentGTName, currentIndex-1)
		}
	}

	def showNext() {
		if(currentIndex < currentTotal-1){
			Service.editCtrl.editSubgraph(model.getCurrentGTName, currentIndex+1)
		}
	}

	def addNew() {
		Service.editCtrl.addSubgraph(model.getCurrentGTName)
	}

	def delete() {
		(currentTotal, currentIndex) match {
			case (x,y) if x > 1 && y > 0 =>
				Service.editCtrl.deleteSubgraph(model.getCurrentGTName, currentIndex)
				showPrev()
			case (x,0) if x > 1 =>
				Service.editCtrl.deleteSubgraph(model.getCurrentGTName, currentIndex)
				currentIndex -= 1
				showNext()
			case (1,_) => 
				Service.editCtrl.deleteSubgraph(model.getCurrentGTName, currentIndex)
				Service.editCtrl.addSubgraph(model.getCurrentGTName)
			case (0,0) => 
		}
	}

}