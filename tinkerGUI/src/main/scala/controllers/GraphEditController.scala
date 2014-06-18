package tinkerGUI.controllers

import scala.swing._

class GraphEditController() extends Publisher {
	private var mouseState: MouseState = SelectTool()

	def getGraph = QuantoLibAPI.getGraph

	def changeMouseState(state: String) {
		state match {
			case "select" =>
				mouseState = SelectTool()
			case "addVertex" =>
				mouseState = AddVertexTool()
			case "addEdge" =>
				mouseState = AddEdgeTool()
		}
	}

	def changeMouseState(state: String, pt: java.awt.Point) {
		state match {
			case "dragVertex" =>
				mouseState = DragVertex(pt, pt)
			case "selectionBox" =>
				val box = SelectionBox(pt, pt)
				mouseState = box
				QuantoLibAPI.viewSelectBox(box)
		}
	}

	def changeMouseState(state: String, param: String) {
		state match {
			case "dragEdge" =>
				mouseState = DragEdge(param)
		}
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphMousePressedEvent(pt, modifiers, clicks) =>
			mouseState match {
				case AddVertexTool() => // do nothing
				case SelectionBox(_,_) => // do nothing
				case DragVertex(_,_) => // do nothing
				case DragEdge(_) => // do nothing
				case SelectTool() =>
					if(clicks == 2){
						QuantoLibAPI.editGraphElement(pt)
					}
					else {
						QuantoLibAPI.selectVertex(pt, modifiers, changeMouseState)
					}
				case AddEdgeTool() =>
					QuantoLibAPI.startAddEdge(pt, changeMouseState)
			}
		case GraphMouseDraggedEvent(pt) =>
			mouseState match {
				case SelectTool() => // do nothing
				case AddVertexTool() => // do nothing
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
					QuantoLibAPI.endAddEdge(startV, pt)
					mouseState = AddEdgeTool()
				case AddVertexTool() =>
					QuantoLibAPI.userAddVertex(pt)
			}
	}
}