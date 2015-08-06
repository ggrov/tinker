package tinkerGUI.controllers

import quanto.util.json.{JsonObject, JsonAccessException, Json}
import tinkerGUI.controllers.events.{GraphTacticListEvent, CurrentGraphChangedEvent, DocumentChangedEvent}
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{PSGraphModelException, AtomicTacticNotFoundException, GraphTacticNotFoundException, SubgraphNotFoundException}
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

	/** Method to undo changes.
		*
		*/
	def undo() {
		undoStack.pop() match {
			case Some(j:JsonObject) =>
				try{
					model.updateJsonPSGraph()
					redoStack.push(model.jsonPSGraph)
					model.loadJsonGraph(j)
					QuantoLibAPI.loadFromJson(model.getCurrentJson)
					Service.graphNavCtrl.viewedGraphChanged(model.isMain,false)
					Service.editCtrl.updateEditors
					publish(CurrentGraphChangedEvent(model.getCurrentGTName, Some(model.currentParents)))
					publish(DocumentChangedEvent(unsavedChanges))
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
					model.updateJsonPSGraph()
					undoStack.push(model.jsonPSGraph)
					model.loadJsonGraph(j)
					QuantoLibAPI.loadFromJson(model.getCurrentJson)
					Service.graphNavCtrl.viewedGraphChanged(model.isMain,false)
					Service.editCtrl.updateEditors
					publish(CurrentGraphChangedEvent(model.getCurrentGTName, Some(model.currentParents)))
					publish(DocumentChangedEvent(unsavedChanges))
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
		model.updateJsonPSGraph()
		if(Service.evalCtrl.inEval) {
			Service.evalCtrl.enableEvalOptions(ArrayBuffer("PUSH"))
			QuantoLibAPI.printEvaluationFlag(true)
		}
		if(undoStack.getTop.toString != model.jsonPSGraph.toString() && (if(!model.isMain) model.getSizeGT(model.getCurrentGTName) > model.currentIndex else true)){
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
		*/
	def openJson() {
		val tmpModel = model
		tmpModel.removeGoals
		tmpModel.updateJsonPSGraph()
		if(DocumentService.promptUnsaved(tmpModel.jsonPSGraph)){
			DocumentService.showOpenDialog(None) match {
				case Some(j:JsonObject) =>
					openJson(j)
				case _ => TinkerDialog.openErrorDialog("<html>Error while loading json from file : not a json object.</html>")
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
				resetApp()
			} catch {
				case e:PSGraphModelException => TinkerDialog.openErrorDialog(e.msg)
				case e:JsonAccessException => TinkerDialog.openErrorDialog(e.getMessage)
			}
		} else {
			TinkerDialog.openErrorDialog("<html>Error while loading json from file : object is empty.</html>")
		}
	}

	/** Method to save the model in a file.
		*
		*/
	def saveJson() {
		//model.updateJsonPSGraph()
		val tmpModel = model
		tmpModel.removeGoals
		tmpModel.updateJsonPSGraph()
		DocumentService.file match {
			case Some(_) => DocumentService.save(None, tmpModel.jsonPSGraph)
			case None => DocumentService.saveAs(None, tmpModel.jsonPSGraph)
		}
		publish(DocumentChangedEvent(unsavedChanges))
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to save the model in a new file.
		*
		*/
	def saveAsJson() {
		val tmpModel = model
		tmpModel.removeGoals
		tmpModel.updateJsonPSGraph()
		DocumentService.saveAs(None, tmpModel.jsonPSGraph)
		publish(DocumentChangedEvent(unsavedChanges))
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to save the model in a new file.
		*
		* @return Boolean to know if everything was correctly saved.
		*/
	def closeDoc():Boolean = {
		val tmpModel = model
		tmpModel.removeGoals
		tmpModel.updateJsonPSGraph()
		DocumentService.promptUnsaved(tmpModel.jsonPSGraph)
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to open a new empty model.
		*
		*/
	def newDoc() {
		val tmpModel = model
		tmpModel.removeGoals
		tmpModel.updateJsonPSGraph()
		if(DocumentService.promptUnsaved(tmpModel.jsonPSGraph)){
			def success(values:Map[String,String]) {
				try{
					model.reset(values("Proof name"))
					resetApp()
					DocumentService.file = None
					DocumentService.proofTitle = values("Proof name")
				} catch {
					case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				}
			}
			def failure() {}
			TinkerDialog.openEditDialog("New proof", Map("Proof name"->""),success,failure)
		}
	}

	def newDoc(name:String): Unit ={
		val tmpModel = model
		tmpModel.removeGoals
		tmpModel.updateJsonPSGraph()
		if(DocumentService.promptUnsaved(tmpModel.jsonPSGraph)) {
			try{
				model.reset(name)
				resetApp()
				DocumentService.file = None
			} catch {
				case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			}
		}
	}

	/** Method restoring the application state when using a new proof.
		*
		*/
	def resetApp() {
		Service.graphNavCtrl.viewedGraphChanged(model.isMain, false)
		Service.libraryTreeCtrl.modelCreated = true
		unsavedChanges = false
		undoStack.empty()
		redoStack.empty()
		DocumentService.proofTitle = model.mainTactic.name
		QuantoLibAPI.loadFromJson(model.getCurrentJson)
		publish(GraphTacticListEvent())
		publish(CurrentGraphChangedEvent(model.getCurrentGTName, Some(model.currentParents)))
		publish(DocumentChangedEvent(unsavedChanges))
		Service.editCtrl.updateEditors
	}
}
