package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.GraphEditController
import tinkerGUI.controllers.NewGraphEvent

class GraphEditPanel() extends BorderPanel {
	val controller = Service.graphEditCtrl
	var graphPanel = controller.getGraph
	val editControls = new EditControlsPanel()
	val graphBreadcrums = new GraphBreadcrums()
	add(new BorderPanel(){
		add(new BorderPanel(){
			add(new BoxPanel(Orientation.Vertical){
				contents += graphBreadcrums.breadcrums
			}, BorderPanel.Position.West)
		}, BorderPanel.Position.North)
		add(new BoxPanel(Orientation.Vertical){
			contents += editControls.MainToolBar
		}, BorderPanel.Position.South)
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