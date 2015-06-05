package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.{AtomicTacticNotFoundException, PSGraph, HierarchyModel, TreeElement}
import quanto.util.json._
import tinkerGUI.utils.ArgumentParser
import scala.collection.mutable.ArrayBuffer

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

  private var topFrame: MainFrame = null
  def setTopFrame(c: MainFrame) { topFrame = c }
  def getTopFrame : MainFrame = topFrame

	// getters on the psgraph model
	// the all json model
	def getJsonPSGraph = {
		model.updateJsonPSGraph()
		model.jsonPSGraph
	}
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
	def getAtomicTacticValue(tactic: String): String = "this should not be used" // TODO remove this method
	// the goal types
	def getGoalTypes = model.goalTypes

	// getters on the hierarchy controller
	// the root node element of the hierarchy tree
	def getHierarchyRoot = hierarchyModel.root
	// the active element
	def getHierarchyActive = hierarchyModel.activeElement
	// the parent list of a specific element
	def getParentList(tactic: String) = hierarchyModel.buildParentList(tactic, Array[String]())

	/** Method to get the core id of an atomic tactic
		*
		* @param name Atomic tactic name
		* @throws tinkerGUI.model.AtomicTacticNotFoundException If the atomic tactic is not in the collection.
		* @return Core id of the atomic tactic
		*/
	@throws (classOf[AtomicTacticNotFoundException])
	def getATCoreId(name:String):String = {
		try{
			model.getATCoreId(name)
		} catch {
			case e:AtomicTacticNotFoundException => throw e
		}
	}

	/**
	  * Method to create a tactic in the model,
	  * if the tactic is already existing, it links the graphical node to it
	  * Launched after user created a node (atomic or nested) on the graph
	  * Launches dialogs to interact with user to get more information on tactic
	  */
	def createTactic(nodeId:String, isAtomicTactic:Boolean, fieldMap:Map[String,String]) {
		// TODO REMOVE COMMENTS TO SUPPORT GRAPH TACTICS
		var dialog:Dialog = new Dialog()
		var name:String = ""
		var args:Array[Array[String]] = Array()
		var tactic:String = ""
		var checkedByModel:Boolean = false
		def failureCallback() = {
			QuantoLibAPI.userDeleteElement(nodeId)
		}
		def successCallback(values:Map[String,String]){
			values.foreach{case (k,v) =>
				k match {
					case "Name" => 
						name = ArgumentParser.separateNameFromArgument(v)._1
						args = ArgumentParser.stringToArguments(ArgumentParser.separateNameFromArgument(v)._2)
					case "Tactic" =>
						tactic = v
					case _ => // do nothing
				}
			}
			if(name=="" || (isAtomicTactic && tactic=="")){
				TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
			} else {
				checkedByModel = if(isAtomicTactic) model.createAT(name,tactic,args) else false /*model.createGraphTactic(name,false,args)*/
				if(checkedByModel){
					if(isAtomicTactic) model.addATOccurrence(name,nodeId) /*else model.addGTOccurrence(name,nodeId)*/
					QuantoLibAPI.setVertexValue(nodeId, name+"("+ArgumentParser.argumentsToString(args)+")")
				} else {
					var confirmDialog = new Dialog()
					val message:String = "<html>The name "+name+" is already used by another atomic tactic <br> do you wish to use the same tactic informations or create a new tactic ?"
					val newAction:Action = new Action("Create new tactic"){
						def apply(){
							dialog = TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
							confirmDialog.close()
						}
					}
					val duplicateAction:Action = new Action("Use same information"){
						def apply(){
							if(isAtomicTactic) model.addATOccurrence(name,nodeId) /*else model.addGTOccurrence(name,nodeId)*/
							val fullName = if(isAtomicTactic) model.getATFullName(name) else "toto"/*model.getGTFullName(name)*/
							QuantoLibAPI.setVertexValue(nodeId, fullName)
							confirmDialog.close()
						}
					}
					confirmDialog = TinkerDialog.openConfirmationDialog(message, Array(newAction,duplicateAction))
				}
			}
		}
		dialog = TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
	}

	/**
	  * Method to create a tactic.
	  * Invokes the other create method after creating an empty fieldmap
	  */
	def createTactic(nodeId:String, isAtomicTactic:Boolean) {
		var fieldMap = Map("Name"->"")
		if(isAtomicTactic){
			fieldMap += ("Tactic"->"")
		}
		createTactic(nodeId, isAtomicTactic, fieldMap)
	}

	/**
	  * Method to update a tactic's details
	  * Launched after the user selected the edit option
	  * Launches dialogs to interact with user to get more information on tactic
	  */
	def updateTactic(nodeId:String, nodeName:String, isAtomicTactic:Boolean){
		// TODO REMOVE COMMENTS TO SUPPORT GRAPH TACTICS
		var dialog:Dialog = new Dialog()
		var name:String = ""
		var args:Array[Array[String]] = Array()
		var tactic:String = ""
		var isUnique:Boolean = false
		val tacticOldName = ArgumentParser.separateNameFromArgument(nodeName)._1
		var fieldMap = Map("Name"->nodeName)
		if(isAtomicTactic){
			fieldMap += ("Tactic"->model.getATCoreId(tacticOldName))
		}
		def failureCallback() = {
			// Nothing
		}
		def successCallback(values:Map[String,String]){
			values.foreach{case (k,v) =>
				k match {
					case "Name" => 
						name = ArgumentParser.separateNameFromArgument(v)._1
						args = ArgumentParser.stringToArguments(ArgumentParser.separateNameFromArgument(v)._2)
					case "Tactic" =>
						tactic = v
					case _ => // do nothing
				}
			}
			if(name=="" || (isAtomicTactic && tactic=="")){
				// TODO : handle empty field
				// TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
			} else {
				try{
					isUnique =
					if(isAtomicTactic) {
						 model.updateAT(tacticOldName, name,tactic,args)
					}
					else false /*model.updateGT(tacticOldName, name,false,args)*/
					if(isUnique){
						QuantoLibAPI.setVertexValue(nodeId, name+"("+ArgumentParser.argumentsToString(args)+")")
					} else {
						var confirmDialog = new Dialog()
						val message:String = "<html>The tactic "+name+" has many occurrences <br> do you wish to edit all of them or make a new tactic ?"
						val newAction:Action = new Action("Make new tactic"){
							def apply(){
								createTactic(nodeId,isAtomicTactic,values)
								if(isAtomicTactic) model.removeATOccurrence(tacticOldName, nodeId) /* else model.removeGTOccurrence(tacticOldName, nodeId) */
								confirmDialog.close()
							}
						}
						val editAllAction:Action = new Action("Edit all"){
							def apply(){
								var nodeToChange:Array[String] = Array()
								if(isAtomicTactic) nodeToChange = model.updateForceAT(tacticOldName, name,tactic,args)
								/*else nodeToChange = model.updateAllGraphTactic(tacticOldName, name,isOr,args)*/
								val fullName = if(isAtomicTactic) model.getATFullName(name) else "toto"/*model.getGTFullName(name)*/
								nodeToChange.foreach{ n =>
									QuantoLibAPI.setVertexValue(n, fullName)
								}
								confirmDialog.close()
							}
						}
						confirmDialog = TinkerDialog.openConfirmationDialog(message, Array(newAction,editAllAction))
					}
				} catch {
					case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				}
			}
		}
		dialog = TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
	}

	/** Method to delete a tactic
		*
		* @param nodeName
		* @param isAtomicTactic
		*/
	def deleteTactic(nodeName:String, nodeId:String, isAtomicTactic:Boolean) {
		// TODO GT deletion
		try {
			val tacticName = ArgumentParser.separateNameFromArgument(nodeName)._1
			val lastOcc:Boolean = if(isAtomicTactic) model.removeATOccurrence(tacticName, nodeId) else false /*model.removeGTOccurrence(name,nodeId) */
			if(lastOcc){
				var confirmDialog = new Dialog()
				val message:String = "This is the last occurrence of this tactic. Do you wish to keep its data ?"
				val keepAction:Action = new Action("Keep data") {
					def apply() {
						// do nothing
						confirmDialog.close()
					}
				}
				val delAction:Action = new Action("Delete data") {
					def apply() {
						if(isAtomicTactic) model.deleteAT(tacticName)
						//else model.deleteGT(name)
						confirmDialog.close()
					}
				}
				confirmDialog = TinkerDialog.openConfirmationDialog(message,Array(keepAction,delAction))
			}
		} catch {
			case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
		}
	}

	def createNode(n: String, isGraphTactic: Boolean, isOr: Boolean): String = {
		println("using old method")
		DocumentService.setUnsavedChanges(true)
		var name = model.generateNewName(n, 0)
		if(isGraphTactic) {
			model.createGraphTactic(name, isOr, Array())
			hierarchyModel.addElement(name)
			hierTreeCtrl.redraw
			name = name+"("+ArgumentParser.argumentsToString(model.getTacticArguments(name))+")"
		}
		else{
			model.createAT(name, name, Array())
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
		ArgumentParser.argumentsToString(args)
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
		// TODO remove this method
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

	listenTo(evalControlsCtrl)
	reactions+={
		case EvalOptionSelectedEvent(opt, node) =>
			publish(UserSelectedEvalOptionEvent(opt, node))
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

  def showTinkerGUI (b : Boolean) {
    getTopFrame.visible_=(b)
  }





  def debugPrintJson(){
		model.updateJsonPSGraph()
  	println(model.jsonPSGraph)
  }
}