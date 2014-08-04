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
			def updateGraphJsonWithNewNames(json: Json): Json = {
				var newJson = json
				valuesToReplace.foreach{ case (oldVal, newVal) =>
					newJson = Json.parse(newJson.toString.replace(oldVal, newVal))
				}
				return newJson
			}
			(json ? "atomic_tactics").asArray.foreach{ tct =>
				val oldVal = (tct / "name").stringValue
				var tctName = fileName+"-"+oldVal
				val tctTactic = (tct / "tactic").stringValue
				tctName = ArgumentParser.separateNameFromArgument(Service.createNode(tctName, false, false))._1
				Service.setAtomicTacticValue(tctName, tctTactic)
				var tctArgs = Array[Array[String]]()
				(tct / "args").asArray.foreach{ a =>
					var arg = Array[String]()
					a.asArray.foreach{ s => arg = arg :+ s.stringValue}
					tctArgs = tctArgs :+ arg
				}
				Service.updateArguments(tctName, tctArgs)
				valuesToReplace = valuesToReplace + ((
					"\""+oldVal+"("+ArgumentParser.argumentsToString(tctArgs)+")\"",
					"\""+tctName+"("+ArgumentParser.argumentsToString(tctArgs)+")\""
				))
			}
			(json ? "graph_tactics").asArray.foreach{ tct =>
				val oldVal = (tct / "name").stringValue
				var tctName = fileName+"-"+oldVal
				val isOr = (tct / "isOr").boolValue
				tctName = ArgumentParser.separateNameFromArgument(Service.createNode(tctName, true, isOr))._1
				var tctArgs = Array[Array[String]]()
				(tct / "args").asArray.foreach{ a =>
					var arg = Array[String]()
					a.asArray.foreach{ s => arg = arg :+ s.stringValue}
					tctArgs = tctArgs :+ arg
				}
				Service.updateArguments(tctName, tctArgs)
				valuesToReplace = valuesToReplace + ((
					"\""+oldVal+"("+ArgumentParser.argumentsToString(tctArgs)+")\"",
					"\""+tctName+"("+ArgumentParser.argumentsToString(tctArgs)+")\""
				))
			}
			(json ? "graph_tactics").asArray.foreach{ tct =>
				val tctName = fileName+"-"+(tct / "name").stringValue
				(tct / "graphs").asArray.foreach{ gr =>
					Service.saveGraphSpecificTactic(tctName, updateGraphJsonWithNewNames(gr))
				}
			}
			Service.setGoalTypes(Service.getGoalTypes + "\n\n\n/* From "+fileName+" */\n\n" + (json / "goal_types").stringValue)
			QuantoLibAPI.addFromJson(updateGraphJsonWithNewNames((json ? "graph")))
		}
	}
}