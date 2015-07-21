package tinkerGUI.views

import java.awt.Font

import tinkerGUI.controllers.Service
import tinkerGUI.controllers.events.{EvalLogEvent, DocumentChangedEvent}

import scala.swing._

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

object EvalLogMenu extends MenuBar {
	val evalLogCtrl = Service.evalCtrl.evalLogCtrl
	val filter = new Menu("Filters"){
		var filters = Array[String]()
		evalLogCtrl.stack.foreach{ case (s,_) =>
			if(!filters.contains(s)){
				filters = filters :+ s
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
		listenTo(evalLogCtrl)
		reactions += {
			case EvalLogEvent() =>
				evalLogCtrl.stack.foreach{ case (s,_) =>
					if(!filters.contains(s)){
						filters = filters :+ s
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
				this.repaint()
		}
	}
	contents += filter
}

object EvalLogWindow extends Frame{
	minimumSize  = new Dimension(250,250)
	title = "Tinker - " + Service.documentCtrl.title + " - eval log"
	menuBar = EvalLogMenu
	listenTo(Service.documentCtrl)
	reactions += {
		case DocumentChangedEvent(_) =>
			title = "Tinker - " + Service.documentCtrl.title + " - eval log"
	}
	contents = new ScrollPane(new EvalLog())
}
