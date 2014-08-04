package tinkerGUI.controllers

import scala.swing._

class MainGUIController() extends Publisher {
	def getTitle = DocumentService.title
	var prevTitle = DocumentService.title
	listenTo(DocumentService)
	reactions += {
		case (DocumentSaved() | DocumentChanged()) =>
			if(prevTitle != DocumentService.title){
				publish(DocumentTitleEvent(DocumentService.title))
				prevTitle = DocumentService.title
			}
	}
}