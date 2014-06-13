package tinkerGUI.controllers

import scala.swing.event.Event

case class DocumentStatusEventAPI(status: Boolean) extends Event
case class DocumentStatusEvent(status: Boolean) extends Event
case class DocumentActionStackEventAPI(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event
case class DocumentActionStackEvent(canUndo: Boolean, canRedo: Boolean, undoActionName: String, redoActionName: String) extends Event