package tinkerGUI.controllers

import scala.swing._
import quanto.util.json._
import java.io.{FilenameFilter, File}

class TinkerLibraryController() extends Publisher {

	var json = new JsonObject()

	def getLibraryView = QuantoLibAPI.getLibraryPreview

	def previewFile(f: File){
		if(!f.isDirectory){
			Json.parse(f) match {
				case j: JsonObject =>
					json = j
					QuantoLibAPI.updateLibraryPreviewFromJson(json)
					publish(ShowPreviewEvent())
				case _ => TinkerDialog.openErrorDialog("Error when parsing file "+f.getName()+" to json")
			}
		}
	}

	val addFileToGraph = new Action("Add to graph"){
		def apply(){
			Service.addJsonToCurrent(json)
		}
	}

}