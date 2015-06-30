package tinkerGUI.controllers

import quanto._
import quanto.util.json._
import quanto.data._
import quanto.data.Names._
import quanto.gui._
import quanto.gui.graphview._
import quanto.layout._
import quanto.layout.constraint._
import tinkerGUI.controllers.events.{OneEdgeSelectedEvent, ManyVerticesSelectedEvent, OneVertexSelectedEvent, NothingSelectedEvent}
import tinkerGUI.model.exceptions.{GraphTacticNotFoundException, AtomicTacticNotFoundException}
import scala.swing._
import scala.swing.event._
import scala.swing.event.Key.Modifiers
import scala.swing.event.Key.Modifier
import scala.math._
import tinkerGUI.utils.{TinkerDialog, ArgumentParser, SelectionBox}


/** API file for the library based on quantomatic.
  *
  */
object QuantoLibAPI extends Publisher{

	/** Panel object containing the graph. */
	private val graphPanel = new BorderPanel {
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

	/** Method to get the graph panel.
	  *
	  * @return Panel component containing the graph.
	  */
	def getGraph = graphPanel

	/** Method to reset the graph panel with an empty graph.
		*
	  */
	def newGraph() {
		document.clear()
		localUpdate()
		publish(NothingSelectedEvent())
	}

	/** Private method setting the labels on nodes with complete names of tactic (including arguments).
		*
		* @param json Input graph in json format.
		* @return Updated graph object.
		*/
	private def graphWithCompleteLabels(json:JsonObject):Graph = {
		var gr = Graph.fromJson(json, theory)
		gr.vdata.foreach{
			case (k,v:NodeV) =>
				v.data.get("label") match {
					case Some(j:Json) =>
					case None =>
						try{
							gr = gr.updateVData(k) { _ => v.withValue(Service.model.getATFullName(v.label)) }
						} catch {
							case e:AtomicTacticNotFoundException =>
								try{
									gr = gr.updateVData(k) { _ => v.withValue(Service.model.getGTFullName(v.label)) }
								} catch {
									case e:GraphTacticNotFoundException =>
										//TinkerDialog.openErrorDialog(e.msg)
										gr = gr.updateVData(k) { _ => v.withValue(v.label) }
								}
						}
				}
			case _ =>
		}
		gr
	}

	/** Method to load a graph from a Json object.
	  *
	  * @param json Json object to load.
	  */
	def loadFromJson(json: JsonObject) {
		document.clear()
		//val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		// wrap Graph.fromJson .... with layout.layout(...) in next line to activate layout
		document.graph = graphWithCompleteLabels(json)
		document.publish(GraphReplaced(document, clearSelection = true))
		localUpdate()
		publish(NothingSelectedEvent())
	}
		
	/** Panel object containing a preview of a nested tactic (used for the graph inspector).
	  *
	  */
	private val subgraphPreview = new BorderPanel {
		preferredSize = new Dimension (250,300)
		val subgraphPreviewDoc = new GraphDocument(this, theory)
		val subgraphPreviewView = new GraphView(theory, subgraphPreviewDoc)
		subgraphPreviewView.drawGrid = false
		val subgraphPreviewScrollPane = new ScrollPane(subgraphPreviewView)
		add(subgraphPreviewScrollPane, BorderPanel.Position.Center)
	}

	/** Method to get the subgraph panel.
	  *
	  * @return Subgraph preview.
	  */
	def getSubgraphPreview = subgraphPreview

	/** Method to update the subgraph preview with a json.
	  *
	  * @param json Json representation of the subgraph.
	  */
	def updateSubgraphPreviewFromJson(json: JsonObject) {
		subgraphPreview.subgraphPreviewDoc.clear()
		// val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		// wrap Graph.fromJson .... with layout.layout(...) in next line to activate layout
		subgraphPreview.subgraphPreviewDoc.graph = graphWithCompleteLabels(json)
		subgraphPreview.subgraphPreviewDoc.publish(GraphReplaced(subgraphPreview.subgraphPreviewDoc, clearSelection = true))
	}

	/** Panel containing a preview of a psgraph file (used for the library).
	  *
	  */
	private val libraryPreview = new BorderPanel {
		val libraryPreviewDoc = new GraphDocument(this, theory)
		val libraryPreviewView = new GraphView(theory, libraryPreviewDoc)
		libraryPreviewView.drawGrid = false
		val libraryPreviewScrollPane = new ScrollPane(libraryPreviewView)
		add(libraryPreviewScrollPane, BorderPanel.Position.Center)
	}

	/** Method to get the library psgraph panel.
	  *
	  * @return Library psgraph preview.
	  */
	def getLibraryPreview = libraryPreview

	/** Method to update the library psgraph preview with a json
	  *
	  * @param json Json representation of the graph
	  */
	def updateLibraryPreviewFromJson(json: Json) {
		libraryPreview.libraryPreviewDoc.clear()
		// val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		// wrap Graph.fromJson .... with layout.layout(...) in next line to activate layout
		libraryPreview.libraryPreviewDoc.graph = Graph.fromJson(json, theory)
		libraryPreview.libraryPreviewDoc.publish(GraphReplaced(libraryPreview.libraryPreviewDoc, clearSelection = true))
	}

	/** Private method to update the local variables.
	  *
	  */
	private def localUpdate() {
		document = graphPanel.graphDoc
		graph = graphPanel.graphDoc.graph
		view = graphPanel.graphView
		theory = graphPanel.theory
	}

	/** Private method to change the graph.
	  *
	  * @param gr New graph
	  */
	private def changeGraph(gr: Graph){
		graphPanel.graphDoc.graph = gr
		graph = graphPanel.graphDoc.graph
		Service.model.saveGraph(Graph.toJson(graph, theory))
		Service.graphNavCtrl.viewedGraphChanged(Service.model.isMain,false)
	}

	// ------------------------------------------------------------
	// Methods manipulating vertices.
	// ------------------------------------------------------------

	/** Private method to add a vertex to the graph.
	  *
	  * @param v Name of the vertex
	  * @param d Data of the vertex
	  */
	private def addVertex(v: VName, d: VData) {
		changeGraph(graph.addVertex(v, d))
	}

	/** Private method to delete a vertex.
	  *
	  * @param v Name of the vertex.
	  */
	private def deleteVertex(v: VName) {
		val d = graph.vdata(v)
		d match { 
			case data:NodeV if data.typ == "G_Break" =>
				removeBreakpoint(v.s)
			case _ =>
				graph.adjacentEdges(v).foreach {deleteEdge}
				if(graph.vdata.contains(v)){
					d match {
						case n: NodeV =>
							if (n.typ == "T_Graph") Service.editCtrl.deleteTactic(n.label, v.s, false)
							else if (n.typ == "T_Atomic") Service.editCtrl.deleteTactic(n.label, v.s, true)
						case _ =>
					}
					view.invalidateVertex(v)
					changeGraph(graph.deleteVertex(v))
				}
		}
	}

	/** Private method to change vertices coordinates.
	  *
	  * @param vs Set of vertices.
		* @param p1 Source point.
	  * @param p2 Target point.
	  */
	private def shiftVertsNoRegister(vs: TraversableOnce[VName], p1: Point, p2: Point) {
		val (dx,dy) = (view.trans scaleFromScreen (p2.getX - p1.getX), view.trans scaleFromScreen (p2.getY - p1.getY))
		changeGraph(vs.foldLeft(graph) { (g,v) =>
			view.invalidateVertex(v)
			graph.adjacentEdges(v).foreach { view.invalidateEdge }
			g.updateVData(v) { d => d.withCoord (d.coord._1 + dx, d.coord._2 - dy) }
		})
	}

	/** Method to drag one or more selected vertices.
	  *
	  * @param pt Target point.
	  * @param prev Origin point.
	  */
	def dragVertex(pt: java.awt.Point, prev: java.awt.Point) {
		shiftVertsNoRegister(view.selectedVerts, prev, pt)
		view.repaint()
	}

	/** Method adding a vertex on user request.
	  *
	  * @param pt Point where to add the vertex.
	  * @param typ String representation of the type of node.
	  */
	def userAddVertex(pt: java.awt.Point, typ: String){
		val coord = view.trans fromScreen (pt.getX, pt.getY)
		val vertexData = NodeV(data = theory.vertexTypes(typ).defaultData, theory = theory).withCoord(coord)
		val vertexName = graph.verts.freshWithSuggestion(VName("v0"))
		addVertex(vertexName, vertexData.withCoord(coord))
		graph.vdata(vertexName) match {
			case data: NodeV =>
				if(typ == "T_Graph") Service.editCtrl.createTactic(vertexName.s,false)
				else if (typ == "T_Atomic") Service.editCtrl.createTactic(vertexName.s, true)
		}
	}

	/** Method to update the value of a vertex.
		*
		* @param nodeId Id of the vertex.
		* @param newValue New value of the vertex.
		*/
	def setVertexValue(nodeId: String, newValue: String) {
		graph.vdata(VName(nodeId)) match {
			case data: NodeV =>
				changeGraph(graph.updateVData(VName(nodeId)) { _ => data.withValue(newValue) })
				view.invalidateVertex(VName(nodeId))
				graph.adjacentEdges(VName(nodeId)).foreach { view.invalidateEdge }
			case _ => // do nothing
		}
	}


	/** Method checking if given node has goals before.
		*
		* @param n Node id.
		* @return Boolean telling if there is a goal node before or not.
		*/
	def hasGoalsBefore(n:String):Boolean = {
		var res = false
		graph.inEdges(n).foreach{e =>
			graph.vdata(graph.source(e)) match {
				case d:NodeV if d.typ == "G" => res = true
				case _ =>
			}
		}
		res
	}

	/** Method chicking if given node has nested tactics after.
		*
		* @param n Node id.
		* @return Boolean telling if there is a nested tactic after or not.
		*/
	def hasNestedTacticAfter(n:String):Boolean = {
		var res = false
		graph.outEdges(n).foreach{e =>
			graph.vdata(graph.target(e)) match {
				case d:NodeV if d.typ == "T_Graph" => res = true
				case _ =>
			}
		}
		res
	}

	// ------------------------------------------------------------
	// End methods manipulating vertices
	// ------------------------------------------------------------



	// ------------------------------------------------------------
	// Methods manipulating edges.
	// ------------------------------------------------------------

	/** Private method to add an edge between two element of the graph.
	  *
	  * @param e Id of the edge.
	  * @param d Data of the edge.
	  * @param vs Source and target elements.
	  */
	private def addEdge(e: EName, d: EData, vs: (VName, VName)) {
		changeGraph(graph.addEdge(e, d, vs))
		graph.edgesBetween(vs._1, vs._2).foreach { view.invalidateEdge }
	}

	/** Private method deleting edges.
	  *
	  * If the edge has a boundary source or target, we delete it, if there are no edges coming from or to this boundary
	  * @param e Id of the edge
	  */
	private def deleteEdge(e: EName) {
		var edge = e
		if(hasBreak(e.s)){
			edge = EName(removeBreakpointFromEdge(e.s))
		}
		val vs = (graph.source(edge), graph.target(edge))
		graph.edgesBetween(vs._1, vs._2).foreach { view.invalidateEdge }
		changeGraph(graph.deleteEdge(edge))
		if(graph.vdata(vs._1).isBoundary){
			view.invalidateVertex(vs._1)
			deleteVertex(vs._1)
		}
		if(graph.vdata(vs._2).isBoundary && !(vs._1 == vs._2)){
			view.invalidateVertex(vs._2)
			deleteVertex(vs._2)
		}
	}

	/** Private method to move an edge.
	  *
	  * @param startV New source vertex
	  * @param endV New target vertex
	  * @param edge Id of the edge
	  * @param moveSource Boolean telling if we are moving the source of the edge
	  */
	private def moveEdge(startV: VName, endV: VName, edge: EName, moveSource: Boolean){
		val data = graph.edata(edge)
		val prevSrc = graph.source(edge)
		val prevTgt = graph.target(edge)
		val delPrevSrc = graph.vdata(prevSrc).isBoundary && (graph.adjacentEdges(prevSrc).size == 1) && moveSource && prevSrc!=prevTgt
		val delPrevTgt = graph.vdata(prevTgt).isBoundary && (graph.adjacentEdges(prevTgt).size == 1) && !moveSource && prevSrc != prevTgt
		val selected = if (view.selectedEdges.contains(edge)) {
			view.selectedEdges -= edge
			true
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
		if(selected){
			view.selectedEdges += edge
		}
		// we reset the boolean
		movingEdge = false
	}

	/** Method to start adding an edge.
	  *
	  * @param pt Point where to look for a source vertex, if none we add a boundary.
	  * @param changeMouseStateCallback Callback function to update the mouse state.
	  */
	def startAddEdge(pt: java.awt.Point, changeMouseStateCallback: (String, String) => Unit) {
		var vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		//if(vertexHit == None){
		if(vertexHit.isEmpty)	{
			val coord = view.trans fromScreen (pt.getX, pt.getY)
			val vertexData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
			val vertexName = graph.verts.freshWithSuggestion(VName("b0"))
			changeGraph(graph.addVertex(vertexName, vertexData.withCoord(coord)))
			vertexHit = Some(vertexName)
		}
		vertexHit map { startV =>
			graph.vdata(startV) match {
				case d:NodeV if d.typ != "G_Break" && d.typ != "G" =>
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

	/** Method to drag an edge on the view.
	  *
	  * @param startV Source vertex.
	  * @param pt Current location of the mouse.
	  */
	def dragEdge(startV: String, pt: java.awt.Point){
		val vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		vertexHit match {
			case Some(v:VName) =>
				graph.vdata(v) match {
					case d:NodeV if d.typ != "G_Break" && d.typ != "G" =>
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

	/** Method to end adding / moving an edge to the view.
	  *
	  * @param startV Source vertex (can be the target in case of moving).
	  * @param pt Point where to look for the target (or source) vertex, if none we add a boundary.
	  * @param changeMouseStateCallback Callback function to update the mouse state.
	  */
	def endAddEdge(startV: String, pt: java.awt.Point, changeMouseStateCallback: (String) => Unit){
		var vertexHit = view.vertexDisplay find { _._2.pointHit(pt) } map { _._1 }
		//if(vertexHit == None){
		if(vertexHit.isEmpty)	{
			val coord = view.trans fromScreen (pt.getX, pt.getY)
			val vertexData = WireV(theory = theory, annotation = JsonObject("boundary" -> JsonBool(true)))
			val vertexName = graph.verts.freshWithSuggestion(VName("b0"))
			changeGraph(graph.addVertex(vertexName, vertexData.withCoord(coord)))
			vertexHit = Some(vertexName)
		}
		vertexHit map { endV =>
			graph.vdata(endV) match {
				case d:NodeV if d.typ != "G_Break" && d.typ != "G" =>
					if(movingEdge){
						moveEdge(VName(startV), endV, movedEdge, movingEdgeSource)
						changeMouseStateCallback("select")
					}
					else{
						val defaultData = DirEdge.fromJson(theory.defaultEdgeData, theory)
						addEdge(graph.edges.fresh, defaultData, (VName(startV), endV))
						changeMouseStateCallback("addEdge")
					}
				case d:WireV if graph.adjacentEdges(endV).size < 1 && endV != VName(startV) && !(graph.vdata(startV).isBoundary) =>
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

	/** Method to update the value of an edge (goal type)
	  *
	  * @param e Id of the edge
	  * @param str New value
	  */
	def setEdgeValue(e: String, str: String) {
		val data = graph.edata(EName(e))
		if(data.label != str){
			changeGraph(graph.updateEData(EName(e)) { _ => data.withValue(str) })
			graph.edgesBetween(graph.source(EName(e)), graph.target(EName(e))).foreach { view.invalidateEdge }
			graph.vdata(graph.source(EName(e))) match {
				case d:NodeV if d.typ == "G_Break" || d.typ == "G" =>
					setEdgeValue(graph.inEdges(graph.source(e)).head.s, str)
				case _ => // do nothing
			}
			graph.vdata(graph.target(EName(e))) match {
				case d:NodeV if d.typ == "G_Break" || d.typ == "G" =>
					setEdgeValue(graph.outEdges(graph.target(e)).head.s, str)
				case _ => // do nothing
			}
		}
	}


	/** Method that updates the source or target of an edge on user request
		*
	  * This method first check if the new source or target exists
	  * @param e Id of the edge
		* @param s New source name
	  * @param t New target name
	  */
	def userUpdateEdge(e: String, s: String, t: String){
		val edge = EName(e)
		val src = VName(s)
		val tgt = VName(t)
		if (graph.vdata.contains(src) && graph.vdata.contains(tgt)) {
			if(graph.source(e) == src && graph.target(e) != tgt) {
				graph.vdata(graph.target(e)) match {
					case d:NodeV if d.typ == "G_Break" || d.typ == "G" => // do nothing
					case _ =>
						graph.vdata(tgt) match {
							case d:NodeV if d.typ == "G_Break" || d.typ == "G" => // do nothing
							case d:WireV if graph.adjacentEdges(tgt).size >= 1 => // do nothing
							case _ => moveEdge(src, tgt, edge, false)
						}
				}
			}
			else if (graph.source(e) != src && graph.target(e) == tgt){
				graph.vdata(graph.source(e)) match {
					case d:NodeV if d.typ == "G_Break" || d.typ == "G"  => // do nothing
					case _ =>
						graph.vdata(src) match {
							case d:NodeV if d.typ == "G_Break" || d.typ == "G" => // do nothing
							case d:WireV if graph.adjacentEdges(src).size >= 1 => // do nothing
							case _ => moveEdge(tgt, src, edge, true)
						}
				}
			}
		}
	}

	/** Method to know if an edge has a breakpoint.
		*
		* @param e Edge id.
		* @return Boolean result : true has breakpoint, false does not.
		*/
	def hasBreak(e: String) : Boolean = {
		graph.vdata(graph.source(EName(e))) match {
			case d:NodeV if d.typ == "G_Break"  => true
			case _ =>
				graph.vdata(graph.target(EName(e))) match {
					case d:NodeV if d.typ == "G_Break" => true
					case _ => false
				}
		}
	}

	/** Method adding a breakpoint on an edge.
		*
		* @param edge edge id.
		*/
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
		publish(NothingSelectedEvent())
	}

	/** Method removing a breakpoint from a specific edge.
		*
		* @param e Edge id.
		* @return New edge id.
		*/
	def removeBreakpointFromEdge(e:String):String = {
		var newEdgeName = ""
		if(hasBreak(e)){
			graph.vdata(graph.source(EName(e))) match {
				case d:NodeV if d.typ == "G_Break" => newEdgeName = removeBreakpoint(graph.source(EName(e)).s)
				case _ => graph.vdata(graph.target(EName(e))) match {
					case d:NodeV if d.typ == "G_Break" => newEdgeName = removeBreakpoint(graph.target(EName(e)).s)
					case _ =>
				}
			}
		}
		newEdgeName
	}

	/** Method to remove a specific breakpoint.
		*
		* @param v Id of the breakpoint.
		* @return New id of the edge on which it was.
		*/
	def removeBreakpoint(v: String):String = {
		var newEdgeName = ""
		graph.vdata(VName(v)) match {
			case d:NodeV if d.typ == "G_Break" =>
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

	// ------------------------------------------------------------
	// End methods manipulating edges
	// ------------------------------------------------------------

	/** Method to layout the graph.
		*
		* Uses Quantomatic's layout algorithm.
	  */
	def layoutGraph() {

		val lo = new ForceLayout with IRanking with VerticalBoundary with Clusters
		changeGraph(lo.layout(graph))
		view.resizeViewToFit()
		view.repaint()
	}

	/** Method to publish an event when one or more vertex are selected.
	  *
	  */
	private def publishSelectedVerts(){
		if(view.selectedVerts.size == 1 && view.selectedEdges.size == 0 && !(graph.vdata(view.selectedVerts.head).isBoundary)){
			(view.selectedVerts.head, graph.vdata(view.selectedVerts.head)) match {
				case (v: VName, data: NodeV) => publish(OneVertexSelectedEvent(v.s, data.typ, data.label))
			}
		}
		else if(view.selectedVerts.size > 1 && view.selectedEdges.size == 0){
			var vnames = Set[String]()
			view.selectedVerts.foreach { v =>
				if(graph.vdata(v).isBoundary) return
				else vnames = vnames + v.s
			}
			publish(ManyVerticesSelectedEvent(vnames))
		}
	}

	/** Method to select an element on a graph view.
	  *
	  * @param pt Point where the vertex is selected, if no vertex is found we start a selection box
	  * @param modifiers Any modifier key to our selection (e.g. Shift key for multiple selection)
	  * @param changeMouseStateCallback Callback function to update the mouse state.
	  */
	def selectElement(pt : java.awt.Point, modifiers: Modifiers, changeMouseStateCallback: (String, Any) => Unit){
		publish(NothingSelectedEvent())
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
						if(view.selectedEdges.size == 1 && view.selectedVerts.isEmpty){
							graph.edata(e) match {
								case data: DirEdge => publish(OneEdgeSelectedEvent(e.s, data.value, graph.source(e).s, graph.target(e).s))
							}
						}
						val rec = graph.source(e) == graph.target(e)
						val ptCoord = view.trans fromScreen (pt.getX, pt.getY)
						val srcCoord = graph.vdata(graph.source(e)).coord
						val tgtCoord = graph.vdata(graph.target(e)).coord
						val dSrc = hypot(srcCoord._1-ptCoord._1, srcCoord._2-ptCoord._2)
						val dTgt = hypot(ptCoord._1-tgtCoord._1, ptCoord._2-tgtCoord._2)
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
									case d:NodeV if d.typ != "G_Break" && d.typ != "G" =>
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
									case d:NodeV if d.typ != "G_Break" && d.typ != "G" =>
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

	/** Method to add a selection box to the view.
	  *
	  * @param box Actual box, default value is null
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

	/** Method for final computation of selection box.
	  *
	  * @param update Boolean being true if the selection has been updated
	  * @param pt Final location of the mouse
	  * @param rect Selection box
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


	/** Method launching the edition process of an element, depending on specified coordinates.
	  *
		* Used with double click, only enable the edition of a nested or atomic node or an edge.
	  * @param pt Coordinates of the potential element.
	  */
	def editGraphElement(pt: java.awt.Point){
		val vertexHit = view.vertexDisplay find { case (v, disp) =>
			disp.pointHit(pt) && !graph.vdata(v).isWireVertex
		} map { _._1 }

		vertexHit.map{ v => (v, graph.vdata(v)) } match {
			case Some((v, data: NodeV)) =>
				if(data.typ == "T_Atomic") Service.editCtrl.updateTactic(v.s,data.label,true)
				else if(data.typ == "T_Graph") Service.editCtrl.updateTactic(v.s,data.label,false)
			case _ =>
				val edgeHit = view.edgeDisplay find { _._2.pointHit(pt) } map { _._1 }
				edgeHit.map { e =>
					val data = graph.edata(e)
					Service.editCtrl.editEdge(e.s, graph.source(e).s, graph.target(e).s, data.value)
				}
		}
	}

	/** Method deleting an element on user request.
	  *
	  * @param eltName Id of the element
	  */
	def userDeleteElement(eltName: String){
		if (graph.vdata.contains(VName(eltName))){
			deleteVertex(VName(eltName))
		}
		else if (graph.edata.contains(EName(eltName))){
			var ename = eltName
			if(hasBreak(eltName)){
				ename = removeBreakpointFromEdge(eltName)
			}
			if(ename != ""){
				deleteEdge(EName(ename))
			}
		}
		publish(NothingSelectedEvent())
	}



	/** Method to merge selected vertices into a nested one.
		*
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
		var newData = NodeV(data = theory.vertexTypes("T_Graph").defaultData, theory = theory).withCoord((newX,newY))
		val newName = graph.verts.freshWithSuggestion(VName("v0"))
		changeGraph(graph.addVertex(newName, newData.withCoord((newX,newY))))
		graph.vdata(newName) match {
			case data: NodeV =>
				changeGraph(graph.updateVData(newName) { _ => data.withValue(Service.editCtrl.createNewTactic(newName.s,"nested",false)) })
				view.invalidateVertex(newName)
				graph.adjacentEdges(newName).foreach { view.invalidateEdge }
		}
		graph.vdata(newName) match { case data: NodeV => newData = data}
		var subgraphVerts = view.selectedVerts
		view.selectedVerts.foreach { v =>
			// we update the hierarchy if v is nested
			graph.vdata(v) match {
				case d:NodeV =>
					if(d.typ == "T_Graph"){
						Service.editCtrl.changeTacticOccurrence(v.s,
							ArgumentParser.separateNameFromArgument(d.label)._1,
							ArgumentParser.separateNameFromArgument(newData.label)._1,
							0,
							false)
					} else if (d.typ == "T_Atomic") {
						Service.editCtrl.changeTacticOccurrence(v.s,
							ArgumentParser.separateNameFromArgument(d.label)._1,
							ArgumentParser.separateNameFromArgument(newData.label)._1,
							0,
							true)
					}
			}
			// foreach "in" edges of selected nodes, setting target to be new node except for recursion
			graph.inEdges(v).foreach { e =>
				val data = graph.edata(e)
				val src = graph.source(e)
				val tgt = graph.target(e)
				// in the subgraph we put boundaries instead of unselected nodes
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
		Service.saveGraphSpecificTactic(ArgumentParser.separateNameFromArgument(newData.label)._1, jsonGraph, 0)
		publish(NothingSelectedEvent())
		Service.editCtrl.updateTactic(newName.s, ArgumentParser.separateNameFromArgument(newData.label)._1, false)
	}

	/** Method to add vertices and edges from specified json into our graph.
	  *
	  * @param json Json object to add
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

	/** listener to view mouse clicks and moves */
	listenTo(view.mouse.clicks, view.mouse.moves)
	reactions += {
		case e :MousePressed =>
			view.requestFocus()
			if(e.peer.getButton == 1){
				Service.editCtrl.leftMousePressed(e.point, e.modifiers, e.clicks)
			}
			else if(e.peer.getButton == 3){
				Service.editCtrl.rightMousePressed(e.point, e.modifiers, e.clicks, graphPanel)
			}
		case MouseDragged(_, pt, _) =>
			Service.editCtrl.mouseDragged(pt)
		case e: MouseReleased if(e.peer.getButton == 1) =>
			Service.editCtrl.mouseReleased(e.point, e.modifiers)
	}

	/** listener to view keys events */
	listenTo(view.keys)
	reactions += {
		case KeyPressed (_, (Key.Delete | Key.BackSpace), _, _) =>
			if(!view.selectedVerts.isEmpty || !view.selectedEdges.isEmpty) {
				Service.documentCtrl.registerChanges()
				view.selectedVerts.foreach { deleteVertex }
				view.selectedEdges.foreach { deleteEdge }
				view.repaint()
				publish(NothingSelectedEvent())
			}
		case KeyPressed(_, Key.Minus, _, _)  => view.zoom *= 0.6
		case KeyPressed(_, Key.Equals, _, _) => view.zoom *= 1.6
	}
}