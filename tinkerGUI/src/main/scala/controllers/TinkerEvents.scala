package tinkerGUI.controllers

import scala.swing.Component
import scala.swing.BorderPanel
import scala.swing.event.Event
import scala.swing.event.Key.Modifiers
import quanto.util.json.Json
import scala.collection.mutable.ArrayBuffer

// events launched by Service.scala

// events launched by GraphInspectorController.scala
case class ShowPreviewEvent(hasSubgraph:Boolean) extends Event
case class UpdateSelectedTacticToInspectEvent(tactic:String) extends Event
case class HidePreviewEvent() extends Event
case class UpdateGTListEvent() extends Event
case class DisableNavigationEvent(a:Array[String]) extends Event

case class GraphEventAPI(graph: Json) extends Event
// TODO since controllers will be less used, check if two separate type of events are necessary


case class NewGraphEvent() extends Event
case class HideNavigationEvent() extends Event
case class ShowNavigationEvent() extends Event
case class HierarchyTreeEvent() extends Event
