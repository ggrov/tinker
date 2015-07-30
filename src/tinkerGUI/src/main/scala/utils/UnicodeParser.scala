package tinkerGUI.utils

/** Object parsing certain strings to unicode characters.
	*
	*/
object UnicodeParser {

	val unicodeMap = Map[String,String](
		" --> " -> " \u2192 ",
		" & " -> " \u2227 "
	)

	def stringToUnicode(s:String):String = {
		var res = s
		unicodeMap.foreach{ case (k,v) =>
			res = res.replace(k,v)
		}
		res
	}

	def unicodeToString(s:String):String = {
		var res = s
		unicodeMap.foreach{ case (k,v) =>
			res = res.replace(v,k)
		}
		res
	}
}
