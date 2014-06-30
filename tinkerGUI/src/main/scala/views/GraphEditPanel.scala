package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.GraphEditController

class GraphEditPanel() extends BorderPanel {
	val controller = Service.getGraphEditController
	val graphPanel = controller.getGraph
	val editControls = new EditControlsPanel()
	val evalControls = new EvalControlsPanel()
	add(new BoxPanel(Orientation.Vertical){
		contents += editControls.MainToolBar
	}, BorderPanel.Position.North)
	add(graphPanel, BorderPanel.Position.Center)
	preferredSize = new Dimension(800, 800)
}