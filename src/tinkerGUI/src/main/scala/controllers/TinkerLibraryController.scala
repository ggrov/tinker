package tinkerGUI.controllers

import tinkerGUI.controllers.events.{UpdateGTListEvent, DisableNavigationEvent, GraphTacticListEvent, PreviewEvent}
import tinkerGUI.model.exceptions.PSGraphModelException
import tinkerGUI.utils.TinkerDialog
import tinkerGUI.model.PSGraph

import quanto.util.json._

import scala.swing._
import java.io.File

class TinkerLibraryController() extends Publisher {

	/** Json model of the psgraph to be loaded.*/
	var json = new JsonObject()

	/** Graph tactics' list of the currently selected json model.*/
	var gtList:List[String] = List()

	/** Currently selected tactic. */
	var selectedGt:String = ""

	/** Currently selected file name.*/
	var fileName = ""

	/** Currently selected file extension.*/
	var fileExtn = ""

	/** Currently viewed subgraph index on total of subgraphs.*/
	var indexOnTotalText = ""

	/** Currently viewed subgraph index.*/
	var currentIndex = 0

	/** Model to work on. */
	var modelCreated = false

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
					gtList = (json / "graphs").asArray.foldLeft(List[String]()){case (l,gt)=> l:+(gt / "name").stringValue}
					previewGTFromJson((json / "main").stringValue,0)
					/*selectedGt = "main"
					QuantoLibAPI.updateLibraryPreviewFromJson(json / "graph")
					indexOnTotalText = "1 / 1"
					publish(PreviewEvent(show = true,hasPreview = true))
					publish(DisableNavigationEvent(Array("next","previous")))*/
					publish(UpdateGTListEvent())
				case _ => TinkerDialog.openErrorDialog("Error when parsing file "+f.getName+" to json")
			}
		}
	}

	def previewGTFromJson(tactic:String,index:Int) {
		var show = true
		(json / "graphs").asArray.foreach{ gt =>
			if((gt / "name").stringValue == tactic) {
				if ((gt / "graphs").asArray.nonEmpty) {
					currentIndex = index
					val tacSize = (gt / "graphs").asArray.size
					QuantoLibAPI.updateLibraryPreviewFromJson((gt / "graphs").asArray.get(index))
					indexOnTotalText = (index+1)+" / "+tacSize
					var arr = Array[String]()
					if(index==0) arr = arr :+ "previous"
					if(index == tacSize-1) arr = arr :+ "next"
					if(!modelCreated) arr = arr :+ "addtograph"
					publish(DisableNavigationEvent(arr))
				} else {
					//QuantoLibAPI.updateLibraryPreviewFromJson(json / "graph")
					currentIndex = 0
					indexOnTotalText = "0 / 0"
					publish(DisableNavigationEvent(Array("next","previous","zoomin","zoomout","addtograph")))
					show = false
				}
			}
		}
		selectedGt = tactic
		publish(PreviewEvent(show,hasPreview = true))
	}

	/** Method adding a json file to the current psgraph.
		*
		* All tactic are renamed to become unique, and the root of the json file's graph becomes the current graph.
		*/
	def addFileToGraph() {
		var valuesToReplace:Map[String,String] = Map()
		def updateGraphJsonWithNewNames(json: Json): Json = {
			QuantoLibAPI.updateValuesInGraph(json,valuesToReplace.toArray)
			/*var newJson = json
			valuesToReplace.foreach{ case (oldVal, newVal) =>
				newJson = Json.parse(newJson.toString.replace("\""+oldVal+"\"", "\""+newVal+"\"").replace("\""+oldVal+"(", "\""+newVal+"("))
			}
			newJson*/
		}
		def appendIndex(name:String, index:Int): String = {
			if(index == 0 && !Service.model.atCollection.contains(name) && !Service.model.gtCollection.contains(name)) name
			else if (index > 0 && !Service.model.atCollection.contains(name+"-"+index) && !Service.model.gtCollection.contains(name+"-"+index)) name+"-"+index
			else appendIndex(name, index+1)
		}
		try{
			Service.documentCtrl.registerChanges()
			val main = (json / "main").stringValue
			(json / "atomic_tactics").asArray.foreach{ tct =>
				val oldName = (tct / "name").stringValue
				val tctName = appendIndex(fileName+"-"+oldName,0)
				valuesToReplace = valuesToReplace + (oldName->tctName)
				val tctTactic = (tct / "tactic").stringValue
				//val tctArgs = (tct / "args").asArray.foldLeft(Array[Array[String]]()){ case (arr,arg) => arr :+ arg.asArray.foldLeft(Array[String]()){ case (a,s) => a :+ s.stringValue}}
				//Service.model.createAT(tctName,tctTactic,tctArgs)
				Service.model.createAT(tctName,tctTactic)
			}
			(json / "graphs").asArray.foreach{ tct =>
				val oldName = (tct / "name").stringValue
				if(oldName != main){
					val tctName = appendIndex(fileName+"-"+oldName,0)
					valuesToReplace = valuesToReplace + (oldName->tctName)
					val tctBranchType = (tct / "branch_type").stringValue
					//val tctArgs = (tct / "args").asArray.foldLeft(Array[Array[String]]()){ case (arr,arg) => arr :+ arg.asArray.foldLeft(Array[String]()){ case (a,s) => a :+ s.stringValue}}
					//Service.model.createGT(tctName,tctBranchType,tctArgs)
					Service.model.createGT(tctName,tctBranchType)
				}
			}
			Service.model.goalTypes = Service.model.goalTypes+"\n\n\n/* From "+fileName+" */\n\n" + (json / "goal_types").stringValue
			var nameNodeIdMap = Map[String,String]()
			(json / "graphs").asArray.foreach{ tct =>
				val oldName = (tct / "name").stringValue
				if(oldName == main){
					nameNodeIdMap = QuantoLibAPI.addFromJson(QuantoLibAPI.updateValuesInGraph(tct / "graphs" / 0,valuesToReplace.toArray))
				} else {
					(tct / "graphs").asArray.foreach{ gr =>
						Service.model.addSubgraphGT(valuesToReplace(oldName),QuantoLibAPI.updateValuesInGraph(gr,valuesToReplace.toArray).asObject,-1)
					}
				}
			}
			(json / "occurrences" / "atomic_tactics").asObject.foreach{ case (k,v) =>
				v.asArray.foreach{ occ =>
					occ.asArray.get(0) match {
						case Some(g:JsonString) =>
							if(g.stringValue == main) Service.model.addATOccurrence(valuesToReplace(k),Service.model.getCurrentGTName, Service.model.currentIndex, nameNodeIdMap(valuesToReplace(k)))
							else Service.model.addATOccurrence(valuesToReplace(k),valuesToReplace(g.stringValue),occ.asArray.get(1).intValue,occ.asArray.get(2).stringValue)
						case _ => throw new JsonAccessException("Json string type expected",json)
					}
				}
			}
			(json / "occurrences" / "graph_tactics").asObject.foreach{ case (k,v) =>
				v.asArray.foreach{ occ =>
					occ.asArray.get(0) match {
						case Some(g:JsonString) =>
							if(g.stringValue == main) Service.model.addGTOccurrence(valuesToReplace(k),Service.model.getCurrentGTName, Service.model.currentIndex, nameNodeIdMap(valuesToReplace(k)))
							else Service.model.addGTOccurrence(valuesToReplace(k),valuesToReplace(g.stringValue),occ.asArray.get(1).intValue,occ.asArray.get(2).stringValue)
						case _ => throw new JsonAccessException("Json string type expected",json)
					}
				}
			}
			publish(GraphTacticListEvent())
			Service.editCtrl.updateEditors
		} catch {
			case e:JsonAccessException => Service.editCtrl.logStack.addToLog("Json parse error",e.getMessage)
			case e:PSGraphModelException => Service.editCtrl.logStack.addToLog("Model error",e.msg)
		}
	}
}