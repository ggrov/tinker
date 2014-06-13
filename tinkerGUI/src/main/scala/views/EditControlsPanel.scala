package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon

class EditControlsPanel() {
	val SelectButton = new ToggleButton() {
		icon = new ImageIcon(MainGUI.getClass.getResource("select-rectangular.png"), "Select")
		tooltip = "Select"
		selected = true
	}

	val MainToolBar = new ToolBar {
		contents += (SelectButton)
	}
}