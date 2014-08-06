package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import tinkerGUI.controllers.Service
// import tinkerGUI.controllers.EditControlsController

class EvalControlsPanel() {
	val FinishButton = new Button(
		new Action(""){
			def apply(){
				println("Finish")
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-finish.png"), "Finish")
		tooltip = "Finish"
	}
	val CompleteButton = new Button(
		new Action(""){
			def apply(){
				println("Complete")
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-complete.png"), "Complete")
		tooltip = "Complete"
	}
	val UndoButton = new Button(
		new Action(""){
			def apply(){
				println("Undo")
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-undo.png"), "Undo")
		tooltip = "Undo"
	}
	val StepInButton = new Button(
		new Action(""){
			def apply(){
				println("Step Into")
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-into.png"), "Step into")
		tooltip = "Step into"
	}
	val StepOverButton = new Button(
		new Action(""){
			def apply(){
				println("Step Over")
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-over.png"), "Step over")
		tooltip = "Step over"
	}
	val StopButton = new Button(
		new Action(""){
			def apply() {
				println("Stop")
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-stop.png"), "Stop")
		tooltip = "Stop"
	}
	val DebugButton = new ToggleButton(
		// new Action(""){
		// 	def apply(){
		// 		println("Debug")
		// 	}
		// }
		){
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-debug.png"), "Debug")
		tooltip = "Debug"
	}

	val EvalToolBar = new ToolBar{
		contents += (UndoButton, StepInButton, StepOverButton, CompleteButton, FinishButton, StopButton, DebugButton)
	}
}