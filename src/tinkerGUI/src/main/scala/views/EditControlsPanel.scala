package tinkerGUI.views

import tinkerGUI.controllers.events.{MouseStateChangedEvent, DocumentChangedEvent}
import tinkerGUI.controllers.Service
import tinkerGUI.utils.ToolBar

import scala.swing._
import scala.swing.event.KeyReleased
import javax.swing.ImageIcon

/*object GoalTypeEditor extends Frame {
	title = "Tinker - " + Service.documentCtrl.title + " - Goal Type Editor"
	listenTo(Service.documentCtrl)
	reactions += {
		case DocumentChangedEvent(_) =>
			title = "Tinker - " + Service.documentCtrl.title + " - Goal Type Editor"
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
}*/

class EditControlsPanel() extends Publisher {

	val SelectButton = new ToggleButton() {
		action = new Action(""){def apply()={Service.editCtrl.changeMouseState("select")}}
		icon = new ImageIcon(MainGUI.getClass.getResource("select-rectangular.png"), "Select")
		tooltip = "Select"
		selected = true
		listenTo(Service.editCtrl)
		reactions += {
			case MouseStateChangedEvent(state) => selected = state == "select"
		}
	}
	val AddIDVertexButton = new ToggleButton() {
		action = new Action(""){def apply()={Service.editCtrl.changeMouseState("addIDVertex")}}
		icon = new ImageIcon(MainGUI.getClass.getResource("draw_id.png"), "Add Vertex")
		tooltip = "Add an identity vertex"
		listenTo(Service.editCtrl)
		reactions += {
			case MouseStateChangedEvent(state) => selected = state == "addIDVertex"
		}
	}
	val AddATMVertexButton = new ToggleButton() {
		action = new Action(""){def apply()={Service.editCtrl.changeMouseState("addATMVertex")}}
		icon = new ImageIcon(MainGUI.getClass.getResource("draw_atomic.png"), "Add Vertex")
		tooltip = "Add an atomic vertex"
		listenTo(Service.editCtrl)
		reactions += {
			case MouseStateChangedEvent(state) => selected = state == "addATMVertex"
		}
	}
	val AddNSTVertexButton = new ToggleButton() {
		action = new Action(""){def apply()={Service.editCtrl.changeMouseState("addNSTVertex")}}
		icon = new ImageIcon(MainGUI.getClass.getResource("draw_nested.png"), "Add Vertex")
		tooltip = "Add a nested vertex"
		listenTo(Service.editCtrl)
		reactions += {
			case MouseStateChangedEvent(state) => selected = state == "addNSTVertex"
		}
	}
	val AddEdgeButton = new ToggleButton() {
		action = new Action(""){def apply()={Service.editCtrl.changeMouseState("addEdge")}}
		icon = new ImageIcon(MainGUI.getClass.getResource("draw-edge.png"), "Add Edge")
		tooltip = "Add edge"
		listenTo(Service.editCtrl)
		reactions += {
			case MouseStateChangedEvent(state) => selected = state == "addEdge"
		}
	}
	val EditGoalButton = new Button() {
		action = new Action(""){def apply()={Service.evalCtrl.editGoal()}}
		icon = new ImageIcon(MainGUI.getClass.getResource("edit-goal.png"), "Edit goal")
		tooltip = "Edit goal"
	}
	val GraphToolGroup = new ButtonGroup(SelectButton, AddIDVertexButton, AddEdgeButton, AddATMVertexButton, AddNSTVertexButton)

/*	val EditGoalTypesButton = new Button(new Action(""){
		def apply() {
			GoalTypeEditor.open()
		}
	}) {
		icon = new ImageIcon(MainGUI.getClass.getResource("edit-goal-type.png"), "Edit Goal Types")
		tooltip = "Edit goal types"
	}*/

	val MainToolBar = new ToolBar {
		contents += (SelectButton, AddIDVertexButton, AddATMVertexButton, AddNSTVertexButton, AddEdgeButton, EditGoalButton)
	}
/*	val SecondaryToolBar = new ToolBar {
		contents += EditGoalTypesButton
	}*/
}
