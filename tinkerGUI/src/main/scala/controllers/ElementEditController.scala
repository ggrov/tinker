package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.KeyReleased
import scala.swing.event.KeyPressed
import scala.swing.event.ButtonClicked
import scala.swing.event.Key._
import scala.swing.event.Key

class ElementEditController() extends Publisher {
	var valueText = ""
	def addValueListener(elt: TextField){
		valueText = elt.text
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(_, key, _, _) =>
				if(elt.text != "" && valueText != elt.text && elt.text == Service.checkNodeName(elt.text, 0, false)){
					Service.updateTacticName(valueText, elt.text)
					QuantoLibAPI.editSelectedElementValue(elt.text)
					valueText = elt.text
				}
		}
	}

	def addArgsListener(elt: TextField){
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(_, key, _, _) =>
				Service.parseArguments(valueText, elt.text)
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

	def addNewSubListener(btn: Button, eltName: String, or: RadioButton){
		if(valueText == "") valueText = eltName
		listenTo(btn)
		reactions += {
			case ButtonClicked(b: Button) =>
				if(b==btn){
					Service.addSubgraph(valueText, or.selected)
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