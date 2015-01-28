package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.ButtonClicked
import scala.collection.mutable.ArrayBuffer

class EvalControlsController() extends Publisher {
	var evalOptions = ArrayBuffer[String]()
	var optionsEnabled = false
	var selectedNode : String = "";

	def enableOptions(v:ArrayBuffer[String]){
		evalOptions = v
		optionsEnabled = true
		publish(EnableEvalOptionsEvent(evalOptions))
	}

	def disableOptions{
		optionsEnabled = false
		publish(DisableEvalOptionsEvent())
	}

	def selectOption(o:String){
		disableOptions
		publish(EvalOptionSelectedEvent(o, selectedNode))
	}

	listenTo(QuantoLibAPI)
	reactions+={
		case OneVertexSelectedEventAPI(name, typ, _) =>
			if(optionsEnabled){
				var options = evalOptions;
				selectedNode = "";
				typ match {
					case "G" =>
						selectedNode = name;
						if(QuantoLibAPI.hasNestedTacticAfter(name)){
							options.foreach{o =>
								if(o=="OPT_EVAL_NEXT"){
									options = options :+ "OPT_EVAL_STEP_INTO"
									options = options :+ "OPT_EVAL_STEP_OVER"
								}
							}
						}
					case "G_Break" =>
						selectedNode = name;
					case _ => // other type of nodes
				}
				publish(EnableEvalOptionsEvent(options))
			}

		case NothingSelectedEventAPI() =>
			if(optionsEnabled){
				var options = evalOptions;
				selectedNode = "";
				publish(EnableEvalOptionsEvent(options))
			}
	}
}