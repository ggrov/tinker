package tinkerGUI.views

import tinkerGUI.controllers.{CommunicationService, Service}
import tinkerGUI.controllers.events.{ConnectedToCoreEvent, EnableEvalOptionsEvent, DisableEvalOptionsEvent}
import tinkerGUI.utils.ToolBar

import scala.swing._
import javax.swing.ImageIcon
import java.util.{Timer, TimerTask}

class EvalControlsPanel() {

	val ConnectButton = new Button(
		new Action(""){
			def apply(){
				if(CommunicationService.connected) CommunicationService.closeConnection()
				else if (CommunicationService.connecting) CommunicationService.interruptConnection()
				else if(!CommunicationService.connecting && !CommunicationService.connected) CommunicationService.openConnection()
			}
		}){
		val connectingIcon1 = new ImageIcon(MainGUI.getClass.getResource("eval-connecting1.png"), "Connecting")
		val connectingIcon2 = new ImageIcon(MainGUI.getClass.getResource("eval-connecting2.png"), "Connecting")
		val connectedIcon = new ImageIcon(MainGUI.getClass.getResource("eval-connected.png"), "Disconnect")
		val disconnectedIcon = new ImageIcon(MainGUI.getClass.getResource("eval-disconnected.png"), "Connect")
		var timer:Timer = null
		var timerTask:TimerTask = null
		enabled = true
		icon = disconnectedIcon
		tooltip = "Connect"
		listenTo(CommunicationService)
		reactions += {
			case ConnectedToCoreEvent(connected, connecting) =>
				if(connected) {
					timer.cancel()
					icon = connectedIcon
					tooltip = "Disconnect"
				} else if(connecting) {
					timer = new Timer()
					timerTask = new TimerTask {
						override def run(): Unit = {
							if(icon == disconnectedIcon
								|| icon == connectedIcon
								|| icon == connectingIcon2) icon = connectingIcon1
							else if(icon == connectingIcon1) icon = connectingIcon2
						}
					}
					timer.schedule(timerTask, 0L, 500L)
					//icon =
					tooltip = "Connecting ..."
				} else {
					timer.cancel()
					icon = disconnectedIcon
					tooltip = "Connect"
				}
		}
	}

	val FinishButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_FINISH")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-finish.png"), "Finish")
		tooltip = "Finish the current graph"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_NEXT"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val CompleteButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_COMPLETE")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-complete.png"), "Complete")
		tooltip = "Complete the whole proof"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_NEXT"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val UndoButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_UNDO")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-undo.png"), "Undo")
		tooltip = "Undo"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_UNDO"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val StepInButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_STEP_INTO")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-into.png"), "Step into")
		tooltip = "Step into"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_STEP_INTO"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val StepOverButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_STEP_OVER")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-step-over.png"), "Step over")
		tooltip = "Step over"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_STEP_OVER"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val StopButton = new Button(
		new Action(""){
			def apply() {
				Service.evalCtrl.selectEvalOption("OPT_EVAL_STOP")
			}
		}){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-stop.png"), "Stop")
		tooltip = "Stop Evaluation"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_STOP"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val UntilBreakButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_UNTIL_BREAK")
			}
		}
		){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-debug.png"), "Until Break")
		tooltip = "Until Break"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_NEXT"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val NextButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_NEXT")
			}
		}
		){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-next.png"), "Next")
		tooltip = "Next"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_NEXT"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val BacktrackButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("OPT_EVAL_BACKTRACK")
			}
		}
		){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("eval-backtrack.png"), "Backtrack")
		tooltip = "Backtrack"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "OPT_EVAL_BACKTRACK"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val PushButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("PUSH")
			}
		}
	){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("push.png"), "Push")
		tooltip = "Send changes"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(opt) => enabled = opt contains "PUSH"
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val PullButton = new Button(
		new Action(""){
			def apply(){
				Service.evalCtrl.selectEvalOption("PULL")
			}
		}
	){
		enabled = false
		icon = new ImageIcon(MainGUI.getClass.getResource("pull.png"), "Push")
		tooltip = "Reload correct graph"
		listenTo(Service.evalCtrl)
		reactions += {
			case EnableEvalOptionsEvent(_) => enabled = Service.evalCtrl.tmpEvalPSGraph.nonEmpty
			case DisableEvalOptionsEvent() => enabled = false
		}
	}

	val MainEvalToolBar = new ToolBar{
		contents += (NextButton, UndoButton, StepInButton, StepOverButton, FinishButton, BacktrackButton, UntilBreakButton, CompleteButton)
	}

	val SecondaryEvalToolBar = new ToolBar{
		contents += (ConnectButton, PushButton, PullButton, StopButton)
	}
}