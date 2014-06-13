package tinkerGUI.controllers

import scala.swing._

class TinkerMenuController() extends Publisher{
	def newAction = {
		QuantoLibAPI.newDoc
	}
	def openAction = {
		QuantoLibAPI.openDoc
	}
	def saveAction = {
		QuantoLibAPI.saveDoc
	}
	def saveAsAction = {
		QuantoLibAPI.saveAsDoc
	}
	def quitAction = {
		if(QuantoLibAPI.closeDoc) sys.exit(0)
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

	listenTo(QuantoLibAPI)
	reactions += { 
		case DocumentStatusEventAPI(status) => 
			publish(DocumentStatusEvent(status))
		case DocumentActionStackEventAPI(canUndo, canRedo, undoActionName, redoActionName) =>
			publish (DocumentActionStackEvent(canUndo, canRedo, undoActionName, redoActionName))
	}
}