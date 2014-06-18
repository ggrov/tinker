package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.MainGUIController
import tinkerGUI.controllers.DocumentTitleEvent

object MainGUI extends SimpleSwingApplication {
	val controller = new MainGUIController()
	def top = new MainFrame{
		title = "Tinker - " + controller.getTitle
		size = new Dimension(800,800)
		minimumSize = new Dimension(400,400)
		menuBar = new TinkerMenu()
		contents = new GraphEditPanel() {
			preferredSize = new Dimension(800,800)
		}
		listenTo(controller)
		reactions += {
			case DocumentTitleEvent(t) =>
				title = "Tinker - " + t
		}
	}
}