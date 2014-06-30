package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.EditControlsController

class EditControlsPanel() {
	val controller = Service.getEditControlsController
	val SelectButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("select-rectangular.png"), "Select")
		tooltip = "Select"
		name = "select"
		selected = true
	}
	val AddIDVertexButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw-ellipse.png"), "Add Vertex")
		tooltip = "Add an identity vertex"
		name = "addIDVertex"
	}
	val AddEdgeButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw-path.png"), "Add Edge")
		tooltip = "Add edge"
		name = "addEdge"
	}
	val AddATMVertexButton = new ToggleButton("add atomic vertex") {
		tooltip = "Add an atomic vertex"
		name = "addATMVertex"
	}
		val AddNSTVertexButton = new ToggleButton("add nested vertex") {
		tooltip = "Add a nested vertex"
		name = "addNSTVertex"
	}
	val GraphToolGroup = new ButtonGroup(SelectButton, AddIDVertexButton, AddEdgeButton, AddATMVertexButton, AddNSTVertexButton)

	controller.addListener(GraphToolGroup)

	val MainToolBar = new ToolBar {
		contents += (SelectButton, AddIDVertexButton, AddEdgeButton, AddATMVertexButton, AddNSTVertexButton)
	}
}