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
import scala.swing.event._
import scala.swing.event.Key.Modifiers
import scala.swing.event.Key.Modifier
import scala.math._

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
	private var graph = graphPanel.graphDoc.graph
	private val theory = graphPanel.theory
	private var view = graphPanel.graphView
	private var document = graphPanel.graphDoc

	/** variables used when we are moving an edge */
	private var movingEdge: Boolean = false
	private var movingEdgeSource: Boolean = false
	private var movedEdge: EName = new EName("")

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
	  * Method to get the name of the document
	  * @return : the name of the document
	  */
	def getTitle = graphPanel.graphDoc.titleDescription

	/**
	  * Private method to change the graph
	  * @param : gr, the new graph
	  */
	private def changeGraph(gr: Graph){
		graphPanel.graphDoc.graph = gr
		graph = graphPanel.graphDoc.graph
	}

	/**
	  * Private method to add a vertex to the graph.
	  * @param : v, the name of the vertex
	  * @param : d, the data of the vertex
	  */
	private def addVertex(v: VName, d: VData) {
		changeGraph(graph.addVertex(v, d))
		document.undoStack.register("Add Vertex") { deleteVertex(v) }
	}

	/**
	  * Private method to delete a vertex
	  * @param : v, the name of the vertex
	  */
	private def deleteVertex(v: VName) {
		document.undoStack.start("Delete Vertex")
		graph.adjacentEdges(v).foreach {deleteEdge}
		if(graph.vdata.contains(v)){
			val d = graph.vdata(v)
			view.invalidateVertex(v)
			val selected = if(view.selectedVerts.contains(v)){
				view.selectedVerts -= v; true
			} else false
			changeGraph(graph.deleteVertex(v))
			document.undoStack += {
				addVertex(v, d)
				if(selected) view.selectedVerts += v
			}
			document.undoStack.commit()
		}
		else {
			document.undoStack.cancel()
		}
	}

	/**
	  * Private method to add a boundary to the graph.
	  * @param : x, the x coordinate of the mouse
	  * @param : y, the y coordinate of the mouse
	  * @return : the name of the new boundary as a string
	  */
	private def addBoundary(x: Double, y: Double) : VName = {
		val coord = view.trans fromScreen (x, y)
		val vertexData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
		val vertexName = graph.verts.freshWithSuggestion(VName("b0"))
		changeGraph(graph.addVertex(vertexName, vertexData.withCoord(coord)))
		return(vertexName)
	}

	/**
	  * Private method to add an edge between two element of the graph.
	  * @param : e, the source element
	  * @param : d, the target element
	  * @param : vs, the target element
	  */
	private def addEdge(e: EName, d: EData, vs: (VName, VName)) {
		changeGraph(graph.addEdge(e, d, vs))
		graph.edgesBetween(vs._1, vs._2).foreach { view.invalidateEdge }
		document.undoStack.register("Add Edge") {deleteEdge(e)}
	}

	/**
	  * Private Method to delete edges
	  * If the edge has a boundary source or target, we delete it, if there is no egde coming from or to this boundary
	  * @param : e, the name of the edge
	  */
	private def deleteEdge(e: EName) {
		val d = graph.edata(e)
		val vs = (graph.source(e), graph.target(e))
		val src = vs._1
		val tgt = vs._2
		val srcData = graph.vdata(vs._1)
		val tgtData = graph.vdata(vs._2)
		val delSource = (srcData.isBoundary && (graph.adjacentEdges(src).size == 1))
		val delTarget = (tgtData.isBoundary && (graph.adjacentEdges(tgt).size == 1))
		val srcSelected = if(view.selectedVerts.contains(src)) {
			view.selectedVerts -= src; true
		} else false
		val tgtSelected = if(view.selectedVerts.contains(tgt)) {
			view.selectedVerts -= tgt; true
		} else false
		val selected = if (view.selectedEdges.contains(e)) {
			view.selectedEdges -= e; true
		} else false
		graph.edgesBetween(vs._1, vs._2).foreach { view.invalidateEdge }
		changeGraph(graph.deleteEdge(e))
		if(delSource){
			view.invalidateVertex(src)
			changeGraph(graph.deleteVertex(src))
		}
		if(delTarget && !(src == tgt)){
			view.invalidateVertex(tgt)
			changeGraph(graph.deleteVertex(tgt))
		}
		document.undoStack.register("Delete Edge") {
			if(delSource){
				changeGraph(graph.addVertex(src, srcData))
				if (srcSelected) view.selectedVerts += src
			}
			if(delTarget && !(src == tgt)){
				changeGraph(graph.addVertex(tgt, tgtData))
				if (tgtSelected) view.selectedVerts += tgt
			}
			addEdge(e, d, vs)
			if (selected) view.selectedEdges += e
		}
	}

	/**
	  * Method to create a new document
	  */
	def newDoc {
		if(document.promptUnsaved()) document.clear()
		document = graphPanel.graphDoc
		graph = graphPanel.graphDoc.graph
		view = graphPanel.graphView
		publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to open a document
	  */
	def openDoc {
		document.showOpenDialog()
		document = graphPanel.graphDoc
		graph = graphPanel.graphDoc.graph
		view = graphPanel.graphView
		publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to save a document
	  */
	def saveDoc {
		document.file match {
			case Some(_) => document.save()
			case None => document.showSaveAsDialog()
		}
		document = graphPanel.graphDoc
		graph = graphPanel.graphDoc.graph
		view = graphPanel.graphView
		publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to save a document as a new file
	  */
	def saveAsDoc {
		document.showSaveAsDialog()
		document = graphPanel.graphDoc
		graph = graphPanel.graphDoc.graph
		view = graphPanel.graphView
		publish(DocumentTitleEventAPI(document.titleDescription))
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
	  * Private method to replace the graph with another, used by layoutGraph method
	  * @param : gr, the future graph
	  * @param : desc, the description of the action done
	  */
	private def replaceGraph(gr: Graph, desc: String){
		val oldGraph = graph
		changeGraph(gr)
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

	/**
	  * Method to select an element on a graph view
	  * @param : pt, the point where the vertex is selected, if no vertex is found we start a selection box
	  * @param : modifiers, any modifier key to our selection (e.g. Shift key for multiple selection)
	  * @param : changeMouseStateCallback, a callback function to update the mouse state
	  */
	def selectElement(pt : java.awt.Point, modifiers: Modifiers, changeMouseStateCallback: (String, Any) => Unit) {
		val vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		val mouseDownOnSelectedVert = vertexHit.exists(view.selectedVerts.contains)
		if (!mouseDownOnSelectedVert && (modifiers & Modifier.Shift) != Modifier.Shift) {
			view.selectedVerts = Set()
			view.selectedEdges = Set()
		}
		vertexHit match {
			case Some(v) =>
				view.selectedVerts += v
				changeMouseStateCallback("dragVertex", pt)
				view.repaint()
			case _ =>
				val edgeHit = view.edgeDisplay find { _._2.pointHit(pt) } map { _._1 }
				edgeHit match {
					case Some(e) =>
						view.selectedEdges += e
						val ptCoord = view.trans fromScreen (pt.getX, pt.getY)
						val srcCoord = (graph.vdata(graph.source(e))).coord
						val tgtCoord = (graph.vdata(graph.target(e))).coord
						val dSrc = hypot((srcCoord._1-ptCoord._1), (srcCoord._2-ptCoord._2))
						val dTgt = hypot((ptCoord._1-tgtCoord._1), (ptCoord._2-tgtCoord._2))
						if(view.selectedEdges.size == 1) {
							if(dSrc<=0.5){
								movingEdge = true
								movingEdgeSource = true
								movedEdge = e
								changeMouseStateCallback("dragEdge", graph.target(e).s)
							}
							else if(dTgt<=0.5){
								movingEdge = true
								movedEdge = e
								changeMouseStateCallback("dragEdge", graph.source(e).s)
							}
						}
						view.repaint()
					case None =>
						changeMouseStateCallback("selectionBox", pt)
						view.repaint()
				}
		}
	}

	/**
	  * Private method to change vertex coordinates
	  * @param : vs, set of vertices
	  * @param : p1, source point
	  * @param : p2, target point
	  */
	private def shiftVertsNoRegister(vs: TraversableOnce[VName], p1: Point, p2: Point) {
		val (dx,dy) = (view.trans scaleFromScreen (p2.getX - p1.getX), view.trans scaleFromScreen (p2.getY - p1.getY))
		changeGraph(vs.foldLeft(graph) { (g,v) =>
			view.invalidateVertex(v)
			graph.adjacentEdges(v).foreach { view.invalidateEdge }
			g.updateVData(v) { d => d.withCoord (d.coord._1 + dx, d.coord._2 - dy) }
		})
	}

	/**
	  * Private method to change vertecoordinates and register it to undo stack
	  * @param : vs, set of vertices
	  * @param : p1, source point
	  * @param : p2, target point
	  */
	private def shiftVerts(vs: TraversableOnce[VName], p1: Point, p2: Point) {
		shiftVertsNoRegister(vs, p1, p2)
		document.undoStack.register("Move Vertices") { shiftVerts(vs, p2, p1) }
	}

	/**
	  * Method to drag one or more selected vertices
	  * @param : pt, target point
	  * @param : prev, origin point
	  */
	def dragVertex(pt: java.awt.Point, prev: java.awt.Point) {
		shiftVertsNoRegister(view.selectedVerts, prev, pt)
		view.repaint()
	}

	/**
	  * Method to add the move of vertices in the undo stack
	  * @param : start, the origin point
	  * @param : end, the target point 
	  */
	def moveVertex(start: java.awt.Point, end: java.awt.Point) {
		val verts = view.selectedVerts
		view.resizeViewToFit()
		document.undoStack.register("Move Vertices") {shiftVerts(verts, end, start)}
	}

	/**
	  * Method to add a selection box to the view
	  * @param : box, the actual box, default value is null
	  */
	def viewSelectBox(box: SelectionBox = null) {
		if(box == null) { 
			view.selectionBox = None
		}
		else {
			view.selectionBox = Some(box.rect)
		}
		view.repaint()
	}

	/**
	  * Method for final computation of selection box
	  * @param : update, boolean being true if the selection has been updated
	  * @param : pt, final location of the mouse
	  * @param : rect, selection box
	  */
	def viewSelectBoxFinal(update: Boolean, pt: java.awt.Point, rect: java.awt.geom.Rectangle2D.Double) {
		if(update){
			view.vertexDisplay filter (_._2.rectHit(rect)) foreach { view.selectedVerts += _._1 }
		}
		else {
			var selectionUpdated = false
			view.vertexDisplay find (_._2.pointHit(pt)) map { x => selectionUpdated = true; view.selectedVerts += x._1 }
			if(!selectionUpdated){
				view.edgeDisplay find (_._2.pointHit(pt)) map { x => selectionUpdated = true; view.selectedEdges += x._1 }
			}
		}
	}

	/**
	  * Method to start adding an edge
	  * @param : pt, point where to look for a source vertex, if none we add a boundary
	  * @param : changeMouseStateCallback, a callback function to update the mouse state
	  */
	def startAddEdge(pt: java.awt.Point, changeMouseStateCallback: (String, String) => Unit) {
		var vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		if(vertexHit == None){
			val coord = view.trans fromScreen (pt.getX, pt.getY)
			val vertexData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
			val vertexName = graph.verts.freshWithSuggestion(VName("b0"))
			changeGraph(graph.addVertex(vertexName, vertexData.withCoord(coord)))
			vertexHit = Some(vertexName)
		}
		vertexHit map { startV =>
			changeMouseStateCallback("dragEdge", startV.s)
			view.edgeOverlay = Some(EdgeOverlay(pt, src = startV, tgt = Some(startV)))
			view.repaint()
		}
	}

	/**
	  * Method to drag an edge on the view
	  * @param : startV, the source vertex
	  * @param : pt, the current location of the mouse
	  */
	def dragEdge(startV: String, pt: java.awt.Point){
		val vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		view.edgeOverlay = Some(EdgeOverlay(pt, startV, vertexHit))
		view.repaint()
	}

	/**
	  * Method to end adding / moving an edge to the view
	  * @param : startV, the source vertex (can be the target in case of moving)
	  * @param : pt, point where to look for the target (or source) vertex, if none we add a boundary
	  */
	def endAddEdge(startV: String, pt: java.awt.Point, changeMouseStateCallback: (String) => Unit){
		var vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		if(vertexHit == None){
			val coord = view.trans fromScreen (pt.getX, pt.getY)
			val vertexData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
			val vertexName = graph.verts.freshWithSuggestion(VName("b0"))
			changeGraph(graph.addVertex(vertexName, vertexData.withCoord(coord)))
			vertexHit = Some(vertexName)
		}
		vertexHit map { endV =>
			if(movingEdge){
				val data = graph.edata(movedEdge)
				if(movingEdgeSource){
					addEdge(graph.edges.fresh, data, (endV, VName(startV)))
					movingEdgeSource = false
				}
				else {
					addEdge(graph.edges.fresh, data, (VName(startV), endV))
				}
				deleteEdge(movedEdge)
				movingEdge = false
				changeMouseStateCallback("select")
			}
			else {
				val defaultData = DirEdge.fromJson(theory.defaultEdgeData, theory)
				addEdge(graph.edges.fresh, defaultData, (VName(startV), endV))
				changeMouseStateCallback("addEdge")
			}
		}
		view.edgeOverlay = None
		view.repaint()
	}

	/**
	  * Method that add a vertex (strategy type) on user request
	  * @param : pt, point where to add the vertex
	  */
	def userAddVertex(pt: java.awt.Point){
		val coord = view.trans fromScreen (pt.getX, pt.getY)
		val vertexData = NodeV(data = theory.vertexTypes("RT").defaultData, theory = theory).withCoord(coord)
		val vertexName = graph.verts.freshWithSuggestion(VName("v0"))
		addVertex(vertexName, vertexData.withCoord(coord))
	}

	/**
	  * Private method to update the value of an edge (goal type)
	  * @param : e, the name of the edge
	  * @param : str, the new value
	  */
	private def setEdgeValue(e: EName, str: String) {
		val data = graph.edata(e)
		val oldVal = data.label
		changeGraph(graph.updateEData(e) { _ => data.withValue(str) })
		graph.edgesBetween(graph.source(e), graph.target(e)).foreach { view.invalidateEdge }
		document.undoStack.register("Set Edge Data") { setEdgeValue(e, oldVal) }
	}

	/**
	  * Private method to update the value of a vertex (strategy)
	  * @param : v, the name of the vertex
	  * @param : str, the new value
	  */
	private def setVertexValue(v: VName, str: String) {
		graph.vdata(v) match {
			case data: NodeV =>
				val oldVal = data.label
				changeGraph(graph.updateVData(v) { _ => data.withValue(str) })
				view.invalidateVertex(v)
				graph.adjacentEdges(v).foreach { view.invalidateEdge }
				document.undoStack.register("Set Vertex Data") { setVertexValue(v, oldVal) }
			case _ => // do nothing
		}
	}

	/**
	  * Method to edit an element value (goal type for edge, strategy for vertex)
	  * @param : pt, point where to find element to edit
	  */
	def editGraphElement(pt: java.awt.Point){
		val vertexHit = view.vertexDisplay find { case (v, disp) =>
			disp.pointHit(pt) && !graph.vdata(v).isWireVertex
		} map { _._1 }

		vertexHit.map{ v => (v, graph.vdata(v)) } match {
			case Some((v, data: NodeV)) =>
				Dialog.showInput(
					title = "Set RTechn",
					message = "RTechn : ",
					initial = data.label).map { newVal => setVertexValue(v, newVal) }
			case _ =>
				val edgeHit = view.edgeDisplay find { _._2.pointHit(pt) } map { _._1 }
				edgeHit.map { e =>
					val data = graph.edata(e)
					Dialog.showInput(
						title = "Set Goal Type",
						message = "Goal Type: ",
						initial = data.label).map { newVal => setEdgeValue(e, newVal) }
					view.repaint()
				}
		}
	}

	/** listener to document status */
	listenTo(document)
	reactions += { case DocumentChanged(_) | DocumentSaved(_) =>
		publish(DocumentTitleEventAPI(document.titleDescription))
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

	/** listener to view mouse clicks and moves */
	listenTo(view.mouse.clicks, view.mouse.moves)
	reactions += {
		case MousePressed(_, pt, modifiers, clicks, _) =>
			view.requestFocus()
			publish(GraphMousePressedEvent(pt, modifiers, clicks))
		case MouseDragged(_, pt, _) =>
			publish(GraphMouseDraggedEvent(pt))
		case MouseReleased(_, pt, modifiers, _, _) =>
			publish(GraphMouseReleasedEvent(pt, modifiers))
	}

	/** listener to view keys events */
	listenTo(view.keys)
	reactions += {
		case KeyPressed (_, (Key.Delete | Key.BackSpace), _, _) =>
			if(!view.selectedVerts.isEmpty || !view.selectedEdges.isEmpty) {
				document.undoStack.start("Delete Vertices / Edges")
				view.selectedVerts.foreach { deleteVertex }
				view.selectedEdges.foreach { deleteEdge }
				document.undoStack.commit()
				view.repaint()
			}
		case KeyPressed(_, Key.Minus, _, _)  => view.zoom *= 0.6
		case KeyPressed(_, Key.Equals, _, _) => view.zoom *= 1.6
	}
}