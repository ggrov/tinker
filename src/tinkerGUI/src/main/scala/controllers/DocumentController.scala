package tinkerGUI.controllers

import java.io.File

import quanto.util.json.{JsonObject, JsonAccessException}
import tinkerGUI.controllers.events.{GraphTacticListEvent, CurrentGraphChangedEvent, DocumentChangedEvent}
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{PSGraphModelException, SubgraphNotFoundException}
import tinkerGUI.utils.{TinkerDialog, FixedStack}

import scala.collection.mutable.ArrayBuffer
import scala.swing.Publisher

/** Controller managing read and write on a file, as well as the undo stack.
	*
	* @param model PSgraph model.
	*/
class DocumentController(model:PSGraph) extends Publisher {

	/** Stack keeping track of PSGraph json object, in case we want to redo things.*/
	val redoStack:FixedStack[JsonObject] = new FixedStack[JsonObject](20)

	/** Stack keeping track of PSGraph json object, in case we want to undo things.*/
	val undoStack:FixedStack[JsonObject] = new FixedStack[JsonObject](20)

	/** Boolean to know if there are any unsaved changes.*/
	var unsavedChanges:Boolean = false

	/** Stack of the last 5 psgraphs files accessed.*/
	val recentProofs = new FixedStack[(String,String)](5)

	/** Method to undo changes.
		*
		*/
	def undo() {
		undoStack.pop() match {
			case Some(j:JsonObject) =>
				try{
					redoStack.push(model.updateJsonPSGraph())
					model.loadJsonGraph(j)
					modelReload()
				} catch {
					case e:PSGraphModelException => TinkerDialog.openErrorDialog(e.msg)
					case e:JsonAccessException => TinkerDialog.openErrorDialog(e.getMessage)
				}
			case None => publish(DocumentChangedEvent(unsavedChanges))
		}
	}

	/** Method to redo changes.
		*
		*/
	def redo() {
		redoStack.pop() match {
			case Some(j:JsonObject) =>
				try{
					undoStack.push(model.updateJsonPSGraph())
					model.loadJsonGraph(j)
					modelReload()
				} catch {
					case e:PSGraphModelException => TinkerDialog.openErrorDialog(e.msg)
					case e:JsonAccessException => TinkerDialog.openErrorDialog(e.getMessage)
				}
			case None => publish(DocumentChangedEvent(unsavedChanges))
		}
	}

	/** Method to notifies the controller of changes in the model.
		* Hence it should register the previous model in the undo stack.
		*
		* Note that this method should be called before making any changes.
		*/
	def registerChanges() {
		if(undoStack.getTop.toString != model.updateJsonPSGraph().toString() && (if(!model.isMain) model.getSizeGT(model.getCurrentGTName) > model.currentIndex else true)){
			if(Service.evalCtrl.inEval) {
				Service.evalCtrl.enableEvalOptions(ArrayBuffer("PUSH"))
				QuantoLibAPI.printEvaluationFlag(true)
			}
			undoStack.push(model.jsonPSGraph)
			redoStack.empty()
			unsavedChanges = true
			publish(DocumentChangedEvent(unsavedChanges))
		}
	}

	/** Method to get the document title.
		*
		* Gets it from DocumentService and appends a * if there are unsaved changes.
		* @return Document title
		*/
	def title = DocumentService.title + (if (unsavedChanges) "*" else "")

	/** Method to open a Json object and set it as the model.
		*
		* @param file Optional file from which to get the json. Default value is none and will trigger a chooser dialog.
		*/
	def openJson(file:Option[String]=None) {
		val tmpModel = model
		tmpModel.removeGoals
		if(DocumentService.promptUnsaved(tmpModel.updateJsonPSGraph())){
			val json = file match {
				case Some(f:String) => DocumentService.load(new File(f))
				case None => DocumentService.showOpenDialog(None)
			}
			json match {
				case Some(j:JsonObject) =>
					openJson(j)
				case _ => TinkerDialog.openErrorDialog("Error while loading json from file : not a json object.")
			}
		}
	}

	/** Method to open a Json object and set it as the model.
		*
		* @param j Json to open.
		*/
	def openJson(j:JsonObject) {
		if(j.nonEmpty){
			try{
				model.loadJsonGraph(j)
				resetDoc()
			} catch {
				case e:PSGraphModelException => TinkerDialog.openErrorDialog(e.msg)
				case e:JsonAccessException => TinkerDialog.openErrorDialog(e.getMessage)
			}
		} else {
			TinkerDialog.openErrorDialog("Error while loading json from file : object is empty.")
		}
	}

	/** Method to save the model in a file.
		*
		*/
	def saveJson() {
		val tmpModel = model
		tmpModel.removeGoals()
		DocumentService.file match {
			case Some(_) => DocumentService.save(None, tmpModel.updateJsonPSGraph())
			case None => DocumentService.saveAs(None, tmpModel.updateJsonPSGraph())
		}
		//publish(DocumentChangedEvent(unsavedChanges))
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to save the model in a new file.
		*
		*/
	def saveAsJson() {
		val tmpModel = model
		tmpModel.removeGoals()
		DocumentService.saveAs(None, tmpModel.updateJsonPSGraph())
		//publish(DocumentChangedEvent(unsavedChanges))
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to close the document, i.e. making sure everything is saved before exiting the application.
		*
		* @return Boolean to know if everything was correctly saved.
		*/
	def closeDoc():Boolean = {
		val tmpModel = model
		tmpModel.removeGoals()
		DocumentService.promptUnsaved(tmpModel.updateJsonPSGraph())
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to open a new empty model.
		*
		* Opens a dialog to get the proof name.
		*/
	def newDoc() {
		val tmpModel = model
		tmpModel.removeGoals()
		if(DocumentService.promptUnsaved(tmpModel.updateJsonPSGraph())){
			def success(values:Map[String,String]) {
				try{
					model.reset(values("Proof name"))
					DocumentService.file = None
					resetDoc()
				} catch {
					case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				}
			}
			def failure() {}
			TinkerDialog.openEditDialog("New proof", Map("Proof name"->""),success,failure)
		}
	}

	/** Method opening a new empty model, with given proof name.
		*
		* Deprecated, since it was only used by the init app dialog [[tinkerGUI.views.MainGUI]], which not used anymore.
		*
		* @param name Proof name to give to the new model.
		*/
	def newDoc(name:String): Unit ={
		val tmpModel = model
		tmpModel.removeGoals()
		if(DocumentService.promptUnsaved(tmpModel.updateJsonPSGraph())) {
			try{
				model.reset(name)
				DocumentService.file = None
				resetDoc()
			} catch {
				case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			}
		}
	}

	/** Method restoring the document state when using a new proof.
		* Also calls [[modelReload]]
		*
		* @param unsaved Value of [[unsavedChanges]] after reset, default if false.
		*/
	def resetDoc(unsaved:Boolean=false) {
		unsavedChanges = unsaved
		undoStack.empty()
		redoStack.empty()
		DocumentService.proofTitle = model.mainTactic.name
		modelReload()
	}

	/** Method calling every methods and events to restore the app when a new model has been loaded.
		*
		*/
	def modelReload(){
		QuantoLibAPI.loadFromJson(model.getCurrentJson)
		Service.graphNavCtrl.viewedGraphChanged(model.isMain,false)
		Service.editCtrl.updateEditors()
		publish(CurrentGraphChangedEvent(model.getCurrentGTName, Some(model.currentParents)))
		publish(DocumentChangedEvent(unsavedChanges))
		publish(GraphTacticListEvent())
	}

	listenTo(DocumentService)
	reactions += {
		case DocumentChangedEvent(b) => publish(DocumentChangedEvent(b))
	}
}
