package tinkerGUI.controllers.events

import scala.collection.mutable.ArrayBuffer
import scala.swing.event.Event

// Launched by EditController, DocumentController and EvalController
/** Event notifying of a change in a graph tactic list.
  *
  */
case class GraphTacticListEvent() extends Event

/** Event notifying of a new graph being edited.
	*
	* @param current New current graph.
	* @param parents Optional list of parents (if we want to rebuild the list).
	*/
case class CurrentGraphChangedEvent(current:String, parents:Option[Array[String]]) extends Event

// Launched by HierarchyController
/** Event for redrawing the hierarchy tree.
  *
  */
case class RedrawHierarchyTreeEvent() extends Event

// Launched by QuantoLibAPI
/** Event notifying of an empty node/edge selection.
  *
  */
case class NothingSelectedEvent() extends Event

/** Event notifying of a selection containing one vertex.
	*
	* @param name Node id.
	* @param typ Node type.
	* @param value Node value/label.
	*/
case class OneVertexSelectedEvent(name : String, typ: String, label: String, value:String) extends Event

/** Event notifying of a selection containing one edge.
	*
	* @param name Edge id.
	* @param value Edge value/label.
	* @param source Edge source.
	* @param target Edge target.
	*/
case class OneEdgeSelectedEvent(name: String, value: String, source: String, target: String) extends Event

/** Event notifying of a selection containing multiple vertices.
	*
	* @param vnames Nodes ids.
	*/
case class ManyVerticesSelectedEvent(vnames : Set[String]) extends Event

//Launched by EvalController
/** Event to enable evaluation options.
	*
	* @param a List of available options.
	*/
case class EnableEvalOptionsEvent(a:ArrayBuffer[String]) extends Event

/** Even to disable evaluation options.
  *
  */
case class DisableEvalOptionsEvent() extends Event

/** Event notifying of the selection of an evaluation option by the user.
	*
	* @param o Option selected.
	* @param n Potential node selected.
	*/
case class EvalOptionSelectedEvent(o:String, n:String) extends Event

// Launched by DocumentController
/** Event notifying of changes in the document.
	*
	* @param unsavedChanges Boolean for unsaved changes.
	*/
case class DocumentChangedEvent(unsavedChanges:Boolean) extends Event

// Launched by CommunicationService
/** Event notifying of a connection established or lost with core.
	*
	* @param connected Boolean for connection status.
	* @param connecting Boolean for connecting status, in case connected in false.
	*/
case class ConnectedToCoreEvent(connected:Boolean, connecting:Boolean) extends Event

// Launched by InspectorController and LibraryController
/** Event notifying of a preview to show or hide.
	*
	* @param show Boolean stating if view should show or hide preview.
	* @param hasPreview Boolean stating if there is graph to show, typically a subgraph can be
	*                   empty therefore the view should display a message instead.
	*/
case class PreviewEvent(show:Boolean, hasPreview:Boolean) extends Event

// Launched by InspectorController
/** Event notifying of a new tactic to inspect.
	*
	* @param tactic Tactic id.
	*/
case class UpdateSelectedTacticToInspectEvent(tactic:String) extends Event

/** Event to change the tactic list ot inspect.
	*
	*/
case class UpdateGTListEvent() extends Event

/** Event to enable/disable navigation options.
	*
	* @param a List of option to disable.
	*/
case class DisableNavigationEvent(a:Array[String]) extends Event

/** Event to enable/disable lock.
	*
	* @param l Lock boolean.
	*/
case class InspectorLockEvent(l:Boolean) extends Event

// launched by edit controller
/** Event notifying of a change of mouse state.
	*
	*/
case class MouseStateChangedEvent(state:String) extends Event

// launched by record controller
/** Event notifying of file setup for recording.
  *
  * @param setup If record file is correctly setup.
  */
case class RecordFileSetupEvent(setup:Boolean) extends Event

/** Event notifying of record started / stopped.
  *
  * @param recording If currently recording.
  */
case class RecordStartStopEvent(recording:Boolean) extends Event