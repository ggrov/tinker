package tinkerGUI.controllers

import scala.swing.event.Event
import scala.swing.event.Key.Modifiers

case class DocumentStatusEventAPI(status: Boolean) extends Event
case class DocumentTitleEventAPI(title: String) extends Event
case class DocumentStatusEvent(status: Boolean) extends Event
case class DocumentTitleEvent(title: String) extends Event
case class DocumentActionStackEventAPI(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event
case class DocumentActionStackEvent(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event
case class GraphMousePressedEvent(point: java.awt.Point, modifiers: Modifiers, clicks: Int) extends Event
case class GraphMouseDraggedEvent(point: java.awt.Point) extends Event
case class GraphMouseReleasedEvent(point: java.awt.Point, modifiers: Modifiers) extends Event