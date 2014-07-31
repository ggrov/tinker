package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.PSGraph
import tinkerGUI.model.HierarchyModel
import tinkerGUI.model.TreeElement
import tinkerGUI.model.HasArguments
import quanto.util.json._
import tinkerGUI.utils.ArgumentParser

object Service extends Publisher {
	val hierarchyModel = new HierarchyModel()
	val model = new PSGraph()
	val mainCtrl = new MainGUIController()
	val graphEditCtrl = new GraphEditController()
	val eltEditCtrl = new ElementEditController()
	val menuCtrl = new MenuController()
	val editControlsCtrl = new EditControlsController()
	val graphBreadcrumsCtrl = new GraphBreadcrumsController()
	val subGraphEditCtrl = new SubGraphEditController()
	val graphNavCtrl = new GraphNavigationController()
	val hierTreeCtrl = new HierarchyTreeController()
	val libraryTreeCtrl = new TinkerLibraryController()

	def changeGraphEditMouseState(state: String){
		graphEditCtrl.changeMouseState(state)
	}

	def getHierarchyRoot = hierarchyModel.root
	def getHierarchyActive = hierarchyModel.activeElement

	def addSubgraph(tactic: String, isOr: Boolean){
		model.newSubGraph(tactic, isOr)
		hierarchyModel.changeActive(tactic)
		hierTreeCtrl.redraw
		QuantoLibAPI.newGraph()
		graphNavCtrl.viewedGraphChanged(model.isMain, true)
		graphBreadcrumsCtrl.addCrum(tactic)
		publish(NothingSelectedEvent())
	}

	def deleteSubGraph(tactic: String, index: Int){
		model.delSubGraph(tactic, index)
	}

	def deleteTactic(tactic: String){
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

	def getSpecificJsonFromModel(tactic: String, index: Int) = model.getSpecificJson(tactic, index)
	def getSizeOfTactic(tactic: String) = model.getSizeOfTactic(tactic)
	def setIsOr(tactic: String, isOr: Boolean) = model.graphTacticSetIsOr(tactic, isOr)
	def isNestedOr(tactic: String) = model.isGraphTacticOr(tactic)

	def getCurrentIndex = model.currentIndex
	def getCurrentSize = model.currentTactic.graphs.size
	def getCurrent = model.currentTactic.name

	def editSubGraph(tactic: String, index: Int): Boolean = {
		if(model.changeCurrent(tactic, index)){
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
					addSubgraph(tactic, true)
					return true
			}
		}
		else{
			addSubgraph(tactic, true)
			return true
		}
		return false
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

	def saveGraphSpecificTactic(tactic: String, graph: Json) = model.saveGraphSpecificTactic(tactic, graph)

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphEventAPI(graph) =>
			model.saveCurrentGraph(graph)
			graphNavCtrl.disableAdd = false
	}

	def createNode(n: String, isGraphTactic: Boolean, isOr: Boolean): String = {
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
		val actualNewVal = model.updateTacticName(oldVal, newVal)
		if(isGraphTactic) {
			hierarchyModel.updateElementName(oldVal, actualNewVal)
			hierTreeCtrl.redraw
		}
		actualNewVal
	}

	def getParentList(tactic: String) = hierarchyModel.buildParentList(tactic, Array[String]())
	def changeTacticParent(tactic: String, parent: String) = hierarchyModel.changeParent(tactic, parent)

	def parseAndUpdateArguments(tactic: String, s: String) {
		val args = ArgumentParser.stringToArguments(s)
		model.updateTacticArguments(tactic, args)
	}

	def updateArguments(tactic: String, args: Array[Array[String]]){
		model.updateTacticArguments(tactic, args)
	}

	def getAtomicTacticValue(tactic: String): String = model.getAtomicTacticValue(tactic)
	def setAtomicTacticValue(tactic: String, value: String) = model.setAtomicTacticValue(tactic, value)

	def getGoalTypes = model.goalTypes
	def setGoalTypes(s: String){
		model.goalTypes = s
	}
}