package tinkerGUI.controllers

import scala.swing._
import quanto.util.json._
import java.io.{FilenameFilter, File}

class TinkerLibraryController() extends Publisher {

	def getLibraryView = QuantoLibAPI.getLibraryPreview

	def previewFile(f: File){
		if(!f.isDirectory){
			val json = Json.parse(f)
			QuantoLibAPI.updateLibraryPreviewFromJson(json)
			publish(ShowPreviewEvent())
		}
	}
}