package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.utils._

class GraphEditController() extends Publisher {
	private var mouseState: MouseState = SelectTool()

	def getGraph = QuantoLibAPI.getGraph

	def changeMouseState(state: String) {
		state match {
			case "select" =>
				mouseState = SelectTool()
			case "addIDVertex" =>
				mouseState = AddVertexTool("T_Identity")
			case "addATMVertex" =>
				mouseState = AddVertexTool("T_Atomic")
			case "addNSTVertex" =>
				mouseState = AddVertexTool("T_Graph")
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
		var elt = "None"
		var eltName = ""
		var eltValue = ""
		var edgeSource = ""
		var edgeTarget = ""
		var eltNames = Set[String]()
		listenTo(QuantoLibAPI)
		reactions += {
			case NothingSelectedEventAPI() =>
				elt = "None"
			case OneVertexSelectedEventAPI(name, typ, value) =>
				eltValue = value
				eltName = name
				typ match {
					case "T_Identity" => elt = "Identity"
					case "T_Atomic" => elt = "Atomic"
					case "T_Graph" => elt = "Nested"
					case "G_Break" => elt = "Breakpoint"
					case "G" => elt = "Goal"
				}
			case OneEdgeSelectedEventAPI(name, value, source, target) =>
				elt = "Edge"; eltName = name; eltValue = value; edgeSource = source; edgeTarget = target
			case ManyVertexSelectedEventAPI(names) =>
				elt = "Many"; eltNames = names
		}
		override def show(invoker: Component, x: Int, y: Int){
			val deleteNodeAction = new Action("Delete node") {def apply = {QuantoLibAPI.userDeleteElement(eltName)}}
			def failureCallback() = {

			}
			def updateValueCallback(newValues :Map[String,String]) = {
				newValues.foreach{ case (k,v) =>
					k match {
						// should only support edges
						case "Goal types" =>
							QuantoLibAPI.setEdgeValue(eltName, v)
							eltValue = v
						case "From" =>
							QuantoLibAPI.userUpdateEdge(eltName, v, edgeTarget)
							edgeSource = v
						case "To" =>
							QuantoLibAPI.userUpdateEdge(eltName, edgeSource, v)
							edgeTarget = v
					}
				}
			}
			contents.clear()
			elt match {
				case "None" =>
					contents += new MenuItem(new Action("Add an identity node") {def apply = QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Identity")})
					contents += new MenuItem(new Action("Add an atomic tactic node") {def apply = QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Atomic")})
					contents += new MenuItem(new Action("Add a nested tactic node") {def apply = QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Graph")})
				case "Identity" => 
					contents += new MenuItem(deleteNodeAction)
				case "Atomic" =>
					contents += new MenuItem(new Action("Edit node") {
						def apply = {
							Service.updateTactic(eltName,eltValue,true)
						}
					})
					contents += new MenuItem(deleteNodeAction)
				case "Nested" =>
					contents += new MenuItem(new Action("Edit node") {
						def apply = {
							Service.updateTactic(eltName,eltValue,false)
						}
					})
					contents += new MenuItem(new Action("Add a subgraph") {def apply = Service.addSubgraph(ArgumentParser.separateNameFromArgument(eltValue)._1)})
					contents += new MenuItem(deleteNodeAction)
				case "Breakpoint" =>
					contents += new MenuItem(new Action("Remove breakpoint") {def apply = QuantoLibAPI.removeBreakpoint(eltName)})
				case "Many" => 
					contents += new MenuItem(new Action("Merge into nested tactic") {def apply = QuantoLibAPI.mergeSelectedVertices()})
					contents += new MenuItem(new Action("Delete nodes") {def apply = eltNames.foreach{n => QuantoLibAPI.userDeleteElement(n)}})
				case "Edge" =>
					contents += new MenuItem(new Action("Edit edge") {
						def apply = {
							TinkerDialog.openEditDialog("Edit egde "+eltName,
							Map("Goal types"->eltValue, "From"->edgeSource, "To"->edgeTarget),
							updateValueCallback,
							failureCallback)
						}
					})
					if(QuantoLibAPI.hasBreak(eltName)){
						contents += new MenuItem(new Action("Remove breakpoint") {def apply = QuantoLibAPI.removeBreakpointFromEdge(eltName)})
					}
					else {
						contents += new MenuItem(new Action("Add breakpoint") {def apply = QuantoLibAPI.addBreakpointOnEdge(eltName)})
					}
					contents += new MenuItem(new Action("Delete edge") {def apply = QuantoLibAPI.userDeleteElement(eltName)})
			}
			super.show(invoker, x, y)
		}
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
			def emptyFunc(s:String, a:Any) { }
			QuantoLibAPI.selectElement(pt, modifiers, emptyFunc)
			popup.show(source, pt.getX.toInt, pt.getY.toInt)
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