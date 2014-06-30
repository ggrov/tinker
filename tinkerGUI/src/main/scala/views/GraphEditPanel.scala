package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.GraphEditController
import tinkerGUI.controllers.NewGraphEvent

class GraphEditPanel() extends BorderPanel {
	val controller = Service.graphEditCtrl
	var graphPanel = controller.getGraph
	val editControls = new EditControlsPanel()
	val evalControls = new EvalControlsPanel()
	add(new BoxPanel(Orientation.Vertical){
		contents += editControls.MainToolBar
	}, BorderPanel.Position.North)
	add(graphPanel, BorderPanel.Position.Center)
	preferredSize = new Dimension(800, 800)
	listenTo(controller)
	reactions += {
		case NewGraphEvent() =>
			graphPanel = controller.getGraph
			add(graphPanel, BorderPanel.Position.Center)
	}
}