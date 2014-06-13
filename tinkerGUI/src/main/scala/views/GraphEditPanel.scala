package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.GraphEditController

class GraphEditPanel() extends BorderPanel {
	val controller = new GraphEditController()
	val graphPanel = controller.getGraph
	val editControls = new EditControlsPanel()
	val evalControls = new EvalControlsPanel()
	add(new FlowPanel{contents += editControls.MainToolBar}, BorderPanel.Position.North)
	add(graphPanel, BorderPanel.Position.Center)
}