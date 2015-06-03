package tinkerGUI.model

import scala.swing.Action
import tinkerGUI.controllers.TinkerDialog
import quanto.util.json._

class ATManager() {
	var tacticCollection: Map[String,AtomicTactic] = Map()

	// behaviours : create, update, delete

	def createTactic(id:String,tactic:String,args:Array[Array[String]]):Boolean = {
		if(tacticCollection contains id){
			false
		} else {
			var t:AtomicTactic = new AtomicTactic(id,tactic)
			t.updateArguments(args)
			tacticCollection += id -> t
			true
		}
	}

	def updateTactic(id:String, newId:String, newTactic:String, newArgs:Array[Array[String]]):Boolean = {
		tacticCollection get id match {
			case Some(t:AtomicTactic) =>
				if(t.occs.size < 2){
					t.name = newId
					t.tactic = newTactic
					t.args = newArgs
					if(id != newId){
						tacticCollection += (newId -> t)
						tacticCollection -= id
					}
					true
				} else {
					false
				}
			case None =>
				throwError("Atomic tactic "+id+" not found")
				false
		}
	}

	def updateAllTactics(id:String, newId:String, newTactic:String, newArgs:Array[Array[String]], graph:String):Array[String] = {
		var nodeArray:Array[String] = Array()
		tacticCollection get id match {
			case Some(t:AtomicTactic) =>
				t.name = newId
				t.tactic = newTactic
				t.args = newArgs
				if(id != newId){
					tacticCollection += (newId -> t)
					tacticCollection -= id
				}
				nodeArray = t.getOccurrencesInGraph(graph)
			case None =>
				throwError("Atomic tactic "+id+" not found")
		}
		nodeArray
	}

	def addOccurrence(id:String, graph:String, node:String) {
		tacticCollection get id match {
			case Some(t:AtomicTactic) =>
				t.addOccurrence(Tuple2(graph,node))
			case None =>
				throwError("Atomic tactic "+id+" not found")
		}
	}

	def removeOccurrence(id:String, graph:String, node:String) {
		tacticCollection get id match {
			case Some(t:AtomicTactic) =>
				t.removeOccurrence(Tuple2(graph,node))
			case None =>
				throwError("Atomic tactic "+id+" not found")
		}
	}

	def getFullName(id:String):String = {
		tacticCollection get id match {
			case Some(t:AtomicTactic) =>
				t.name+"("+t.argumentsToString()+")"
			case None =>
				throwError("Atomic tactic "+id+" not found")
				"Not Found"
		}
	}

	def getTacticCoreId(id:String):String = {
		tacticCollection get id match {
			case Some(t:AtomicTactic) =>
				t.tactic
			case None =>
				throwError("Atomic tactic "+id+" not found")
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