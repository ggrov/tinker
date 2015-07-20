package tinkerGUI.views

import java.awt.Font

import tinkerGUI.controllers.Service
import tinkerGUI.controllers.events.{EvalLogEvent, DocumentChangedEvent}

import scala.swing._
import scala.swing.event.MouseClicked

class EvalLog extends TextArea {
	val evalLogCtrl = Service.evalCtrl.evalLogCtrl
	lineWrap = true
	text = evalLogCtrl.getLog
	editable = false
	font = new Font(Font.MONOSPACED,Font.BOLD,14)
	listenTo(evalLogCtrl)
	reactions += {
		case EvalLogEvent() => text = evalLogCtrl.getLog
	}
}

class EvalLogMenu extends MenuBar {
	val evalLogCtrl = Service.evalCtrl.evalLogCtrl
	val filter = new Menu("Filters"){
		val filters = Array[String]("BASIC_INFO","GOALTYPE","TACTIC","ENV_DATA","ARG_DATA","SOCKET","GRAPH","HIERARCHY","JSON_GUI","JSON_CORE","EVAL","GUI_LAUNCHER")
		filters.foreach { case s =>
			contents += new CheckMenuItem(s) {
				selected = false
				action = new Action(s) {
					def apply() {
						if (selected) evalLogCtrl.addToFilter(s) else evalLogCtrl.removeFromFilter(s)
					}
				}
			}
		}
	}
	contents += (filter)
}

object EvalLogWindow extends Frame{
	minimumSize  = new Dimension(250,250)
	title = "Tinker - " + Service.documentCtrl.title + " - eval log"
	menuBar = new EvalLogMenu()
	listenTo(Service.documentCtrl)
	reactions += {
		case DocumentChangedEvent(_) =>
			title = "Tinker - " + Service.documentCtrl.title + " - eval log"
	}
	contents = new ScrollPane(new EvalLog())
}
