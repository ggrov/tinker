package tinkerGUI.controllers

import java.io.{IOException, FileNotFoundException, File}

import tinkerGUI.controllers.events.GraphTacticListEvent
import tinkerGUI.model.exceptions.{SubgraphNotFoundException, GraphTacticNotFoundException, AtomicTacticNotFoundException}

import scala.swing._
import tinkerGUI.model.PSGraph
import quanto.util.json._
import tinkerGUI.utils.{UnicodeParser, FixedStack, TinkerDialog, ArgumentParser}
import scala.collection.mutable.ArrayBuffer

object Service extends Publisher {
	// other services
	//val c = CommunicationService // the communication needs to be "instantiates" to actually listen for connections
	// Models
	//val hierarchyModel = new HierarchyModel()
	val libraryTreeCtrl = new TinkerLibraryController()

	/** Psgrah model. */
	var model = new PSGraph("scratch")
	// controllers
	/** Edit controller. */
	val editCtrl = new EditController(model)
	val evalCtrl = new EvalController(model)
	val documentCtrl = new DocumentController(model)
	val hierarchyCtrl = new HierarchyController(model)
	val inspectorCtrl = new InspectorController(model)
	val graphNavCtrl = new GraphNavigationController(model)

	def createModel(name:String) = {
		model.reset(name)
	}

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
	}
	/** Method to get the current graph index. See [[tinkerGUI.model.PSGraph.currentIndex]].*/
	def getCurrentIndex = model.currentIndex
	/** Method to get the current graph tactic size. See [[tinkerGUI.model.PSGraph.currentTactic]]. */
	def getCurrentSize = model.currentTactic.graphs.size
	/** Method to get the current graph name (ee [[tinkerGUI.model.PSGraph.currentTactic]]), or "main" if current graph is main (see [[tinkerGUI.model.PSGraph.isMain]]).*/
	def getCurrent = model.currentTactic.name
	/** Method to get the goal types of the psgraph. See [[tinkerGUI.model.PSGraph.goalTypes]].*/
	def getGoalTypes = model.goalTypes
	/** Method to get the core id of an atomic tactic. See [[tinkerGUI.model.PSGraph.getTacticValue]].*/
	def getATCoreId(name:String) = model.getTacticValue(name)
	/** Method to get the branch type of a specific graph tactic. See [[tinkerGUI.model.PSGraph.getGTBranchType]].*/
	def getBranchTypeGT(tactic: String) = model.getGTBranchType(tactic)

	def initApp() {
		try {
			val jsonConfig = Json.parse(new File(".tinkerConfig"))
			jsonConfig/"recent" match {
				case j:JsonObject =>
					j.foreach{case(k,v) => documentCtrl.recentProofs.push(k,v.stringValue)}
				case _ =>
			}
//			DocumentService.load(new File((Json.parse(new File(".tinkerConfig"))/"file").stringValue)) match {
//				case Some(j:JsonObject) =>
//					documentCtrl.openJson(j)
//				case _ =>
//			}
		} catch {
			case e: Exception =>
		}

		try {
			UnicodeParser.loadMap(new File("unicodeConfig"))
		} catch {
			case e: Exception =>
				TinkerDialog.openErrorDialog("Error while opening unicodeConfig<br>"+e.getMessage+"<br>Default settings will be used.")
		}
	}

	def closeApp() {
		if(documentCtrl.closeDoc()){
			val recent = documentCtrl.recentProofs.values.reverse.foldLeft(JsonObject()){case(j,p) => j + (p._1 -> JsonString(p._2))}
			JsonObject("recent"->recent).writeTo(new File(".tinkerConfig"))
//			DocumentService.file match {
//				case Some(f:File) => JsonObject("file"->JsonString(f.toString)).writeTo(new File(".tinkerConfig"))
//				case None =>
//			}
			sys.exit(0)
		}
	}


	def saveGraphSpecificTactic(tactic: String, graph: Json, index: Int) = {
		//documentCtrl.registerChanges()
		model.saveGraph(tactic, graph, index)
	}

  def showTinkerGUI (b : Boolean) {
    getTopFrame.visible_=(b)
  }





  def debugPrintJson(){
  	println(model.updateJsonPSGraph())
  }
}