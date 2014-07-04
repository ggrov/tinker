package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.SubGraphEditController
import tinkerGUI.controllers.ShowPreviewEvent
import tinkerGUI.controllers.HidePreviewEvent

class SubGraphEditPanel() extends BorderPanel {
	minimumSize = new Dimension(250, 350)
	val controller = Service.subGraphEditCtrl

	val nextAction = new Action("Next") {
		def apply() {
			controller.showNext()
		}
	}
	val prevAction = new Action("Prev") {
		def apply() {
			controller.showPrev()
		}
	}
	val editAction = new Action("Edit") {
		def apply() {
			controller.edit()
		}
	}

	val navPanel = new FlowPanel{
		contents += new Button(prevAction)
		contents += new Button(nextAction)
		contents += new Button(editAction)
	}

	val subgraphPanel = controller.getSubgraphView

	listenTo(controller)
	reactions += {
		case ShowPreviewEvent() =>
			_contents.clear()
			add(navPanel, BorderPanel.Position.North)
			add(subgraphPanel, BorderPanel.Position.Center)
			this.repaint()
		case HidePreviewEvent() =>
			_contents.clear()
			this.repaint()
	}
}