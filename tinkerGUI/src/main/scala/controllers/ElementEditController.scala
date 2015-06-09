package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.KeyReleased
import scala.swing.event.KeyPressed
import scala.swing.event.ButtonClicked
import scala.swing.event.Key._
import scala.swing.event.Key
import tinkerGUI.utils.{ArgumentParser, TinkerDialog}

class ElementEditController() extends Publisher {
	var dialog:Dialog = new Dialog()
	var elementName = ""
	var elementArguments = ""

	def reset = {
		elementName = ""
		elementArguments = ""
	}

	def delete(eltName: String){
		QuantoLibAPI.userDeleteElement(eltName)
		publish(NothingSelectedEvent())
	}

	def addEdgeValueListener(e: String, elt: TextField) {
		var prevValue = ""
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(c, key, _, _) =>
				if(c == elt && elt.text != "" && elt.text != prevValue){
					prevValue = elt.text
					QuantoLibAPI.setEdgeValue(e, elt.text)
				}
		}
	}

	def addEdgeListener(e: String, src: TextField, tgt: TextField){
		listenTo(src.keys)
		listenTo(tgt.keys)
		reactions += {
			case KeyReleased(c, key, _, _) =>
				if(c == src || c == tgt)
				QuantoLibAPI.userUpdateEdge(e, src.text, tgt.text)
		}
	}

	def breakpoint(e: String): Action = {
		if(QuantoLibAPI.hasBreak(e)){
			new Action("Remove breakpoint") {
				def apply() {
					QuantoLibAPI.removeBreakpointFromEdge(e)
				}
			}
		}
		else {
			new Action("Add breakpoint") {
				def apply() {
					QuantoLibAPI.addBreakpointOnEdge(e)
				}
			}
		}
	}

	def removeBreakpoint(n:String):Action = {
		new Action("Remove breakpoint"){
			def apply() {
				QuantoLibAPI.removeBreakpoint(n)
			}
		}
	}

	val mergeAction = new Action("Yes"){
		def apply() {
			QuantoLibAPI.mergeSelectedVertices()
			dialog.close()
		}
	}
	val cancelAction = new Action("Cancel"){
		def apply() {
			dialog.close()
		}
	}

	def addMergeListener(btn: Button, names: Set[String]){
		listenTo(btn)
		reactions += {
			case ButtonClicked(b: Button) =>
				if(b==btn){
					dialog = TinkerDialog.openConfirmationDialog("<html>You are about to merge these nodes.</br>Do you wish to continue ?</html>", Array(mergeAction, cancelAction))
				}
		}
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case NothingSelectedEventAPI() =>
			publish(NothingSelectedEvent())
		case OneVertexSelectedEventAPI(name, typ, value) =>
			typ match {
				case "T_Identity" => publish(OneVertexSelectedEvent(name, "Identity", value))
				case "T_Atomic" => publish(OneVertexSelectedEvent(name, "Atomic", value))
				case "T_Graph" => publish(OneVertexSelectedEvent(name, "Nested", value))
				case "G_Break" => publish(OneVertexSelectedEvent(name, "Breakpoint", value))
				case "G" => publish(OneVertexSelectedEvent(name, "Goal", value))
			}
		case OneEdgeSelectedEventAPI(name, value, source, target) =>
			publish(OneEdgeSelectedEvent(name, value, source, target))
		case ManyVertexSelectedEventAPI(names) =>
			publish(ManyVertexSelectedEvent(names))
	}
}