package tinkerGUI.model

import quanto.util.json._
import tinkerGUI.utils.ArgumentParser

trait HasArguments {
	var args: Array[Array[String]] = Array()

	def addArgument(a: Array[String]){
		args = args :+ a
	}

	def argumentsToJson(): JsonArray = {
		var arr1: Array[JsonString] = Array()
		var arr2: Array[JsonArray] = Array()
		args.foreach { arg =>
			arg.foreach { s =>
				arr1 = arr1 :+ JsonString(s)
			}
			arr2 = arr2 :+ JsonArray(arr1)
			arr1 = Array()
		}
		return JsonArray(arr2)
	}

	def argumentsToString(): String = ArgumentParser.argumentsToString(args)

	def updateArguments(newArgs:Array[Array[String]]) {
		args = newArgs
	}

	def eraseArguments() {
		args = Array()
	}
}