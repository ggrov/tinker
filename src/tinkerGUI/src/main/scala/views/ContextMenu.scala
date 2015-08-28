package tinkerGUI.views

import tinkerGUI.controllers._
import tinkerGUI.controllers.events._
import tinkerGUI.utils._

import scala.swing._

object ContextMenu extends PopupMenu {

	var elt = "None"
	var eltName = ""
	var eltLabel = ""
	var eltValue = ""
	var edgeSource = ""
	var edgeTarget = ""
	var eltNames = Set[String]()

	listenTo(QuantoLibAPI)
	reactions += {
		case NothingSelectedEvent() =>
			elt = "None"
		case OneVertexSelectedEvent(name, typ, label, value) =>
			eltLabel = label
			eltName = name
			eltValue = value
			elt = typ
		case OneEdgeSelectedEvent(name, label, source, target) =>
			elt = "Edge"; eltName = name; eltLabel = label; edgeSource = source; edgeTarget = target
		case ManyVerticesSelectedEvent(names) =>
			elt = "Many"; eltNames = names
	}

	override def show(invoker: Component, x: Int, y: Int){
		val deleteNodeAction = new Action("Delete node") {
			def apply() = {
				Service.editCtrl.deleteNode(elt,eltName,eltValue)
			}
		}
		val copyAction = new Action("Copy") {
			def apply() = {
				QuantoLibAPI.copy()
			}
		}
		contents.clear()
		elt match {
			case "None" =>
				contents += new MenuItem(new Action("Add an identity node") {
					def apply() = {
						//Service.documentCtrl.registerChanges()
						Service.editCtrl.createNode("T_Identity",new java.awt.Point(x, y))
						//QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Identity")
					}
				})
				contents += new MenuItem(new Action("Add an atomic tactic node") {
					def apply() = {
						//Service.documentCtrl.registerChanges()
						Service.editCtrl.createNode("T_Atomic",new java.awt.Point(x, y))
						//QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Atomic")
					}
				})
				contents += new MenuItem(new Action("Add a graph tactic node") {
					def apply() = {
						//Service.documentCtrl.registerChanges()
						Service.editCtrl.createNode("T_Graph",new java.awt.Point(x, y))
						//QuantoLibAPI.userAddVertex(new java.awt.Point(x, y), "T_Graph")
					}
				})
				contents += new MenuItem(new Action("Paste") {
					def apply() = {
						Service.editCtrl.paste
					}
				}){
					this.peer.setEnabled(QuantoLibAPI.canPaste)
				}
			case "T_Identity" =>
				contents += new MenuItem(deleteNodeAction)
				contents += new MenuItem(copyAction){
					this.peer.setEnabled(QuantoLibAPI.canCopy)
				}
			case "T_Atomic" =>
				contents += new MenuItem(new Action("Edit node") {
					def apply() = {
						//Service.documentCtrl.registerChanges()
						Service.editCtrl.updateTactic(eltName,eltLabel,eltValue,isAtomicTactic = true)
					}
				})
				contents += new MenuItem(deleteNodeAction)
				contents += new MenuItem(copyAction){
					this.peer.setEnabled(QuantoLibAPI.canCopy)
				}
			case "T_Graph" =>
				contents += new MenuItem(new Action("Edit node") {
					def apply() = {
						//Service.documentCtrl.registerChanges()
						Service.editCtrl.updateTactic(eltName,eltLabel,eltValue,isAtomicTactic = false)
					}
				})
				contents += new MenuItem(new Action("Inspect tactic") {
					def apply() = {
						Service.inspectorCtrl.inspect(eltValue)
					}
				})
				contents += new MenuItem(new Action("Add a subgraph") {
					def apply() = {
						Service.editCtrl.addSubgraph(eltValue)
					}
				})
				contents += new MenuItem(deleteNodeAction)
				contents += new MenuItem(copyAction){
					this.peer.setEnabled(QuantoLibAPI.canCopy)
				}
			case "G_Break" =>
				contents += new MenuItem(new Action("Remove breakpoint") {
					def apply() = {
						Service.editCtrl.deleteNode(elt,eltName,"")
					}
				})
			case "Many" =>
				contents += new MenuItem(new Action("Merge into nested tactic") {
					def apply() = {
						Service.editCtrl.mergeSelectedNodes()
					}
				})
				contents += new MenuItem(new Action("Delete nodes") {
					def apply() = {
						Service.editCtrl.deleteNodes(eltNames)
					}
				})
				contents += new MenuItem(copyAction){
					this.peer.setEnabled(QuantoLibAPI.canCopy)
				}
			case "Edge" =>
				contents += new MenuItem(new Action("Edit edge") {
					def apply() = {
						Service.editCtrl.editEdge(eltName,edgeSource,edgeTarget,eltLabel)
					}
				})
				if(QuantoLibAPI.hasBreak(eltName)){
					contents += new MenuItem(new Action("Remove breakpoint") {
						def apply() = {
							Service.editCtrl.removeBreakFromEdge(eltName)
						}
					})
				}
				else {
					contents += new MenuItem(new Action("Add breakpoint") {
						def apply() = {
							Service.editCtrl.addBreakOnEdge(eltName)
						}
					})
				}
				contents += new MenuItem(new Action("Delete edge") {
					def apply() = {
						Service.editCtrl.deleteEdge(eltName)
					}
				})
			case "G" => // do nothing
		}
		super.show(invoker, x, y)
	}
}