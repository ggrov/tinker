package tinkerGUI.views

import tinkerGUI.controllers.events.CurrentGraphChangedEvent
import tinkerGUI.controllers.Service

import scala.swing._
import scala.swing.event._
import java.awt.Cursor

class GraphBreadcrumbs() extends Publisher{
	val currentLabel = new Label(Service.hierarchyCtrl.root)
	var parentLabels: Array[Label] = Array()
	val breadcrumbs = new FlowPanel() {
		contents += currentLabel
	}

	def updateContent(){
		breadcrumbs.contents.clear()
		parentLabels.foreach { p =>
			breadcrumbs.contents += p
			listenTo(p.mouse.moves, p.mouse.clicks)
			reactions += {
				case MouseEntered(_,_,_) => p.cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				case e:MouseClicked =>
					if(p == e.source && !e.consumed){
						e.consume()
						Service.editCtrl.editSubgraph(p.text,0,Some(parentLabels.splitAt(parentLabels.indexOf(p))._1.foldLeft(Array[String]()){case (a,parent) => a:+parent.text}))
					}
			}
			breadcrumbs.contents += new Label ("\u25B8")
		}
		breadcrumbs.contents += currentLabel
		breadcrumbs.revalidate()
	}

	listenTo(Service.editCtrl)
	listenTo(Service.documentCtrl)
	listenTo(Service.evalCtrl)
	reactions += {
		case CurrentGraphChangedEvent(current, parents) =>
			parents match {
				case Some(p:Array[String]) =>
					parentLabels = p.foldLeft(Array[Label]()){case(a,s) => a :+ new Label(s){foreground = new Color(0,128,255)}}
				case None => if (current != currentLabel.text) parentLabels = parentLabels :+ new Label(currentLabel.text){foreground = new Color(0,128,255)}
			}
			currentLabel.text = current
			updateContent()
	}
}