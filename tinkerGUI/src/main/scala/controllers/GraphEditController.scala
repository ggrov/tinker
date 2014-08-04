package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.utils.PopupMenu
import tinkerGUI.utils.SelectTool
import tinkerGUI.utils.SelectionBox
import tinkerGUI.utils.DragVertex
import tinkerGUI.utils.AddVertexTool
import tinkerGUI.utils.AddEdgeTool
import tinkerGUI.utils.DragEdge
import tinkerGUI.utils.MouseState

class GraphEditController() extends Publisher {
	private var mouseState: MouseState = SelectTool()

	def getGraph = QuantoLibAPI.getGraph

	def resetGraph() {
		publish(NewGraphEvent())
	}

	def changeMouseState(state: String) {
		state match {
			case "select" =>
				mouseState = SelectTool()
			case "addIDVertex" =>
				mouseState = AddVertexTool("RT_ID")
			case "addATMVertex" =>
				mouseState = AddVertexTool("RT_ATM")
			case "addNSTVertex" =>
				mouseState = AddVertexTool("RT_NST")
			case "addEdge" =>
				mouseState = AddEdgeTool()
		}
	}

	def changeMouseState(state: String, param: Any) {
		param match {
			case s:String =>
				state match {
					case "dragEdge" =>
						mouseState = DragEdge(s)
				}
			case pt:java.awt.Point =>
				state match {
					case "dragVertex" =>
						mouseState = DragVertex(pt, pt)
					case "selectionBox" =>
						val box = SelectionBox(pt, pt)
						mouseState = box
						QuantoLibAPI.viewSelectBox(box)
				}
		}
	}

	val popup = new PopupMenu(){
		contents += new MenuItem(new Action("Say Hello") {def apply = println("Hello World")})
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case MouseLeftPressedEvent(pt, modifiers, clicks) =>
			mouseState match {
				case AddVertexTool(_) => // do nothing
				case SelectionBox(_,_) => // do nothing
				case DragVertex(_,_) => // do nothing
				case DragEdge(_) => // do nothing
				case SelectTool() =>
					// if(clicks == 2){
						// QuantoLibAPI.editGraphElement(pt)
					// }
					// else {
						QuantoLibAPI.selectElement(pt, modifiers, changeMouseState)
					// }
				case AddEdgeTool() =>
					QuantoLibAPI.startAddEdge(pt, changeMouseState)
			}
		case MouseRightPressedEvent(pt, modifiers, clicks, source) =>
			 mouseState match {
				case AddVertexTool(_) => // do nothing
				case SelectionBox(_,_) => // do nothing
				case DragVertex(_,_) => // do nothing
				case DragEdge(_) => // do nothing
				case SelectTool() =>
					QuantoLibAPI.selectElement(pt, modifiers, changeMouseState)
					popup.show(source, pt.getX.toInt, pt.getY.toInt)
				case AddEdgeTool() =>
					QuantoLibAPI.startAddEdge(pt, changeMouseState)
			}
		case GraphMouseDraggedEvent(pt) =>
			mouseState match {
				case SelectTool() => // do nothing
				case AddVertexTool(_) => // do nothing
				case AddEdgeTool() => //do nothing
				case DragVertex(start, prev) =>
					QuantoLibAPI.dragVertex(pt, prev)
					mouseState = DragVertex(start, pt)
				case SelectionBox(start, _) =>
					val box = SelectionBox(start, pt)
					mouseState = box
					QuantoLibAPI.viewSelectBox(box)
				case DragEdge(startV) =>
					QuantoLibAPI.dragEdge(startV, pt)
			}
		case GraphMouseReleasedEvent(pt, modifiers) =>
			mouseState match {
				case SelectTool() => // do nothing
				case AddEdgeTool() => //do nothing
				case DragVertex(start, end) =>
					if(start.getX != end.getX || start.getY != end.getY) {
						QuantoLibAPI.moveVertex(start, end)
					}
					mouseState = SelectTool()
				case SelectionBox(start, _) =>
					val selectionUpdated = !(pt.getX == start.getX && pt.getY == start.getY)
					val rect = mouseState.asInstanceOf[SelectionBox].rect
					QuantoLibAPI.viewSelectBoxFinal(selectionUpdated, pt, rect)
					mouseState = SelectTool()
					QuantoLibAPI.viewSelectBox()
				case DragEdge(startV) =>
					QuantoLibAPI.endAddEdge(startV, pt, changeMouseState)
				case AddVertexTool(typ) =>
					QuantoLibAPI.userAddVertex(pt, typ)
			}
	}
}