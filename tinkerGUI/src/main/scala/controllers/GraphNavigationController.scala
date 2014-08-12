package tinkerGUI.controllers

import scala.swing._

class GraphNavigationController() extends Publisher {
	var currentIndex = 0
	var currentTotal = 0
	var disableAdd = false
	val indexOnTotal = new Label()

	def viewedGraphChanged(isMain: Boolean, isNew: Boolean){
		if(isMain) publish(HideNavigationEvent())
		else {
			currentTotal = Service.getCurrentSize
			currentIndex = Service.getCurrentIndex
			if(isNew) {
				indexOnTotal.text = (currentIndex+1) + " / " + (currentTotal+1)
				disableAdd = true
			}
			else {
				indexOnTotal.text = (currentIndex+1) + " / " + currentTotal
				disableAdd = false
			}
			publish(ShowNavigationEvent())
		}
	}

	def showPrev() {
		if(currentIndex > 0){
			Service.editSubGraph(Service.getCurrent, currentIndex-1)
		}
	}

	def showNext() {
		if(currentIndex < currentTotal-1){
			Service.editSubGraph(Service.getCurrent, currentIndex+1)
		}
	}

	def addNew() {
		if(!disableAdd) Service.addSubgraph(Service.getCurrent)
		else println("no add")
	}

	def delete() {
		(currentTotal, currentIndex) match {
			case (x,y) if (x>1 && y>0) =>
				Service.deleteSubGraph(Service.getCurrent, currentIndex)
				showPrev()
			case (x,0) if (x>1) => 
				Service.deleteSubGraph(Service.getCurrent, currentIndex)
				currentIndex -= 1
				showNext()
			case (1,_) => 
				Service.deleteSubGraph(Service.getCurrent, currentIndex)	
				Service.addSubgraph(Service.getCurrent)
			case (0,0) => 
		}
	}
}