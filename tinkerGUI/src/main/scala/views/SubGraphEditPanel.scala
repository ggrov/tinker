package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.SubGraphEditController
import tinkerGUI.controllers.ShowPreviewEvent

class SubGraphEditPanel() extends FlowPanel {
	minimumSize = new Dimension(250, 350)
	val controller = Service.subGraphEditCtrl
	listenTo(controller)
	reactions += {
		case ShowPreviewEvent(panel: BorderPanel) =>
			contents.clear()
			contents += panel
	}
}