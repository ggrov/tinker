package tinkerGUI.controllers

import scala.swing.BorderPanel
import scala.swing.event.Event
import scala.swing.event.Key.Modifiers
import quanto.util.json.Json

case class GraphEventAPI(graph: Json) extends Event
case class DocumentStatusEventAPI(status: Boolean) extends Event
case class DocumentTitleEventAPI(title: String) extends Event
case class DocumentStatusEvent(status: Boolean) extends Event
case class DocumentTitleEvent(title: String) extends Event
case class DocumentActionStackEventAPI(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event
case class DocumentActionStackEvent(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event
case class MouseLeftPressedEvent(point: java.awt.Point, modifiers: Modifiers, clicks: Int) extends Event
case class GraphMouseDraggedEvent(point: java.awt.Point) extends Event
case class GraphMouseReleasedEvent(point: java.awt.Point, modifiers: Modifiers) extends Event
case class NothingSelectedEventAPI() extends Event
case class NothingSelectedEvent() extends Event
case class OneVertexSelectedEventAPI(name : String, typ: String, value: String) extends Event
case class OneVertexSelectedEvent(name : String, typ: String, value: String) extends Event
case class OneEdgeSelectedEventAPI(name: String, value: String, source: String, target: String) extends Event
case class OneEdgeSelectedEvent(name: String, value: String, source: String, target: String) extends Event
case class ManyVertexSelectedEventAPI(vnames : Set[String]) extends Event
case class ManyVertexSelectedEvent(vnames : Set[String]) extends Event
case class NewGraphEvent() extends Event
case class AddCrumEvent(crum: String) extends Event
case class DelCrumFromEvent(crum: String) extends Event
case class ShowPreviewEvent() extends Event
case class HidePreviewEvent() extends Event
case class HideNavigationEvent() extends Event
case class ShowNavigationEvent() extends Event
case class HierarchyTreeEvent() extends Event