package tinkerGUI.controllers

import tinkerGUI.controllers.events.GraphTacticListEvent
import tinkerGUI.model.exceptions.{SubgraphNotFoundException, GraphTacticNotFoundException, AtomicTacticNotFoundException}

import scala.swing._
import tinkerGUI.model.PSGraph
import quanto.util.json._
import tinkerGUI.utils.{TinkerDialog, ArgumentParser}
import scala.collection.mutable.ArrayBuffer

object Service extends Publisher {
	// other services
	//val c = CommunicationService // the communication needs to be "instantiates" to actually listen for connections
	// Models
	//val hierarchyModel = new HierarchyModel()
	/** Psgrah model. */
	val model = new PSGraph()

	// controllers
	/** Edit controller. */
	val editCtrl = new EditController(model)
	val evalCtrl = new EvalController(model)
	val documentCtrl = new DocumentController(model)
	val libraryTreeCtrl = new TinkerLibraryController(model)
	val hierarchyCtrl = new HierarchyController(model)
	val inspectorCtrl = new InspectorController(model)
	val graphNavCtrl = new GraphNavigationController(model)
	// TODO get rid of unecessary controllers

	// getter-setter of the main frame
	private var mainFrame: Component = new BorderPanel()
	def setMainFrame(c: Component) { mainFrame = c }
	def getMainFrame : Component = mainFrame

	private var topFrame: MainFrame = null
	def setTopFrame(c: MainFrame) { topFrame = c }
	def getTopFrame : MainFrame = topFrame

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
	/** Method to get the branch type of a specific graph tactic. See [[tinkerGUI.model.PSGraph.getGTBranchType]].*/
	def getBranchTypeGT(tactic: String) = model.getGTBranchType(tactic)
	/** Method to get the children of a graph tactic or the main graph children. See [[tinkerGUI.model.GraphTactic.children]] and [[tinkerGUI.model.PSGraph.childrenMain]].*/
	def getGTChildren(tactic:String) = if(tactic=="main") model.childrenMain else model.getChildrenGT(tactic)



	def saveGraphSpecificTactic(tactic: String, graph: Json, index: Int) = {
		//documentCtrl.registerChanges()
		model.saveGraph(tactic, graph, index)
	}

	def setGoalTypes(s: String){
		//documentCtrl.registerChanges()
		model.goalTypes = s
	}

  def showTinkerGUI (b : Boolean) {
    getTopFrame.visible_=(b)
  }





  def debugPrintJson(){
		model.updateJsonPSGraph()
  	println(model.jsonPSGraph)
  }
}