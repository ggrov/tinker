package tinkerGUI.views

import tinkerGUI.utils.MutableComboBox

import scala.swing._
import javax.swing.{ImageIcon}
import java.awt.{Font, Cursor, Insets}
import tinkerGUI.controllers._

import scala.swing.event.SelectionChanged

class navigationPanel(controller:GraphInspectorController) extends BoxPanel(Orientation.Vertical){
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

		contents += new FlowPanel(FlowPanel.Alignment.Right)(){
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
}

class GraphInspectorPanel() extends BorderPanel {
	minimumSize = new Dimension(250, 500)
	preferredSize = new Dimension(250, 550)
	val controller = Service.graphInspectorCtrl

	val tacticNavigation = new navigationPanel(controller)

	val noSubgraphLabel = new Label("This tactic does not have any subgraphs.")

	val header = new BorderPanel {

		val titleFont = new Font("Dialog",Font.BOLD,14)
		add(new FlowPanel(FlowPanel.Alignment.Center)(new Label("Tactic inspector"){font = titleFont}),BorderPanel.Position.North)

		add(new FlowPanel(FlowPanel.Alignment.Left)(){
			var list = controller.gtList
			list = list :+ "Select a tactic"
			val cb = new MutableComboBox[String]
			cb.items = list
			cb.item = "Select a tactic"
			listenTo(controller)
			reactions += {
				case UpdateGTListEvent() =>
					val selected = cb.item
					var list = controller.gtList
					list = list :+ "Select a tactic"
					cb.items = list
					cb.item = if(list contains selected) selected else "Select a tactic"
				case UpdateSelectedTacticToInspectEvent(name:String) =>
					cb.item = name
			}
			contents += cb
			listenTo(cb)
			reactions += {
				case SelectionChanged(`cb`) => controller.inspect(cb.item)
			}
		},BorderPanel.Position.West)

		add(new FlowPanel(FlowPanel.Alignment.Right)(tacticNavigation),BorderPanel.Position.East)
		add(new FlowPanel(FlowPanel.Alignment.Center)(noSubgraphLabel),BorderPanel.Position.South)
	}

	val subgraphPanel = controller.getSubgraphView

	add(header, BorderPanel.Position.North)
	add(subgraphPanel, BorderPanel.Position.Center)
	subgraphPanel.visible = false
	noSubgraphLabel.visible = false
	tacticNavigation.visible = false
	listenTo(controller)
	reactions += {
		case ShowPreviewEvent(hasSubgraph:Boolean) =>
			if(hasSubgraph){
				subgraphPanel.visible = true
				noSubgraphLabel.visible = false
			} else {
				noSubgraphLabel.visible = true
				subgraphPanel.visible = false
			}
			tacticNavigation.visible = true
			this.repaint()
		case HidePreviewEvent() =>
			subgraphPanel.visible = false
			noSubgraphLabel.visible = false
			tacticNavigation.visible = false
			this.repaint()
	}
}