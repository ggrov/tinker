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
		val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		document.graph = layout.layout(Graph.fromJson(json, theory))
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
	def updatePreviewFromJson(json: JsonObject) {
		subgraphPreview.subgraphPreviewDoc.clear()
		val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		subgraphPreview.subgraphPreviewDoc.graph = layout.layout(Graph.fromJson(json, theory))
		subgraphPreview.subgraphPreviewDoc.publish(GraphReplaced(subgraphPreview.subgraphPreviewDoc, clearSelection = true))
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
		document.undoStack.start("Delete Vertex")
		graph.adjacentEdges(v).foreach {deleteEdge}
		if(graph.vdata.contains(v)){
			val d = graph.vdata(v)
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
		publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to open a document
	  */
	def openDoc {
		document.showOpenDialog()
		localUpdate()
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
		localUpdate()
		publish(DocumentTitleEventAPI(document.titleDescription))
	}

	/**
	  * Method to save a document as a new file
	  */
	def saveAsDoc {
		document.showSaveAsDialog()
		localUpdate()
		publish(DocumentTitleEventAPI(document.titleDescription))
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
	def selectElement(pt : java.awt.Point, modifiers: Modifiers, changeMouseStateCallback: (String, Any) => Unit) {
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
								movingEdge = true
								movingEdgeSource = true
								movedEdge = e
								changeMouseStateCallback("dragEdge", graph.target(e).s)
							}
							else if(dTgt<=0.5){
								movingEdge = true
								movingEdgeSource = false
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
			changeMouseStateCallback("dragEdge", startV.s)
			view.edgeOverlay = Some(EdgeOverlay(pt, src = startV, tgt = Some(startV)))
			view.repaint()
		}
	}

	/**
	  * Method to drag an edge on the view
	  * @param startV, the source vertex
	  * @param pt, the current location of the mouse
	  */
	def dragEdge(startV: String, pt: java.awt.Point){
		val vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		view.edgeOverlay = Some(EdgeOverlay(pt, startV, vertexHit))
		view.repaint()
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
			if(movingEdge){
				moveEdge(VName(startV), endV, movedEdge, movingEdgeSource)
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
	  * @param pt, point where to add the vertex
	  * @param typ, string representation of the type of node
	  */
	def userAddVertex(pt: java.awt.Point, typ: String){
		val coord = view.trans fromScreen (pt.getX, pt.getY)
		val vertexData = NodeV(data = theory.vertexTypes(typ).defaultData, theory = theory).withCoord(coord)
		val vertexName = graph.verts.freshWithSuggestion(VName("v0"))
		addVertex(vertexName, vertexData.withCoord(coord))
		if(typ == "RT_NST") {
			graph.vdata(vertexName) match {
				case data: NodeV =>
					changeGraph(graph.updateVData(vertexName) { _ => data.withValue(Service.checkNodeName(data.label, 0, true)) })
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
	private def setEdgeValue(e: EName, str: String) {
		val data = graph.edata(e)
		val oldVal = data.label
		changeGraph(graph.updateEData(e) { _ => data.withValue(str) })
		graph.edgesBetween(graph.source(e), graph.target(e)).foreach { view.invalidateEdge }
		document.undoStack.register("Set Edge Data") { setEdgeValue(e, oldVal) }
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

	/**
	  * Method to edit an element value (goal type for edge, strategy for vertex)
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

	/**
	  * Method that delete an element on user request
	  * @param eltName, the name of the element
	  */
	def userDeleteElement(eltName: String){
		if (graph.vdata.contains(VName(eltName))){
			deleteVertex(VName(eltName))
		}
		else if (graph.edata.contains(EName(eltName))){
			deleteEdge(EName(eltName))
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
				moveEdge(src, tgt, edge, false)
			}
			else if (graph.source(e) != src && graph.target(e) == tgt){
				moveEdge(tgt, src, edge, true)
			}
		}
	}

	/** listener to document status */
	listenTo(document)
	reactions += { case DocumentChanged(_) | DocumentSaved(_) =>
		publish(DocumentTitleEventAPI(document.titleDescription))
		publish(DocumentStatusEventAPI(document.unsavedChanges))
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
				publish(NothingSelectedEventAPI())
			}
		case KeyPressed(_, Key.Minus, _, _)  => view.zoom *= 0.6
		case KeyPressed(_, Key.Equals, _, _) => view.zoom *= 1.6
	}
}