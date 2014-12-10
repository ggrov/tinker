package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.PSGraph
import tinkerGUI.model.HierarchyModel
import tinkerGUI.model.TreeElement
import tinkerGUI.model.HasArguments
import quanto.util.json._
import tinkerGUI.utils.ArgumentParser
import scala.collection.mutable.ArrayBuffer
import scala.concurrent._
import ExecutionContext.Implicits.global
import scala.util.{Success, Failure}

object Service extends Publisher {
	// other services
	val c = CommunicationService // the communication needs to be "instantiates" to actually listen for connections
	// Models
	val hierarchyModel = new HierarchyModel()
	val model = new PSGraph()
	// controllers
	val mainCtrl = new MainGUIController()
	val graphEditCtrl = new GraphEditController()
	val eltEditCtrl = new ElementEditController()
	val menuCtrl = new MenuController()
	val editControlsCtrl = new EditControlsController()
	val evalControlsCtrl = new EvalControlsController()
	val graphBreadcrumsCtrl = new GraphBreadcrumsController()
	val subGraphEditCtrl = new SubGraphEditController()
	val graphNavCtrl = new GraphNavigationController()
	val hierTreeCtrl = new HierarchyTreeController()
	val libraryTreeCtrl = new TinkerLibraryController()

	// getter-setter of the main frame
	private var mainFrame: Component = new BorderPanel()
	def setMainFrame(c: Component) { mainFrame = c }
	def getMainFrame : Component = mainFrame 
	
	// getters on the psgraph model
	// the all json model
	def getJsonPSGraph = {model.updateJsonPSGraph; model.jsonPSGraph}
	// a specific subgraph
	def getSpecificJsonFromModel(tactic: String, index: Int) = model.getSpecificJson(tactic, index)
	// the size of a nested tactic
	def getSizeOfTactic(tactic: String) = model.getSizeOfTactic(tactic)
	// the isOr value of a nested tactic
	def isNestedOr(tactic: String) = model.isGraphTacticOr(tactic)
	// the index of the current graph
	def getCurrentIndex = model.currentIndex
	// the size of the current nested tactic
	def getCurrentSize = model.currentTactic.graphs.size
	// the current tactic name
	def getCurrent = if(model.isMain) "main" else model.currentTactic.name
	// the tactic value of an atomic tactic
	def getAtomicTacticValue(tactic: String): String = model.getAtomicTacticValue(tactic)
	// the goal types
	def getGoalTypes = model.goalTypes

	// getters on the hierarchy controller
	// the root node element of the hierarchy tree
	def getHierarchyRoot = hierarchyModel.root
	// the active element
	def getHierarchyActive = hierarchyModel.activeElement
	// the parent list of a specific element
	def getParentList(tactic: String) = hierarchyModel.buildParentList(tactic, Array[String]())


	def createNode(n: String, isGraphTactic: Boolean, isOr: Boolean): String = {
		DocumentService.setUnsavedChanges(true)
		var name = model.generateNewName(n, 0)
		if(isGraphTactic) {
			model.createGraphTactic(name, isOr)
			hierarchyModel.addElement(name)
			hierTreeCtrl.redraw
			name = name+"("+ArgumentParser.argumentsToString(model.getTacticArguments(name))+")"
		}
		else{
			model.createAtomicTactic(name)
			name = name+"("+ArgumentParser.argumentsToString(model.getTacticArguments(name))+")"
		}
		name
	}

	def updateTacticName(oldVal: String, newVal: String, isGraphTactic: Boolean): String = {
		DocumentService.setUnsavedChanges(true)
		val actualNewVal = model.updateTacticName(oldVal, newVal)
		if(isGraphTactic) {
			hierarchyModel.updateElementName(oldVal, actualNewVal)
			hierTreeCtrl.redraw
		}
		actualNewVal
	}

	def deleteTactic(tactic: String){
		DocumentService.setUnsavedChanges(true)
		model.deleteTactic(tactic)
		hierarchyModel.lookForElement(tactic) match {
			case Some(e: TreeElement) => 
				e.children.foreach { c =>
					deleteTactic(c.name)
				}
				hierarchyModel.elementArray -= e
				hierTreeCtrl.redraw
			case None =>
		}
	}

	def parseAndUpdateArguments(tactic: String, s: String): String = {
		DocumentService.setUnsavedChanges(true)
		val args = ArgumentParser.stringToArguments(s)
		model.updateTacticArguments(tactic, args)
		return ArgumentParser.argumentsToString(args)
		// the reason we return this string is to update the graph and textfield (where the arguments where first input)
		// with a unique format, so the program won't struggle with later with spaces missing or anthing
		// (main problem comes from importing file from library, were we assume the name in the library file are correctly formatted)
	}

	def updateArguments(tactic: String, args: Array[Array[String]]){
		DocumentService.setUnsavedChanges(true)
		model.updateTacticArguments(tactic, args)
	}

	def changeTacticParent(tactic: String, parent: String) = hierarchyModel.changeParent(tactic, parent)

	def addSubgraph(tactic: String){
		DocumentService.setUnsavedChanges(true)
		model.newSubGraph(tactic)
		hierarchyModel.changeActive(tactic)
		hierTreeCtrl.redraw
		QuantoLibAPI.newGraph()
		graphNavCtrl.viewedGraphChanged(model.isMain, true)
		graphBreadcrumsCtrl.addCrum(tactic)
		publish(NothingSelectedEvent())
	}

	def deleteSubGraph(tactic: String, index: Int){
		DocumentService.setUnsavedChanges(true)
		model.delSubGraph(tactic, index)
	}

	def editSubGraph(tactic: String, index: Int): Boolean = {
		if(model.changeCurrent(tactic, index)){
			DocumentService.setUnsavedChanges(true)
			publish(NothingSelectedEvent())
			getSpecificJsonFromModel(tactic, index) match {
				case Some(j: JsonObject) =>
					QuantoLibAPI.loadFromJson(j)
					graphNavCtrl.viewedGraphChanged(model.isMain, false)
					graphBreadcrumsCtrl.addCrum(tactic)
					hierarchyModel.changeActive(tactic)
					hierTreeCtrl.redraw
					return true
				case None =>
					addSubgraph(tactic)
					return true
			}
		}
		else{
			DocumentService.setUnsavedChanges(true)
			addSubgraph(tactic)
			return true
		}
		return false
	}

	def setIsOr(tactic: String, isOr: Boolean) = {
		DocumentService.setUnsavedChanges(true)
		model.graphTacticSetIsOr(tactic, isOr)
	}

	def saveGraphSpecificTactic(tactic: String, graph: Json) = {
		DocumentService.setUnsavedChanges(true)
		model.saveGraphSpecificTactic(tactic, graph)
	}

	def setAtomicTacticValue(tactic: String, value: String) = {
		DocumentService.setUnsavedChanges(true)
		model.setAtomicTacticValue(tactic, value)
	}

	def setGoalTypes(s: String){
		DocumentService.setUnsavedChanges(true)
		model.goalTypes = s
	}

	def refreshGraph {
		model.getCurrentJson match {
			case Some(j: JsonObject) =>
				QuantoLibAPI.loadFromJson(j)
				// graphBreadcrumsCtrl.addCrum(getCurrent)
				hierarchyModel.changeActive(getCurrent)
				hierTreeCtrl.redraw
			case None => TinkerDialog.openErrorDialog("<html>Program tried to refresh current graph,<br>but json model could not be found.</html>")
		}
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphEventAPI(graph) =>
			DocumentService.setUnsavedChanges(true)
			model.saveCurrentGraph(graph)
			graphNavCtrl.disableAdd = false
	}
	
	def changeGraphEditMouseState(state: String){
		graphEditCtrl.changeMouseState(state)
	}

	def displayEvalGraph(tactic:String, index:Int, j:JsonObject){
		model.changeCurrent(tactic, index)
		DocumentService.setUnsavedChanges(true)
		publish(NothingSelectedEvent())
		QuantoLibAPI.loadFromJson(j)
		graphNavCtrl.viewedGraphChanged(model.isMain, false)
		graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
		graphBreadcrumsCtrl.addCrum(getCurrent)
		hierarchyModel.changeActive(getCurrent)
		hierTreeCtrl.redraw
	}

	def loadJson(j:Json) {
		if(!j.isEmpty){
			model.loadJsonGraph(j)
			hierarchyModel.rebuildHierarchy(model)
			graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
			graphBreadcrumsCtrl.addCrum(getCurrent)
			graphNavCtrl.viewedGraphChanged(model.isMain, false)
			refreshGraph
		}
		else{
			TinkerDialog.openErrorDialog("<html>Error while loading json from file : object is empty.</html>")
		}
	}

	def enableEvalOptions(v:ArrayBuffer[String]){
		evalControlsCtrl.enableOptions(v)
	}

	def userEvalChoice:String = {
		// asynchronous call here
		// either get selected in evalController until different from "" --> not pretty
		// or make asynchronous listener to event where user selects option
	}

	// function to change document service

	def loadJsonFromFile() {
		DocumentService.showOpenDialog(None) match {
			case Some(j: Json) =>
				if(!j.isEmpty){
					model.loadJsonGraph(j)
					hierarchyModel.rebuildHierarchy(model)
					graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
					graphBreadcrumsCtrl.addCrum(getCurrent)
					graphNavCtrl.viewedGraphChanged(model.isMain, false)
					refreshGraph
				}
				else{
					TinkerDialog.openErrorDialog("<html>Error while loading json from file : object is empty.</html>")
				}
			case None =>
		}
	}

	def saveJsonToFile() {
		model.updateJsonPSGraph;
		DocumentService.file match {
			case Some(_) => DocumentService.save(None, model.jsonPSGraph)
			case None => DocumentService.saveAs(None, model.jsonPSGraph)
		}
	}

	def saveJsonAs(){
		model.updateJsonPSGraph
		DocumentService.saveAs(None, model.jsonPSGraph)
	}

	def closeDoc : Boolean = {
		model.updateJsonPSGraph
		DocumentService.promptUnsaved(model.jsonPSGraph)
	}

	def newDoc {
		model.updateJsonPSGraph
		if(DocumentService.promptUnsaved(model.jsonPSGraph)){
			model.loadJsonGraph(JsonObject("current" -> "main", "current_index" -> 0, "graph" -> JsonObject(), "graph_tactics" -> JsonArray(Array[JsonObject]()), "atomic_tactics" -> JsonArray(Array[JsonObject]()), "goal_types" -> ""))
			hierarchyModel.rebuildHierarchy(model)
			graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
			graphBreadcrumsCtrl.addCrum(getCurrent)
			graphNavCtrl.viewedGraphChanged(model.isMain, false)
			refreshGraph
		}
	}
}