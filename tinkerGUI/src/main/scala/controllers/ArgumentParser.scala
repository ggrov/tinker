package tinkerGUI.controllers

object ArgumentParser {
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
					println("ERROR !!!")
					return Array[String]()
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
		if(res.length > 0 && res.head.equals(' ')) res = res.tail
		if(res.length > 0 && res.charAt(res.length-1).equals(' ')) res = res.substring(0, res.length-2)
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
		res += arg.head+": "
		if(arg.size > 1){
			arg.tail.foreach{ a =>
				res += a+" "
			}
		}
		res = res.substring(0, res.length-1)
		return res
	}

}