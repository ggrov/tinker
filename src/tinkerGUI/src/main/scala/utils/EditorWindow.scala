package tinkerGUI.utils

import java.awt.Font

import scala.swing._

/** Class implementing a window where users can edit a text and submit the text to a parsing function.
	*
	* @param frameTitle Title to give to the window.
	* @param parseCallback Callback function to parse the text and/or process it.
	*/
class EditorWindow(frameTitle:String, parseCallback:(String)=>Unit) {

	/** Actual frame object.
		*
		* Will contain a text area mainly and a button to submit the text to parsing.
		* Closing this frame will also parse the text.
		*/
	private object frame extends Frame {
		val editArea = new TextArea(""){
			lineWrap = true
			font = new Font(Font.MONOSPACED,Font.BOLD,14)
		}
		title = frameTitle
		minimumSize = new Dimension(250,250)
		contents = new BorderPanel(){
			add(new ScrollPane(editArea),BorderPanel.Position.Center)
			add(new FlowPanel(FlowPanel.Alignment.Right)(new Button(new Action("Submit"){def apply(){parseCallback(editArea.text)}})),BorderPanel.Position.South)
		}
		override def closeOperation() {
			parseCallback(editArea.text)
		}
	}

	/** Method opening the frame.*/
	def open() = frame.open()

	/** Method inserting text in the editor.
		*
		* @param s Text to insert.
		*/
	def appendText(s:String) {
		frame.editArea.text += s
	}

	/** Method clearing the text in the editor.
		*
		*/
	def clear(): Unit = {
		frame.editArea.text = ""
	}
}
