package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import java.awt.Cursor
import java.awt.Insets
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.SubGraphEditController
import tinkerGUI.controllers.ShowPreviewEvent
import tinkerGUI.controllers.HidePreviewEvent

class SubGraphEditPanel() extends BorderPanel {
	minimumSize = new Dimension(250, 350)
	val controller = Service.subGraphEditCtrl

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
	val editAction = new Action("") {
		def apply() {
			controller.edit()
		}
	}
	val delAction = new Action("") {
		def apply() {
			controller.delete()
		}
	}
	val addAction = new Action(""){
		def apply() {
			controller.add()
		}
	}

	val navPanel = new FlowPanel{
		contents += new Button(prevAction){
			icon = new ImageIcon(MainGUI.getClass.getResource("previous.png"), "Prev")
			tooltip = "Previous"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		}
		contents += controller.indexOnTotal
		contents += new Button(nextAction){
			icon = new ImageIcon(MainGUI.getClass.getResource("next.png"), "Next")
			tooltip = "Next"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		}
		contents += new Button(editAction){
			icon = new ImageIcon(MainGUI.getClass.getResource("edit-pen.png"), "Edit")
			tooltip = "Edit"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		}
		contents += new Button(addAction){
			icon = new ImageIcon(MainGUI.getClass.getResource("add.png"), "Add")
			tooltip = "Add"
			enabled = false
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		}
		contents += new Button(delAction){
			icon = new ImageIcon(MainGUI.getClass.getResource("delete.png"), "Delete")
			tooltip = "Delete"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		}
	}

	val subgraphPanel = controller.getSubgraphView

	listenTo(controller)
	reactions += {
		case ShowPreviewEvent() =>
			_contents.clear()
			add(navPanel, BorderPanel.Position.North)
			add(subgraphPanel, BorderPanel.Position.Center)
			this.repaint()
		case HidePreviewEvent() =>
			_contents.clear()
			this.repaint()
	}
}