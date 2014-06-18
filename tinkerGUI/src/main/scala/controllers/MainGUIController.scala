package tinkerGUI.controllers

import scala.swing._

class MainGUIController() extends Publisher {
	def getTitle = QuantoLibAPI.getTitle
	var prevTitle = QuantoLibAPI.getTitle
	listenTo(QuantoLibAPI)
	reactions += {
		case DocumentTitleEventAPI(title) =>
			if(prevTitle != title){
				publish(DocumentTitleEvent(title))
			}
	}
}