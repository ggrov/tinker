package tinkerGUI.model

import scala.swing.Action
import tinkerGUI.controllers.TinkerDialog
import quanto.util.json._

class ATManager() {
	var tacticCollection: Map[String,AtomicTactic] = Map()

	def findTactic(id:String):Option[AtomicTactic] = {
		tacticCollection.foreach{ case (k,v) =>
			k match {
				case `id` => return Some(v)
				case _ =>
			}
		}
		return None
	}

	// behaviours : create, update, delete

	def createTactic(id:String,tactic:String,args:Array[Array[String]]):Boolean = {
		var checked:Boolean = false
		// look for tactic in map
		findTactic(id) match {
			// nothing found : create new one
			case None =>
				var t:AtomicTactic = new AtomicTactic(id,tactic)
				t.updateArguments(args)
				tacticCollection += id -> t
				checked = true
			// name already used
			case Some(t:AtomicTactic) =>
				checked = false
		}
		return checked
	}

	def addOccurence(id:String, graph:String, node:String) {
		findTactic(id) match {
			case Some(t:AtomicTactic) =>
				t.addOccurence(Array(graph,node))
			case None =>
				throwError("Atomic tactic "+id+" not found")
		}
	}

	def getFullName(id:String):String = {
		findTactic(id) match {
			case Some(t:AtomicTactic) =>
				t.name+"("+t.argumentsToString()+")"
			case None =>
				"Not Found"
		}
		
	}

	def toJson:JsonArray = {
		var arr:Array[JsonObject] = Array()
		tacticCollection.foreach{ case(k,v) =>
			arr = arr :+ v.toJson
		}
		return JsonArray(arr)
	}

	def throwError(text: String) = TinkerDialog.openErrorDialog(text)

}