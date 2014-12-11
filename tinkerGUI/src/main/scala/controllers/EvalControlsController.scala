package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.ButtonClicked
import scala.collection.mutable.ArrayBuffer

class EvalControlsController() extends Publisher {
	var evalOptions = ArrayBuffer[String]()
	var optionsEnabled = false

	def enableOptions(v:ArrayBuffer[String]){
		evalOptions = v
		optionsEnabled = true
	}

	def disableOptions{
		optionsEnabled = false
		publish(DisableEvalOptionsEvent())
	}

	def selectOption(o:String){
		disableOptions
		publish(EvalOptionSelectedEvent(o))
	}

	listenTo(QuantoLibAPI)
	reactions+={
		case OneVertexSelectedEventAPI(name, typ, _) =>
			if(optionsEnabled && QuantoLibAPI.hasGoalsBefore(name)){
				var options = evalOptions
				typ match {
					case "RT_NST" =>
						options = options :+ "stepInto"
						options = options :+ "stepOver"
				}
				publish(EnableEvalOptionsEvent(options))
			}
		case NothingSelectedEventAPI() =>
			publish(DisableEvalOptionsEvent())
	}
}