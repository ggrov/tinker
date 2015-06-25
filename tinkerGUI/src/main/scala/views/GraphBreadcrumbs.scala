package tinkerGUI.views

import tinkerGUI.controllers.events.CurrentGraphChangedEvent

import scala.swing._
import scala.swing.event._
import java.awt.Cursor
import tinkerGUI.controllers.Service

class GraphBreadcrumbs() extends Publisher{
	val currentLabel = new Label("main")
	var parentLabels: Array[Label] = Array()
	//var parents:Array[String] = Array()
	//var current:String = "main"
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
						Service.editCtrl.editSubgraph(p.text,0,Some(parentLabels.splitAt(parentLabels.indexOf(p))._1.foldLeft(Array[String]()){case (a,p) => a:+p.text}))
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
			/*parentLabels.foreach{ p =>
				listenTo(p.mouse.moves, p.mouse.clicks)
				reactions += {
					case MouseEntered(_,_,_) => p.cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
					case MouseClicked(src, _, _, _, _) =>
						if(p == src){
							Service.editCtrl.editSubgraph(p.text,0,Some(parentLabels.splitAt(parentLabels.indexOf(p))._1.foldLeft(Array[String]()){case (a,p) => a:+p.text}))
						}
				}
			}*/
	}
}