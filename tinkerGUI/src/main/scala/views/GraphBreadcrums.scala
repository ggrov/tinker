package tinkerGUI.views

import scala.swing._
import scala.swing.event._
import java.awt.Cursor
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.AddCrumEvent
import tinkerGUI.controllers.DelCrumFromEvent
import tinkerGUI.controllers.GraphBreadcrumsController

class GraphBreadcrums() extends Publisher{
	val controller = Service.graphBreadcrumsCtrl
	val current = new Label("main")
	var parents: Array[Label] = Array()
	val breadcrums = new FlowPanel() {
		contents += current
	}

	def updateContent(){
		breadcrums.contents.clear()
		parents.foreach { p => 
			breadcrums.contents += p
			breadcrums.contents += new Label (">")
		}
		breadcrums.contents += current
		breadcrums.repaint()	
	}
	
	listenTo(controller)
	reactions += {
		case AddCrumEvent(s) =>
			if(current.text != s){
				val parent = new Label(current.text)
				parent.foreground = new Color(0, 128, 255)
				parents = parents :+ parent
				current.text = s
				updateContent()
				parents.foreach { p =>
					listenTo(p.mouse.moves, p.mouse.clicks)
					reactions += {
						case MouseEntered(_, _, _) =>
							p.cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
						case MouseClicked(src:Label, _, _, _, _) =>
							current.text = src.text
							parents.foreach { p =>
								if(p.text == src.text){
									if(controller.changeGraph(src.text)) {
										parents = parents.splitAt(parents.indexOf(p))._1
									}
								}
							}
							updateContent()
					}
				}
			}
		case DelCrumFromEvent(s) =>
			current.text = s
			parents.foreach { p =>
				if(p.text == s){
					parents = parents.splitAt(parents.indexOf(p))._1
				}
			}
			updateContent()
			// parents.foreach { p =>
			// 	listenTo(p.mouse.moves, p.mouse.clicks)
			// 	reactions += {
			// 		case MouseEntered(_, _, _) =>
			// 			p.cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			// 		case MouseClicked(src:Label, _, _, _, _) =>
			// 			println("change graph " + src.text)
			// 			controller.changeGraph(src.text)
			// 	}
			// }
	}
}