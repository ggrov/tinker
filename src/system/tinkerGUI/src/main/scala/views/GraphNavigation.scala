package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import java.awt.Cursor
import java.awt.Insets
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.GraphNavigationController
import tinkerGUI.controllers.HideNavigationEvent
import tinkerGUI.controllers.ShowNavigationEvent

class GraphNavigation() extends Publisher {
	val controller = Service.graphNavCtrl

	val navigation = new FlowPanel()

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
	}
	val nextBtn = new Button(nextAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("next.png"), "Next")
		tooltip = "Next"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
	}
	val addBtn = new Button(addNewAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("add.png"), "Add")
		tooltip = "Add"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
	}
	val delBtn = new Button(delAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("delete.png"), "Delete")
		tooltip = "Delete"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
	}

	listenTo(controller)
	reactions += {
		case HideNavigationEvent() =>
			navigation.contents.clear()
			navigation.repaint()
		case ShowNavigationEvent() =>
			navigation.contents.clear()
			navigation.contents += prevBtn
			navigation.contents += controller.indexOnTotal
			navigation.contents += nextBtn
			navigation.contents += addBtn
			navigation.contents += delBtn
			navigation.repaint()
	}
}