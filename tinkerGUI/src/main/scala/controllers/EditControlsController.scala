package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.ButtonClicked

class EditControlsController() extends Publisher {
	def changeMouseState(state: String) {
		Service.changeGraphEditMouseState(state)
	}
	def addListener(group: ButtonGroup){
		group.buttons.foreach(listenTo(_))
		reactions += {
			case ButtonClicked(b: ToggleButton) =>
				changeMouseState(b.name)
		}		
	}
}