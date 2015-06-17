package tinkerGUI.controllers

import scala.swing.Component
import scala.swing.BorderPanel
import scala.swing.event.Event
import scala.swing.event.Key.Modifiers
import quanto.util.json.Json
import scala.collection.mutable.ArrayBuffer

// events launched by Service.scala
/** Event when the graph tactic list is changed. */
case class GraphTacticListEvent() extends Event

// events launched by GraphInspectorController.scala
case class ShowPreviewEvent(hasSubgraph:Boolean) extends Event
case class UpdateSelectedTacticToInspectEvent(tactic:String) extends Event
case class HidePreviewEvent() extends Event
case class UpdateGTListEvent() extends Event
case class DisableNavigationEvent(a:Array[String]) extends Event

case class DocumentSaved() extends Event
case class DocumentChanged() extends Event
case class DocumentStatusEvent(status: Boolean) extends Event
case class DocumentTitleEvent(title: String) extends Event
case class DocumentActionStackEventAPI(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event
case class DocumentActionStackEvent(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event
case class MouseLeftPressedEvent(point: java.awt.Point, modifiers: Modifiers, clicks: Int) extends Event

case class GraphEventAPI(graph: Json) extends Event
case class MouseRightPressedEvent(point: java.awt.Point, modifiers: Modifiers, clicks: Int, source: Component) extends Event
case class GraphMouseDraggedEvent(point: java.awt.Point) extends Event
case class GraphMouseReleasedEvent(point: java.awt.Point, modifiers: Modifiers) extends Event
// TODO since controllers will be less used, check if two separate type of events are necessary
case class NothingSelectedEventAPI() extends Event
case class NothingSelectedEvent() extends Event
case class OneVertexSelectedEventAPI(name : String, typ: String, value: String) extends Event
case class OneVertexSelectedEvent(name : String, typ: String, value: String) extends Event
case class OneEdgeSelectedEventAPI(name: String, value: String, source: String, target: String) extends Event
case class OneEdgeSelectedEvent(name: String, value: String, source: String, target: String) extends Event
case class ManyVerticesSelectedEventAPI(vnames : Set[String]) extends Event
case class ManyVertexSelectedEvent(vnames : Set[String]) extends Event

case class NewGraphEvent() extends Event
case class AddCrumbEvent(crum: String) extends Event
case class DelCrumFromEvent(crum: String) extends Event
case class HideNavigationEvent() extends Event
case class ShowNavigationEvent() extends Event
case class HierarchyTreeEvent() extends Event
case class RebuildBreadcrumbParentEvent(p: Array[String]) extends Event

case class EnableEvalOptionsEvent(a:ArrayBuffer[String]) extends Event
case class DisableEvalOptionsEvent() extends Event
case class EvalOptionSelectedEvent(o:String, n:String) extends Event
case class UserSelectedEvalOptionEvent(o:String, n:String) extends Event
