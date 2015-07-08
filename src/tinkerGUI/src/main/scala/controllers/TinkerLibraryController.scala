package tinkerGUI.controllers

import tinkerGUI.controllers.events.{GraphTacticListEvent, PreviewEvent}
import tinkerGUI.utils.TinkerDialog
import tinkerGUI.model.PSGraph

import quanto.util.json._

import scala.swing._
import java.io.File

class TinkerLibraryController(model:PSGraph) extends Publisher {

	/** Json model of the psgraph to be loaded.*/
	var json = new JsonObject()
	/** Graph tactics' list of the currently selected json model.*/
	var gtList:List[String] = List()
	var selectedGt:String = ""
	/** Currently selected file name.*/
	var fileName = ""
	/**Currently selected file extension.*/
	var fileExtn = ""

	/** Method to get the preview from QuantoLibAPI.*/
	def getLibraryView = QuantoLibAPI.getLibraryPreview

	/** Method updating the library preview.
		*
		* @param f file from which to upload the graph.
		*/
	def previewFile(f: File){
		if(!f.isDirectory){
			Json.parse(f) match {
				case j: JsonObject =>
					fileName = f.getName.substring(0, f.getName.lastIndexOf("."))
					fileExtn = f.getName.substring(f.getName.lastIndexOf("."))
					json = j
					gtList = (json / "graph_tactics").asArray.foldLeft(List[String]()){case (l,gt)=> l:+(gt / "name").stringValue} :+ "main"
					selectedGt = "main"
					QuantoLibAPI.updateLibraryPreviewFromJson(json / "graph")
					publish(PreviewEvent(show = true,hasPreview = true))
				case _ => TinkerDialog.openErrorDialog("Error when parsing file "+f.getName+" to json")
			}
		}
	}

	def previewGTFromJson(tactic:String,index:Int) {
		if(tactic == "main") QuantoLibAPI.updateLibraryPreviewFromJson(json / "graph")
		else (json / "graph_tactics").asArray.foreach{ gt =>
			if((gt / "name").stringValue == tactic) QuantoLibAPI.updateLibraryPreviewFromJson((gt / "graphs").asArray.get(index))
		}
		selectedGt = tactic
		publish(PreviewEvent(show = true,hasPreview = true))
	}

	/** Method adding a json file to the current psgraph.
		*
		* All tactic are renamed to become unique, and the root of the json file's graph becomes the current graph.
		*/
	def addFileToGraph() {
		var valuesToReplace:Map[String,String] = Map()
		def updateGraphJsonWithNewNames(json: Json): Json = {
			var newJson = json
			valuesToReplace.foreach{ case (oldVal, newVal) =>
				newJson = Json.parse(newJson.toString.replace(oldVal, newVal))
			}
			newJson
		}
		def appendIndex(name:String, index:Int): String = {
			if(index == 0 && !model.atCollection.contains(name) && !model.gtCollection.contains(name)) name
			else if (index > 0 && !model.atCollection.contains(name+"-"+index) && !model.gtCollection.contains(name+"-"+index)) name+"-"+index
			else appendIndex(name, index+1)
		}
		try{
			(json / "atomic_tactics").asArray.foreach{ tct =>
				val oldName = (tct / "name").stringValue
				val tctName = appendIndex(fileName+"-"+oldName,0)
				valuesToReplace = valuesToReplace + (oldName->tctName)
				val tctTactic = (tct / "tactic").stringValue
				val tctArgs = (tct / "args").asArray.foldLeft(Array[Array[String]]()){ case (arr,arg) => arr :+ arg.asArray.foldLeft(Array[String]()){ case (a,s) => a :+ s.stringValue}}
				model.createAT(tctName,tctTactic,tctArgs)
			}
			(json / "graph_tactics").asArray.foreach{ tct =>
				val oldName = (tct / "name").stringValue
				val tctName = appendIndex(fileName+"-"+oldName,0)
				valuesToReplace = valuesToReplace + (oldName->tctName)
				val tctBranchType = (tct / "branchType").stringValue
				val tctArgs = (tct / "args").asArray.foldLeft(Array[Array[String]]()){ case (arr,arg) => arr :+ arg.asArray.foldLeft(Array[String]()){ case (a,s) => a :+ s.stringValue}}
				model.createGT(tctName,tctBranchType,tctArgs)
			}
			model.goalTypes = model.goalTypes+"\n\n\n/* From "+fileName+" */\n\n" + (json / "goal_types").stringValue
			(json / "graph_tactics").asArray.foreach{ tct =>
				val oldName = (tct / "name").stringValue
				(tct / "graphs").asArray.foreach{ gr =>
					model.addSubgraphGT(valuesToReplace(oldName),updateGraphJsonWithNewNames(gr).asObject,-1)
				}
			}
			val nameNodeIdMap = QuantoLibAPI.addFromJson(updateGraphJsonWithNewNames(json / "graph"))
			(json / "occurrences" / "atomic_tactics").asObject.foreach{ case (k,v) =>
				v.asArray.foreach{ occ =>
					occ.asArray.get(0) match {
						case Some(g:JsonString) =>
							if(g.stringValue == "main") model.addATOccurrence(valuesToReplace(k),model.getCurrentGTName, model.currentIndex, nameNodeIdMap(valuesToReplace(k)))
							else model.addATOccurrence(valuesToReplace(k),valuesToReplace(g.stringValue),occ.asArray.get(1).intValue,occ.asArray.get(2).stringValue)
						case _ => throw new JsonAccessException("Json string type expected",json)
					}
				}
			}
			(json / "occurrences" / "graph_tactics").asObject.foreach{ case (k,v) =>
				v.asArray.foreach{ occ =>
					occ.asArray.get(0) match {
						case Some(g:JsonString) =>
							if(g.stringValue == "main") model.addGTOccurrence(valuesToReplace(k),model.getCurrentGTName, model.currentIndex, nameNodeIdMap(valuesToReplace(k)))
							else model.addGTOccurrence(valuesToReplace(k),valuesToReplace(g.stringValue),occ.asArray.get(1).intValue,occ.asArray.get(2).stringValue)
						case _ => throw new JsonAccessException("Json string type expected",json)
					}
				}
			}
			publish(GraphTacticListEvent())
		} catch {
			case e:JsonAccessException => TinkerDialog.openErrorDialog(e.getMessage)
		}
	}
}