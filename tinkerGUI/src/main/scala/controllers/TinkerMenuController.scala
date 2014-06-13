package tinkerGUI.controllers

import tinkerGUI.views.TinkerMenu
import quantoLib.QuantoLibAPI
import quantoLib.DocumentStatusEvent
import scala.swing._
import scala.swing.event.Event

abstract class MenuEvent extends Event
case class DocumentEvent(status : Boolean) extends MenuEvent

class TinkerMenuController(view : TinkerMenu) extends Publisher{
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
	listenTo(QuantoLibAPI)
	reactions += { case DocumentStatusEvent(status) =>
		publish(DocumentEvent(status))
	}
}