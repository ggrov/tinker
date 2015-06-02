package tinkerGUI.controllers

import scala.swing._

class MenuController() extends Publisher{
	def newAction = {
		Service.newDoc
	}
	def openAction = {
		Service.loadJsonFromFile
	}
	def saveAction = {
		Service.saveJsonToFile
	}
	def saveAsAction = {
		Service.saveJsonAs
	}
	def quitAction = {
		if(Service.closeDoc) sys.exit(0)
	}

	def undoAction = {
		QuantoLibAPI.undo
	}
	def redoAction = {
		QuantoLibAPI.redo
	}
	def layoutAction = {
		QuantoLibAPI.layoutGraph
	}

	listenTo(DocumentService)
	reactions += { 
		case (DocumentSaved() | DocumentChanged()) => 
			publish(DocumentStatusEvent(DocumentService.unsavedChanges))
		// case DocumentActionStackEventAPI(canUndo, canRedo, undoActionName, redoActionName) =>
		// 	publish (DocumentActionStackEvent(canUndo, canRedo, undoActionName, redoActionName))
	}


	def debugPrintJson(){
		Service.debugPrintJson()
	}
}