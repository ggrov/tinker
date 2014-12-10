package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.EvalControlsController
import tinkerGUI.controllers.EnableEvalOptionsEvent
import tinkerGUI.controllers.DisableEvalOptionsEvent
import tinkerGUI.utils.ToolBar

class EvalControlsPanel() {
	val ctrl = Service.evalControlsCtrl

	val FinishButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("finish")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-finish.png"), "Finish")
		tooltip = "Finish"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="finish") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val CompleteButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("complete")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-complete.png"), "Complete")
		tooltip = "Complete"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="complete") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val UndoButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("undo")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-undo.png"), "Undo")
		tooltip = "Undo"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="undo") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val StepInButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("stepInto")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-into.png"), "Step into")
		tooltip = "Step into"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="stepInto") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val StepOverButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("stepOver")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-over.png"), "Step over")
		tooltip = "Step over"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="stepOver") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val StopButton = new Button(
		new Action(""){
			def apply() {
				ctrl.selectOption("stop")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-stop.png"), "Stop")
		tooltip = "Stop"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="stop") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
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