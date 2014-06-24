package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.KeyReleased
import scala.swing.event.Key._
import scala.swing.event.Key

class NodeEditController() extends Publisher {
	def addListener(elt: TextField){
		var prevText = elt.text
		listenTo(elt.keys)
		reactions += {
			case KeyReleased(_, key, _, _) =>
				if(prevText != elt.text){
					QuantoLibAPI.editSelectedNodeValue(elt.text)
					prevText = elt.text
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
	}
}