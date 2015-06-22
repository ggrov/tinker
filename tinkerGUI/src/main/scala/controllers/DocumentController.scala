package tinkerGUI.controllers

import quanto.util.json.Json
import tinkerGUI.controllers.events.{GraphTacticListEvent, CurrentGraphChangedEvent, DocumentChangedEvent}
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{AtomicTacticNotFoundException, GraphTacticNotFoundException, SubgraphNotFoundException}
import tinkerGUI.utils.{TinkerDialog, FixedStack}

import scala.swing.Publisher

/** Controller managing read and write on a file, as well as the undo stack.
	*
	* @param model PSgraph model.
	*/
class DocumentController(model:PSGraph) extends Publisher {

	/** Stack keeping track of PSGraph json object, in case we want to redo things.*/
	val redoStack:FixedStack[Json] = new FixedStack[Json](20)

	/** Stack keeping track of PSGraph json object, in case we want to undo things.*/
	val undoStack:FixedStack[Json] = new FixedStack[Json](20)

	/** Boolean to know if there are any unsaved changes.*/
	var unsavedChanges:Boolean = false

	/** Method to undo changes.
		*
		*/
	def undo() {
		undoStack.pop() match {
			case Some(j:Json) =>
				try{
					model.updateJsonPSGraph()
					redoStack.push(model.jsonPSGraph)
					model.loadJsonGraph(j)
					QuantoLibAPI.loadFromJson(model.getCurrentJson)
					publish(CurrentGraphChangedEvent(if(model.isMain) "main" else model.currentTactic.name, None))
					publish(DocumentChangedEvent(unsavedChanges))
				} catch {
					case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
					case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
					case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				}
			case None => // do nothing
		}
	}

	/** Method to redo changes.
		*
		*/
	def redo() {
		redoStack.pop() match {
			case Some(j:Json) =>
				try{
					undoStack.push(j)
					model.loadJsonGraph(j)
					QuantoLibAPI.loadFromJson(model.getCurrentJson)
					publish(CurrentGraphChangedEvent(model.getCurrentGTName, None))
					publish(DocumentChangedEvent(unsavedChanges))
				} catch {
					case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
					case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
					case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				}
			case None => // do nothing
		}
	}

	/** Method to notifies the controller of changes in the model.
		* Hence it should register the previous model in the undo stack.
		*
		* Note that this method should be called before making any changes.
		*/
	def registerChanges() {
		model.updateJsonPSGraph()
		if(undoStack.getTop().toString != model.jsonPSGraph.toString()){
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
		model.updateJsonPSGraph()
		DocumentService.showOpenDialog(None) match {
			case Some(j:Json) =>
				if(!j.isEmpty){
					try{
						model.loadJsonGraph(j)
						undoStack.empty()
						redoStack.empty()
						publish(GraphTacticListEvent())
						publish(CurrentGraphChangedEvent(model.getCurrentGTName,Some(Service.hierarchyCtrl.elementParents(model.getCurrentGTName))))
						QuantoLibAPI.loadFromJson(model.getCurrentJson)
						Service.graphNavCtrl.viewedGraphChanged(model.isMain, false)
						unsavedChanges = false
						publish(DocumentChangedEvent(unsavedChanges))
					} catch {
						case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
					}
				} else {
					TinkerDialog.openErrorDialog("<html>Error while loading json from file : object is empty.</html>")
				}
			case None => // do nothing
		}
	}

	/** Method to save the model in a file.
		*
		*/
	def saveJson() {
		model.updateJsonPSGraph()
		DocumentService.file match {
			case Some(_) => DocumentService.save(None, model.jsonPSGraph)
			case None => DocumentService.saveAs(None, model.jsonPSGraph)
		}
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to save the model in a new file.
		*
		*/
	def saveAsJson() {
		model.updateJsonPSGraph()
		DocumentService.saveAs(None, model.jsonPSGraph)
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to save the model in a new file.
		*
		* @return Boolean to know if everything was correctly saved.
		*/
	def closeDoc():Boolean = {
		model.updateJsonPSGraph()
		DocumentService.promptUnsaved(model.jsonPSGraph)
		// we leave the setting of unsavedChanges and the event in document service as errors might happen
	}

	/** Method to open a new empty model.
		*
		*/
	def newDoc() {
		model.updateJsonPSGraph()
		if(DocumentService.promptUnsaved(model.jsonPSGraph)){
			try{
				model.reset()
				Service.graphNavCtrl.viewedGraphChanged(model.isMain, false)
				unsavedChanges = false
				undoStack.empty()
				redoStack.empty()
				QuantoLibAPI.loadFromJson(model.getCurrentJson)
				publish(GraphTacticListEvent())
				publish(CurrentGraphChangedEvent(model.getCurrentGTName, Some(Array())))
			} catch {
				case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			}
		}
	}
}
