package tinkerGUI.views

import scala.swing._
import javax.swing.ImageIcon
import java.awt.Cursor
import java.awt.Insets
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.GraphEditController
import tinkerGUI.controllers.NewGraphEvent

class GraphEditPanel() extends BorderPanel {
	val controller = Service.graphEditCtrl
	var graphPanel = controller.getGraph
	val editControls = new EditControlsPanel()
	val evalControls = new EvalControlsPanel()
	val graphBreadcrums = new GraphBreadcrumbs()
	val graphNav = new GraphNavigation
	add(new BorderPanel(){
		add(new BorderPanel(){
			add(new BoxPanel(Orientation.Horizontal){
				val openHierTree = new Action(""){
					def apply(){
						HierarchyTree.open()
					}
				}
				contents += new Button(openHierTree){
					icon = new ImageIcon(MainGUI.getClass.getResource("hierarchy-tree-view.png"), "Tree")
					tooltip = "View hierarchy as a tree."
					borderPainted = false
					margin = new Insets(0,0,0,0)
					contentAreaFilled = false
					opaque = false
					cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				}
				contents += graphBreadcrums.breadcrumbs
			}, BorderPanel.Position.West)
			add(new BoxPanel(Orientation.Vertical){
				contents += graphNav.navigation
			}, BorderPanel.Position.East)
		}, BorderPanel.Position.North)
		add(new BoxPanel(Orientation.Horizontal){
			contents += editControls.SecondaryToolBar
			contents += editControls.MainToolBar
			contents += evalControls.EvalToolBar
		}, BorderPanel.Position.South)
	}, BorderPanel.Position.North)
	add(graphPanel, BorderPanel.Position.Center)
	minimumSize = new Dimension(800, 800)
}