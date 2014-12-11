package tinkerGUI.controllers

import scala.swing._
import scala.swing.event.ButtonClicked
import scala.collection.mutable.ArrayBuffer

class EvalControlsController() extends Publisher {
	var evalOptions = ArrayBuffer[String]()
	// var selected:String = ""
	def enableOptions(v:ArrayBuffer[String]){
		evalOptions = v
		// selected = ""
		publish(EnableEvalOptionsEvent(evalOptions))
	}

	def disableOptions{
		publish(DisableEvalOptionsEvent())
	}

	def selectOption(o:String){
		disableOptions
		// selected = o
		publish(EvalOptionSelectedEvent(o))
	}
}