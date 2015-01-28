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
				ctrl.selectOption("OPT_EVAL_FINISH")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-finish.png"), "Finish")
		tooltip = "Finish"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_FINISH") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val CompleteButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("OPT_EVAL_COMPLETE")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-complete.png"), "Complete")
		tooltip = "Complete"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_COMPLETE") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val UndoButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("OPT_EVAL_UNDO")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-undo.png"), "Undo")
		tooltip = "Undo"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_UNDO") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val StepInButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("OPT_EVAL_STEP_INTO")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-into.png"), "Step into")
		tooltip = "Step into"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_STEP_INTO") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val StepOverButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("OPT_EVAL_STEP_OVER")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-over.png"), "Step over")
		tooltip = "Step over"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_STEP_OVER") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val StopButton = new Button(
		new Action(""){
			def apply() {
				ctrl.selectOption("OPT_EVAL_STOP")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-stop.png"), "Stop")
		tooltip = "Stop"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_STOP") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val UntilBreakButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("OPT_EVAL_UNTIL_BREAK")
			}
		}
		){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-debug.png"), "Until Break")
		tooltip = "Until Break"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_UNTIL_BREAK") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val NextButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("OPT_EVAL_NEXT")
			}
		}
		){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-next.png"), "Next")
		tooltip = "Next"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_NEXT") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}
	val BacktrackButton = new Button(
		new Action(""){
			def apply(){
				ctrl.selectOption("OPT_EVAL_BACKTRACK")
			}
		}
		){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-backtrack.png"), "Backtrack")
		tooltip = "Backtrack"
		listenTo(ctrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) =>
				opt.foreach{o => if(o=="OPT_EVAL_BACKTRACK") enabled = true}
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val EvalToolBar = new ToolBar{
		contents += (NextButton, UndoButton, StepInButton, StepOverButton, BacktrackButton, CompleteButton, FinishButton, StopButton, UntilBreakButton)
	}
}