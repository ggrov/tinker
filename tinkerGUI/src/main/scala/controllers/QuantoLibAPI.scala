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
import tinkerGUI.utils.ArgumentParser
import tinkerGUI.utils.SelectionBox


/**
  *
  * API file for the library based on quantomatic
  *
  */

object QuantoLibAPI extends Publisher{

	/** the main object, the graph */
	private var graphPanel = new BorderPanel{
		println("loading theory " + Theory.getClass.getResource("strategy_graph_modified.qtheory"))
		val theoryFile = new Json.Input(Theory.getClass.getResourceAsStream("strategy_graph_modified.qtheory"))
		val theory = Theory.fromJson(Json.parse(theoryFile))
		val graphDoc = new GraphDocument(this, theory)
		val graphView = new GraphView(theory, graphDoc)
		val graphScrollPane = new ScrollPane(graphView)
		add(graphScrollPane, BorderPanel.Position.Center)
	}

	/** shortcuts for variables of graph */
	private var graph = graphPanel.graphDoc.graph
	private var theory = graphPanel.theory
	private var view = graphPanel.graphView
	private var document = graphPanel.graphDoc

	/** variables used when we are moving an edge */
	private var movingEdge: Boolean = false
	private var movingEdgeSource: Boolean = false
	private var movedEdge: EName = new EName("")

	/**
	  * Method to get the graph panel
	  * @return a panel component containing the graph
	  */
	def getGraph = graphPanel

	/** Method to get a whole new graph
	  */
	def newGraph() {
		document.clear()
		localUpdate()
	}

	/**
	  * Method to load a graph from a Json object
	  * @param json, the json object
	  */
	def loadFromJson(json: JsonObject) {
		document.clear()
		// val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		// wrap Graph.fromJson .... with layout.layout(...) in next line to activate layout
		document.graph = Graph.fromJson(json, theory)
		document.publish(GraphReplaced(document, clearSelection = true))
		localUpdate()
	}

	/**
	  * Method to get the name of the document
	  * @return the name of the document
	  */
	def getTitle = graphPanel.graphDoc.titleDescription
		
	/**
	  * private value representing the preview of a graph from a tactic
	  */
	private val subgraphPreview = new BorderPanel {
		preferredSize = new Dimension (250,300)
		val subgraphPreviewDoc = new GraphDocument(this, theory)
		val subgraphPreviewView = new GraphView(theory, subgraphPreviewDoc)
		subgraphPreviewView.drawGrid = false
		val subgraphPreviewScrollPane = new ScrollPane(subgraphPreviewView)
		add(subgraphPreviewScrollPane, BorderPanel.Position.Center)
	}

	/**
	  * Method to get the subgraph preview
	  * @return the subgraph preview
	  */
	def getSubgraphPreview = subgraphPreview

	/**
	  * Method to update the subgraphPreview with a json
	  * @param json, the json representation of the graph
	  */
	def updateSubgraphPreviewFromJson(json: JsonObject) {
		subgraphPreview.subgraphPreviewDoc.clear()
		// val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		// wrap Graph.fromJson .... with layout.layout(...) in next line to activate layout
		subgraphPreview.subgraphPreviewDoc.graph = Graph.fromJson(json, theory)
		subgraphPreview.subgraphPreviewDoc.publish(GraphReplaced(subgraphPreview.subgraphPreviewDoc, clearSelection = true))
	}

	/**
	  * private value representing the preview of a graph from the tinker library
	  */
	private val libraryPreview = new BorderPanel {
		val libraryPreviewDoc = new GraphDocument(this, theory)
		val libraryPreviewView = new GraphView(theory, libraryPreviewDoc)
		libraryPreviewView.drawGrid = false
		val libraryPreviewScrollPane = new ScrollPane(libraryPreviewView)
		add(libraryPreviewScrollPane, BorderPanel.Position.Center)
	}

	/**
	  * Method to get the library preview
	  * @return the library preview
	  */
	def getLibraryPreview = libraryPreview

	/**
	  * Method to update the libraryPreview with a json
	  * @param json, the json representation of the graph
	  */
	def updateLibraryPreviewFromJson(json: Json) {
		libraryPreview.libraryPreviewDoc.clear()
		// val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		// wrap Graph.fromJson .... with layout.layout(...) in next line to activate layout
		libraryPreview.libraryPreviewDoc.graph = Graph.fromJson(json, theory)
		libraryPreview.libraryPreviewDoc.publish(GraphReplaced(libraryPreview.libraryPreviewDoc, clearSelection = true))
	}

	/**
	  * Private method to update the local variables
	  */
	private def localUpdate() {
		document = graphPanel.graphDoc
		graph = graphPanel.graphDoc.graph
		view = graphPanel.graphView
		theory = graphPanel.theory
	}

	/**
	  * Private method to change the graph
	  * @param gr, the new graph
	  */
	private def changeGraph(gr: Graph){
		graphPanel.graphDoc.graph = gr
		graph = graphPanel.graphDoc.graph
		publish(GraphEventAPI(Graph.toJson(graph, theory)))
	}

	/**
	  * Private method to add a vertex to the graph.
	  * @param v, the name of the vertex
	  * @param d, the data of the vertex
	  */
	private def addVertex(v: VName, d: VData) {
		changeGraph(graph.addVertex(v, d))
		document.undoStack.register("Add Vertex") { deleteVertex(v) }
	}

	/**
	  * Private method to delete a vertex
	  * @param v, the name of the vertex
	  */
	private def deleteVertex(v: VName) {
		val d = graph.vdata(v)
		d match { 
			case data:NodeV if(data.typ == "G_Break") =>
				removeBreakpoint(v.s)
			case _ =>
				document.undoStack.start("Delete Vertex")
				graph.adjacentEdges(v).foreach {deleteEdge}
				if(graph.vdata.contains(v)){
					// Uncomment the next line to delete the node in the model too
					// d match { case n: NodeV => if (n.typ == "RT_NST") Service.deleteTactic(n.label)}
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
	}

	/**
	  * Private method to add an edge between two element of the graph.
	  * @param e, the name of the edge
	  * @param d, the data of the edge
	  * @param vs, the source and target elements
	  */
	private def addEdge(e: EName, d: EData, vs: (VName, VName)) {
		changeGraph(graph.addEdge(e, d, vs))
		graph.edgesBetween(vs._1, vs._2).foreach { view.invalidateEdge }
		document.undoStack.register("Add Edge") {deleteEdge(e)}
	}

	/**
	  * Private Method to delete edges
	  * If the edge has a boundary source or target, we delete it, if there is no egde coming from or to this boundary
	  * @param e, the name of the edge
	  */
	private def deleteEdge(e: EName) {
		var edge = e
		var hadBreak = false;
		if(hasBreak(e.s)){
			hadBreak = true;
			edge = EName(removeBreakpointFromEdge(e.s))
		}
		var d = graph.edata(edge)
		val vs = (graph.source(edge), graph.target(edge))
		val src = vs._1
		val tgt = vs._2
		val srcData = graph.vdata(vs._1)
		val tgtData = graph.vdata(vs._2)
		val delSource = (srcData.isBoundary)
		val delTarget = (tgtData.isBoundary)
		val srcSelected = if(view.selectedVerts.contains(src)) {
			view.selectedVerts -= src; true
		} else false
		val tgtSelected = if(view.selectedVerts.contains(tgt)) {
			view.selectedVerts -= tgt; true
		} else false
		val selected = if (view.selectedEdges.contains(edge)) {
			view.selectedEdges -= edge; true
		} else false
		graph.edgesBetween(vs._1, vs._2).foreach { view.invalidateEdge }
		changeGraph(graph.deleteEdge(edge))
		if(delSource){
			view.invalidateVertex(src)
			deleteVertex(src)
		}
		if(delTarget && !(src == tgt)){
			view.invalidateVertex(tgt)
			deleteVertex(tgt)
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
			addEdge(edge, d, vs)
			if (selected) view.selectedEdges += edge
			if(hadBreak) addBreakpointOnEdge(edge.toString)
		}
	}

	/**
	  * Private method to move an edge.
	  * @param startV, the new source vertex
	  * @param endV, the new target vertex
	  * @param edge, the name of the edge
	  * @param moveSource, boolean to tell if we are moving the source of the edge
	  */
	private def moveEdge(startV: VName, endV: VName, edge: EName, moveSource: Boolean){
		val data = graph.edata(edge)
		val prevSrc = graph.source(edge)
		val prevTgt = graph.target(edge)
		val prevSrcData = graph.vdata(prevSrc)
		val prevTgtData = graph.vdata(prevTgt)
		val delPrevSrc = (prevSrcData.isBoundary && (graph.adjacentEdges(prevSrc).size == 1) && moveSource && prevSrc!=prevTgt)
		val delPrevTgt = (prevTgtData.isBoundary && (graph.adjacentEdges(prevTgt).size == 1) && !(moveSource) && prevSrc!=prevTgt)
		val prevSrcSelec = if(view.selectedVerts.contains(prevSrc) && delPrevSrc) {
			view.selectedVerts -= prevSrc; true
		} else false
		val prevTgtSelec = if(view.selectedVerts.contains(prevTgt) && delPrevTgt) {
			view.selectedVerts -= prevTgt; true
		} else false
		val selec = if (view.selectedEdges.contains(edge)) {
			view.selectedEdges -= edge; true
		} else false

		// we delete the previous edge
		graph.edgesBetween(prevSrc, prevTgt).foreach { view.invalidateEdge }
		changeGraph(graph.deleteEdge(edge))
		if(delPrevSrc){
			view.invalidateVertex(prevSrc)
			changeGraph(graph.deleteVertex(prevSrc))
		}
		if(delPrevTgt && !(prevSrc == prevTgt)){
			view.invalidateVertex(prevTgt)
			changeGraph(graph.deleteVertex(prevTgt))
		}

		// we create and draw the new edge
		if(moveSource){
			changeGraph(graph.addEdge(edge, data, (endV, startV)))
			graph.edgesBetween(endV, startV).foreach { view.invalidateEdge }
		}
		else {
			changeGraph(graph.addEdge(edge, data, (startV, endV)))
			graph.edgesBetween(startV, endV).foreach { view.invalidateEdge }
		}
		if(selec){
			view.selectedEdges += edge
		}

		// we build the undo stack
		document.undoStack.register("Move Edge") {
			if(delPrevSrc){
				changeGraph(graph.addVertex(prevSrc, prevSrcData))
				if (prevSrcSelec) view.selectedVerts += prevSrc
			}
			if(delPrevTgt && !(prevSrc == prevTgt)){
				changeGraph(graph.addVertex(prevTgt, prevTgtData))
				if (prevTgtSelec) view.selectedVerts += prevTgt
			}
			if(moveSource){
				moveEdge(prevTgt, prevSrc, edge, moveSource)
			}
			else {
				moveEdge(prevSrc, prevTgt, edge, moveSource)
			}
		}

		// we reset the boolean
		movingEdge = false
	}

	/**
	  * Method to create a new document
	  */
	def newDoc {
		if(document.promptUnsaved()) document.clear()
		localUpdate()
		// publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to open a document
	  */
	def openDoc {
		document.showOpenDialog()
		localUpdate()
		// publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to save a document
	  */
	def saveDoc {
		document.file match {
			case Some(_) => document.save()
			case None => document.showSaveAsDialog()
		}
		localUpdate()
		// publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to save a document as a new file
	  */
	def saveAsDoc {
		document.showSaveAsDialog()
		localUpdate()
		// publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to safely close a document
	  * @return a boolean telling if closing if safe 
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
	  * @param gr, the future graph
	  * @param desc, the description of the action done
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
	  * Method to publish an event when one or more vertex are selected
	  */
	private def publishSelectedVerts(){
		if(view.selectedVerts.size == 1 && view.selectedEdges.size == 0 && !(graph.vdata(view.selectedVerts.head).isBoundary)){
			(view.selectedVerts.head, graph.vdata(view.selectedVerts.head)) match {
				case (v: VName, data: NodeV) => publish(OneVertexSelectedEventAPI(v.s, data.typ, data.label))
			}
		}
		else if(view.selectedVerts.size > 1 && view.selectedEdges.size == 0){
			var vnames = Set[String]()
			view.selectedVerts.foreach { v =>
				if(graph.vdata(v).isBoundary) return
				else vnames = vnames + v.s
			}
			publish(ManyVertexSelectedEventAPI(vnames))
		}
	}

	/**
	  * Method to select an element on a graph view
	  * @param pt, the point where the vertex is selected, if no vertex is found we start a selection box
	  * @param modifiers, any modifier key to our selection (e.g. Shift key for multiple selection)
	  * @param changeMouseStateCallback, a callback function to update the mouse state
	  */
	def selectElement(pt : java.awt.Point, modifiers: Modifiers, changeMouseStateCallback: (String, Any) => Unit){
		publish(NothingSelectedEventAPI())
		val vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		val mouseDownOnSelectedVert = vertexHit.exists(view.selectedVerts.contains)
		if (!mouseDownOnSelectedVert && (modifiers & Modifier.Shift) != Modifier.Shift) {
			view.selectedVerts = Set()
			view.selectedEdges = Set()
		}
		vertexHit match {
			case Some(v) =>
				view.selectedVerts += v
				publishSelectedVerts()
				changeMouseStateCallback("dragVertex", pt)
				view.repaint()
			case _ =>
				val edgeHit = view.edgeDisplay find { _._2.pointHit(pt) } map { _._1 }
				edgeHit match {
					case Some(e) =>
						view.selectedEdges += e
						if(view.selectedEdges.size == 1 && view.selectedVerts.size == 0){
							graph.edata(e) match {
								case data: DirEdge => publish(OneEdgeSelectedEventAPI(e.s, data.label, graph.source(e).s, graph.target(e).s))
							}
						}
						val rec = (graph.source(e) == graph.target(e))
						val ptCoord = view.trans fromScreen (pt.getX, pt.getY)
						val srcCoord = (graph.vdata(graph.source(e))).coord
						val tgtCoord = (graph.vdata(graph.target(e))).coord
						val dSrc = hypot((srcCoord._1-ptCoord._1), (srcCoord._2-ptCoord._2))
						val dTgt = hypot((ptCoord._1-tgtCoord._1), (ptCoord._2-tgtCoord._2))
						if(view.selectedEdges.size == 1){
							if(rec && dSrc<=0.5) {
								if(ptCoord._1 > srcCoord._1){
									movingEdge = true
									movingEdgeSource = true
									movedEdge = e
									changeMouseStateCallback("dragEdge", graph.target(e).s)									
								}
								else{
									movingEdge = true
									movingEdgeSource = false
									movedEdge = e
									changeMouseStateCallback("dragEdge", graph.source(e).s)									
								}
							}
							else if(dSrc<=0.5){
								graph.vdata(graph.source(e)) match {
									case d:NodeV if(d.typ != "G_Break" && d.typ != "G") =>
										movingEdge = true
										movingEdgeSource = true
										movedEdge = e
										changeMouseStateCallback("dragEdge", graph.target(e).s)
									case d:WireV =>
										movingEdge = true
										movingEdgeSource = true
										movedEdge = e
										changeMouseStateCallback("dragEdge", graph.target(e).s)
									case _ =>
								}
							}
							else if(dTgt<=0.5){
								graph.vdata(graph.target(e)) match {
									case d:NodeV if(d.typ != "G_Break" && d.typ != "G") =>
										movingEdge = true
										movingEdgeSource = false
										movedEdge = e
										changeMouseStateCallback("dragEdge", graph.source(e).s)
									case d:WireV =>
										movingEdge = true
										movingEdgeSource = false
										movedEdge = e
										changeMouseStateCallback("dragEdge", graph.source(e).s)
									case _ =>
								}
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
	  * @param vs, set of vertices
	  * @param p1, source point
	  * @param p2, target point
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
	  * Private method to change vertex coordinates and register it to undo stack
	  * @param vs, set of vertices
	  * @param p1, source point
	  * @param p2, target point
	  */
	private def shiftVerts(vs: TraversableOnce[VName], p1: Point, p2: Point) {
		shiftVertsNoRegister(vs, p1, p2)
		document.undoStack.register("Move Vertices") { shiftVerts(vs, p2, p1) }
	}

	/**
	  * Method to drag one or more selected vertices
	  * @param pt, target point
	  * @param prev, origin point
	  */
	def dragVertex(pt: java.awt.Point, prev: java.awt.Point) {
		shiftVertsNoRegister(view.selectedVerts, prev, pt)
		view.repaint()
	}

	/**
	  * Method to add the move of vertices in the undo stack
	  * @param start, the origin point
	  * @param end, the target point 
	  */
	def moveVertex(start: java.awt.Point, end: java.awt.Point) {
		val verts = view.selectedVerts
		view.resizeViewToFit()
		document.undoStack.register("Move Vertices") {shiftVerts(verts, end, start)}
	}

	/**
	  * Method to add a selection box to the view
	  * @param box, the actual box, default value is null
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
	  * @param update, boolean being true if the selection has been updated
	  * @param pt, final location of the mouse
	  * @param rect, selection box
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
		publishSelectedVerts()
	}

	/**
	  * Method to start adding an edge
	  * @param pt, point where to look for a source vertex, if none we add a boundary
	  * @param changeMouseStateCallback, a callback function to update the mouse state
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
			graph.vdata(startV) match {
				case d:NodeV if(d.typ != "G_Break" && d.typ != "G") =>
						changeMouseStateCallback("dragEdge", startV.s)
						view.edgeOverlay = Some(EdgeOverlay(pt, src = startV, tgt = Some(startV)))
						view.repaint()
				case d:WireV =>
					if(graph.adjacentEdges(startV).size < 1){
						changeMouseStateCallback("dragEdge", startV.s)
						view.edgeOverlay = Some(EdgeOverlay(pt, src = startV, tgt = Some(startV)))
						view.repaint()
					}
				case _ => 
			}
		}
	}

	/**
	  * Method to drag an edge on the view
	  * @param startV, the source vertex
	  * @param pt, the current location of the mouse
	  */
	def dragEdge(startV: String, pt: java.awt.Point){
		val vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		vertexHit match {
			case Some(v:VName) =>
				graph.vdata(v) match {
					case d:NodeV if(d.typ != "D_Break" && d.typ != "G") =>
						view.edgeOverlay = Some(EdgeOverlay(pt, startV, vertexHit))
						view.repaint()
					case _ =>
						view.edgeOverlay = Some(EdgeOverlay(pt, startV, None))
						view.repaint()
				}
			case _ =>
				view.edgeOverlay = Some(EdgeOverlay(pt, startV, vertexHit))
				view.repaint()
		}
	}

	/**
	  * Method to end adding / moving an edge to the view
	  * @param startV, the source vertex (can be the target in case of moving)
	  * @param pt, point where to look for the target (or source) vertex, if none we add a boundary
	  * @param changeMouseStateCallback, a callback function to update the mouse state
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
			graph.vdata(endV) match {
				case d:NodeV if(d.typ != "G_Break" && d.typ != "G") =>
					if(movingEdge){
						moveEdge(VName(startV), endV, movedEdge, movingEdgeSource)
						changeMouseStateCallback("select")
					}
					else{
						val defaultData = DirEdge.fromJson(theory.defaultEdgeData, theory)
						addEdge(graph.edges.fresh, defaultData, (VName(startV), endV))
						changeMouseStateCallback("addEdge")
					}
				case d:WireV if(graph.adjacentEdges(endV).size < 1 && endV != VName(startV) && !(graph.vdata(startV).isBoundary)) =>
					if(movingEdge){
						moveEdge(VName(startV), endV, movedEdge, movingEdgeSource)
						changeMouseStateCallback("select")
					}
					else{
						val defaultData = DirEdge.fromJson(theory.defaultEdgeData, theory)
						addEdge(graph.edges.fresh, defaultData, (VName(startV), endV))
						changeMouseStateCallback("addEdge")
					}
				case _ =>
					if(!movingEdge){
						if(graph.vdata(VName(startV)).isBoundary  && endV != VName(startV)) {
							deleteVertex(VName(startV))
						}
						if(graph.vdata(endV).isBoundary) {
							deleteVertex(endV)
						}
						changeMouseStateCallback("addEdge")
					}
			}
		}
		view.edgeOverlay = None
		view.repaint()
	}

	/**
	  * Method that add a vertex (strategy type) on user request
	  * @param pt, point where to add the vertex
	  * @param typ, string representation of the type of node
	  */
	def userAddVertex(pt: java.awt.Point, typ: String){
		val coord = view.trans fromScreen (pt.getX, pt.getY)
		val vertexData = NodeV(data = theory.vertexTypes(typ).defaultData, theory = theory).withCoord(coord)
		val vertexName = graph.verts.freshWithSuggestion(VName("v0"))
		addVertex(vertexName, vertexData.withCoord(coord))
		graph.vdata(vertexName) match {
			case data: NodeV =>
				if(typ == "RT_NST") {
					changeGraph(graph.updateVData(vertexName) { _ => data.withValue(Service.createNode(data.label, true, true)) })
					view.invalidateVertex(vertexName)
					graph.adjacentEdges(vertexName).foreach { view.invalidateEdge }
				}
				else if (typ == "RT_ATM") {
					changeGraph(graph.updateVData(vertexName) { _ => data.withValue(Service.createNode(data.label, false, false)) })
					view.invalidateVertex(vertexName)
					graph.adjacentEdges(vertexName).foreach { view.invalidateEdge }
				}
		}
	}

	/**
	  * Private method to update the value of an edge (goal type)
	  * @param e, the name of the edge
	  * @param str, the new value
	  */
	def setEdgeValue(e: EName, str: String) {
		val data = graph.edata(e)
		val oldVal = data.label
		if(oldVal != str){
			changeGraph(graph.updateEData(e) { _ => data.withValue(str) })
			graph.edgesBetween(graph.source(e), graph.target(e)).foreach { view.invalidateEdge }
			graph.vdata(graph.source(e)) match {
				case d:NodeV if(d.typ == "G_Break" || d.typ == "G") =>
					setEdgeValue(graph.inEdges(graph.source(e)).head, str)
				case _ => // do nothing special
			}
			graph.vdata(graph.target(e)) match {
				case d:NodeV if(d.typ == "G_Break" || d.typ == "G") =>
					setEdgeValue(graph.outEdges(graph.target(e)).head, str)
				case _ => // do nothing special
			}
			document.undoStack.register("Set Edge Data") { setEdgeValue(e, oldVal) }
		}
	}

	/**
	  * Private method to update the value of a vertex (strategy)
	  * @param v, the name of the vertex
	  * @param str, the new value
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

	def setVertexValue(s: String, str: String) {setVertexValue(VName(s), str)}
	def setEdgeValue(s: String, str: String) {setEdgeValue(EName(s), str)}

	/**
	  * Method to edit an element value via a dialog (goal type for edge, strategy for vertex)
	  * Was used for double-click
	  * @param pt, point where to find element to edit
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

	/**
	  * Method to edit a single graph element value (selected one)
	  * @param newVal, the new value of the element
	  */
	def editSelectedElementValue(newVal: String){
		if(view.selectedVerts.size == 1 && view.selectedEdges.size == 0){
			setVertexValue((view.selectedVerts.head), newVal)
		}
		else if (view.selectedVerts.size == 0 && view.selectedEdges.size == 1){
			setEdgeValue((view.selectedEdges.head), newVal)
		}
	}

	def getSelectedElementName() : Option[String] = {
		if(view.selectedVerts.size == 1 && view.selectedEdges.size == 0) Some(view.selectedVerts.head.s)
		else if (view.selectedVerts.size == 0 && view.selectedEdges.size == 1) Some(view.selectedEdges.head.s)
		else None 
	}

	/**
	  * Method that delete an element on user request
	  * @param eltName, the name of the element
	  */
	def userDeleteElement(eltName: String){
		if (graph.vdata.contains(VName(eltName))){
			deleteVertex(VName(eltName))
		}
		else if (graph.edata.contains(EName(eltName))){
			var ename = ""
			if(hasBreak(eltName)){
				ename = removeBreakpointFromEdge(eltName)
			}
			if(ename != ""){
				deleteEdge(EName(ename))
			}
		}
	}

	/**
	  * Method that updates the source or target of an edge on user request
	  * This method firs check if the new source or target exists
	  * @param e, the edge
	  * @param src, the new source name
	  * @param tgt, the new target name
	  */
	def userUpdateEdge(e: String, s: String, t: String){
		val edge = EName(e)
		val src = VName(s)
		val tgt = VName(t)
		if (graph.vdata.contains(src) && graph.vdata.contains(tgt)) {
			if(graph.source(e) == src && graph.target(e) != tgt) {
				graph.vdata(graph.target(e)) match {
					case d:NodeV if(d.typ == "G_Break" || d.typ == "G") => // do nothing
					case _ => 
						graph.vdata(tgt) match {
							case d:NodeV if(d.typ == "G_Break" || d.typ == "G") => // do nothing
							case d:WireV if(graph.adjacentEdges(tgt).size >= 1) => // do nothing
							case _ => moveEdge(src, tgt, edge, false)
						}
				}
			}
			else if (graph.source(e) != src && graph.target(e) == tgt){
				graph.vdata(graph.source(e)) match {
					case d:NodeV if(d.typ == "G_Break" || d.typ == "G") => // do nothing
					case _ => 
						graph.vdata(src) match {
							case d:NodeV if(d.typ == "G_Break" || d.typ == "G") => // do nothing
							case d:WireV if(graph.adjacentEdges(src).size >= 1) => // do nothing
							case _ => moveEdge(tgt, src, edge, true)
						}
				}
			}
		}
	}

	def hasBreak(e: String) : Boolean = {
		graph.vdata(graph.source(EName(e))) match {
			case d:NodeV if(d.typ == "G_Break") => true
			case _ =>
				graph.vdata(graph.target(EName(e))) match {
					case d:NodeV if(d.typ == "G_Break") => true
					case _ => false
				}
		}
	}

	def addBreakpointOnEdge(edge:String){
		val e = EName(edge)
		if(view.selectedEdges.contains(e)) view.selectedEdges -= e
		val esrc = graph.source(e)
		val etgt = graph.target(e)
		val edata = graph.edata(e)
		val coordSrc = graph.vdata(esrc).coord
		val coordTgt = graph.vdata(etgt).coord
		val x = coordSrc._1 + ((coordTgt._1 - coordSrc._1)/2)
		val y = coordSrc._2 + ((coordTgt._2 - coordSrc._2)/2)
		val d = NodeV(data = theory.vertexTypes("G_Break").defaultData, theory = theory).withCoord((x,y))
		val n = graph.verts.freshWithSuggestion(VName("v0"))
		graph.edgesBetween(esrc, etgt).foreach { view.invalidateEdge }
		changeGraph(graph.deleteEdge(e))
		changeGraph(graph.addVertex(n, d.withCoord((x,y))))
		changeGraph(graph.addEdge(graph.edges.fresh, edata, (n, etgt)))
		graph.edgesBetween(n, etgt).foreach { view.invalidateEdge }
		changeGraph(graph.addEdge(graph.edges.fresh, edata, (esrc, n)))
		graph.edgesBetween(esrc, n).foreach { view.invalidateEdge }
		publish(NothingSelectedEventAPI())
	}

	/**
	  * Method to add a breakpoint on selected edges
	  */
	def addBreakpointOnSelectedEdges() {
		view.selectedEdges.foreach{ e =>
			addBreakpointOnEdge(e.s)
		}
	}

	def removeBreakpointFromEdge(e:String):String = {
		var newEdgeName = ""
		if(hasBreak(e)){
			graph.vdata(graph.source(EName(e))) match {
				case d:NodeV if(d.typ == "G_Break") => newEdgeName = removeBreakpoint(graph.source(EName(e)).s)
				case _ => graph.vdata(graph.target(EName(e))) match {
					case d:NodeV if(d.typ == "G_Break") => newEdgeName = removeBreakpoint(graph.target(EName(e)).s)
					case _ =>
				}
			}
		}
		newEdgeName
	}

	/**
	  * Method to remove the selected breakpoint
	  */
	def removeBreakpoint(v: String):String = {
		var newEdgeName = ""
		graph.vdata(VName(v)) match {
			case d:NodeV if(d.typ == "G_Break") =>
				val break = v
				val edata = DirEdge.fromJson(theory.defaultEdgeData, theory)
				val src = graph.source(graph.inEdges(break).head)
				val tgt = graph.target(graph.outEdges(break).head)
				graph.adjacentEdges(break).foreach {e => view.invalidateEdge(e) ; changeGraph(graph.deleteEdge(e))}
				view.invalidateVertex(break)
				changeGraph(graph.deleteVertex(break))
				val ename = graph.edges.fresh
				changeGraph(graph.addEdge(ename, edata, (src, tgt)))
				newEdgeName = ename.toString
			case _ =>
		}
		newEdgeName
	}

	/**
	  * Method to check if given node has goals before
	  */
	def hasGoalsBefore(n:String):Boolean = {
		var res = false
		graph.inEdges(n).foreach{e =>
			graph.vdata(graph.source(e)) match {
				case d:NodeV if(d.typ == "GN") => res = true
			}
		}
		res
	}

	/**
	  * Method to merge selected vertices into a nested one
	  */
	def mergeSelectedVertices() {
		// duplicate graph in a subgraph
		var newSubgraph = graph
		// computing new node coordinates to be at center of all selected nodes
		var maxX = -1000.0
		var minX = 1000.0
		var maxY = -1000.0
		var minY = 1000.0
		view.selectedVerts.foreach{ v=>
			maxX = max(maxX, graph.vdata(v).coord._1)
			minX = min(minX, graph.vdata(v).coord._1)
			maxY = max(maxY, graph.vdata(v).coord._2)
			minY = min(minY, graph.vdata(v).coord._2)
		}
		val newX = (minX+maxX)/2
		val newY = (minY+maxY)/2
		// creating new node (cannot use userAddVertex as we don't have the mouse point coordinates)
		var newData = NodeV(data = theory.vertexTypes("RT_NST").defaultData, theory = theory).withCoord((newX,newY))
		val newName = graph.verts.freshWithSuggestion(VName("v0"))
		changeGraph(graph.addVertex(newName, newData.withCoord((newX,newY))))
		graph.vdata(newName) match {
			case data: NodeV =>
				changeGraph(graph.updateVData(newName) { _ => data.withValue(Service.createNode(data.label, true, true)) })
				view.invalidateVertex(newName)
				graph.adjacentEdges(newName).foreach { view.invalidateEdge }
		}
		graph.vdata(newName) match { case data: NodeV => newData = data}
		var subgraphVerts = view.selectedVerts
		view.selectedVerts.foreach { v =>
			// we update the hierarchy if v is nested
			graph.vdata(v) match {
				case d:NodeV =>
					if(d.typ == "RT_NST"){
						Service.changeTacticParent(ArgumentParser.separateNameFromArgument(d.label)._1, ArgumentParser.separateNameFromArgument(newData.label)._1)
					}
			}
			// foreach "in" edges of selected nodes, setting target to be new node except for recursion
			graph.inEdges(v).foreach { e =>
				val data = graph.edata(e)
				val src = graph.source(e)
				val tgt = graph.target(e)
				// in the subgraph we put boundaries instead on unselected nodes
				if(!view.selectedVerts.contains(src) && src != newName){
					val bData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
					val bName = newSubgraph.verts.freshWithSuggestion(VName("b0"))
					subgraphVerts += bName
					newSubgraph = newSubgraph.addVertex(bName, bData.withCoord(newSubgraph.vdata(src).coord))
					newSubgraph = newSubgraph.deleteEdge(e)
					newSubgraph = newSubgraph.addEdge(e, data, (bName, v))
				}
				graph.edgesBetween(src, tgt).foreach { view.invalidateEdge }
				changeGraph(graph.deleteEdge(e))
				if(src != tgt && src != newName){
					changeGraph(graph.addEdge(e, data, (src, newName)))
					graph.edgesBetween(src, newName).foreach { view.invalidateEdge }
				}
			}
			// foreach "out" edges of selected nodes, setting source to be new node if it doesn't create recursion
			graph.outEdges(v).foreach { e =>
				val data = graph.edata(e)
				val tgt = graph.target(e)
				// in the subgraph we put boundaries instead on unselected nodes
				if(!view.selectedVerts.contains(tgt) && tgt != newName){
					val bData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
					val bName = newSubgraph.verts.freshWithSuggestion(VName("b0"))
					subgraphVerts += bName					
					newSubgraph = newSubgraph.addVertex(bName, bData.withCoord(newSubgraph.vdata(tgt).coord))
					newSubgraph = newSubgraph.deleteEdge(e)
					newSubgraph = newSubgraph.addEdge(e, data, (v, bName))
				}
				graph.edgesBetween(graph.source(e), tgt).foreach { view.invalidateEdge }
				changeGraph(graph.deleteEdge(e))
				if(tgt != newName){
					changeGraph(graph.addEdge(e, data, (newName, tgt)))
					graph.edgesBetween(newName, tgt).foreach { view.invalidateEdge }
				}
			}
			// deleting selected nodes
			view.invalidateVertex(v)
			view.selectedVerts -= v
			changeGraph(graph.deleteVertex(v))
		}
		newSubgraph.verts.foreach{ v => 
			if(!subgraphVerts.contains(v)) newSubgraph = newSubgraph.deleteVertex(v)
		}
		// saving json graph
		val jsonGraph = Graph.toJson(newSubgraph, theory)
		Service.saveGraphSpecificTactic(ArgumentParser.separateNameFromArgument(newData.label)._1, jsonGraph)
		publish(NothingSelectedEventAPI())
	}

	/**
	  * Method to add vertices and edges from specified json into our graph
	  * @param json, the json object to add
	  */
	def addFromJson(json: Json) {
		view.selectedVerts.foreach { v => view.selectedVerts -= v}
		var newNameMap = Map[String, String]()
		(json ? "wire_vertices").mapValue.foreach{ case (k,v) =>
			val bName = graph.verts.freshWithSuggestion(VName("b0"))
			newNameMap = newNameMap + ((k, bName.s))
			changeGraph(graph.addVertex(bName, WireV.fromJson(v, theory)))
			view.selectedVerts += bName
		}
		(json ? "node_vertices").mapValue.foreach{ case (k,v) =>
			val vName = graph.verts.freshWithSuggestion(VName("v0"))
			newNameMap = newNameMap + ((k, vName.s))
			changeGraph(graph.addVertex(vName, NodeV.fromJson(v, theory)))
			view.selectedVerts += vName
		}
		(json ? "dir_edges").mapValue.foreach{ case (k,v) =>
			val eName = graph.edges.freshWithSuggestion(EName("e0"))
			val data = v.getOrElse("data", theory.defaultEdgeData).asObject
			val annotation = (v ? "annotation").asObject
			changeGraph(graph.addEdge(eName, DirEdge(data, annotation, theory), (newNameMap((v / "src").stringValue), newNameMap((v / "tgt").stringValue))))
		}
	}

	/** listener to document undo stack */
	listenTo(document.undoStack)
	reactions += { case _: UndoEvent =>
		val canUndo = document.undoStack.canUndo
		val canRedo = document.undoStack.canRedo
		val undoActionName = document.undoStack.undoActionName.getOrElse("")
		val redoActionName = document.undoStack.redoActionName.getOrElse("")
		publish(DocumentActionStackEventAPI(canUndo, canRedo, undoActionName, redoActionName))
	}

	/** listener to undo stack, in order to re draw the graph*/
	listenTo(document.undoStack)
	reactions += {
		case UndoPerformed(_) =>
			view.resizeViewToFit()
			view.repaint()
		case RedoPerformed(_) =>
			view.resizeViewToFit()
			view.repaint()
	}

	/** listener to view mouse clicks and moves */
	listenTo(view.mouse.clicks, view.mouse.moves)
	reactions += {
		case e :MousePressed =>
			view.requestFocus()
			if(e.peer.getButton == 1){
				publish(MouseLeftPressedEvent(e.point, e.modifiers, e.clicks))
			}
			else if(e.peer.getButton == 3){
				publish(MouseRightPressedEvent(e.point, e.modifiers, e.clicks, graphPanel))
			}
		case MouseDragged(_, pt, _) =>
			publish(GraphMouseDraggedEvent(pt))
		case e: MouseReleased if(e.peer.getButton == 1) =>
			publish(GraphMouseReleasedEvent(e.point, e.modifiers))
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
				publish(NothingSelectedEventAPI())
			}
		case KeyPressed(_, Key.Minus, _, _)  => view.zoom *= 0.6
		case KeyPressed(_, Key.Equals, _, _) => view.zoom *= 1.6
	}
}