package tinkerGUI.controllers

import tinkerGUI.controllers.events.{CurrentGraphChangedEvent, GraphTacticListEvent}
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{SubgraphNotFoundException, GraphTacticNotFoundException, AtomicTacticNotFoundException}
import tinkerGUI.utils._
import tinkerGUI.views.ContextMenu

import scala.swing.event.Key.Modifiers
import scala.swing.{Component, Publisher, Action, Dialog}


/** Controller managing the edition of psgraph.
	*
	* @param model Psgraph model.
	*/
class EditController(model:PSGraph) extends Publisher {

	/** Mouse state variable.
		*
		* Keeps track of what is the current edition mode.
		*/
	private var mouseState: MouseState = SelectTool()

	/** Method to update the mouse state.
		*
		* @param state State id.
		*/
	def changeMouseState(state: String) {
		state match {
			case "select" => mouseState = SelectTool()
			case "addIDVertex" => mouseState = AddVertexTool("T_Identity")
			case "addATMVertex" => mouseState = AddVertexTool("T_Atomic")
			case "addNSTVertex" => mouseState = AddVertexTool("T_Graph")
			case "addEdge" => mouseState = AddEdgeTool()
		}
	}

	/** Method to update the mouse state.
		*
		* @param state State id.
		* @param param Potential parameter (e.g. vertex id, coordinates ...).
		*/
	def changeMouseState(state: String, param: Any) {
		param match {
			case s:String =>
				state match {
					case "dragEdge" => mouseState = DragEdge(s)
				}
			case pt:java.awt.Point =>
				state match {
					case "dragVertex" => mouseState = DragVertex(pt, pt)
					case "selectionBox" =>
						val box = SelectionBox(pt, pt)
						mouseState = box
						QuantoLibAPI.viewSelectBox(box)
				}
		}
	}

	/** Method handling a left click on the graph.
		*
		* @param point Coordinates of the click.
		* @param modifiers Potential modifiers of the click.
		* @param clicks Number of clicks.
		*/
	def leftMousePressed(point: java.awt.Point, modifiers: Modifiers, clicks: Int) {
		mouseState match {
			case SelectTool() =>
				if(clicks == 2) {
					Service.documentCtrl.registerChanges()
					QuantoLibAPI.editGraphElement(point)
				}
				else QuantoLibAPI.selectElement(point,modifiers,changeMouseState)
			case AddEdgeTool() => QuantoLibAPI.startAddEdge(point,changeMouseState)
			case _ => //do nothing
		}
	}

	/** Method handling a right click on the graph.
		*
		* @param point Coordinates of the click.
		* @param modifiers Potential modifiers of the click.
		* @param clicks Number of clicks.
		* @param source Source of the click.
		*/
	def rightMousePressed(point: java.awt.Point, modifiers: Modifiers, clicks: Int, source: Component): Unit = {
		def emptyFunc(s:String, a:Any) { }
		QuantoLibAPI.selectElement(point, modifiers, emptyFunc)
		ContextMenu.show(source, point.getX.toInt, point.getY.toInt)
	}

	/** Method handling a mouse drag on the graph.
		*
		* @param point Coordinates of the origin of the drag.
		*/
	def mouseDragged(point: java.awt.Point): Unit = {
		mouseState match {
			case DragVertex(start, prev) =>
				QuantoLibAPI.dragVertex(point, prev)
				mouseState = DragVertex(start,point)
			case SelectionBox(start, _) =>
				val box = SelectionBox(start,point)
				mouseState = box
				QuantoLibAPI.viewSelectBox(box)
			case DragEdge(startV)	=> QuantoLibAPI.dragEdge(startV,point)
			case _ => // do nothing
		}
	}

	/** Method handling a mouse release on the graph.
		*
		* @param point Coordinates of the release.
		* @param modifiers Potential modifiers of the release.
		*/
	def mouseReleased(point: java.awt.Point, modifiers:Modifiers): Unit = {
		mouseState match {
			case DragVertex(start, end) =>
				if(start.getX != end.getX || start.getY != end.getY) {
					//QuantoLibAPI.moveVertex(start, end)
				}
				mouseState = SelectTool()
			case SelectionBox(start, _) =>
				val selectionUpdated = !(point.getX == start.getX && point.getY == start.getY)
				val rect = mouseState.asInstanceOf[SelectionBox].rect
				QuantoLibAPI.viewSelectBoxFinal(selectionUpdated, point, rect)
				mouseState = SelectTool()
				QuantoLibAPI.viewSelectBox()
			case DragEdge(startV) =>
				Service.documentCtrl.registerChanges()
				QuantoLibAPI.endAddEdge(startV, point, changeMouseState)
			case AddVertexTool(typ) =>
				Service.documentCtrl.registerChanges()
				QuantoLibAPI.userAddVertex(point, typ)
			case _ => // do nothing
		}
	}

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
					//DocumentService.setUnsavedChanges(true)
					checkedByModel = if(isAtomicTactic) model.createAT(name,tactic,args) else model.createGT(name,branchType,args)
					if(checkedByModel){
						if(isAtomicTactic) model.addATOccurrence(name,nodeId) else {model.addGTOccurrence(name,nodeId); publish(GraphTacticListEvent())}
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
								if(isAtomicTactic) model.addATOccurrence(name,nodeId) else {model.addGTOccurrence(name,nodeId); publish(GraphTacticListEvent())}
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

	/** Method to force the creation of a new default tactic, i.e. does not allow duplication.
		*
		* The user should be asked to update the tactic information after the use of this method.
		*
		* @param nodeId Id of the node the user is creating.
		* @param name Default name given to the tactic (reused for atomic tactic core id).
		* @param isAtomicTactic Boolean stating the nature of the node, atomic of nested.
		*/
	def createNewTactic(nodeId:String, name:String, isAtomicTactic:Boolean):String = {
		var checkedByModel:Boolean =
			if(isAtomicTactic) model.createAT(name, name, "")
			else model.createGT(name,"OR","")
		var i = 0
		var n = name
		while(!checkedByModel){
			i+=1
			n = name+"-"+i
			checkedByModel =
				if(isAtomicTactic) model.createAT(n, n, "")
				else model.createGT(n,"OR","")
		}
		try{
			if(isAtomicTactic) model.addATOccurrence(name,nodeId) else {model.addGTOccurrence(name,nodeId); publish(GraphTacticListEvent())}
		} catch {
			case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
		}
		n
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
					//DocumentService.setUnsavedChanges(true)
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
									publish(GraphTacticListEvent())
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
										publish(GraphTacticListEvent())
										confirmDialog.close()
									}
								}
								val editAllAction:Action = new Action("Edit all"){
									def apply(){
										val nodesToChange: Array[String] = model.updateForceGT(tacticOldName, name, branchType, args)
										publish(GraphTacticListEvent())
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

			val tacticName = ArgumentParser.separateNameFromArgument(nodeName)._1
			val lastOcc:Boolean = if(isAtomicTactic) model.removeATOccurrence(tacticName, nodeId) else model.removeGTOccurrence(tacticName,nodeId)
			publish(GraphTacticListEvent())
			if(lastOcc){
				val message =
					if(isAtomicTactic) "This was the only occurrence of this atomic tactic, its data have been deleted."
					else "This was the only occurrence of this graph tactic, its data and child tactic's data have been deleted."
				TinkerDialog.openInformationDialog(message)
				// the following was opening a dialog to ask the user if they want to keep the data
				// note that it induced complication when removing a graph tactic having children tactic appearing once as well
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

	/** Method changing a tactic occurrence in the model.
		*
		* Mainly used when nodes are merged into a subgraph.
		*
		* @param nodeId Id of the node.
		* @param name Id of the tactic.
		* @param newParent New parent of the tactic.
		* @param newIndex New index of the tactic.
		* @param isAtomicTactic Boolean stating the nature of the node (atomic or nested).
		*/
	def changeTacticOccurrence(nodeId:String, name:String, newParent:String, newIndex:Int, isAtomicTactic:Boolean) {
		try{
			if(isAtomicTactic){
				model.removeATOccurrenceNoDelete(name, nodeId)
				model.addATOccurrence(name, newParent, newIndex, nodeId)
			} else {
				model.removeGTOccurrenceNoDelete(name, nodeId)
				model.addGTOccurrence(name, newParent, newIndex, nodeId)
			}
		} catch {
			case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
		}
	}

	/** Method opening a dialog to edit an edge.
		*
		* @param edge Id of the edge to edit.
		* @param src Source of the edge.
		* @param tgt Target of the edge.
		* @param gt Goaltype of the edge.
		*/
	def editEdge(edge:String, src:String, tgt:String, gt:String) {
		var source = src
		var target = tgt
		var goalTypes = gt
		def failureCallback() {
			// do nothing
		}
		def successCallback(values:Map[String,String]) {
			values.foreach{
				case ("Goal types",v) =>
					goalTypes = v
				case ("From",v) =>
					source = v
				case ("To",v) =>
					target = v
			}
			if(goalTypes=="" || source=="" || target=="") {
				TinkerDialog.openEditDialog("Edit edge " + edge,
						Map("Goal types" -> goalTypes, "From" -> source, "To" -> target),
						successCallback,
						failureCallback
				)
			} else {
				QuantoLibAPI.setEdgeValue(edge,goalTypes)
				QuantoLibAPI.userUpdateEdge(edge, source, target)
			}
		}
		TinkerDialog.openEditDialog("Edit edge "+edge,
			Map("Goal types"->goalTypes, "From"->source, "To"->target),
			successCallback,
			failureCallback
		)
	}

	/** Method switching the currently edited subgraph.
		*
		* @param tactic Id of the tactic in which the subgraph is.
		* @param index Index of the subgraph to edit.
		* @param parents Optional parent list of the tactic, used to remake the breadcrumbs, default value is None.
		*/
	def editSubgraph(tactic:String, index:Int, parents:Option[Array[String]] = None) {
		try {
			//Service.documentCtrl.registerChanges()
			if(model.getCurrentGTName != tactic){
				publish(CurrentGraphChangedEvent(tactic,parents))
			}
			model.changeCurrent(tactic, index)
			Service.graphNavCtrl.viewedGraphChanged(model.isMain,false)
			QuantoLibAPI.loadFromJson(model.getCurrentJson)
		} catch {
			case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			case e:SubgraphNotFoundException =>
				addSubgraph(tactic,parents)
		}
	}

	/** Method adding a subgraph to a tactic and using it as current.
		*
		* @param tactic Id of the tactic in which to add the subgraph.
		* @param parents Optional parent list of the tactic, used to remake the breadcrumbs, default value is None.
		*/
	def addSubgraph(tactic:String, parents:Option[Array[String]] = None) {
		try{
			//Service.documentCtrl.registerChanges()
			if(model.getCurrentGTName != tactic){
				publish(CurrentGraphChangedEvent(tactic,parents))
			}
			model.newSubgraph(tactic)
			QuantoLibAPI.newGraph()
			Service.graphNavCtrl.viewedGraphChanged(model.isMain,true)
		} catch {
			case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
		}
	}

	/** Method deleting a subgraph in the model.
		*
		* @param tactic Id of the tactic in which the subgraph is.
		* @param index Index of the subgraph in the tactic.
		*/
	def deleteSubgraph(tactic:String,index:Int) {
		//Service.documentCtrl.registerChanges()
		model.delSubgraphGT(tactic,index)
	}
}
