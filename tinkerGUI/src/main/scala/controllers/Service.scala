package tinkerGUI.controllers

import scala.swing._
import tinkerGUI.model.PSGraph
import tinkerGUI.model.HierarchyModel
import tinkerGUI.model.TreeElement
import tinkerGUI.model.HasArguments
import quanto.util.json._

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

	def saveGraphSpecificTactic(tactic: String, graph: Json) = model.saveGraphSpecificTactic(tactic, graph)

	listenTo(QuantoLibAPI)
	reactions += {
		case GraphEventAPI(graph) =>
			model.saveCurrentGraph(graph)
			graphNavCtrl.disableAdd = false
	}

	def checkNodeName(n: String, sufix: Int, create: Boolean): String = {
		var name = n
		if(sufix != 0) name = (n+"-"+sufix)
		model.lookForGraphTactic(name) match {
			case None =>
				if(create) {
					model.createGraphTactic(name, true)
					hierarchyModel.addElement(name)
					hierTreeCtrl.redraw
				}
				name
			case Some(t:HasArguments) =>
				checkNodeName(n, (sufix+1), create)
		}
	}

	def updateTacticName(oldVal: String, newVal: String) = {
		val isGraphTactic = model.updateTacticName(oldVal, newVal)
		if(isGraphTactic) {
			hierarchyModel.updateElementName(oldVal, newVal)
			hierTreeCtrl.redraw
		}
	}

	def getParentList(tactic: String) = hierarchyModel.buildParentList(tactic, Array[String]())
	def changeTacticParent(tactic: String, parent: String) = hierarchyModel.changeParent(tactic, parent)

	def parseArguments(tactic: String, s: String) {
		val args = ArgumentParser.stringToArguments(s)
		model.updateTacticArguments(tactic, args)
	}

	def getArgumentsOfTactic(tactic: String): String ={
		model.lookForTactic(tactic) match {
			case Some(t:HasArguments) =>
				var array = Array[Array[String]]()
				t.arg.foreach{ a => 
					array = array :+ a.arg
				}
				return ArgumentParser.argumentsToString(array)
			case None => return ""
		}
	}

	def getAtomicTacticValue(tactic: String): String = model.getAtomicTacticValue(tactic)
	def setAtomicTacticValue(tactic: String, value: String) = model.setAtomicTacticValue(tactic, value)

	def addAtomicTactic(name: String): String = {
		val args = model.createAtomicTactic(name)
		return name+"("+ArgumentParser.argumentsToString(args)+")"
	}
}