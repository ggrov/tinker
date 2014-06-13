package tinkerGUI.controllers

import quanto._
import quanto.util.json._
import quanto.data._
import quanto.data.Names._
import quanto.gui._
import quanto.gui.graphview._
import quanto.layout._
import quanto.layout.constraint._
import scala.swing._

/*
*
* API file for the library based on quantomatic
*
*/

object QuantoLibAPI extends Publisher{
	val graphPanel = new BorderPanel{
		println("loading theory " + Theory.getClass.getResource("strategy_graph.qtheory"))
		val theoryFile = new Json.Input(Theory.getClass.getResourceAsStream("strategy_graph.qtheory"))
		val theory = Theory.fromJson(Json.parse(theoryFile))
		val graphDoc = new GraphDocument(this, theory)
		val graphView = new GraphView(theory, graphDoc)
		val graphScrollPane = new ScrollPane(graphView)
		add(graphScrollPane, BorderPanel.Position.Center)
	}
	var graph = graphPanel.graphDoc.graph
	val theory = graphPanel.theory
	val view = graphPanel.graphView
	val document = graphPanel.graphDoc

	/** one undo stack for the view */
	view.listenTo(document.undoStack)
	view.reactions += {
		case UndoPerformed(_) =>
			view.resizeViewToFit()
			view.repaint()
		case RedoPerformed(_) =>
			view.resizeViewToFit()
			view.repaint()
	}

	/**
	  * Method to get the graph panel
	  * @return : a panel component containing the graph
	  */
	def getGraph = graphPanel

	/**
	  * Method to add a vertex to the graph.
	  * @param : x, the x coordinate of the mouse
	  * @param : y, the y coordinate of the mouse
	  * @param : typ the type of hte vertex : "GN" or "RT"
	  * @return : the name of the new vertex as a string
	  */
	def addVertex(x: Double, y: Double, typ: String) : String = {
		val coord = view.trans fromScreen (x, y)
		val vertexData = NodeV(data = theory.vertexTypes(typ).defaultData, theory = theory).withCoord(coord)
		val vertexName = graph.verts.freshWithSuggestion(VName("v0"))
		graphPanel.graphDoc.graph = graph.addVertex(vertexName, vertexData.withCoord(coord))
		graph = graphPanel.graphDoc.graph
		return(vertexName.s)
	}

	/**
	  * Method to add a boundary to the graph.
	  * @param : x, the x coordinate of the mouse
	  * @param : y, the y coordinate of the mouse
	  * @return : the name of the new boundary as a string
	  */
	def addBoundary(x: Double, y: Double) : String = {
		val coord = view.trans fromScreen (x, y)
		val vertexData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
		val vertexName = graph.verts.freshWithSuggestion(VName("b0"))
		graphPanel.graphDoc.graph = graph.addVertex(vertexName, vertexData.withCoord(coord))
		graph = graphPanel.graphDoc.graph
		return(vertexName.s)
	}

	/**
	  * Method to add an edge between two element of the graph.
	  * @param : start, the source element
	  * @param : end, the target element
	  * @return : 
	  */
	def addEdge(start: String, end: String) {
		val startV = VName(start)
		val endV = VName(end)
		val defaultData = DirEdge.fromJson(theory.defaultEdgeData, theory)
		graphPanel.graphDoc.graph = graph.addEdge(graph.edges.fresh, defaultData, (startV, endV))
		graph = graphPanel.graphDoc.graph
		graph.edgesBetween(startV, endV).foreach { view.invalidateEdge }
	}

	/**
	  * Method to add an edge targeting one element of the graph.
	  * @param : startCoord, the coordinates where the edge starts, a boundary will be created as a source element
	  * @param : end, the target element
	  * @return : 
	  */
	def addEdge(startCoord: (Double, Double), end: String) {
		val start = addBoundary(startCoord._1, startCoord._2)
		addEdge(start, end)
	}

	/**
	  * Method to add an edge coming from one element of the graph.
	  * @param : start, the source element
	  * @param : endCoord, the coordinates where the edge ends, a boundary will be created as a target element
	  * @return : 
	  */
	def addEdge(start: String, endCoord: (Double, Double)) {
		val end = addBoundary(endCoord._1, endCoord._2)
		addEdge(start, end)
	}

	/**
	  * Method to add an edge in the graph.
	  * @param : startCoord, the coordinates where the edge starts, a boundary will be created as a source element
	  * @param : endCoord, the coordinates where the edge ends, a boundary will be created as a target element
	  * @return : 
	  */
	def addEdge(startCoord: (Double, Double), endCoord: (Double, Double)) {
		val start = addBoundary(startCoord._1, startCoord._2)
		val end = addBoundary(endCoord._1, endCoord._2)
		addEdge(start, end)
	}

	/**
	  * Method to create a new document
	  */
	def newDoc {
		if(document.promptUnsaved()) document.clear()
	}

	/**
	  * Method to open a document
	  */
	def openDoc {
		document.showOpenDialog()
	}

	/**
	  * Method to save a document
	  */
	def saveDoc {
		document.file match {
			case Some(_) => document.save()
			case None => document.showSaveAsDialog()
		}
	}

	/**
	  * Method to save a document as a new file
	  */
	def saveAsDoc {
		document.showSaveAsDialog()
	}

	/**
	  * Method to safely close a document
	  */
	def closeDoc : Boolean = {
		return document.promptUnsaved()
	}

	/**
	  * Method to undo an action in the document action stack
	  */
	def undo {
		document.undoStack.undo()
	}

	/**
	  * Method to redo an action in the document action stack
	  */
	def redo {
		document.undoStack.redo()
	}

	/**
	  * Private method to replace one graph with another
	  */
	private def replaceGraph(gr: Graph, desc: String){
		val oldGraph = graph
		graphPanel.graphDoc.graph = gr
		graph = graphPanel.graphDoc.graph
		document.publish(GraphReplaced(document, clearSelection = false))
		document.undoStack.register(desc) { replaceGraph(oldGraph, desc) }
	}
	/**
	  * Method to layout the graph
	  */
	def layoutGraph {
		val lo = new ForceLayout with IRanking with VerticalBoundary with Clusters
		replaceGraph(lo.layout(graph), "Layout Graph")
		view.resizeViewToFit()
		view.repaint()
	}

	/** listener to document status */
	listenTo(document)
	reactions += { case DocumentChanged(_) | DocumentSaved(_) =>
		publish(DocumentStatusEventAPI(document.unsavedChanges))
	}

	/** listener to document action stack */
	listenTo(document.undoStack)
	reactions += { case _: UndoEvent =>
		val canUndo = document.undoStack.canUndo
		val canRedo = document.undoStack.canRedo
		val undoActionName = document.undoStack.undoActionName.getOrElse("")
		val redoActionName = document.undoStack.redoActionName.getOrElse("")
		publish(DocumentActionStackEventAPI(canUndo, canRedo, undoActionName, redoActionName))
	}

	def addBBox {

	}
	def removeVertex {

	}
	def removeBoundary {

	}
	def removeEdge {

	}
	def removeBBox {

	}	
}