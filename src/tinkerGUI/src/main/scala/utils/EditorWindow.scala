package tinkerGUI.utils

import java.awt.Font

import scala.swing._

class EditorWindow(frameTitle:String, parseCallback:(String)=>Unit) {

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

	def open() = frame.open()

	def appendText(s:String) {
		frame.editArea.text += s
	}

	def clear(): Unit = {
		frame.editArea.text = ""
	}
}
