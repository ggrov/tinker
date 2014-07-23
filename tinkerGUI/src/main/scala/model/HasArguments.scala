package tinkerGUI.model

import quanto.util.json._

trait HasArguments {
	var arg: Array[Argument] = Array()

	def argumentsToArrays : Array[Array[String]] = {
		var res = Array[Array[String]]()
		arg.foreach{a =>
			res = res :+ a.arg
		}
		return res
	}

	def addArgument(a: Argument){
		arg = arg :+ a
	}

	def addArgument(a: Array[String]){
		addArgument(new Argument(a))
	}

	def argumentsToJson(): JsonArray = {
		var arg2: Array[JsonArray] = Array()
		arg.foreach { a =>
			arg2 = arg2 :+ a.toJsonArray
		}
		return JsonArray(arg2)
	}

	def eraseArguments() {
		arg = Array()
	}
}