package tinkerGUI.views

import tinkerGUI.controllers.{Service, QuantoLibAPI}

import scala.swing._
import javax.swing.ImageIcon
import java.awt.Cursor
import java.awt.Insets

import scala.swing.event.{Key, KeyReleased}

class GraphEditPanel() extends BorderPanel {

	var graphPanel = QuantoLibAPI.getGraph
	//graphPanel.visible = false

	val editControls = new EditControlsPanel()
	val evalControls = new EvalControlsPanel()
	val graphBreadcrumbs = new GraphBreadcrumbs()
	val graphNav = new GraphNavigation()

	val top = new BorderPanel(){
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
				contents += graphBreadcrumbs.breadcrumbs
			}, BorderPanel.Position.West)
			add(new BoxPanel(Orientation.Vertical){
				contents += graphNav.navigation
			}, BorderPanel.Position.East)
		}, BorderPanel.Position.North)
		add(new BoxPanel(Orientation.Horizontal){
			//contents += editControls.SecondaryToolBar
			contents += editControls.MainToolBar
			contents += evalControls.SecondaryEvalToolBar
			contents += evalControls.MainEvalToolBar
		}, BorderPanel.Position.South)
	}
	//top.visible = false

	add(top,BorderPanel.Position.North)

	add(graphPanel, BorderPanel.Position.Center)

	minimumSize = new Dimension(300, 400)

	def display(visible:Boolean) {
		top.visible = visible
		graphPanel.visible = visible
	}

}