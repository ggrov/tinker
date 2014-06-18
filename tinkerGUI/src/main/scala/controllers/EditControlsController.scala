package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.ButtonClicked

class EditControlsController(graphController : GraphEditController) extends Publisher {
	def changeMouseState(state: String) {
		graphController.changeMouseState(state)
	}
	def addListener(group: ButtonGroup){
		group.buttons.foreach(listenTo(_))
		reactions += {
			case ButtonClicked(b: ToggleButton) =>
				changeMouseState(b.name)
		}		
	}
}