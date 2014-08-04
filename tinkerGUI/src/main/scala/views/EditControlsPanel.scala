package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.EditControlsController
import tinkerGUI.controllers.DocumentTitleEvent
import scala.swing.event.KeyReleased

object GoalTypeEditor extends Frame {
	title = "Tinker - " + Service.mainCtrl.getTitle + " - Goal Type Editor"
	listenTo(Service.mainCtrl)
	reactions += {
		case DocumentTitleEvent(t) =>
			title = "Tinker - " + t + " - Goal Type Editor"
	}
	minimumSize = new Dimension(800, 400)
	var prevText = Service.getGoalTypes
	val txtArea = new TextArea(prevText)
	contents = txtArea
	listenTo(txtArea.keys)
	reactions += {
		case KeyReleased(c, key, _, _) =>
			if(c == txtArea && txtArea.text != prevText){
				Service.setGoalTypes(txtArea.text)
				prevText = txtArea.text
			}
	}

	override def open() {
		prevText = Service.getGoalTypes
		txtArea.text = prevText
		super.open()
	}
}

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

	val EditGoalTypesButton = new Button(new Action(""){
		def apply() {
			GoalTypeEditor.open()
		}
		}) {
		icon = new ImageIcon(MainGUI.getClass.getResource("edit-goal-type.png"), "Edit Goal Types")
		tooltip = "Edit goal types"
	}

	val MainToolBar = new ToolBar {
		contents += (SelectButton, AddIDVertexButton, AddATMVertexButton, AddNSTVertexButton, AddEdgeButton)
	}
	val SecondaryToolBar = new ToolBar {

		contents += (EditGoalTypesButton)
	}
}