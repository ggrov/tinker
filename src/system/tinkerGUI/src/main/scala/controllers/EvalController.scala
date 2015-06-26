package tinkerGUI.controllers

import quanto.util.json.{Json, JsonObject}
import tinkerGUI.controllers.events._
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{SubgraphNotFoundException, AtomicTacticNotFoundException, GraphTacticNotFoundException}
import tinkerGUI.utils.TinkerDialog

import scala.collection.mutable.ArrayBuffer
import scala.swing.Publisher

/** Controller managing the evaluation process of a psgraph.
	*
	* @param model Psgraph model.
	*/
class EvalController(model:PSGraph) extends Publisher {

	/** Boolean stating if the application is performing an evaluation or not.*/
	var inEval:Boolean = false

	/** List of the evaluation options available to the user.*/
	var evalOptions = ArrayBuffer[String]()

	/** Node selected by the user during evaluation, should be of type goal or breakpoint.*/
	var selectedNode : String = ""

	/** Method to switch evaluation state.
		*
		* Notifies if some views should disable some options.
		* @param b New value of inEval.
		*/
	def setInEval(b:Boolean) {
		inEval = b
		publish(DisableActionsForEvalEvent(inEval))
	}

	/** Method displaying an evaluation graph.
		*
		* @param tactic Id of the current tactic, used to change it in the model.
		* @param index Index of the current subgraph, used to change it in the model.
		* @param j Json object of the graph to display.
		* @param parents List of parents of the graph
		*/
	def displayEvalGraph(tactic:String, index:Int, j:JsonObject, parents:Array[String]) {
	 try{
		 model.changeCurrent(tactic,index,Some(parents))
		 //DocumentService.setUnsavedChanges(true)
		 QuantoLibAPI.loadFromJson(j)
		 Service.graphNavCtrl.viewedGraphChanged(model.isMain,false)
		 publish(CurrentGraphChangedEvent(tactic,Some(parents)))
	 } catch {
		 case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
	 }
	}

	/** Method loading a new model from a json object.
		*
		* @param j Json object of the new model.
		*/
	def loadJson(j:Json) {
		if(!j.isEmpty){
			try{
				model.loadJsonGraph(j)
				publish(GraphTacticListEvent())
				publish(CurrentGraphChangedEvent(model.getCurrentGTName,Some(Service.hierarchyCtrl.elementParents(model.getCurrentGTName))))
				Service.graphNavCtrl.viewedGraphChanged(model.isMain, false)
				QuantoLibAPI.loadFromJson(model.getCurrentJson)
			} catch {
				case e:GraphTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				case e:AtomicTacticNotFoundException => TinkerDialog.openErrorDialog(e.msg)
				case e:SubgraphNotFoundException => TinkerDialog.openErrorDialog(e.msg)
			}
		} else {
			TinkerDialog.openErrorDialog("<html>Error while loading json from file : object is empty.</html>")
		}
	}

	/** Method enabling evaluation options to the user.
		*
		* @param o Evaluation options available.
		*/
	def enableEvalOptions(o:ArrayBuffer[String]) {
		evalOptions = o
		publish(EnableEvalOptionsEvent(evalOptions))
	}

	/** Method handling the selection of an evaluation option by the user.
		*
		* @param o Selected evaluation option.
		*/
	def selectEvalOption(o:String){
		publish(DisableEvalOptionsEvent())
		publish(EvalOptionSelectedEvent(o, selectedNode))
	}

	listenTo(QuantoLibAPI)
	reactions+={
		case OneVertexSelectedEvent(name, typ, _) =>
			if(inEval){
				var options = evalOptions
				selectedNode = ""
				typ match {
					case "G" =>
						selectedNode = name
						if(QuantoLibAPI.hasNestedTacticAfter(name) && (options contains "OPT_EVAL_NEXT")){
							options = options :+ "OPT_EVAL_STEP_INTO"
							options = options :+ "OPT_EVAL_STEP_OVER"
						}
					case "G_Break" =>
						selectedNode = name;
					case _ => // other type of nodes
				}
				publish(EnableEvalOptionsEvent(options))
			}
		case NothingSelectedEvent() =>
			if(inEval){
				selectedNode = ""
				publish(EnableEvalOptionsEvent(evalOptions))
			}
	}
}
