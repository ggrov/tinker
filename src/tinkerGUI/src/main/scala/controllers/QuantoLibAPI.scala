package tinkerGUI.controllers

import scala.swing._
import scala.swing.event._
import scala.swing.event.Key.Modifiers
import scala.swing.event.Key.Modifier
import scala.math._
import java.awt.{Font => AWTFont}
import java.io.File

import quanto.util.FileHelper
import quanto.util.json._
import quanto.data._
import quanto.data.Names._
import quanto.gui._
import quanto.gui.graphview._
import quanto.layout._
import quanto.layout.constraint._
import tinkerGUI.controllers.events.{OneEdgeSelectedEvent, ManyVerticesSelectedEvent, OneVertexSelectedEvent, NothingSelectedEvent}
import tinkerGUI.model.exceptions.{PSGraphModelException, GraphTacticNotFoundException, AtomicTacticNotFoundException}
import tinkerGUI.utils.{TinkerDialog, ArgumentParser, SelectionBox}


/** API file for the library based on quantomatic.
  *
  */
object QuantoLibAPI extends Publisher{

	/** Panel object containing the main graph. */
	private val graphPanel = new BorderPanel {
		println("loading theory " + Theory.getClass.getResource("strategy_graph_modified.qtheory"))
		val theoryFile = new Json.Input(Theory.getClass.getResourceAsStream("strategy_graph_modified.qtheory"))
		val theory = Theory.fromJson(Json.parse(theoryFile))
		val graphDoc = new GraphDocument(this, theory)
		val graphView = new GraphView(theory, graphDoc)
		val graphScrollPane = new ScrollPane(graphView)
		add(graphScrollPane, BorderPanel.Position.Center)
	}

	/** shortcuts for variables for graph instance. */
	private var graph = graphPanel.graphDoc.graph
	private var theory = graphPanel.theory
	private var view = graphPanel.graphView
	private var document = graphPanel.graphDoc

	/** variables used when we are moving an edge */
	var movingEdge: Boolean = false
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
						v.typ match {
							case "G_Break" =>
								gr = gr.updateVData(k) { _ => v.withLabel("STOP") }
							case "T_Atomic" =>
								gr = gr.updateVData(k) { _ => v.withLabel(v.label) }
							case "T_Graph" =>
								gr = gr.updateVData(k) { _ => v.withLabel(v.label) }
							case _ =>
						}
				}
			case _ =>
		}
		gr
	}

	private def tinkerLayout(graph:Graph):Graph = {
		var gr = graph
		def rearrange(v1:VName,v2:VName,factor:Double):((Double,Double),(Double,Double)) = {
			val c1 = gr.vdata(v1).coord
			val c2 = gr.vdata(v2).coord
			val varX = c2._1-c1._1
			val varY = c2._2-c1._2
			val d = Math.sqrt(varX*varX + varY*varY)
			if(d < factor){
				val newvarX = (factor/d)*varX
				val newvarY = (factor/d)*varY
				gr = gr.updateVData(v2) { d => d.withCoord(gr.vdata(v1).coord._1 + newvarX, gr.vdata(v1).coord._2 + newvarY)}
				((newvarX,newvarY),(newvarX-varX,newvarY-varY))
			} else {
				((varX,varY),(0,0))
			}
		}
		def rearrangeGoals(pred:VName,delta:(Double,Double),factor:Int,goals:Set[VName]){
			if(!goals.isEmpty){
				val g = goals.head
				gr = gr.updateVData(g) { d => d.withCoord(gr.vdata(pred).coord._1 + delta._1/factor, gr.vdata(pred).coord._2 + delta._2/factor)}
				val newDelta = (delta._1 - delta._1/factor, delta._2 - delta._2/factor)
				rearrangeGoals(g,newDelta,factor-1,goals.tail)
			}
		}
		var nodeComputed = Set[VName]()
		def rec(v:VName, tvarX:Double, tvarY:Double){
			nodeComputed = nodeComputed + v
			gr.succVerts(v).foreach { case v1 =>
				var f = 1
				var succ = v1
				var goals = Set[VName]()
				while(gr.vdata(succ) match { case n:NodeV => n.typ=="G" case _ => false}){
					f += 1
					goals = goals + succ
					succ = gr.succVerts(succ).head
				}
				if(succ.s != v.s && !nodeComputed.contains(succ)){
					gr = gr.updateVData(succ) { d => d.withCoord(d.coord._1 + tvarX, d.coord._2 + tvarY)}
					val delta = rearrange(v,succ,f*1.5)
					if(f > 1){
						rearrangeGoals(v,(delta._1),f,goals)
					}
					rec(succ,tvarX+delta._2._1,tvarY+delta._2._2)
				}
			}
		}
		gr.inputs.foreach(rec(_,0,0))

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
		document.graph = tinkerLayout(graphWithCompleteLabels(json))
		//document.graph = graphWithCompleteLabels(json)
		document.publish(GraphReplaced(document, clearSelection = true))
		localUpdate()
		view.resizeViewToFit()
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

	/** Method to zoom in the subgraph preview.
		*
		*/
	def zoomInSubgraphPreview() {
		subgraphPreview.subgraphPreviewView.zoom *= 1.5
	}

	/** Method to zoom out the subgraph preview.
		*
		*/
	def zoomOutSubgraphPreview() {
		subgraphPreview.subgraphPreviewView.zoom *= 0.5
	}

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
		subgraphPreview.subgraphPreviewView.resizeViewToFit()
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

	/** Method to update the library psgraph preview with a json.
	  *
	  * @param json Json representation of the graph.
	  */
	def updateLibraryPreviewFromJson(json: Json) {
		libraryPreview.libraryPreviewDoc.clear()
		// val layout = new ForceLayout with IRanking with VerticalBoundary with Clusters
		// wrap Graph.fromJson .... with layout.layout(...) in next line to activate layout
		libraryPreview.libraryPreviewDoc.graph = Graph.fromJson(json, theory)
		libraryPreview.libraryPreviewDoc.publish(GraphReplaced(libraryPreview.libraryPreviewDoc, clearSelection = true))
		libraryPreview.libraryPreviewView.resizeViewToFit()
	}

	/** Method to zoom in the library preview.
		*
		*/
	def zoomInLibraryPreview() {
		libraryPreview.libraryPreviewView.zoom *= 1.5
	}

	/** Method to zoom out the library preview.
		*
		*/
	def zoomOutLibraryPreview() {
		libraryPreview.libraryPreviewView.zoom *= 0.5
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

	/** Method zooming in the graph view.
		*
		*/
	def zoomInGraph() {
		view.zoom *= 1.5
	}

	/** Method zooming out the graph view.
		*
		*/
	def zoomOutGraph() {
		view.zoom *= 0.5
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
			case data:NodeV if data.typ == "G" =>
			case _ =>
				graph.adjacentEdges(v).foreach {deleteEdge}
				view.invalidateVertex(v)
				changeGraph(graph.deleteVertex(v))
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
		* @return Id of the new node
	  */
	def userAddVertex(pt: java.awt.Point, typ: String, label:String):String = {
		val coord = view.trans fromScreen (pt.getX, pt.getY)
		val vertexData = NodeV(data = theory.vertexTypes(typ).defaultData, theory = theory).withCoord(coord)
		val vertexName = graph.verts.freshWithSuggestion(VName("v0"))
		addVertex(vertexName, vertexData.withCoord(coord).withLabel(label))
		/*graph.vdata(vertexName) match {
			case data: NodeV =>
				if(typ == "T_Graph") Service.editCtrl.createTactic(vertexName.s,false)
				else if (typ == "T_Atomic") Service.editCtrl.createTactic(vertexName.s, true)
		}*/
		vertexName.s
	}

	/** Method to update the value of a vertex.
		*
		* @param nodeId Id of the vertex.
		* @param newValue New value of the vertex.
		*/
	def setVertexLabel(nodeId: String, newValue: String) {
		graph.vdata(VName(nodeId)) match {
			case data: NodeV =>
				changeGraph(graph.updateVData(VName(nodeId)) { _ => data.withLabel(newValue) })
				view.invalidateVertex(VName(nodeId))
				graph.adjacentEdges(VName(nodeId)).foreach { view.invalidateEdge }
				publishSelectedVerts()
			case _ => // do nothing
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
				publishSelectedVerts()
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

	/** Method checking if given node has nested tactics after.
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

	/** Method retreiving a node type and value.
		*
		* @param n Node id.
 		* @return Pair of string, first is type, second is value.
		*/
	def getNodeTypeAndValue(n:String):(String,String) = {
		graph.vdata(VName(n)) match {
			case (d:NodeV) => (d.typ,d.value.stringValue)
			case (d:WireV) => ("Boundary","")
		}
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
	def endAddEdge(startV: String, pt:java.awt.Point, changeMouseStateCallback: (String) => Unit){
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
							case d:WireV if graph.adjacentEdges(tgt).nonEmpty => // do nothing
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
							case d:WireV if graph.adjacentEdges(src).nonEmpty => // do nothing
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

	/** Method to know if an edge is carrying a goal.
		*
		* @param e Edge id.
 		* @return Bolean result : true has goal, false does not.
		*/
	def hasGoal(e:String) : Boolean = {
		graph.vdata(graph.source(EName(e))) match {
			case d:NodeV if d.typ == "G"  => true
			case _ =>
				graph.vdata(graph.target(EName(e))) match {
					case d:NodeV if d.typ == "G" => true
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

	// ------------------------------------------------------------
	// Methods manipulating graphs (generic, i.e. those method
	// will take a json graph as parameter and return a json graph)
	// ------------------------------------------------------------

	/** Method updating tactics' values.
		*
 		* @param graph Json to update.
		* @param tacticsToUpdate Array of the tactics' values to update.
		* @return Updated json.
		*/
	def updateValuesInGraph(graph:Json, tacticsToUpdate:Array[(String,String)]):Json = {
		var gr = Graph.fromJson(graph,theory)
		gr.vdata.foreach{ case (name,data) =>
			data match {
				case d:NodeV if d.typ == "T_Graph" || d.typ == "T_Atomic" =>
					tacticsToUpdate.foreach{ case (o,n) =>
						if(d.value.stringValue == o) gr = gr.updateVData(name){_ => d.withValue(n)}
					}
				case _ =>
			}
		}
		Graph.toJson(gr,theory)
	}

	/** Method removing all goals from one graph.
		*
		* @param graph Json graph to modify.
		* @return Updated json with no goals.
		*/
	def graphWithNoGoals(graph:Json):Json = {
		var gr = Graph.fromJson(graph,theory)
		gr.vdata.foreach { case(name,data) =>
			data match {
				case d:NodeV if d.typ == "G" =>
					val prevNode = gr.source(gr.inEdges(name).head)
					val nextNode = gr.target(gr.outEdges(name).head)
					val edgeData = gr.edata(gr.inEdges(name).head)
					gr = gr.deleteVertex(name).newEdge(edgeData,(prevNode,nextNode))
				case _ =>
			}
		}
		Graph.toJson(gr,theory)
	}

	// ------------------------------------------------------------
	// End methods manipulating graphs
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
				case (v: VName, data: NodeV) => publish(OneVertexSelectedEvent(v.s, data.typ, data.label, data.value.stringValue))
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
				if(data.typ == "T_Atomic") Service.editCtrl.updateTactic(v.s,data.label,data.value.stringValue,true)
				else if(data.typ == "T_Graph") Service.editCtrl.updateTactic(v.s,data.label,data.value.stringValue,false)
			case _ =>
				val edgeHit = view.edgeDisplay find { _._2.pointHit(pt) } map { _._1 }
				edgeHit.foreach { e =>
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
			while(hasBreak(ename)){
				ename = removeBreakpointFromEdge(eltName)
			}
			if(ename != ""){
				deleteEdge(EName(ename))
			}
		}
		publish(NothingSelectedEvent())
	}

	/** Method to know if at least one of the selected vertices is a goal.
		*
		* @return Boolean stating if one of the selected vertices is a goal.
		*/
	def selectedContainGoals:Boolean = {
		var res = false
		view.selectedVerts foreach { v =>
			graph.vdata(v) match {
				case (d: NodeV) if d.typ == "G" => res = true
				case _ =>
			}
		}
		res
	}

	/** Method to know if at least one of the selected vertices match one of the tactics specified.
		*
		* @param t Set of tactic name.
		* @return Boolean stating if one of the tactics is selected.
		*/
	def selectedContainTactics(t:Set[String]):Boolean = {
		var res = false
		view.selectedVerts foreach { v =>
			graph.vdata(v) match {
				case (d:NodeV) if (d.typ=="T_Atomic" || d.typ=="T_Graph") && t.contains(d.value.stringValue) => res = true
				case _ =>
			}
		}
		res
	}

	/** Method to merge selected vertices into a nested one.
		*
		* @param newNodeLabel Label of of the new nested node.
		* @return id of the new nested node.
		*/
	def mergeSelectedVertices(newNodeLabel:String):String = {
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
		val newData = NodeV(data = theory.vertexTypes("T_Graph").defaultData, theory = theory).withCoord((newX,newY)).withLabel(newNodeLabel)
		val newName = graph.verts.freshWithSuggestion(VName("v0"))
		changeGraph(graph.addVertex(newName, newData))
		var subgraphVerts = view.selectedVerts
		view.selectedVerts.foreach { v =>
			// we update the hierarchy if v is nested
			graph.vdata(v) match {
				case d:NodeV =>
					if(d.typ == "T_Graph"){
						Service.editCtrl.changeTacticOccurrence(v.s,d.value.stringValue,newData.value.stringValue,0,false)
					} else if (d.typ == "T_Atomic") {
						Service.editCtrl.changeTacticOccurrence(v.s,d.value.stringValue,newData.value.stringValue,0,true)
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
		Service.saveGraphSpecificTactic(newData.value.stringValue, jsonGraph, 0)
		publish(NothingSelectedEvent())
		newName.s
	}

	/** Method to add vertices and edges from specified json into our graph.
	  *
	  * @param json Json object to add
	  */
	def addFromJson(json: Json):Map[String,String] = {
		view.selectedVerts.foreach { v => view.selectedVerts -= v}
		var newNodeIdMap = Map[String, String]()
		var nameNodeIdMap = Map[String,String]()
		(json ? "wire_vertices").mapValue.foreach{ case (k,v) =>
			val bName = graph.verts.freshWithSuggestion(VName("b0"))
			newNodeIdMap = newNodeIdMap + (k -> bName.s)
			changeGraph(graph.addVertex(bName, WireV.fromJson(v, theory)))
			view.selectedVerts += bName
		}
		(json ? "node_vertices").mapValue.foreach{ case (k,v) =>
			val vName = graph.verts.freshWithSuggestion(VName("v0"))
			newNodeIdMap = newNodeIdMap + (k -> vName.s)
			changeGraph(graph.addVertex(vName, NodeV.fromJson(v, theory)))
			graph.vdata(vName) match {
				case d:NodeV if d.typ == "T_Atomic" || d.typ == "T_Graph" =>
					nameNodeIdMap = nameNodeIdMap + (ArgumentParser.separateNameArgs(d.value.stringValue)._1->vName.s)
				case _ =>  // do nothing
			}
			view.selectedVerts += vName
		}
		(json ? "dir_edges").mapValue.foreach{ case (k,v) =>
			val eName = graph.edges.freshWithSuggestion(EName("e0"))
			val data = v.getOrElse("data", theory.defaultEdgeData).asObject
			val annotation = (v ? "annotation").asObject
			changeGraph(graph.addEdge(eName, DirEdge(data, annotation, theory), (newNodeIdMap((v / "src").stringValue), newNodeIdMap((v / "tgt").stringValue))))
		}
		view.resizeViewToFit()
		publishSelectedVerts()
		nameNodeIdMap
	}

	/** Method printing a message on the graph panel, notifying of unsafe evaluation.
		*
		* @param b Boolean to show the message or hide it.
		*/
	def printEvaluationFlag(b:Boolean) = {
		view.printTinkerEvaluationFlag = b
		view.repaint()
	}


	def toSvg() {
		val fmNode = view.peer.getGraphics.getFontMetrics(new Font("Dialog", AWTFont.PLAIN, 14))
		val fmNodeSmall = view.peer.getGraphics.getFontMetrics(new Font("Dialog", AWTFont.BOLD, 10))
		val fmEdge = view.peer.getGraphics.getFontMetrics(new Font("Dialog", AWTFont.PLAIN, 12))
		var minX = 1000
		var minY = 1000
		var maxX = 0
		var maxY = 0
		val nodes = graph.vdata.foldLeft(Map[String,(String,String,Int,Int,Int,Int)]()){ (m,p) =>
			val x = (p._2.coord._1*50).toInt
			val y = (-p._2.coord._2*50).toInt
			p._2 match {
				case d:NodeV if d.typ == "T_Identity" =>
					val w = 24
					val h = 22
					minX = min(minX,x-w/2)
					minY = min(minY,y-h/2)
					m + (p._1.s -> ("id","",x,y,w,h))
				case d:NodeV if d.typ == "T_Atomic" =>
					val w = fmNode.charsWidth(d.label.toCharArray,0,d.label.size)+6
					val h = fmNode.getHeight+4
					minX = min(minX,x-w/2)
					minY = min(minY,y-h/2)
					m + (p._1.s -> ("atm",d.label,x,y,w,h))
				case d:NodeV if d.typ == "T_Graph" =>
					val w = fmNode.charsWidth(d.label.toCharArray,0,d.label.size)+6
					val h = fmNode.getHeight+4
					minX = min(minX,x-w/2)
					minY = min(minY,y-h/2)
					m + (p._1.s -> ("nst",d.label,x,y,w,h))
				case d:NodeV if d.typ == "G_Break" =>
					val w = fmNodeSmall.charsWidth("STOP".toCharArray,0,d.label.size)+2
					minX = min(minX,x-w/2)
					minY = min(minY,y-w/2)
					m + (p._1.s -> ("break","STOP",x,y,w,w))
				case d:NodeV if d.typ == "G" =>
					val w = fmNode.charsWidth(d.label.toCharArray,0,d.label.size)+6
					minX = min(minX,x-w/2)
					minY = min(minY,y-w/2)
					m + (p._1.s -> ("goal",d.label,x,y,w,w))
				case d:WireV =>
					val w = 10
					minX = min(minX,x-w/2)
					minY = min(minY,y-w/2)
					m + (p._1.s -> ("bound","",x,y,10,10))
			}
		}.mapValues(v => {
			(v._1,v._2,v._3-minX,v._4-minY,v._5,v._6)
		})
		nodes.foreach{case (k,v) =>
			maxX = max(maxX, v._3+v._5/2)
			maxY = max(maxY, v._4+v._6/2)
		}
		val edges = graph.edata.foldLeft(Map[String,(String,String,String)]()){ (m,p) =>
			m + (p._1.s -> (p._2.value,graph.source(p._1).s,graph.target(p._1).s))
		}
		FileHelper.printToFile(new File("psgraph.svg"), append = false)(p=>{
			def printNode(id:String,typ:String,label:String,x:Int,y:Int,w:Int,h:Int) {
				p.println("\t<g transform=\"translate("+(x-w/2+20)+","+(y-h/2+20)+")\">")
				typ match {
					case "nst" =>
						p.println("\t\t<rect class=\""+typ+"\" width=\""+w+"\" height=\""+h+"\" transform=\"translate(4,4)\"></rect>")
						p.println("\t\t<rect class=\""+typ+"\" width=\""+w+"\" height=\""+h+"\"></rect>")
						p.println("\t\t<text class=\"label\" x=\""+(w/2)+"\" y=\""+(h-6)+"\">"+label+"</text>")
					case "atm" =>
						p.println("\t\t<rect class=\""+typ+"\" width=\""+w+"\" height=\""+h+"\"></rect>")
						p.println("\t\t<text class=\"label\" x=\""+(w/2)+"\" y=\""+(h-6)+"\">"+label+"</text>")
					case "id" =>
						p.println("\t\t<polygon class=\""+typ+"\" points=\"0,"+h+" "+w+","+h+" "+(w/2)+",0 0,"+h+"\"/>")
					case "bound" =>
						p.println("\t\t<rect class=\""+typ+"\" width=\""+w+"\" height=\""+h+"\"></rect>")
					case "goal" =>
						p.println("\t\t<circle class=\""+typ+"\" cx=\""+(w/2)+"\" cy=\""+(w/2)+"\" r=\""+(w/2)+"\"/>")
						p.println("\t\t<text class=\"label\" x=\""+(w/2)+"\" y=\""+(h/3*2-2)+"\">"+label+"</text>")
					case "break" =>
						var arr = Array[(Double,Double)]()
						for(i <- 0 to 7){
							arr = arr :+ Tuple2(w / 2 + (sin(2 * Pi * i / 8) * w / 2), w / 2 - (cos(2 * Pi * i / 8) * w / 2))
						}
						p.println("\t\t<polygon class=\""+typ+"\" points=\""+arr(0)._1+","+arr(0)._2+" "+arr(1)._1+","+arr(1)._2+" "+arr(2)._1+","+arr(2)._2+" "+arr(3)._1+","+arr(3)._2+" "+arr(4)._1+","+arr(4)._2+" "+arr(5)._1+","+arr(5)._2+" "+arr(6)._1+","+arr(6)._2+" "+arr(7)._1+","+arr(7)._2+" "+"\" transform=\"rotate(22.5,"+(w/2)+","+(w/2)+")\"/>")
						p.println("\t\t<text class=\"labelBreak\" x=\""+(w/2)+"\" y=\""+(h/3*2-2)+"\">"+label+"</text>")
					case _ =>
				}
				p.println("\t\t<text class=\"nodeId\" x=\"-5\" y=\"-2\">"+id+"</text>")
				p.println("\t</g>")
			}
			def printEdge(label:String, src:String, tgt:String) {
				//atan2(nodes(tgt)._4+20 - nodes(src)._4+20, nodes(tgt)._3+20 - nodes(src)._3+20))
				p.println("\t<path marker-end=\"url(#end-arrow)\" class=\"edge\" d=\"M "+(nodes(src)._3+20)+" "+(nodes(src)._4+20)+" L "+(nodes(tgt)._3+20)+" "+(nodes(tgt)._4+20)+"\"></path>")
			}
			p.println("<svg width=\""+(maxX+40)+"\" height=\""+(maxY+40)+"\">")
			p.println("\t<defs>")
			p.println("\t\t<style type=\"text/css\"><![CDATA[path{stroke:#333;}path.edge{stroke-width:2px;}text{fill:#333;font-family:Arial;}text.nodeId{font-size:9;font-weight:bold;}text.label{text-anchor:middle;font-size:14;}text.labelBreak{fill:#eee;text-anchor:middle;font-size:10;font-weight:bold;}rect{stroke-width:1px;stroke:#333;}rect.atm{fill:#89D674;}rect.nst{fill:#F7A943;}polygon{stroke-width:1px;stroke:#333;}polygon.id{fill:#6495ED;}polygon.break{fill:#FF3000;}circle{stroke-width:1px;stroke:#333;}circle.break{fill:#FF3000;}circle.goal{fill:#B0C4DE;}]]></style>")
			p.println("\t\t<marker id=\"end-arrow\" viewBox=\"0 -5 10 10\" refY=\"5\" refX=\"8\" markerWidth=\"4\" markerHeight=\"4\" orient=\"auto\">\n\t\t\t<path fill=\"#333\" d=\"M0,-5L10,0L0,5\"></path>\n\t\t</marker>")
			p.println("\t</defs>")
			edges.foreach(e => printEdge(e._2._1,e._2._2,e._2._3))
			nodes.foreach(n => printNode(n._1,n._2._1,n._2._2,n._2._3,n._2._4,n._2._5,n._2._6))
			p.println("</svg>")
		})
	}


	// --------- COPY / PASTE functions and variables ----------

	/** Map of nodes to paste. */
	private var toPasteNode:Map[VName,VData] = Map()

	/** Map of edges to paste. */
	private var toPasteEdge:Map[EName,(VName,VName,EData)] = Map()

	/** Map of atomic tactics to re-create or duplicate. */
	private var toPasteATactics:Map[String,String] = Map()

	/** Map of graph tactics to re-create, or duplicate. */
	private var toPasteGTactics:Map[String,String] = Map()

	/** Method to know if there are anything to paste. */
	def canPaste:Boolean = toPasteNode.nonEmpty

	/** Method to know if there are anything to copy. */
	def canCopy:Boolean = view.selectedVerts.nonEmpty

	/** Method copying the selected nodes. */
	def copy() {
		try {
			toPasteNode = graph.vdata.filter((x) => view.selectedVerts.contains(x._1) && (x._2 match { case d:NodeV if d.typ == "G" => false case _ => true}))
			toPasteEdge = Map()
			view.selectedVerts.foreach{ n1 =>
				view.selectedVerts.foreach { n2 =>
					toPasteEdge = toPasteEdge ++ graph.edgesBetween(n1, n2).foldLeft(Map[EName,(VName,VName,EData)]()){
						case (m,e) =>
							if(graph.source(e)==n1) m + (e -> (n1,n2,graph.edata(e)))
							else m
					}
				}
			}
			toPasteATactics = Map()
			toPasteGTactics = Map()
			for ((name, node) <- toPasteNode) {
				node match {
					case d: NodeV if d.typ == "T_Atomic" =>
						//val (tName, tArgs) = ArgumentParser.separateNameArgs(d.label)
						toPasteATactics += (d.value.stringValue ->Service.model.getTacticValue(d.value.stringValue))
					case d: NodeV if d.typ == "T_Graph" =>
						//val (tName, tArgs) = ArgumentParser.separateNameArgs(d.label)
						toPasteGTactics += (d.value.stringValue ->Service.model.getGTBranchType(d.value.stringValue))
					case _ => // do nothing
				}
			}
		} catch {
			case e: PSGraphModelException => TinkerDialog.openErrorDialog(e.msg)
		}
	}

	/** Method to paste nodes on the graph. */
	def paste() {
		var newNodeNames = Map[VName,VName]()
		for ((node,data) <- toPasteNode) {
			data match {
				case d: NodeV =>
					val vertexName = graph.verts.freshWithSuggestion(VName("v0"))
					newNodeNames = newNodeNames + (node -> vertexName)
					addVertex(vertexName, d.withCoord(d.coord._1 + 1, d.coord._2 - 1))
					if (d.typ == "T_Atomic") {
						Service.editCtrl.createTactic(vertexName.s, d.value.stringValue, toPasteATactics(d.value.stringValue), true)
					}
					if (d.typ == "T_Graph") {
						Service.editCtrl.createTactic(vertexName.s, d.value.stringValue, toPasteATactics(d.value.stringValue), false)
					}
				case d: WireV =>
					val vertexName = graph.verts.freshWithSuggestion(VName("b0"))
					newNodeNames = newNodeNames + (node -> vertexName)
					addVertex(vertexName, d.withCoord(d.coord._1 + 1, d.coord._2 - 1))
			}
		}
		for((edge,data) <- toPasteEdge) {
			val edgeName = graph.edges.freshWithSuggestion(EName("e0"))
			addEdge(edgeName,data._3,(newNodeNames(data._1),newNodeNames(data._2)))
		}
		newNodeNames.values.foreach{ v =>
			graph.vdata(v) match {
				case d:NodeV if d.typ == "G_Break" =>
					if (graph.inEdges(v).isEmpty || graph.outEdges(v).isEmpty)
						changeGraph(graph.deleteVertex(v))
				case d:WireV =>
					if (graph.inEdges(v).isEmpty && graph.outEdges(v).isEmpty)
						changeGraph(graph.deleteVertex(v))
				case _ =>
			}
		}
	}

	// --------------------------------------------------

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
		case e: MouseReleased if e.peer.getButton == 1 =>
			Service.editCtrl.mouseReleased(e.point, e.modifiers)
	}

	/** listener to view keys events */
	listenTo(view.keys)
	reactions += {
		case KeyPressed (_, (Key.Delete | Key.BackSpace), _, _) =>
			if(view.selectedVerts.nonEmpty || view.selectedEdges.nonEmpty) {
				Service.editCtrl.deleteNodes(view.selectedVerts map (v => v.s))
				view.selectedEdges.foreach { e => Service.editCtrl.deleteEdge(e.s) }
				view.repaint()
				publish(NothingSelectedEvent())
			}
		case KeyPressed(_, Key.Minus, _, _)  => zoomInGraph()
		case KeyPressed(_, Key.Equals, _, _) => zoomOutGraph()
		case KeyPressed(source, Key.C, Key.Modifier.Control, _) =>
			if(source == this.view && canCopy){
				copy()
			}
		case KeyPressed(source, Key.V, Key.Modifier.Control, _) =>
			if(source == this.view) {
				Service.editCtrl.paste
			}
		case KeyReleased(_,Key.S,_,_) =>
			Service.editCtrl.changeMouseState("select")
		case KeyReleased(_,Key.I,_,_) =>
			Service.editCtrl.changeMouseState("addIDVertex")
		case KeyReleased(_,Key.A,_,_) =>
			Service.editCtrl.changeMouseState("addATMVertex")
		case KeyReleased(_,Key.N,_,_) =>
			Service.editCtrl.changeMouseState("addNSTVertex")
		case KeyReleased(_,Key.E,_,_) =>
			Service.editCtrl.changeMouseState("addEdge")

	}
}