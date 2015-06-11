package tinkerGUI.controllers

import tinkerGUI.model.exceptions.{SubgraphNotFoundException, GraphTacticNotFoundException, AtomicTacticNotFoundException}

import scala.swing._
import tinkerGUI.model.PSGraph
import quanto.util.json._
import tinkerGUI.utils.{TinkerDialog, ArgumentParser}
import scala.collection.mutable.ArrayBuffer

object Service extends Publisher {
	// other services
	val c = CommunicationService // the communication needs to be "instantiates" to actually listen for connections
	// Models
	//val hierarchyModel = new HierarchyModel()

	// controllers
	// TODO get rid of unecessary controllers
	val mainCtrl = new MainGUIController()
	val graphEditCtrl = new GraphEditController()
	val eltEditCtrl = new ElementEditController()
	val menuCtrl = new MenuController()
	val editControlsCtrl = new EditControlsController()
	val evalControlsCtrl = new EvalControlsController()
	val graphBreadcrumsCtrl = new GraphBreadcrumbsController()
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

	/** Psgrah model. */
	val model = new PSGraph()
	// getters on the psgraph model
	/** Method updating a getting the psgraph json object. See[[tinkerGUI.model.PSGraph.jsonPSGraph]].*/
	def getJsonPSGraph:JsonObject = {
		model.updateJsonPSGraph()
		model.jsonPSGraph
	}
	/** Method to get the current graph index. See [[tinkerGUI.model.PSGraph.currentIndex]].*/
	def getCurrentIndex = model.currentIndex
	/** Method to get the current graph tactic size. See [[tinkerGUI.model.PSGraph.currentTactic]]. */
	def getCurrentSize = model.currentTactic.graphs.size
	/** Method to get the current graph name (ee [[tinkerGUI.model.PSGraph.currentTactic]]), or "main" if current graph is main (see [[tinkerGUI.model.PSGraph.isMain]]).*/
	def getCurrent = if(model.isMain) "main" else model.currentTactic.name
	/** Method to get the goal types of the psgraph. See [[tinkerGUI.model.PSGraph.goalTypes]].*/
	def getGoalTypes = model.goalTypes
	/** Method to get the core id of an atomic tactic. See [[tinkerGUI.model.PSGraph.getATCoreId]].*/
	def getATCoreId(name:String) = model.getATCoreId(name)
	/** Method to get the a specific subgraph json object. See [[tinkerGUI.model.PSGraph.getSubgraphGT]].*/
	def getSubgraphGT(tactic: String, index: Int) = model.getSubgraphGT(tactic, index)
	/** Method to get the size of a specific graph tactic. See [[tinkerGUI.model.PSGraph.getSizeGT]].*/
	def getSizeGT(tactic: String) = model.getSizeGT(tactic)
	/** Method to get the branch type of a specific graph tactic. See [[tinkerGUI.model.PSGraph.getGTBranchType]].*/
	def getBranchTypeGT(tactic: String) = model.getGTBranchType(tactic)
	/** Method to get the children of a graph tactic or the main graph children. See [[tinkerGUI.model.GraphTactic.children]] and [[tinkerGUI.model.PSGraph.childrenMain]].*/
	def getGTChildren(tactic:String) = if(tactic=="main") model.childrenMain else model.getChildrenGT(tactic)

	// getters on the hierarchy controller
	// the root node element of the hierarchy tree
	//def getHierarchyRoot = hierarchyModel.root
	// the active element
	//def getHierarchyActive = hierarchyModel.activeElement
	// the parent list of a specific element
	//def getParentList(tactic: String) = hierarchyModel.buildParentList(tactic, Array[String]())


	/** Method to create a tactic in the model.
	  *
	  * If the tactic is already existing, it links the graphical node to it.
	  * Launched after user created a node (atomic or nested) on the graph.
	  * Launches dialogs to interact with user to get more information on tactic.
		*
		* @param nodeId Id of the node the user is creating.
		* @param isAtomicTactic Boolean stating the nature of the node, atomic of nested.
		* @param fieldMap Map of the value to specify for the creation of a tactic.
	  */
	def createTactic(nodeId:String, isAtomicTactic:Boolean, fieldMap:Map[String,String]) {
		var dialog:Dialog = new Dialog()
		var name:String = ""
		var args:String = ""
		var tactic:String = ""
		var branchType:String = ""
		var checkedByModel:Boolean = false
		def failureCallback() = {
			QuantoLibAPI.userDeleteElement(nodeId)
		}
		def successCallback(values:Map[String,String]){
			values.foreach{case (k,v) =>
				k match {
					case "Name" => 
						name = ArgumentParser.separateNameFromArgument(v)._1
						args = ArgumentParser.separateNameFromArgument(v)._2
					case "Tactic" =>
						tactic = v
					case "Branch type" =>
						branchType = v
					case _ => // do nothing
				}
			}
			if(name=="" || (isAtomicTactic && tactic=="")){
				TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
			} else {
				try{
					DocumentService.setUnsavedChanges(true)
					checkedByModel = if(isAtomicTactic) model.createAT(name,tactic,args) else model.createGT(name,branchType,args)
					if(checkedByModel){
						if(isAtomicTactic) model.addATOccurrence(name,nodeId) else {model.addGTOccurrence(name,nodeId); hierTreeCtrl.redraw()}
						QuantoLibAPI.setVertexValue(nodeId, name+"("+args+")")
					} else {
						var confirmDialog = new Dialog()
						val message:String = if(isAtomicTactic) "<html>The name "+name+" is already used by another atomic tactic <br> do you wish to use the same tactic informations or create a new tactic ?"
						else "<html>The name "+name+" is already used by another graph tactic <br> do you wish to use the same tactic informations or create a new tactic ?"
						val newAction:Action = new Action("Create new tactic"){
							def apply(){
								dialog = TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
								confirmDialog.close()
							}
						}
						val duplicateAction:Action = new Action("Use same informations"){
							def apply(){
								if(isAtomicTactic) model.addATOccurrence(name,nodeId) else {model.addGTOccurrence(name,nodeId); hierTreeCtrl.redraw()}
								val fullName = if(isAtomicTactic) model.getATFullName(name) else model.getGTFullName(name)
								QuantoLibAPI.setVertexValue(nodeId, fullName)
								confirmDialog.close()
							}
						}
						confirmDialog = TinkerDialog.openConfirmationDialog(message, Array(newAction,duplicateAction))
					}
				} catch {
					case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
					case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				}
			}
		}
		dialog = TinkerDialog.openEditDialog("Create node", fieldMap, successCallback, failureCallback)
	}

	/** Method to create a tactic.
	  *
	  * Invokes the other createTactic method after generating a default fieldmap.
		*
		* @param nodeId Id of the node the user is creating.
		* @param isAtomicTactic Boolean stating the nature of the node, atomic or nested.
	  */
	def createTactic(nodeId:String, isAtomicTactic:Boolean) {
		var fieldMap = Map("Name"->"")
		if(isAtomicTactic){
			fieldMap += ("Tactic"->"")
		} else {
			fieldMap += ("Branch type"->"OR")
		}
		createTactic(nodeId, isAtomicTactic, fieldMap)
	}

	/** Method to update a tactic's details.
	  *
	  * Launched after the user selected the edit option.
	  * Launches dialogs to interact with user to get more information on tactic.
	  */
	def updateTactic(nodeId:String, nodeName:String, isAtomicTactic:Boolean){
		var dialog:Dialog = new Dialog()
		var name:String = ""
		var args:String = ""
		var tactic:String = ""
		var branchType:String = ""
		var isUnique:Boolean = false
		var existingName:Boolean = false
		val tacticOldName = ArgumentParser.separateNameFromArgument(nodeName)._1
		var fieldMap = Map("Name"->nodeName)
		if(isAtomicTactic){
			fieldMap += ("Tactic"->model.getATCoreId(tacticOldName))
		} else {
			fieldMap += ("Branch type"->model.getGTBranchType(tacticOldName))
		}
		def failureCallback() = {
			// Nothing
		}
		def successCallback(values:Map[String,String]){
			values.foreach{case (k,v) =>
				k match {
					case "Name" => 
						name = ArgumentParser.separateNameFromArgument(v)._1
						args = ArgumentParser.separateNameFromArgument(v)._2
					case "Tactic" =>
						tactic = v
					case "Branch type" =>
						branchType = v
					case _ => // do nothing
				}
			}
			if(name=="" || (isAtomicTactic && tactic=="")){
				dialog = TinkerDialog.openEditDialog("Update node", fieldMap, successCallback, failureCallback)
			} else {
				try{
					DocumentService.setUnsavedChanges(true)
					if(isAtomicTactic) {
						existingName = model.atCollection contains name
						if(existingName && name!=tacticOldName){
							var confirmDialog = new Dialog()
							val message:String = "The atomic tactic "+name+" already exists, do you wish to link this node with it ?"
							val reuseInfo = new Action("Link node"){
								def apply() {
									// TODO : consider linking all occurrences
									deleteTactic(tacticOldName,nodeId,true)
									model.addATOccurrence(name,nodeId)
									QuantoLibAPI.setVertexValue(nodeId, model.getATFullName(name))
									confirmDialog.close()
								}
							}
							val redoUpdate = new Action("Choose another name"){
								def apply() {
									dialog = TinkerDialog.openEditDialog("Update node", fieldMap, successCallback, failureCallback)
									confirmDialog.close()
								}
							}
							confirmDialog = TinkerDialog.openConfirmationDialog(message,Array(reuseInfo,redoUpdate))
						} else {
							isUnique = model.updateAT(tacticOldName,name,tactic,args)
							if(isUnique){
								QuantoLibAPI.setVertexValue(nodeId, name+"("+args+")")
							} else {
								var confirmDialog = new Dialog()
								val message:String = "<html>The atomic tactic "+name+" has many occurrences. <br> Do you wish to edit all of them or make a new tactic ?</html>"
								val newAction:Action = new Action("Make new tactic"){
									def apply(){
										createTactic(nodeId,isAtomicTactic,values)
										model.removeATOccurrence(tacticOldName, nodeId)
										confirmDialog.close()
									}
								}
								val editAllAction:Action = new Action("Edit all"){
									def apply(){
										val nodesToChange:Array[String] = model.updateForceAT(tacticOldName, name,tactic,args)
										val fullName = model.getATFullName(name)
										nodesToChange.foreach{ n =>
											QuantoLibAPI.setVertexValue(n, fullName)
										}
										confirmDialog.close()
									}
								}
								confirmDialog = TinkerDialog.openConfirmationDialog(message, Array(newAction,editAllAction))
							}
						}
					} else {
						existingName = model.gtCollection contains name
						if(existingName && name!=tacticOldName){
							var confirmDialog = new Dialog()
							val message:String = "The graph tactic "+name+" already exists, do you wish to link this node with it ?"
							val reuseInfo = new Action("Link node"){
								def apply() {
									// TODO : consider linking all occurrences
									deleteTactic(tacticOldName,nodeId,false)
									model.addGTOccurrence(name,nodeId)
									hierTreeCtrl.redraw()
									QuantoLibAPI.setVertexValue(nodeId, model.getGTFullName(name))
									confirmDialog.close()
								}
							}
							val redoUpdate = new Action("Choose another name"){
								def apply() {
									dialog = TinkerDialog.openEditDialog("Update node", fieldMap, successCallback, failureCallback)
									confirmDialog.close()
								}
							}
							confirmDialog = TinkerDialog.openConfirmationDialog(message,Array(reuseInfo,redoUpdate))
						} else {
							isUnique = model.updateGT(tacticOldName,name,branchType,args)
							if(isUnique){
								QuantoLibAPI.setVertexValue(nodeId, name+"("+args+")")
							} else {
								var confirmDialog = new Dialog()
								val message:String = "<html>The graph tactic "+name+" has many occurrences. <br> Do you wish to edit all of them or make a new tactic ?</html>"
								val newAction:Action = new Action("Make new tactic"){
									def apply(){
										createTactic(nodeId,isAtomicTactic,values)
										model.removeGTOccurrence(tacticOldName, nodeId)
										hierTreeCtrl.redraw()
										confirmDialog.close()
									}
								}
								val editAllAction:Action = new Action("Edit all"){
									def apply(){
										val nodesToChange: Array[String] = model.updateForceGT(tacticOldName, name, branchType, args)
										hierTreeCtrl.redraw()
										val fullName = model.getGTFullName(name)
										nodesToChange.foreach{ n =>
											QuantoLibAPI.setVertexValue(n, fullName)
										}
										confirmDialog.close()
									}
								}
								confirmDialog = TinkerDialog.openConfirmationDialog(message, Array(newAction,editAllAction))
							}
						}
					}
				} catch {
					case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
					case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				}
			}
		}
		dialog = TinkerDialog.openEditDialog("Update node "+nodeId, fieldMap, successCallback, failureCallback)
	}

	/** Method to delete a tactic
		*
		* @param nodeName Name of tactic associated with the node.
		* @param nodeId Id of the node deleted.
		* @param isAtomicTactic Boolean stating the nature of the node, atomic or nested.
		*/
	def deleteTactic(nodeName:String, nodeId:String, isAtomicTactic:Boolean) {
		try {
			DocumentService.setUnsavedChanges(true)
			val tacticName = ArgumentParser.separateNameFromArgument(nodeName)._1
			val lastOcc:Boolean = if(isAtomicTactic) model.removeATOccurrence(tacticName, nodeId) else model.removeGTOccurrence(tacticName,nodeId)
			hierTreeCtrl.redraw()
			if(lastOcc){
				val message =
					if(isAtomicTactic) "This was the only occurrence of this atomic tactic, its data have been deleted."
					else "This was the only occurrence of this graph tactic, its data and child tactic's data have been deleted."
				TinkerDialog.openErrorDialog(message)
				/*var confirmDialog = new Dialog()
				val message:String = "This is the last occurrence of this tactic. Do you wish to keep its data ?"
				val keepAction:Action = new Action("Keep data") {
					def apply() {
						// do nothing
						confirmDialog.close()
					}
				}
				val delAction:Action = new Action("Delete data") {
					def apply() {
						if(isAtomicTactic) model.deleteAT(tacticName) else model.deleteGT(tacticName)
						confirmDialog.close()
					}
				}
				confirmDialog = TinkerDialog.openConfirmationDialog(message,Array(keepAction,delAction))*/
			}
		} catch {
			case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
		}
	}

	def addSubgraph(tactic: String){
		DocumentService.setUnsavedChanges(true)
		model.newSubgraph(tactic)
		hierTreeCtrl.redraw()
		QuantoLibAPI.newGraph()
		graphNavCtrl.viewedGraphChanged(model.isMain, true)
		graphBreadcrumsCtrl.addCrumb(tactic)
		publish(NothingSelectedEvent())
	}

	def deleteSubGraph(tactic: String, index: Int){
		DocumentService.setUnsavedChanges(true)
		model.delSubgraphGT(tactic, index)
	}

	def editSubGraph(tactic: String, index: Int, parents:Option[Array[String]] = None): Boolean = {
		try{
			model.changeCurrent(tactic, index)
			DocumentService.setUnsavedChanges(true)
			publish(NothingSelectedEvent())
			graphNavCtrl.viewedGraphChanged(model.isMain, false)
			graphBreadcrumsCtrl.addCrumb(tactic, parents)
			hierTreeCtrl.redraw()
			try{
				QuantoLibAPI.loadFromJson(model.getCurrentJson)
				true
			} catch {
				case e:SubgraphNotFoundException =>
					addSubgraph(tactic)
					true
			}
		} catch {
			case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				false
		}
	}

	def saveGraphSpecificTactic(tactic: String, graph: Json, index: Int) = {
		DocumentService.setUnsavedChanges(true)
		model.saveGraph(tactic, graph, index)
	}

	def setGoalTypes(s: String){
		DocumentService.setUnsavedChanges(true)
		model.goalTypes = s
	}

	def refreshGraph() {
		try{
			QuantoLibAPI.loadFromJson(model.getCurrentJson)
			// graphBreadcrumsCtrl.addCrum(getCurrent)
			hierTreeCtrl.redraw()

		} catch {
			case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
		}
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphEventAPI(graph) =>
			DocumentService.setUnsavedChanges(true)
			model.saveGraph(graph)
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
		//graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
		graphBreadcrumsCtrl.addCrumb(getCurrent)
		//hierarchyModel.changeActive(getCurrent)
		hierTreeCtrl.redraw()
	}

	def loadJson(j:Json) {
		if(!j.isEmpty){
			model.loadJsonGraph(j)
			//hierarchyModel.rebuildHierarchy(model)
			//graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
			graphBreadcrumsCtrl.addCrumb(getCurrent)
			graphNavCtrl.viewedGraphChanged(model.isMain, false)
			refreshGraph()
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
					//hierarchyModel.rebuildHierarchy(model)
					//graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
					graphBreadcrumsCtrl.addCrumb(getCurrent)
					graphNavCtrl.viewedGraphChanged(model.isMain, false)
					refreshGraph()
				}
				else{
					TinkerDialog.openErrorDialog("<html>Error while loading json from file : object is empty.</html>")
				}
			case None =>
		}
	}

	def saveJsonToFile() {
		model.updateJsonPSGraph()
		DocumentService.file match {
			case Some(_) => DocumentService.save(None, model.jsonPSGraph)
			case None => DocumentService.saveAs(None, model.jsonPSGraph)
		}
	}

	def saveJsonAs(){
		model.updateJsonPSGraph()
		DocumentService.saveAs(None, model.jsonPSGraph)
	}

	def closeDoc : Boolean = {
		model.updateJsonPSGraph()
		DocumentService.promptUnsaved(model.jsonPSGraph)
	}

	def newDoc() {
		model.updateJsonPSGraph()
		if(DocumentService.promptUnsaved(model.jsonPSGraph)){
			model.loadJsonGraph(JsonObject("current" -> "main", "current_index" -> 0, "graph" -> JsonObject(), "graph_tactics" -> JsonArray(Array[JsonObject]()), "atomic_tactics" -> JsonArray(Array[JsonObject]()), "goal_types" -> ""))
			//hierarchyModel.rebuildHierarchy(model)
			//graphBreadcrumsCtrl.rebuildParent(getParentList(getCurrent))
			graphBreadcrumsCtrl.addCrumb(getCurrent)
			graphNavCtrl.viewedGraphChanged(model.isMain, false)
			refreshGraph()
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