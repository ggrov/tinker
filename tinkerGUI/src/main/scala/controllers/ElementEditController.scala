package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.KeyReleased
import scala.swing.event.KeyPressed
import scala.swing.event.ButtonClicked
import scala.swing.event.Key._
import scala.swing.event.Key
import tinkerGUI.utils.ArgumentParser

class ElementEditController() extends Publisher {
	var elementName = ""
	var elementArguments = ""

	def reset = {
		elementName = ""
		elementArguments = ""
	}

	def addValueListener(elt: TextField, isGraphTactic: Boolean){
		val eltNameArg = ArgumentParser.separateNameFromArgument(elt.text)
		elementName = eltNameArg._1
		elementArguments = eltNameArg._2
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(c, key, _, _) =>
				if(c == elt){
					var (name, arguments) = ArgumentParser.separateNameFromArgument(elt.text)
					if(name == elementName && arguments != elementArguments && (key != Key.Colon && key != Key.Comma && key != Key.Space)){
						val actualArgs = Service.parseAndUpdateArguments(name, arguments)
						elementArguments = actualArgs
						val oldPosition = elt.text.length-elt.caret.position
						elt.text = name+"("+actualArgs+")"
						elt.caret.position = elt.text.length-oldPosition
						QuantoLibAPI.editSelectedElementValue(elt.text)
					}
					else if(name != elementName && name != "" && arguments != elementArguments){
						val actualName = Service.updateTacticName(elementName, name, isGraphTactic)
						val actualArgs = Service.parseAndUpdateArguments(actualName, arguments)
						elementName = actualName
						val oldPosition = elt.caret.position
						elt.text = actualName+"("+actualArgs+")"
						elt.caret.position = oldPosition
						QuantoLibAPI.editSelectedElementValue(elt.text)
					}
					else if(name != elementName && name != "" && arguments == elementArguments){
						val actualName = Service.updateTacticName(elementName, name, isGraphTactic)
						elementName = actualName
						val oldPosition = elt.caret.position
						elt.text = actualName+"("+arguments+")"
						elt.caret.position = oldPosition
						QuantoLibAPI.editSelectedElementValue(elt.text)
					}
				}
		}
	}

	def getAtomicTacticValue(value: String): String = {
		val name = ArgumentParser.separateNameFromArgument(value)._1
		Service.getAtomicTacticValue(name)
	}

	def addAtmTctValueListener(elt: TextField, node:String){
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(c, key, _, _) =>
				val name = ArgumentParser.separateNameFromArgument(node)._1
				if(elementName == "") elementName = name
				if(c == elt){
					Service.setAtomicTacticValue(elementName, elt.text)
				}
		}
	}

	def delete(eltName: String){
		QuantoLibAPI.userDeleteElement(eltName)
		publish(NothingSelectedEvent())
	}

	def addNewSubgraph(tactic: String, isOr: Boolean){
		val name = ArgumentParser.separateNameFromArgument(tactic)._1
		if(elementName == "") elementName = name
		Service.addSubgraph(elementName, isOr)
	}

	def setIsNestedOr(eltName: String, isOr: Boolean) = Service.setIsOr(ArgumentParser.separateNameFromArgument(eltName)._1, isOr)
	def getIsNestedOr(eltName: String) = Service.isNestedOr(ArgumentParser.separateNameFromArgument(eltName)._1)

	def addEdgeValueListener(elt: TextField) {
		var prevValue = ""
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(c, key, _, _) =>
				if(c == elt && elt.text != "" && elt.text != prevValue){
					prevValue = elt.text
					QuantoLibAPI.editSelectedElementValue(elt.text)
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

	val addBreakpoints = new Action("Add breakpoint") {
		def apply() {
			QuantoLibAPI.addBreakpointOnSelectedEdges()
		}
	}

	val removeBreakpoint = new Action("Remove breakpoint"){
		def apply() {
			QuantoLibAPI.removeSelectedBreakpoint()
		}
	}

	val mergeAction = new Action("Yes"){
		def apply() {
			QuantoLibAPI.mergeSelectedVertices()
			TinkerDialog.close()
		}
	}
	val cancelAction = new Action("Cancel"){
		def apply() {
			TinkerDialog.close()
		}
	}

	def addMergeListener(btn: Button, names: Set[String]){
		listenTo(btn)
		reactions += {
			case ButtonClicked(b: Button) =>
				if(b==btn){
					TinkerDialog.openConfirmationDialog("<html>You are about to merge these nodes.</br>Do you wish to continue ?</html>", Array(mergeAction, cancelAction))
				}
		}
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case NothingSelectedEventAPI() =>
			publish(NothingSelectedEvent())
		case OneVertexSelectedEventAPI(name, typ, value) =>
			typ match {
				case "RT_ID" => publish(OneVertexSelectedEvent(name, "Identity", value))
				case "RT_ATM" => publish(OneVertexSelectedEvent(name, "Atomic", value))
				case "RT_NST" => publish(OneVertexSelectedEvent(name, "Nested", value))
				case "break" => publish(OneVertexSelectedEvent(name, "Breakpoint", value))
			}
		case OneEdgeSelectedEventAPI(name, value, source, target) =>
			publish(OneEdgeSelectedEvent(name, value, source, target))
		case ManyVertexSelectedEventAPI(names) =>
			publish(ManyVertexSelectedEvent(names))
	}
}