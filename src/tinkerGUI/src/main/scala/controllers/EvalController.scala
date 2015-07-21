package tinkerGUI.controllers

import quanto.util.json._
import tinkerGUI.controllers.events._
import tinkerGUI.model.PSGraph
import tinkerGUI.model.exceptions.{PSGraphModelException, GraphTacticNotFoundException}
import tinkerGUI.utils.TinkerDialog

import scala.collection.mutable
import scala.collection.mutable.{ArrayBuffer}
import scala.swing.Publisher


class EvalLogController extends Publisher {
	val stack = mutable.ArrayStack[(String,String)]()

	var filter = ArrayBuffer[String]()

	def addToFilter(s:String) {
		if(!filter.contains(s)) filter += s
		publish(EvalLogEvent())
	}

	def removeFromFilter(s:String) {
		if(filter.contains(s)) filter -= s
		publish(EvalLogEvent())
	}

	def getLog:String = {
		stack.foldRight(""){
			case (p,s) =>
				if(filter contains p._1) s + " > " + p._1 + " : " + p._2 + "\n"
				else s
		}
	}

	def addToLog(j:JsonObject) {
		j.foreach{
			case(k,v:JsonArray) =>
				v.vectorValue.foreach{
					case s:JsonString =>
						stack.push((k,s.stringValue))
					case _ =>
				}
			case _ =>
		}
		println(stack.foldLeft(""){ case (s,p) => s + p._1 + " - " + p._2 + "\n"})
		publish(EvalLogEvent())
	}
}


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

	/** Array of tactics representing the current evalPath. */
	var evalPath = Array[String]()

	/** Temporary eval psgraph, given by the core, used to refresh the model if changes were not approved by the core. */
	var tmpEvalPSGraph = JsonObject()

	/** Eval log controller. */
	val evalLogCtrl = new EvalLogController

	/** Method to switch evaluation state.
		*
		* Notifies if some views should disable some options.
		* @param b New value of inEval.
		*/
	def setInEval(b:Boolean) {
		inEval = b
		if(!b) {
			publish(DisableEvalOptionsEvent())
			QuantoLibAPI.loadFromJson(model.getCurrentJson)
		} else {
			Service.editCtrl.changeMouseState("select")
		}
	}

	/** Method saving the eval path from the model.*/
	def saveEvalPath() {
		evalPath = model.currentParents :+ model.getCurrentGTName
	}

	/** Method displaying an evaluation graph.
		*
		* @param tactic Id of the current tactic, used to change it in the model.
		* @param index Index of the current subgraph, used to change it in the model.
		* @param parents List of parents of the graph
		*/
	def displayEvalGraph(tactic:String, index:Int, parents:Array[String]) {
	 try{
		 model.changeCurrent(tactic,index,Some(parents))
		 //DocumentService.setUnsavedChanges(true)
		 QuantoLibAPI.loadFromJson(model.getCurrentJson)
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
	def loadJson(j:JsonObject) {
		if(!j.isEmpty){
			try{
				model.loadJsonGraph(j)
				publish(GraphTacticListEvent())
				publish(CurrentGraphChangedEvent(model.getCurrentGTName,Some(Service.hierarchyCtrl.elementParents(model.getCurrentGTName))))
				Service.graphNavCtrl.viewedGraphChanged(model.isMain, false)
				QuantoLibAPI.loadFromJson(model.getCurrentJson)
				saveEvalPath()
			} catch {
				case e:PSGraphModelException => TinkerDialog.openErrorDialog(e.msg)
				case e:JsonAccessException => TinkerDialog.openErrorDialog(e.getMessage)
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
		selectedNode = ""
		o match {
			case "PUSH" =>
				model.updateJsonPSGraph()
				CommunicationService.sendPSGraphChange(model.jsonPSGraph,JsonArray(evalPath.reverse))
			case "PULL" =>
				loadJson(tmpEvalPSGraph)
			case _ =>
				publish(EvalOptionSelectedEvent(o, selectedNode))
		}
	}

	listenTo(QuantoLibAPI)
	reactions+={
		case OneVertexSelectedEvent(name, typ, _, _) =>
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
