package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import tinkerGUI.controllers.GraphEditController
import tinkerGUI.controllers.EditControlsController

class EditControlsPanel(graphController: GraphEditController) {
	val controller = new EditControlsController(graphController)
	val SelectButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("select-rectangular.png"), "Select")
		tooltip = "Select"
		name = "select"
		selected = true
	}
	val AddVertexButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw-ellipse.png"), "Add Vertex")
		tooltip = "Add Vertex"
		name = "addVertex"
	}
	val AddEdgeButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("draw-path.png"), "Add Edge")
		tooltip = "Add Edge"
		name = "addEdge"
	}
	val GraphToolGroup = new ButtonGroup(SelectButton, AddVertexButton, AddEdgeButton)

	controller.addListener(GraphToolGroup)

	val MainToolBar = new ToolBar {
		contents += (SelectButton, AddVertexButton, AddEdgeButton)
	}
}