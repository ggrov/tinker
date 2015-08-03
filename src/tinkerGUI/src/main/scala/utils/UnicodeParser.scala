package tinkerGUI.utils

/** Object providing methods to parse certain character sequences into unicode characters and the other way around.
	*
	*/
object UnicodeParser {

	/** The parsing collection.
		* Associates a character sequence to a unicode character.
		*/
	val unicodeMap = Set[(String,String)](
		" --> " -> " \u2192 ",
		" & " -> " \u2227 "
	)

	/** Method replacing a character sequence into a unicode character in a string.
		*
		* @param s Input string.
		* @return String with some character sequences replaced into unicode characters.
		*/
	def stringToUnicode(s:String):String = {
		unicodeMap.foldLeft(s){(s,p)=>s.replace(p._1,p._2)}
	}

	/** Method replacing a unicode character into a character sequence in a string.
		*
		* @param s Input string.
		* @return String with some unicode characters replaced into character sequences.
		*/
	def unicodeToString(s:String):String = {
		unicodeMap.foldLeft(s){(s,p)=>s.replace(p._2,p._1)}
	}
}
