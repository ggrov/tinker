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
	def addValueListener(elt: TextField){
		elementName = ArgumentParser.separateNameFromArgument(elt.text)._1
		elementArguments = ArgumentParser.separateNameFromArgument(elt.text)._2
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(_, key, _, _) =>
				val name = ArgumentParser.separateNameFromArgument(elt.text)._1
				val arguments = ArgumentParser.separateNameFromArgument(elt.text)._2
				if(name == elementName && arguments != elementArguments){
					Service.parseArguments(name, arguments)
					QuantoLibAPI.editSelectedElementValue(elt.text)
					elementArguments = arguments
				}
				else if(name != elementName && name != "" && name == Service.checkNodeName(name, 0, false)){
					Service.updateTacticName(elementName, name)
					Service.parseArguments(name, arguments)
					QuantoLibAPI.editSelectedElementValue(elt.text)
					elementName = name
				}
		}
	}

	def getArgumentValue(node: String) = Service.getArgumentsOfTactic(node)

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
		val name = ArgumentParser.separateNameFromArgument(elt)._1
		if(elementName == "") elementName = name
		listenTo(btn)
		reactions += {
			case ButtonClicked(b: Button) =>
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

	val mergeAction = new Action("ok"){
		def apply() {
		}
	}

	def addMergeListener(btn: Button, names: Set[String]){
		listenTo(btn)
		reactions += {
			case ButtonClicked(b: Button) =>
				if(b==btn){
					QuantoLibAPI.mergeSelectedVertices()
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
			}
		case OneEdgeSelectedEventAPI(name, value, source, target) =>
			publish(OneEdgeSelectedEvent(name, value, source, target))
		case ManyVertexSelectedEventAPI(names) =>
			publish(ManyVertexSelectedEvent(names))
	}
}