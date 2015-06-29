package tinkerGUI.views

import tinkerGUI.controllers.events.DisableNavigationEvent

import scala.swing._
import javax.swing.ImageIcon
import java.awt.Cursor
import java.awt.Insets
import tinkerGUI.controllers.Service

class GraphNavigation() extends Publisher {
	val controller = Service.graphNavCtrl

	val nextAction = new Action("") {
		def apply() {
			controller.showNext()
		}
	}
	val prevAction = new Action("") {
		def apply() {
			controller.showPrev()
		}
	}
	val addNewAction = new Action("") {
		def apply() {
			controller.addNew()
		}
	}
	val delAction = new Action("") {
		def apply() {
			controller.delete()
		}
	}

	val prevBtn = new Button(prevAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("previous.png"), "Prev")
		tooltip = "Previous"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = false
		listenTo(controller)
		reactions += {
			case DisableNavigationEvent(a) =>
				enabled = !(a contains "prev")
		}
	}
	val nextBtn = new Button(nextAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("next.png"), "Next")
		tooltip = "Next"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = false
		listenTo(controller)
		reactions += {
			case DisableNavigationEvent(a) =>
				enabled = !(a contains "next")
		}
	}
	val addBtn = new Button(addNewAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("add.png"), "Add")
		tooltip = "Add"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = false
		listenTo(controller)
		reactions += {
			case DisableNavigationEvent(a) =>
				enabled = !(a contains "add")
		}
	}
	val delBtn = new Button(delAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("delete.png"), "Delete")
		tooltip = "Delete"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = false
		listenTo(controller)
		reactions += {
			case DisableNavigationEvent(a) =>
				enabled = !(a contains "del")
		}
	}

	val navigation = new FlowPanel(){
		contents += prevBtn
		contents += controller.indexOnTotal
		contents += nextBtn
		contents += addBtn
		contents += delBtn
	}
}