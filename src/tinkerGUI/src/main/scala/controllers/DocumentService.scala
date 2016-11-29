/* The following is inspired by the Document class in Quantomatic.
   It as been change to support the new json format of psgraphs. */

package tinkerGUI.controllers

import tinkerGUI.controllers.events.DocumentChangedEvent
import tinkerGUI.utils.TinkerDialog

import scala.swing._
import java.io.{FileNotFoundException, IOException, File}
import quanto.util.json._
import java.util.prefs.Preferences
import javax.swing.filechooser.FileNameExtensionFilter

/** Service to read and write psgraph files on the file management system.
	*
	* Inspired by [[quanto.gui.Document]].
	*/
object DocumentService extends Publisher {

	/** Optional current file, on which to save the current psgraph.
		* Note that the file name is also used as the document title.
		*/
	var file : Option[File] = None

	/** Current proof name, used as document title until the model has been saved on a file.*/
	var proofTitle = Service.model.mainTactic.name

	/** Method returning the document title (e.g. to be printed on windows).
		*
		* @return The title : either [[file]]'s name or [[proofTitle]]'s value.
		*/
	def title = file.map(f => f.getName).getOrElse(proofTitle)

	/** Method to access the previous directory used by the user.
		*
		* @return Previous directory used by user.
		*/
	def previousDir: File = {
		val prefs = Preferences.userRoot().node(this.getClass.getName)
		new File(prefs.get("previousDir", System.getProperty("user.home")))
	}

	/** Method to set the previous directory used by the user.
		*
		* @param f File to become previous directory.
		*/
	def previousDir_=(f: File) {
		val dir = if (f.isDirectory) f.getPath else f.getParent
		if (dir != null) {
			val prefs = Preferences.userRoot().node(this.getClass.getName)
			prefs.put("previousDir", dir)
		}
	}

	/** Method to save a psgraph model onto a file.
		*
		* @param fopt Optional file, default value is None, which will make the psgraph on [[file]]
		* @param json Psgraph model in json format.
		*/
	def save(fopt: Option[File] = None, json: Json){
		fopt.orElse(file).map { f =>
			try {
				json.writeTo(f)
				file = Some(f)
				if(!Service.documentCtrl.recentProofs.values.map{p => p._2}.contains(f.getAbsolutePath)){
					Service.documentCtrl.recentProofs.push(f.getName,f.getAbsolutePath)
				}
				Service.documentCtrl.unsavedChanges = false
				Service.documentCtrl.publish(DocumentChangedEvent(false))
			} catch {
				case _: IOException => TinkerDialog.openErrorDialog("Error while saving : file unwriteable.")
				case e: Exception =>
					TinkerDialog.openErrorDialog("Error while saving : unexpected error.")
					e.printStackTrace()
			}
		}
	}

	/** Method to save a psgraph model onto a file.
		* Will open a chooser dialog so the user can choose in which directory to save the psgraph,
		* and if a new file should be created.
		*
		* @param rootDir Optional directory with which to set the chooser starting directory.
		*                Default value is None which will make use of [[previousDir]].
		* @param json Psgraph model in json format.
		*/
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

	/** Method to save the current graph in a svg file.
		*
		* @param rootDir Optional directory with which to set the chooser starting directory.
		*                Default value is None which will make use of [[previousDir]].
		*/
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

	/** Method to save the current graph in a dot file.
		*
		* @param rootDir Optional directory with which to set the chooser starting directory.
		*                Default value is None which will make use of [[previousDir]].
		*/
	def exportDot(rootDir: Option[String] = None): Unit ={
		val chooser = new FileChooser()
		chooser.peer.setCurrentDirectory(rootDir match {
			case Some(d) => new File(d)
			case None => previousDir
		})
		chooser.peer.setSelectedFile(new File(proofTitle+".gv"))
		chooser.fileFilter = new FileNameExtensionFilter("DOT File (*.gv)","gv")
		chooser.showSaveDialog(Service.getMainFrame) match {
			case FileChooser.Result.Approve =>
				previousDir = chooser.selectedFile
				val p = chooser.selectedFile.getAbsolutePath
				val file = new File(if (p.endsWith("." + "gv")) p else p + "." + "gv")
				if(promptExists(file)) QuantoLibAPI.toDot(file)
			case _ =>
		}
	}

	/** Method displaying a prompt dialog in case a file exist.
		* Will ask if the user want to overwrite the file.
		*
		* @param f File to check the existence of.
		* @return Boolean if file is writable (true if file does not exist or user approved of overwriting).
		*/
	def promptExists(f: File):Boolean = {
		if (f.exists()) {
			Dialog.showConfirmation(
				title = "File exists",
				message = "File exists, do you wish to overwrite?") == Dialog.Result.Yes
		}
		else true
	}

	/** Method displaying a prompt dialog in case there are unsaved changes on the document.
		* Will ask the user if they want to save those changes or discard them.
		*
		* @param json Psgraph model in json, in case it needs to be saved.
		* @return Boolean to inform of save made if wanted.
		*/
	def promptUnsaved(json: Json):Boolean = {
		if (Service.documentCtrl.unsavedChanges) {
			val choice = Dialog.showOptions(
				title = "Unsaved changes",
				message = "Do you want to save your changes or discard them?",
				entries = "Save" :: "Discard" :: "Cancel" :: Nil,
				initial = 0
			)
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

	/** Method displaying a chooser dialog from which users can select a file to open.
		*
		* @param rootDir Optional directory with which to set the chooser starting directory.
		*                Default value is None which will make use of [[previousDir]].
		* @return Optional json result from loading the file (see [[load]]).
		*/
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

	/** Method opening a file and retrieving the potential json it has.
		*
		* @param f File to open.
		* @return Optional json result, None if exception occurs (unreadable file, bad json format, ...).
		*/
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