package tinkerGUI.utils

import java.util.regex.Pattern
import tinkerGUI.controllers.TinkerDialog

object ArgumentParser {

	def separateNameFromArgument(s: String): (String, String) = {
		if(s.contains("(")){
			val parts = s.split(Pattern.quote("("))
			var args = ""
			if(parts.size > 1){
				if(parts(1).charAt(parts(1).length-1).equals(')')){
					args = parts(1).substring(0, parts(1).length-1)
				}
				else { args = parts(1)}
			}
			return(removeUselessSpace(parts(0)), removeUselessSpace(args))
		}
		else return (s, "")
	}

	def stringToArguments(s: String): Array[Array[String]] = {
		var res = Array[Array[String]]()
		if(s.contains(",")){
			val parts = s.split(",")
			parts.foreach {p =>
				res = res :+ stringToArgument(removeUselessSpace(p))
			}
		}
		else { res = res :+ stringToArgument(s) }
		return res
	}

	def stringToArgument(s: String): Array[String] = {
		var res = Array[String]()
		if(s.contains(":")){
			val parts = s.split(":")
			parts.size match {
				case 1 => res = res :+ removeUselessSpace(parts(0))
				case 2 => 
					res = res :+ removeUselessSpace(parts(0))
					res = res ++ stringToArgumentParameters(removeUselessSpace(parts(1)))
				case x if(x > 2 || x < 1) => 
					TinkerDialog.openErrorDialog("<html>Error when parsing arguments, found more than one colon in one argument,<br> you probably forgot a comma to separate two arguments.</html>")
					res = res :+ removeUselessSpace(parts(0))
					res = res ++ stringToArgumentParameters(removeUselessSpace(parts(1)))
			}
		}
		else { res = res :+ s }
		return res
	}

	def stringToArgumentParameters(s: String): Array[String] = {
		var res = Array[String]()
		if(s.contains(" ")){
			val parts = s.split(" ")
			parts.foreach {p =>
				if(p != "") res = res :+ p
			}
		}
		else{ res = res :+ s }
		return res
	}

	def removeUselessSpace(s: String): String = {
		var res = s
		if(res.length > 0 && res.head.equals(' ')) res = removeUselessSpace(res.tail)
		if(res.length > 0 && res.charAt(res.length-1).equals(' ')) res = removeUselessSpace(res.substring(0, res.length-1))
		return res
	}

	def argumentsToString(args: Array[Array[String]]): String = {
		var res = ""
		if(args.size > 0){
			args.foreach{ a => 
				res += argumentToString(a)+", "
			}
			res = res.substring(0, res.length-2)
		}
		return res
	}

	def argumentToString(arg: Array[String]): String = {
		var res = ""
		if(arg.size > 0) res += arg.head+" "
		if(arg.size > 1){
			res += ": "
			arg.tail.foreach{ a =>
				res += a+" "
			}
		}
		if(arg.size > 0) res = res.substring(0, res.length-1)
		return res
	}

}