package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.KeyReleased
import scala.swing.event.KeyPressed
import scala.swing.event.ButtonClicked
import scala.swing.event.Key._
import scala.swing.event.Key

class ElementEditController() extends Publisher {
	var elementName = ""
	var elementArguments = ""

	def reset = {
		elementName = ""
		elementArguments = ""
	}

	def addValueListener(elt: TextField){
		val eltNameArg = ArgumentParser.separateNameFromArgument(elt.text)
		elementName = eltNameArg._1
		elementArguments = eltNameArg._2
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(c, key, _, _) =>
				if(c == elt){
					var (name, arguments) = ArgumentParser.separateNameFromArgument(elt.text)
					if(name == elementName && arguments != elementArguments){
						Service.parseArguments(name, arguments)
						elementArguments = arguments
					}
					else if(name != elementName && name != ""){
						Service.updateTacticName(elementName, name)
						Service.parseArguments(name, arguments)
						elementName = name
					}
					QuantoLibAPI.editSelectedElementValue(elt.text)
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

	def addDeleteListener(btn: Button, eltName: String){
		listenTo(btn)
		reactions += {
			case ButtonClicked(b: Button) =>
				if(b==btn)  {
					QuantoLibAPI.userDeleteElement(eltName)
					publish(NothingSelectedEvent())
				}
		}
	}

	def addNewSubListener(btn: Button, elt: String, or: RadioButton){
		listenTo(btn)
		reactions += {
			case ButtonClicked(b: Button) =>
				val name = ArgumentParser.separateNameFromArgument(elt)._1
				if(elementName == "") elementName = name
				if(b==btn){
					Service.addSubgraph(elementName, or.selected)
				}
		}
	}

	def setIsNestedOr(eltName: String, isOr: Boolean) = Service.setIsOr(eltName, isOr)
	def getIsNestedOr(eltName: String) = Service.isNestedOr(eltName)

	def addEdgeListener(e: String, src: TextField, tgt: TextField){
		listenTo(src.keys)
		listenTo(tgt.keys)
		reactions += {
			case KeyReleased(_, key, _, _) =>
				QuantoLibAPI.userUpdateEdge(e, src.text, tgt.text)
		}
	}

	def addBreakpoints = {
		QuantoLibAPI.addBreakpointOnSelectedEdges()
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
				case "break" => publish(NothingSelectedEvent())
			}
		case OneEdgeSelectedEventAPI(name, value, source, target) =>
			publish(OneEdgeSelectedEvent(name, value, source, target))
		case ManyVertexSelectedEventAPI(names) =>
			publish(ManyVertexSelectedEvent(names))
	}
}