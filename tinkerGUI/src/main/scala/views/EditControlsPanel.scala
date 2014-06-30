package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.EditControlsController

class EditControlsPanel() {
	val controller = Service.editControlsCtrl
	val SelectButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("select-rectangular.png"), "Select")
		tooltip = "Select"
		name = "select"
		selected = true
	}
	val AddIDVertexButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw_id.png"), "Add Vertex")
		tooltip = "Add an identity vertex"
		name = "addIDVertex"
	}
	val AddATMVertexButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw_atomic.png"), "Add Vertex")
		tooltip = "Add an atomic vertex"
		name = "addATMVertex"
	}
		val AddNSTVertexButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw_nested.png"), "Add Vertex")
		tooltip = "Add a nested vertex"
		name = "addNSTVertex"
	}
	val AddEdgeButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw-path.png"), "Add Edge")
		tooltip = "Add edge"
		name = "addEdge"
	}
	val GraphToolGroup = new ButtonGroup(SelectButton, AddIDVertexButton, AddEdgeButton, AddATMVertexButton, AddNSTVertexButton)

	controller.addListener(GraphToolGroup)

	val MainToolBar = new ToolBar {
		contents += (SelectButton, AddIDVertexButton, AddATMVertexButton, AddNSTVertexButton, AddEdgeButton)
	}
}