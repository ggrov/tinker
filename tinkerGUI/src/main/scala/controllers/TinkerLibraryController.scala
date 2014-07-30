package tinkerGUI.controllers

import scala.swing._
import quanto.util.json._
import java.io.{FilenameFilter, File}
import scala.collection.mutable.ArrayBuffer
import tinkerGUI.utils.ArgumentParser

class TinkerLibraryController() extends Publisher {

	var json = new JsonObject()
	var fileName = ""
	def getLibraryView = QuantoLibAPI.getLibraryPreview

	def previewFile(f: File){
		if(!f.isDirectory){
			Json.parse(f) match {
				case j: JsonObject =>
					fileName = f.getName().substring(0, f.getName().lastIndexOf("."))
					json = j
					QuantoLibAPI.updateLibraryPreviewFromJson((json ? "graph"))
					publish(ShowPreviewEvent())
				case _ => TinkerDialog.openErrorDialog("Error when parsing file "+f.getName()+" to json")
			}
		}
	}


	val addFileToGraph = new Action("Add to graph"){
		def apply(){
			var valuesToReplace = Map[String, String]()
			def removeBrackets(s: String): String = {
				s.substring(1, s.length-1)
			}
			def updateGraphJsonWithNewNames(json: Json): Json = {
				var newJson = json
				valuesToReplace.foreach{ case (oldVal, newVal) =>
					newJson = Json.parse(newJson.toString.replace(oldVal, newVal))
				}
				return newJson
			}
			(json ? "atomic_tactics").asArray.foreach{ tct =>
				val oldVal = removeBrackets((tct / "name").toString)
				var tctName = fileName+"-"+oldVal
				val tctTactic = removeBrackets((tct / "tactic").toString)
				tctName = Service.checkNodeName(tctName, 0, true, false, false)
				Service.setAtomicTacticValue(tctName, tctTactic)
				var tctArgs = Array[Array[String]]()
				(tct / "args").asArray.foreach{ a =>
					var arg = Array[String]()
					a.asArray.foreach{ s => arg = arg :+ removeBrackets(s.toString)}
					tctArgs = tctArgs :+ arg
				}
				Service.updateArguments(tctName, tctArgs)
				valuesToReplace = valuesToReplace + ((
					"\""+oldVal+"("+ArgumentParser.argumentsToString(tctArgs)+")\"",
					"\""+tctName+"("+ArgumentParser.argumentsToString(tctArgs)+")\""
				))
			}
			(json ? "graph_tactics").asArray.foreach{ tct =>
				val oldVal = removeBrackets((tct / "name").toString)
				var tctName = fileName+"-"+oldVal
				val isOr = (tct / "isOr").boolValue
				tctName = Service.checkNodeName(tctName, 0, true, true, isOr)
				var tctArgs = Array[Array[String]]()
				(tct / "args").asArray.foreach{ a =>
					var arg = Array[String]()
					a.asArray.foreach{ s => arg = arg :+ removeBrackets(s.toString)}
					tctArgs = tctArgs :+ arg
				}
				Service.updateArguments(tctName, tctArgs)
				valuesToReplace = valuesToReplace + ((
					"\""+oldVal+"("+ArgumentParser.argumentsToString(tctArgs)+")\"",
					"\""+tctName+"("+ArgumentParser.argumentsToString(tctArgs)+")\""
				))
			}
			(json ? "graph_tactics").asArray.foreach{ tct =>
				val tctName = fileName+"-"+removeBrackets((tct / "name").toString)
				(tct / "graphs").asArray.foreach{ gr =>
					Service.saveGraphSpecificTactic(tctName, updateGraphJsonWithNewNames(gr))
				}
			}
			QuantoLibAPI.addFromJson(updateGraphJsonWithNewNames((json ? "graph")))
		}
	}
}