package tinkerGUI.views

import tinkerGUI.controllers.events.DisableNavigationEvent
import tinkerGUI.controllers.{QuantoLibAPI, Service}

import scala.swing._
import javax.swing.ImageIcon
import java.awt.Cursor
import java.awt.Insets

class GraphNavigation() extends Publisher {
	val controller = Service.graphNavCtrl

	val nextAction = new Action("") {
		def apply() = {
			controller.showNext()
		}
	}
	val prevAction = new Action("") {
		def apply() = {
			controller.showPrev()
		}
	}
	val zoomInAction = new Action(""){
		def apply() = {
			QuantoLibAPI.zoomInGraph()
		}
	}
	val zoomOutAction = new Action(""){
		def apply() = {
			QuantoLibAPI.zoomOutGraph()
		}
	}
	val addNewAction = new Action("") {
		def apply() = {
			controller.addNew()
		}
	}
	val delAction = new Action("") {
		def apply() = {
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
	val zoomInBtn = new Button(zoomInAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("zoom-in.png"), "Zoom in")
		tooltip = "Zoom in"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		/*listenTo(controller)
		reactions += {
			case DisableNavigationEvent(a) =>
				enabled = !(a contains "zoomin")
		}*/
	}
	val zoomOutBtn = new Button(zoomOutAction){
		icon = new ImageIcon(MainGUI.getClass.getResource("zoom-out.png"), "Zoom out")
		tooltip = "Zoom out"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		/*listenTo(controller)
		reactions += {
			case DisableNavigationEvent(a) =>
				enabled = !(a contains "zoomout")
		}*/
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
		contents += zoomInBtn
		contents += zoomOutBtn
		contents += addBtn
		contents += delBtn
	}
}