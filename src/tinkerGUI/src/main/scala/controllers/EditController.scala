package tinkerGUI.controllers

import java.util.regex.Pattern

import tinkerGUI.controllers.events.{CurrentGraphChangedEvent, GraphTacticListEvent, MouseStateChangedEvent}
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{AtomicTacticNotFoundException, PSGraphModelException, SubgraphNotFoundException, GraphTacticNotFoundException}
import tinkerGUI.utils._
import tinkerGUI.views.ContextMenu

import scala.swing.event.Key
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

	/** Log stack for edition.*/
	val logStack = new FilteredLogStack

	/** Callback method for parsing the tactic definitions in tactic editor.
		*
		* @param s Input string.
		*/
	def tacticParser(s:String) {
		val pattern = Pattern.compile("^tactic\\s([^\\s]+)\\s?:=\\s*(([^;]|\\n|\\t)*)\\s*;$",Pattern.MULTILINE)
		val matcher = pattern.matcher(s)
		while(matcher.find()){
			try{
				Service.documentCtrl.registerChanges()
				model.setTacticValue(matcher.group(1),matcher.group(2))
			} catch {
				case e:AtomicTacticNotFoundException =>
					model.createAT(matcher.group(1),matcher.group(2))
			}
		}
	}

	/** Tactic editor.*/
	val tacticEditor = new EditorWindow("Tinker - tactic editor",tacticParser)

	/** Method updating the tactic editor text, after loading a model for instance.*/
	def updateTacticEditor() {
		tacticEditor.clear()
		tacticEditor.appendText("// edit your tactic here\n")
		model.atCollection.foreach{
			case (k,v) if v.tactic.nonEmpty =>
				tacticEditor.appendText("tactic "+v.name+" := "+v.tactic+";\n")
			case _ =>
		}
	}

	/** Callback method for parsing the goal types definitions in goal type editor.
		*
		* @param s Input string.
		*/
	def goalTypeParser(s:String) {
		Service.documentCtrl.registerChanges()
		model.goalTypes = s
	}

	/** Goal types editor.*/
	val goaltypeEditor = new EditorWindow("Tinker - goal type editor",goalTypeParser)

	/** Method updating the goal types editor text, after loading a model for instance.*/
	def updateGoaltypeEditor() {
		goaltypeEditor.clear()
		goaltypeEditor.appendText(model.goalTypes)
	}

	/** Method launching all editors' update functions.*/
	def updateEditors() {
		updateTacticEditor()
		updateGoaltypeEditor()
	}

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
		publish(MouseStateChangedEvent(state))
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
					QuantoLibAPI.editGraphElement(point)
				}
				else QuantoLibAPI.selectElement(point,modifiers,changeMouseState)
			case AddEdgeTool() =>
				Service.documentCtrl.registerChanges()
				QuantoLibAPI.startAddEdge(point,changeMouseState)
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
				if(Service.evalCtrl.recording){
					Service.evalCtrl.overwriteLastRecord()
				}
				mouseState = SelectTool()
			case SelectionBox(start, _) =>
				val selectionUpdated = !(point.getX == start.getX && point.getY == start.getY)
				val rect = mouseState.asInstanceOf[SelectionBox].rect
				QuantoLibAPI.viewSelectBoxFinal(selectionUpdated, point, rect)
				mouseState = SelectTool()
				QuantoLibAPI.viewSelectBox()
			case DragEdge(startV) =>
				if(QuantoLibAPI.movingEdge) Service.documentCtrl.registerChanges()
				QuantoLibAPI.endAddEdge(startV, point, changeMouseState)
			case AddVertexTool(typ) =>
				//Service.documentCtrl.registerChanges()
				createNode(typ,point)
				//QuantoLibAPI.userAddVertex(point, typ)
			case _ => // do nothing
		}
	}

	/** Method editing the proof name.
		*
		*/
	def changeProofName() {
		def successCallBack(values:Map[String,String]) {
			val name = values("Proof name")
			if(model.gtCollection.contains(name)){
				TinkerDialog.openEditDialog("This name is already taken, enter another one.",values,successCallBack,()=>Unit)
			} else {
				model.changeMainName(name)
				DocumentService.proofTitle = name
				publish(GraphTacticListEvent())
				publish(CurrentGraphChangedEvent(model.getCurrentGTName,Some(model.currentParents)))
			}
		}
		TinkerDialog.openEditDialog("Edit proof name.",Map("Proof name"->model.mainTactic.name),successCallBack,()=>Unit)
	}

	/** Method creating a node and if necessary a tactic.
		*
		* @param typ Type of node, should be "T_Identity", "T_Atomic" or "T_Graph", the latter two will create a tactic in the model.
		* @param pt Coordinates of the node.
		*/
	def createNode(typ:String,pt:java.awt.Point) {
		try{
			typ match {
				case "T_Identity" =>
					Service.documentCtrl.registerChanges()
					QuantoLibAPI.userAddVertex(pt,typ,"")
				case "T_Atomic" =>
					def successCallback(values:Map[String,String]) {
						val name = ArgumentParser.separateNameArgs(values("Name"))._1
						if(name.isEmpty){
							TinkerDialog.openEditDialog("Create atomic tactic",values,successCallback,()=>Unit)
						} else {
							Service.documentCtrl.registerChanges()
							if(model.createAT(name,"")){
								model.addATOccurrence(name,QuantoLibAPI.userAddVertex(pt,typ,values("Name")))
							} else {
								var confirmDialog = new Dialog()
								val newAction = new Action("Create new"){
									def apply() = {
										confirmDialog.close()
										TinkerDialog.openEditDialog("Create atomic tactic",values,successCallback,()=>Unit)
									}
								}
								val duplicateAction = new Action("Link node to tactic"){
									def apply() = {
										confirmDialog.close()
										model.addATOccurrence(name,QuantoLibAPI.userAddVertex(pt,typ,values("Name")))
									}
								}
								confirmDialog = TinkerDialog.openConfirmationDialog("The atomic tactic name "+name+" is already defined.",Array(newAction,duplicateAction))
							}
						}
					}
					TinkerDialog.openEditDialog("Create atomic tactic", Map("Name"->""),successCallback,()=>Unit)
				case "T_Graph" =>
					def successCallback(values:Map[String,String]) {
						val name = ArgumentParser.separateNameArgs(values("Name"))._1
						val branchType = values("Branch type")
						if(name.isEmpty){
							TinkerDialog.openEditDialog("Create graph tactic",values,successCallback,()=>Unit)
						} else {
							Service.documentCtrl.registerChanges()
							if(model.createGT(name,branchType)){
								model.addGTOccurrence(name,QuantoLibAPI.userAddVertex(pt,typ,values("Name")))
								publish(GraphTacticListEvent())
							} else {
								var confirmDialog = new Dialog()
								val newAction = new Action("Create new"){
									def apply() = {
										confirmDialog.close()
										TinkerDialog.openEditDialog("Create graph tactic",values,successCallback,()=>Unit)
									}
								}
								val duplicateAction = new Action("Link node to tactic"){
									def apply() = {
										confirmDialog.close()
										model.addGTOccurrence(name,QuantoLibAPI.userAddVertex(pt,typ,values("Name")))
										publish(GraphTacticListEvent())
									}
								}
								confirmDialog = TinkerDialog.openConfirmationDialog("The graph tactic name "+name+" is already defined.",Array(newAction,duplicateAction))
							}
						}
					}
					TinkerDialog.openEditDialog("Create graph tactic", Map("Name"->"","Branch type"->"OR"),successCallback,()=>Unit)
			}
		} catch {
			case e:PSGraphModelException =>
				logStack.addToLog("Model error",e.msg)
		}
	}

	/** Method deleting a node and removing its occurrence in the model if necessary.
		*
		* @param typ Type of node, should be "T_Identity", "T_Atomic" or "T_Graph", the latter two will remove the occurrence in the model.
		* @param nodeId Id tof the node to delete.
		* @param nodeValue Value associated with the node, i.e. the tactic name if any.
		*/
	def deleteNode(typ:String,nodeId:String,nodeValue:String) {
		try{
			typ match {
				case "G_Break" =>
					Service.documentCtrl.registerChanges()
					QuantoLibAPI.removeBreakpoint(nodeId)
				case "T_Identity" =>
					Service.documentCtrl.registerChanges()
					QuantoLibAPI.userDeleteElement(nodeId)
				case "T_Atomic" =>
					Service.documentCtrl.registerChanges()
					QuantoLibAPI.userDeleteElement(nodeId)
					model.removeATOccurrence(nodeValue,nodeId)
				case "T_Graph" =>
					if(!(Service.evalCtrl.inEval
						&& Service.evalCtrl.evalPath.contains(model.getCurrentGTName)
						&& Service.evalCtrl.evalPath.contains(nodeValue))){
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.userDeleteElement(nodeId)
						model.removeGTOccurrence(nodeValue,nodeId)
						publish(GraphTacticListEvent())
					} else {
						logStack.addToLog("Edit forbidden","this tactic is being evaluated by the core, you cannot delete it")
					}
				case "Boundary" =>
					Service.documentCtrl.registerChanges()
					QuantoLibAPI.userDeleteElement(nodeId)
				case "G" => logStack.addToLog("Edit forbidden","you cannot delete a goal")
			}
		} catch {
			case e:PSGraphModelException => logStack.addToLog("Model error",e.msg)
		}
	}

	/** Method deleting an edge.
		*
		* Prevents deleting an edge with goal on it. Will also remove all breakpoints on this edge before deleting it.
		* @param edgeId Id of the edge to remove.
		*/
	def deleteEdge(edgeId:String) {
		if(!QuantoLibAPI.hasGoal(edgeId)){
			Service.documentCtrl.registerChanges()
			QuantoLibAPI.userDeleteElement(edgeId)
		} else {
			logStack.addToLog("Edit forbidden","you can not delete an edge with a goal on it.")
		}
	}

	/** Method to create a tactic with given name and parameters.
		*
		* Does not implement any user interaction.
		* @param nodeId Node id on the graph.
		* @param name Tactic id.
		* @param param Tactic parameter (core id for atomic, branchtype for graph).
		* @param isAtomic Whether it is an atomic tactic or not to be created.
		*/
	def createTactic(nodeId:String, name:String, param:String, isAtomic:Boolean) {
		try{
			if(isAtomic){
				model.createAT(name,param)
				model.addATOccurrence(name,nodeId)
			} else {
				model.createGT(name,param)
				model.addGTOccurrence(name,nodeId)
			}
		} catch {
			case e:PSGraphModelException => logStack.addToLog("Model error",e.msg)
		}
	}

	/** Method to update a tactic's details.
		*
		* Launched after the user selected the edit option.
		* Launches dialogs to interact with user to get more information on tactic.
		*/
	def updateTactic(nodeId:String, nodeLabel:String, tacticValue:String, isAtomicTactic:Boolean){
		try{
			if(isAtomicTactic){
				def successCallback(values:Map[String,String]) {
					val name = ArgumentParser.separateNameArgs(values("Name"))._1
					if(name.isEmpty){
						TinkerDialog.openEditDialog("Edit atomic tactic",values,successCallback,()=>Unit)
					} else {
						if(model.atCollection.contains(name) && name != tacticValue){
							var confirmDialog = new Dialog()
							val duplicateAction = new Action("Link node to "+name){
								def apply() = {
									confirmDialog.close()
									Service.documentCtrl.registerChanges()
									model.removeATOccurrence(tacticValue,nodeId)
									model.addATOccurrence(name,nodeId)
									QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
								}
							}
							val redoAction = new Action("Choose another name"){
								def apply() = {
									confirmDialog.close()
									TinkerDialog.openEditDialog("Edit atomic tactic",values,successCallback,()=>Unit)
								}
							}
							val cancelAction = new Action("Cancel"){def apply() = { confirmDialog.close() }}
							confirmDialog = TinkerDialog.openConfirmationDialog("The atomic tactic name "+name+" is already taken.",Array(duplicateAction,redoAction,cancelAction))
						} else if(name == tacticValue) {
							Service.documentCtrl.registerChanges()
							QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
						} else {
							Service.documentCtrl.registerChanges()
							if(model.updateAT(tacticValue,name)){
								QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
							} else {
								var confirmDialog = new Dialog()
								val createAction = new Action("Create new"){
									def apply() = {
										confirmDialog.close()
										model.removeATOccurrence(tacticValue,nodeId)
										model.createAT(name,"")
										model.addATOccurrence(name,nodeId)
										QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
									}
								}
								val updateAction = new Action("Update all"){
									def apply() = {
										confirmDialog.close()
										model.updateForceAT(tacticValue,name).foreach(QuantoLibAPI.setVertexValue(_,name))
										QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
									}
								}
								val cancelAction = new Action("Cancel"){def apply() = { confirmDialog.close() }}
								confirmDialog = TinkerDialog.openConfirmationDialog("The atomic tactic "+name+" has many occurrences.",Array(createAction,updateAction,cancelAction))
							}
						}
					}
				}
				TinkerDialog.openEditDialog("Edit atomic tactic",Map("Name"->nodeLabel),successCallback,()=>Unit)
			} else {
				def successCallback(values:Map[String,String]) {
					val name = ArgumentParser.separateNameArgs(values("Name"))._1
					val branchType = values("Branch type")
					if(name.isEmpty){
						TinkerDialog.openEditDialog("Edit graph tactic",values,successCallback,()=>Unit)
					} else {
						if(model.gtCollection.contains(name) && name != tacticValue){
							var confirmDialog = new Dialog()
							val duplicateAction = new Action("Link node to "+name){
								def apply() = {
									confirmDialog.close()
									Service.documentCtrl.registerChanges()
									model.removeGTOccurrence(tacticValue,nodeId)
									model.addGTOccurrence(name,nodeId)
									QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
									publish(GraphTacticListEvent())
								}
							}
							val redoAction = new Action("Choose another name"){
								def apply() = {
									confirmDialog.close()
									TinkerDialog.openEditDialog("Edit graph tactic",values,successCallback,()=>Unit)
								}
							}
							val cancelAction = new Action("Cancel"){def apply() = { confirmDialog.close() }}
							// the following will not give the option to link a nested node to another graph tactic
							// if the user is evaluating and the is editing the evaluation path
							val actionArray:Array[Action] =
								if(Service.evalCtrl.inEval
									&& Service.evalCtrl.evalPath.contains(model.getCurrentGTName)
									&& Service.evalCtrl.evalPath.contains(tacticValue)){
									Array(redoAction,cancelAction)
								} else {
									Array(duplicateAction,redoAction,cancelAction)
								}
							confirmDialog = TinkerDialog.openConfirmationDialog("The graph tactic name "+name+" is already taken.",actionArray)
						} else if(name == tacticValue && branchType == model.getGTBranchType(name)){
							Service.documentCtrl.registerChanges()
							QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
						} else {
							Service.documentCtrl.registerChanges()
							if(model.updateGT(tacticValue,name,branchType)){
								QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
								publish(GraphTacticListEvent())
							} else {
								var confirmDialog = new Dialog()
								val createAction = new Action("Create new"){
									def apply() = {
										confirmDialog.close()
										model.removeGTOccurrence(tacticValue,nodeId)
										model.createGT(name,branchType)
										model.addATOccurrence(name,nodeId)
										QuantoLibAPI.setVertexLabel(nodeId,values("Name"))
										publish(GraphTacticListEvent())
									}
								}
								val updateAction = new Action("Update all"){
									def apply() = {
										confirmDialog.close()
										model.updateForceGT(tacticValue,name,branchType).foreach(QuantoLibAPI.setVertexLabel(_,values("Name")))
										publish(GraphTacticListEvent())
									}
								}
								val cancelAction = new Action("Cancel"){def apply() = { confirmDialog.close() }}
								// the following will not give the option to create a new graph tactic
								// if the user is evaluating and the is editing the evaluation path
								val actionArray:Array[Action] =
									if(Service.evalCtrl.inEval
										&& Service.evalCtrl.evalPath.contains(model.getCurrentGTName)
										&& Service.evalCtrl.evalPath.contains(tacticValue)){
										Array(updateAction,cancelAction)
									} else {
										Array(createAction,updateAction,cancelAction)
									}
								confirmDialog = TinkerDialog.openConfirmationDialog("The graph tactic "+name+" has many occurrences.",actionArray)
							}
						}
					}
				}
				TinkerDialog.openEditDialog("Edit graph tactic",Map("Name"->nodeLabel,"Branch type"->model.getGTBranchType(tacticValue)),successCallback,()=>Unit)
			}
		} catch {
			case e:PSGraphModelException => logStack.addToLog("Model error",e.msg)
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
			case e:PSGraphModelException => logStack.addToLog("Model error",e.msg)
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
						successCallback,()=>Unit
				)
			} else {
				Service.documentCtrl.registerChanges()
				QuantoLibAPI.setEdgeValue(edge, goalTypes)
				QuantoLibAPI.userUpdateEdge(edge, source, target)
			}
		}
		TinkerDialog.openEditDialog("Edit edge "+edge,
			Map("Goal types"->goalTypes, "From"->source, "To"->target),
			successCallback,()=>Unit
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
			Service.documentCtrl.registerChanges()
			model.changeCurrent(tactic, index, parents)
			Service.graphNavCtrl.viewedGraphChanged(model.isMain,false)
			QuantoLibAPI.loadFromJson(model.getCurrentJson)
			publish(CurrentGraphChangedEvent(tactic,parents))
		} catch {
			case e:GraphTacticNotFoundException => logStack.addToLog("Model error",e.msg)
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
			Service.documentCtrl.registerChanges()
			model.newSubgraph(tactic, parents)
			QuantoLibAPI.newGraph()
			Service.graphNavCtrl.viewedGraphChanged(model.isMain,true)
			publish(CurrentGraphChangedEvent(tactic,parents))
		} catch {
			case e:GraphTacticNotFoundException => logStack.addToLog("Model error",e.msg)
		}
	}

	/** Method deleting a subgraph in the model.
		*
		* @param tactic Id of the tactic in which the subgraph is.
		* @param index Index of the subgraph in the tactic.
		*/
	def deleteSubgraph(tactic:String,index:Int) {
		if(!(Service.evalCtrl.inEval && Service.evalCtrl.evalPath.contains(tactic))){
			Service.documentCtrl.registerChanges()
			model.delSubgraphGT(tactic,index)
		} else {
			logStack.addToLog("Edit forbidden","this tactic is being evaluated by the core, you cannot delete one of its subgraph")
		}
	}

	/** Method allowing merge of selected node into a graph tactic.
		*
		*/
	def mergeSelectedNodes(){
		def successCallback(values:Map[String,String]): Unit ={
			if(values("Name") == ""){
				TinkerDialog.openEditDialog("Merge nodes into a graph tactic",values,successCallback,()=>Unit)
			} else {
				val name = ArgumentParser.separateNameArgs(values("Name"))._1
				if(model.gtCollection.contains(name) || model.mainTactic.name == name){
					TinkerDialog.openEditDialog("<html>Merge nodes into a graph tactic<br>This name is already taken</html>",values,successCallback,()=>Unit)
				} else {
					Service.documentCtrl.registerChanges()
					model.createGT(name,values("Branch type"))
					model.addGTOccurrence(name,QuantoLibAPI.mergeSelectedVertices(values("Name")))
					// todo : insert new tactic in eval path if necessary
					publish(GraphTacticListEvent())
				}
			}
		}
		if(Service.evalCtrl.inEval
			&& !QuantoLibAPI.selectedContainTactics(Service.evalCtrl.evalPath.toSet)
			&& QuantoLibAPI.selectedContainGoals){
			logStack.addToLog("Edit forbidden","merging these nodes will break the evaluation")
		} else {
			TinkerDialog.openEditDialog("Merge nodes into a graph tactic",Map("Name"->"","Branch type"->"OR"),successCallback,()=>Unit)
		}
	}

	/** Method deleting a set of nodes on the graph.
		*
		* @param names Ids of the nodes to remove.
		*/
	def deleteNodes(names:Set[String]) {
		Service.documentCtrl.registerChanges()
		names.foreach{ n =>
			QuantoLibAPI.getNodeTypeAndValue(n) match {
				case ("G_Break",_) => QuantoLibAPI.removeBreakpoint(n)
				case ("G",_) => logStack.addToLog("Edit forbidden","you cannot delete a goal")
				case ("Boundary",_) => QuantoLibAPI.userDeleteElement(n)
				case ("T_Identity",_) => QuantoLibAPI.userDeleteElement(n)
				case ("T_Atomic",v:String) =>
					model.removeATOccurrence(v,n)
					QuantoLibAPI.userDeleteElement(n)
				case ("T_Graph",v:String) =>
					if(!(Service.evalCtrl.inEval
						&& Service.evalCtrl.evalPath.contains(model.getCurrentGTName)
						&& Service.evalCtrl.evalPath.contains(v))){
						model.removeGTOccurrence(v,n)
						QuantoLibAPI.userDeleteElement(n)
						publish(GraphTacticListEvent())
					} else {
						logStack.addToLog("Edit forbidden","this tactic is being evaluated by the core, you cannot delete it")
					}
			}
		}
	}

	/** Method to trigger the paste function.
		*
		*/
	def paste {
		if(QuantoLibAPI.canPaste){
			Service.documentCtrl.registerChanges()
			QuantoLibAPI.paste()
		}
	}

	/** Method removing a breakpoint from an edge.
		*
		* @param edge Edge id.
		*/
	def removeBreakFromEdge(edge:String) {
		Service.documentCtrl.registerChanges()
		QuantoLibAPI.removeBreakpointFromEdge(edge)
	}

	/** Method adding a breakpoint on aa edge.
		*
		* @param edge Edge id.
		*/
	def addBreakOnEdge(edge:String) {
		Service.documentCtrl.registerChanges()
		QuantoLibAPI.addBreakpointOnEdge(edge)
	}
}
