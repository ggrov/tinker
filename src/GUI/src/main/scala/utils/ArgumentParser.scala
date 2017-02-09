package tinkerGUI.utils

import java.util.regex.Pattern

import quanto.util.json.{JsonString, JsonArray}

/** Object providing methods to parse tactic arguments.
	*
	* It can parse from a string to an array of array of string and the other way around.
	* This format (array of array of string) is what the format used by tinker core.
	* Also it extends this parsing to Json arrays (to append them in json messages).
	* Finally it provides a function to separate the tactic name from its arguments.
	*/
object ArgumentParser {

	/** Method separating a tactic name from its arguments.
		*
		* @param s Full name, often entered by the user during graph edition.
		* @return Pair of strings, one for the tactic name, the other for its arguments.
		*/
	def separateNameArgs(s: String): (String, String) = {
		if(s.contains("(") && s.charAt(0) != '?'){
			val parts = s.split(Pattern.quote("("),2)
			var args = ""
			if(parts.size > 1){
				if(parts(1).charAt(parts(1).length-1).equals(')')){
					args = parts(1).substring(0, parts(1).length-1)
				}
				else { args = parts(1)}
			}
			(removeUselessSpace(parts(0)), removeUselessSpace(args))
		}
		else (s, "")
	}

	/** Method to parse arguments from a string to an array of array of string.
		*
		* Typically :
		*
		* "X: Y Z, A: B, C" becomes [ [ "X", "Y", "Z" ], [ "A", "B" ], [ "C" ] ].
		*
		* Note that variable X above (for instance) can be of type : "[i,j,..]", "{i,j,..}", "(i,j,..)", " "i,j,.." " or simply " i ".
		*
		* @param s Arguments in a string format.
		* @return Arguments in a array of array of string format.
		*/
	def stringToArguments(s: String): Array[Array[String]] = {
		var arguments = Array[Array[String]]()

		var openBrackets:Int = 0
		var openSquareBrackets:Int = 0
		var openCurlyBrackets:Int = 0
		var quotes:Int = 0

		def parseArguments(fullString:String,temporaryString:String) {
			var tmpString = temporaryString
			if(fullString.nonEmpty) {
				fullString.charAt(0) match {
					case ',' =>
						if (openBrackets == 0 && openCurlyBrackets == 0 && openSquareBrackets == 0 && quotes%2 == 0) {
							arguments = arguments :+ stringToArgument(removeUselessSpace(tmpString))
							parseArguments(fullString.substring(1), "")
						} else {
							tmpString += fullString.charAt(0)
							parseArguments(fullString.substring(1), tmpString)
						}
					case '[' =>
						tmpString += fullString.charAt(0)
						openSquareBrackets += 1
						parseArguments(fullString.substring(1), tmpString)
					case '{' =>
						tmpString += fullString.charAt(0)
						openCurlyBrackets += 1
						parseArguments(fullString.substring(1), tmpString)
					case '(' =>
						tmpString += fullString.charAt(0)
						openBrackets += 1
						parseArguments(fullString.substring(1), tmpString)
					case '"' =>
						tmpString += fullString.charAt(0)
						quotes += 1
						parseArguments(fullString.substring(1), tmpString)
					case ']' =>
						tmpString += fullString.charAt(0)
						openSquareBrackets -= 1
						parseArguments(fullString.substring(1), tmpString)
					case '}' =>
						tmpString += fullString.charAt(0)
						openCurlyBrackets -= 1
						parseArguments(fullString.substring(1), tmpString)
					case ')' =>
						tmpString += fullString.charAt(0)
						openBrackets -= 1
						parseArguments(fullString.substring(1), tmpString)
					case _ =>
						tmpString += fullString.charAt(0)
						parseArguments(fullString.substring(1), tmpString)
				}
			} else {
				if(temporaryString.nonEmpty) {
					arguments = arguments :+ stringToArgument(removeUselessSpace(temporaryString))
				}
				if(openBrackets > 0) TinkerDialog.openErrorDialog("Error while parsing arguments, ' ) ' missing.")
				else if(openBrackets < 0) TinkerDialog.openErrorDialog("Error while parsing arguments, ' ( ' missing.")
				if(openSquareBrackets > 0) TinkerDialog.openErrorDialog("Error while parsing arguments, ' ] ' missing.")
				else if(openSquareBrackets < 0) TinkerDialog.openErrorDialog("Error while parsing arguments, ' [ ' missing.")
				if(openCurlyBrackets > 0) TinkerDialog.openErrorDialog("Error while parsing arguments, ' } ' missing.")
				else if(openCurlyBrackets > 0) TinkerDialog.openErrorDialog("Error while parsing arguments, ' { ' missing.")
				if(quotes%2 > 0) TinkerDialog.openErrorDialog("Error while parsing arguments, ' \" ' missing.")
				// should check openbrackets
			}
		}
		parseArguments(s,"")
		arguments
	}

	/** Method to parse a single argument from a string to a an array of string.
		*
		* Typically :
		*
		* "X: Y Z" becomes [ "X", "Y", "Z" ] , "A: B" becomes [ "A", "B" ] and "C" becomes [ "C" ]
		*
		* Note that variable X above (for instance) can be of type : "[i,j,..]", "{i,j,..}", "(i,j,..)", " "i,j,.." " or simply " i ".
		*
		* @param s Argument in a string format.
		* @return Argument in a array of string format.
		*/
	private def stringToArgument(s: String): Array[String] = {
		var res = Array[String]()
		if(s.contains(":")){
			val parts = s.split(":")
			parts.size match {
				case 1 => res = res :+ removeUselessSpace(parts(0))
				case 2 => 
					res = res :+ removeUselessSpace(parts(0))
					res = res ++ stringToArgumentParameters(removeUselessSpace(parts(1)))
				case x if x > 2 || x < 1 =>
					TinkerDialog.openErrorDialog("Error when parsing arguments, found more than one colon in one argument, you probably forgot a comma to separate two arguments.")
					res = res :+ removeUselessSpace(parts(0))
					res = res ++ stringToArgumentParameters(removeUselessSpace(parts(1)))
			}
		}
		else { res = res :+ s }
		res
	}

	/** Method to parse argument's parameters from a string to an array of string.
		*
		* @param s Argument's parameters in a string format.
		* @return Argument's parameters in an array of string format.
		*/
	private def stringToArgumentParameters(s: String): Array[String] = {
		var res = Array[String]()
		if(s.contains(" ")){
			val parts = s.split(" ")
			parts.foreach {p =>
				if(p != "") res = res :+ p
			}
		}
		else{ res = res :+ s }
		res
	}

	/** Method to remove space ahead and at the end of a string.
		*
		* @param s String with spaces.
		* @return String without spaces.
		*/
	private def removeUselessSpace(s: String): String = {
		var res = s
		if(res.length > 0 && res.head.equals(' ')) res = removeUselessSpace(res.tail)
		if(res.length > 0 && res.charAt(res.length-1).equals(' ')) res = removeUselessSpace(res.substring(0, res.length-1))
		res
	}

	/** Method to parse arguments from an array of array of string to a string.
		*
		* Typically :
		*
		* [ [ "X", "Y", "Z" ], [ "A", "B" ], [ "C" ] ] becomes "X: Y Z, A: B, C"
		*
		* @param args Arguments in a array of array of string format.
		* @return Arguments in a string format.
		*/
	def argumentsToString(args: Array[Array[String]]): String = {
		var res = ""
		if(args.size > 0){
			res = args.foldLeft(""){case(s,a) => s + argumentToString(a) + ", "}
			res = res.substring(0, res.length-2)
		}
		res
	}

	/** Method to parse a single argument from an array of string to a string.
		*
		* Typically :
		*
		* [ "X", "Y", "Z" ] becomes "X: Y Z", [ "A", "B" ] becomes "A: B" and [ "C" ] becomes "C"
		*
		* @param arg Argument in array of string format.
		* @return Argument in a string format.
		*/
	private def argumentToString(arg: Array[String]): String = {
		var res = ""
		if(arg.size > 0) res += arg.head+" "
		if(arg.size > 1){
			res += ": "
			arg.tail.foreach{ a =>
				res += a+" "
			}
		}
		if(arg.size > 0) res = res.substring(0, res.length-1)
		res
	}

	/** Method parsing a argument string into a JsonArray.
		*
		* @param s Arguments in string format.
		* @return Arguments in json format.
		*/
	def argStringToJson(s:String):JsonArray = {
		var arr1 = Array[JsonArray]()
		var arr2 = Array[JsonString]()
		stringToArguments(s).foreach{ arg =>
			arr2 = Array()
			arg.foreach{str =>
				arr2 = arr2 :+ JsonString(str)
			}
			arr1 = arr1 :+ JsonArray(arr2)
		}
		JsonArray(arr1)
	}

	/** Method parsing a JsonArray into a argument string.
		*
		* @param j Arguments in json format.
		* @return Arguments in string format.
		*/
	def jsonToArgString(j:JsonArray):String = {
		var args = Array[Array[String]]()
		j.foreach{ a =>
			var arg = Array[String]()
			a.asArray.foreach{ s => arg = arg :+ s.stringValue}
			args = args :+ arg
		}
		argumentsToString(args)
	}

}