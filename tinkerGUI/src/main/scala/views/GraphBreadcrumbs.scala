package tinkerGUI.views

import tinkerGUI.controllers.events.CurrentGraphChangedEvent

import scala.swing._
import scala.swing.event._
import java.awt.Cursor
import tinkerGUI.controllers.Service

class GraphBreadcrumbs() extends Publisher{
	val currentLabel = new Label("main")
	var parentLabels: Array[Label] = Array()
	val breadcrumbs = new FlowPanel() {
		contents += currentLabel
	}
	var addCurrent = true

	def updateContent(){
		breadcrumbs.contents.clear()
		parentLabels.foreach { p => 
			breadcrumbs.contents += p
			breadcrumbs.contents += new Label ("\u25B8")
		}
		breadcrumbs.contents += currentLabel
		breadcrumbs.repaint()	
	}

	listenTo(Service.editCtrl)
	listenTo(Service.documentCtrl)
	listenTo(Service.evalCtrl)
	reactions += {
		case CurrentGraphChangedEvent(current, parents) =>
			parents match {
				case Some(p:Array[String]) =>
					parentLabels = Array()
					p.foreach{ s => parentLabels = parentLabels :+ new Label(s){foreground = new Color(0,128,255)}}
				case None => parentLabels = parentLabels :+ new Label(currentLabel.text){foreground = new Color(0,128,255)}
			}
			currentLabel.text = current
			updateContent()
			parentLabels.foreach{ p =>
				listenTo(p.mouse.moves, p.mouse.clicks)
				reactions += {
					case MouseEntered(_,_,_) => p.cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
					case MouseClicked(src:Label, _, _, _, _) =>
						if(p.text == src.text){
							Service.editCtrl.editSubgraph(p.text,0,Some(parentLabels.splitAt(parentLabels.indexOf(p))._1.foldLeft(Array[String]()){case (a,p) => a:+p.text}))
						}
				}
			}
			
	}
}