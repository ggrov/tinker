package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.KeyReleased
import scala.swing.event.ButtonClicked
import scala.swing.event.Key._
import scala.swing.event.Key

class ElementEditController() extends Publisher {
	def addValueListener(elt: TextField){
		var prevText = elt.text
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(_, key, _, _) =>
				if(prevText != elt.text){
					QuantoLibAPI.editSelectedElementValue(elt.text)
					prevText = elt.text
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

	def addEdgeListener(e: String, src: TextField, tgt: TextField){
		listenTo(src.keys)
		listenTo(tgt.keys)
		reactions += {
			case KeyReleased(_, key, _, _) =>
				QuantoLibAPI.userUpdateEdge(e, src.text, tgt.text)
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
	}
}