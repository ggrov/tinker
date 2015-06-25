package tinkerGUI.views

import tinkerGUI.controllers._
import tinkerGUI.controllers.events.{ManyVerticesSelectedEvent, OneEdgeSelectedEvent, OneVertexSelectedEvent, NothingSelectedEvent}

import scala.swing._
import tinkerGUI.utils._

object ContextMenu extends PopupMenu {

	var elt = "None"
	var eltName = ""
	var eltValue = ""
	var edgeSource = ""
	var edgeTarget = ""
	var eltNames = Set[String]()

	listenTo(QuantoLibAPI)
	reactions += {
		case NothingSelectedEvent() =>
			elt = "None"
		case OneVertexSelectedEvent(name, typ, value) =>
			eltValue = value
			eltName = name
			typ match {
				case "T_Identity" => elt = "Identity"
				case "T_Atomic" => elt = "Atomic"
				case "T_Graph" => elt = "Nested"
				case "G_Break" => elt = "Breakpoint"
				case "G" => elt = "Goal"
			}
		case OneEdgeSelectedEvent(name, value, source, target) =>
			elt = "Edge"; eltName = name; eltValue = value; edgeSource = source; edgeTarget = target
		case ManyVerticesSelectedEvent(names) =>
			elt = "Many"; eltNames = names
	}

	override def show(invoker: Component, x: Int, y: Int){
		val deleteNodeAction = new Action("Delete node") {
			def apply = {
				Service.documentCtrl.registerChanges()
				QuantoLibAPI.userDeleteElement(eltName)
			}
		}
		contents.clear()
		elt match {
			case "None" =>
				contents += new MenuItem(new Action("Add an identity node") {
					def apply = {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Identity")
					}
				})
				contents += new MenuItem(new Action("Add an atomic tactic node") {
					def apply = {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Atomic")
					}
				})
				contents += new MenuItem(new Action("Add a nested tactic node") {
					def apply = {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Graph")
					}
				})
			case "Identity" =>
				contents += new MenuItem(deleteNodeAction)
			case "Atomic" =>
				contents += new MenuItem(new Action("Edit node") {
					def apply = {
						Service.documentCtrl.registerChanges()
						Service.editCtrl.updateTactic(eltName,eltValue,true)
					}
				})
				contents += new MenuItem(deleteNodeAction)
			case "Nested" =>
				contents += new MenuItem(new Action("Edit node") {
					def apply() {
						Service.documentCtrl.registerChanges()
						Service.editCtrl.updateTactic(eltName,eltValue,false)
					}
				})
				contents += new MenuItem(new Action("Inspect tactic") {
					def apply() {
						Service.inspectorCtrl.inspect(ArgumentParser.separateNameFromArgument(eltValue)._1)
					}
				})
				contents += new MenuItem(new Action("Add a subgraph") {
					def apply = {
						Service.documentCtrl.registerChanges()
						Service.editCtrl.addSubgraph(ArgumentParser.separateNameFromArgument(eltValue)._1)
					}
				})
				contents += new MenuItem(deleteNodeAction)
			case "Breakpoint" =>
				contents += new MenuItem(new Action("Remove breakpoint") {
					def apply = {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.removeBreakpoint(eltName)
					}
				})
			case "Many" =>
				contents += new MenuItem(new Action("Merge into nested tactic") {
					def apply = {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.mergeSelectedVertices()
					}
				})
				contents += new MenuItem(new Action("Delete nodes") {
					def apply = {
						Service.documentCtrl.registerChanges()
						eltNames.foreach{n => QuantoLibAPI.userDeleteElement(n)}
					}
				})
			case "Edge" =>
				contents += new MenuItem(new Action("Edit edge") {
					def apply = {
						Service.documentCtrl.registerChanges()
						Service.editCtrl.editEdge(eltName,edgeSource,edgeTarget,eltValue)
					}
				})
				if(QuantoLibAPI.hasBreak(eltName)){
					contents += new MenuItem(new Action("Remove breakpoint") {
						def apply = {
							Service.documentCtrl.registerChanges()
							QuantoLibAPI.removeBreakpointFromEdge(eltName)
						}
					})
				}
				else {
					contents += new MenuItem(new Action("Add breakpoint") {
						def apply = {
							Service.documentCtrl.registerChanges()
							QuantoLibAPI.addBreakpointOnEdge(eltName)
						}
					})
				}
				contents += new MenuItem(new Action("Delete edge") {
					def apply = {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.userDeleteElement(eltName)
					}
				})
		}
		super.show(invoker, x, y)
	}
}