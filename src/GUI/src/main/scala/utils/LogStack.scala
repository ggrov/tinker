package tinkerGUI.utils

import java.awt.{Dimension, Font}

//import tinkerGUI.utils.LogStack.logFrame._

import scala.collection.mutable
import scala.swing._

/** Class representing a stack of messages used for a log system.
	*
	* Comes with a Swing frame component (to print the messages).
	*
	* ==Usage :==
	* {{{
	*   import tinkerGUI.utils.LogStack
	*   ...
	*   val myLogStack = new LogStack
	*   ...
	*   myLogStack.openFrame("My app - log") // open the frame
	*   ...
	*   mylogStack.add("Hello World") // add a single message
	*   mylogStack.add(Array("Foo","Bar")) // add a set of messages
	*   ...
	* }}}
	*
	*/
class LogStack {

	/** The actual stack containing the messages.*/
	private val stack = mutable.ArrayBuffer[String]()

	/** The frame object.*/
	private object logFrame extends Frame{
		val messages = new TextArea(){
			lineWrap = true
			editable = false
			font = new Font(Font.MONOSPACED,Font.BOLD,14)
			text = getLog
		}
		menuBar = new MenuBar(){
			val options = new Menu("Options"){ menu =>
				new Action("Clear"){
					menu.contents += new MenuItem(this)
					def apply() = clearStack()
				}
			}
			contents += options
		}
		def updateText() = {messages.text = getLog}
		minimumSize = new Dimension(250,250)
		preferredSize = new Dimension(500,350)
		contents = new ScrollPane(messages)
	}

	/** Method to get the logs in a single string.*/
	private def getLog:String = {
		stack.foldLeft(""){
			case(s,m) => s + " > " + m + "\n"
		}
	}

	/** Method adding a single message to the stack.
		*
		* @param m Message.
		*/
	def addToLog(m:String) {
		stack += m
		logFrame.updateText()
	}

	/** Method adding a set of messages to the stack.
		*
		* @param m Set of messages.
		*/
	def addToLog(m:Traversable[String]) {
		m.foreach(stack += _)
		logFrame.updateText()
	}

	/** Method to empty the stack.
		*
		*/
	private def clearStack() {
		stack.clear()
		logFrame.updateText()
	}

	/** Method opening a frame which displays the messages.
		*
		* @param title Title given to the frame.
		*/
	def openFrame(title:String) {
		logFrame.title = title
		logFrame.open()
	}
}

/** Class representing a stack of messages used for a log system,
	* combined with a filter of messages to display.
	*
	* Comes with a Swing frame component (to print the messages).
	*
	* ==Usage :==
	* {{{
	*   import tinkerGUI.utils.LogStack
	*   ...
	*   val myLogStack = new LogStack
	*   ...
	*   myLogStack.openFrame("My app - log") // open the frame
	*   ...
	*   mylogStack.add(("myMessageType","Hello World")) // add a single message with its type (used for filtering)
	*   mylogStack.add(Array(("myMessageType","Foo"),("myOtherMessageType","Bar"))) // add a set of messages with their types (used for filtering)
	*   // you can do things with maps too :
	*   mylogStack.add(Map("myMessageType"->Array("Foo","Bar"),"myOtherMessageType"->Array("HelloWorld")))
	*   ...
	* }}}
	*
	*/
class FilteredLogStack {

	/** The actual stack containing the messages.*/
	private val stack = mutable.ArrayBuffer[(String,String)]()

	/** The message's type to display.*/
	private val filtered = mutable.ArrayBuffer[String]()

	/** The frame object.
		*
		* Filters will be printed on the right-hand side, as a list of checkboxes.
		*/
	private object logFrame extends Frame{
		val messages = new TextArea(){
			lineWrap = true
			editable = false
			font = new Font(Font.MONOSPACED,Font.BOLD,14)
			text = getLog
		}
		val filters = new BoxPanel(Orientation.Vertical){
			contents += new Label("Filters :")
			var f = Array[String]()
			def updateFilters() {
				stack.foreach{ case (s,_) =>
					if(!f.contains(s)){
						f = f :+ s
						filtered += s
						this.contents += new CheckBox(s){
							selected = true
							action = new Action(s){
								def apply() = if(selected) addToFilter(s) else removeFromFilter(s)
							}
						}
					}
				}
			}
			updateFilters()
		}
		val mBar = new MenuBar(){
			val options = new Menu("Options"){ menu =>
				new Action("Clear"){
					menu.contents += new MenuItem(this)
					def apply() = clearStack
				}
			}
			contents += options
		}
		def updateText() = {
			filters.updateFilters()
			messages.text = getLog
		}
		menuBar = mBar
		minimumSize = new Dimension(250,250)
		preferredSize = new Dimension(500,350)
		contents = new SplitPane(Orientation.Vertical){
			contents_=(filters, new ScrollPane(messages))
		}
	}

	/** Method to get the logs in a single string.*/
	private def getLog:String = {
		stack.foldLeft(""){
			case (s,m) if filtered contains m._1 => s + " > " + m._1 + " : " + m._2 + "\n"
			case (s,_) => s
		}
	}

	/** Method adding a single message to the stack.
		*
		* @param m Pair of type/message.
		*/
	def addToLog(m:(String,String)) {
		stack += m
		logFrame.updateText()
	}

	/** Method adding a set of messages to the stack.
		*
		* @param m Set of pairs of type/message.
		*/
	def addToLog(m:Traversable[(String,String)]) {
		m.foreach(stack += _)
		logFrame.updateText()
	}

	/** Method adding a set of messages to the stack, clustered by type.
		*
		* @param m Map of messages, key is the type, value is a set of messages for this type.
		*/
	def addToLog(m:Map[String,Traversable[String]]) {
		m.foreach {
			case (k,v) =>
				v.foreach(stack += Tuple2(k,_))
		}
		logFrame.updateText()
	}

	/** Method to empty the stack.
		*
		*/
	private def clearStack() {
		stack.clear()
		logFrame.updateText()
	}

	/** Method registering a type to filter.
		*
		* @param s Type to filter.
		*/
	private def addToFilter(s:String) {
		if(!filtered.contains(s)) filtered += s
		logFrame.updateText()
	}

	/** Method removing a type to filter.
		*
		* @param s Type to remove from filter.
		*/
	private def removeFromFilter(s:String) {
		if(filtered.contains(s)) filtered -= s
		logFrame.updateText()
	}

	/** Method opening a frame which displays the messages.
		*
		* @param title Title given to the frame.
		*/
	def openFrame(title:String) {
		logFrame.title = title
		logFrame.open()
	}
}
