package tinkerGUI.model

import quanto.util.json._
import tinkerGUI.utils.ArgumentParser

/** Tactic behaviour for having arguments.
	*
	* Arguments are used by the core of tinker during the evaluation process.
	* A tactic can have many arguments, each of them having many terms.
	* Although they are printed using a single string in the most of the application (along with the tactic name),
	* arguments are stored in a list of list of strings, easing the construction of the psgraph model.
	* See [[tinkerGUI.utils.ArgumentParser]] for details on how arguments are constructed.
	*/
trait HasArguments {

	/** Argument list of a tactic */
	var args: Array[Array[String]] = Array()

	/** Method adding one argument in the list of arguments.
		*
		* @param a Argument to add.
		*/
	def addArgument(a: Array[String]){
		args = args :+ a
	}

	/** Method to generate a Json representation of the arguments of a tactic.
		*
		* @return Json array of the arguments of a tactic.
		*/
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
		JsonArray(arr2)
	}

	/** Method to generate a string of the arguments of a tactic.
		*
		* @return String representation of the arguments.
		*/
	def argumentsToString(): String = ArgumentParser.argumentsToString(args)

	/** Method to replace the arguments of a tactic with new ones.
		*
		* @param newArgs The new arguments of the tactic.
		*/
	def replaceArguments(newArgs:Array[Array[String]]) {
		args = newArgs
	}

	/** Method to replace the arguments of a tactic with new ones.
		*
		* @param newArgs The new arguments of the tactic, in a string format.
		*/
	def replaceArguments(newArgs:String) {
		args = ArgumentParser.stringToArguments(newArgs)
	}

	/** Method to remove all the arguments of a tactic.
		* 
		*/
	def eraseArguments() {
		args = Array()
	}
}