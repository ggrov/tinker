/* The following is inspired by the Document class in Quantomatic.
   It as been change to support the new json format of psgraphs. */

package tinkerGUI.controllers

import quanto.util.FileHelper
import tinkerGUI.controllers.events.DocumentChangedEvent
import tinkerGUI.utils.TinkerDialog

import scala.swing._
import java.io.{FileNotFoundException, IOException, File}
import quanto.util.json._
import java.util.prefs.Preferences
import javax.swing.filechooser.FileNameExtensionFilter

object DocumentService extends Publisher {
	var file : Option[File] = None

	var proofTitle = "untitled"

	def title = file.map(f => f.getName).getOrElse(proofTitle)

	def previousDir: File = {
		val prefs = Preferences.userRoot().node(this.getClass.getName)
		new File(prefs.get("previousDir", System.getProperty("user.home")))
	}
	def previousDir_=(f: File) {
		val dir = if (f.isDirectory) f.getPath else f.getParent
		if (dir != null) {
			val prefs = Preferences.userRoot().node(this.getClass.getName)
			prefs.put("previousDir", dir)
		}
	}

	def save(fopt: Option[File] = None, json: Json){
		fopt.orElse(file).map { f =>
			try {
				json.writeTo(f)
				file = Some(f)
				if(!Service.documentCtrl.recentProofs.values.map{p => p._2}.contains(f.getAbsolutePath)){
					Service.documentCtrl.recentProofs.push(f.getName,f.getAbsolutePath)
				}
				Service.documentCtrl.unsavedChanges = false
				publish(DocumentChangedEvent(false))
			} catch {
				case _: IOException => TinkerDialog.openErrorDialog("Error while saving : file unwriteable.")
				case e: Exception =>
					TinkerDialog.openErrorDialog("Error while saving : unexpected error.")
					e.printStackTrace()
			}
		}
	}

	def saveAs(rootDir: Option[String] = None, json: Json) {
		val chooser = new FileChooser()
		chooser.peer.setCurrentDirectory(rootDir match {
			case Some(d) => new File(d)
			case None => previousDir
		})
		chooser.peer.setSelectedFile(new File(proofTitle+".psgraph"))
		chooser.fileFilter = new FileNameExtensionFilter("Tinker Proof Strategy Graph File (*.psgraph)", "psgraph")
		chooser.showSaveDialog(Service.getMainFrame) match {
			case FileChooser.Result.Approve =>
				previousDir = chooser.selectedFile
				val p = chooser.selectedFile.getAbsolutePath
				val file = new File(if (p.endsWith("." + "psgraph")) p else p + "." + "psgraph")
				if (promptExists(file)) save(Some(file), json)
			case _ =>
		}
	}

	def exportSvg(rootDir: Option[String] = None): Unit ={
		val chooser = new FileChooser()
		chooser.peer.setCurrentDirectory(rootDir match {
			case Some(d) => new File(d)
				case None => previousDir
		})
		chooser.peer.setSelectedFile(new File(proofTitle+".svg"))
		chooser.fileFilter = new FileNameExtensionFilter("SVG File (*.svg)","svg")
		chooser.showSaveDialog(Service.getMainFrame) match {
			case FileChooser.Result.Approve =>
				previousDir = chooser.selectedFile
				val p = chooser.selectedFile.getAbsolutePath
				val file = new File(if (p.endsWith("." + "svg")) p else p + "." + "svg")
				if(promptExists(file)) QuantoLibAPI.toSvg(file)
			case _ =>
		}
	}

	def promptExists(f: File) = {
		if (f.exists()) {
			Dialog.showConfirmation(
				title = "File exists",
				message = "File exists, do you wish to overwrite?") == Dialog.Result.Yes
		}
		else true
	}

	def promptUnsaved(json: Json) = {
		if (Service.documentCtrl.unsavedChanges) {
			val choice = Dialog.showOptions(
				title = "Unsaved changes",
				message = "Do you want to save your changes or discard them?",
				entries = "Save" :: "Discard" :: "Cancel" :: Nil,
				initial = 0
			)
			// scala swing dialogs implementation is dumb, here's what I found :
			// Result(0) = Save, Result(1) = Discard, Result(2) = Cancel
			if (choice == Dialog.Result(0)) {
				file match {
					case Some(_) => DocumentService.save(None, json)
					case None => DocumentService.saveAs(None, json)
				}
				true
			}
			else choice == Dialog.Result(1)
		} else true
	}

	def showOpenDialog(rootDir: Option[String] = None): Option[Json] = {
		val chooser = new FileChooser()
		chooser.peer.setCurrentDirectory(rootDir match {
			case Some(d) => new File(d)
			case None => previousDir
		})
		chooser.fileFilter = new FileNameExtensionFilter("Tinker Proof Strategy Graph File (*.psgraph)", "psgraph")
		chooser.showOpenDialog(Service.getMainFrame) match {
			case FileChooser.Result.Approve =>
				previousDir = chooser.selectedFile
				load(chooser.selectedFile) match{
					case Some(j: Json) => Some(j)
					case None => None
				}
			case _ => None
		}
	}

	def load(f : File): Option[Json] = {
		try {
			val json = Json.parse(f)
			file = Some(f)
			previousDir = f
			if(!Service.documentCtrl.recentProofs.values.map{p => p._2}.contains(f.getAbsolutePath)){
				Service.documentCtrl.recentProofs.push(f.getName,f.getAbsolutePath)
			}
			Some(json)
		} catch {
			case e: JsonParseException => 
				TinkerDialog.openErrorDialog("loading : mal-formed JSON: " + e.getMessage)
				None
			case e: FileNotFoundException => 
				TinkerDialog.openErrorDialog("loading : file not found")
				None
			case e: IOException => 
				TinkerDialog.openErrorDialog("loading : file unreadable")
				None
			case e: Exception =>
				TinkerDialog.openErrorDialog("loading : unexpected error")
				e.printStackTrace()
				None
		}
	}
}