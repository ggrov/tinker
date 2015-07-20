package tinkerGUI.views

import tinkerGUI.controllers.events.DocumentChangedEvent
import tinkerGUI.controllers.Service

import scala.swing._

object MainGUI extends SimpleSwingApplication {

	val graphPanel = new GraphEditPanel() {
		Service.setMainFrame(this)
	}
	val inspectorPanel = new GraphInspectorPanel()
	val elementPanel = new ElementInfoPanel()

	object FourthSplit extends SplitPane {
		orientation = Orientation.Horizontal
		//minimumSize = new Dimension (300,800)
		//preferredSize = new Dimension (300,800)
		//contents_=(new GraphInspectorPanel(), new ElementInfoPanel())
		contents_=(inspectorPanel, elementPanel)
	}

	object ThirdSplit extends SplitPane {
		orientation = Orientation.Horizontal
		//minimumSize = new Dimension (300,800)
		//preferredSize = new Dimension (300,800)
		val tinkerLibTree = new TinkerLibraryTree()
		contents_=(tinkerLibTree.libraryTreePanel, tinkerLibTree.libraryPreviewPanel)
	}

	object SecondSplit extends SplitPane {
		orientation = Orientation.Vertical
		//minimumSize = new Dimension (1100,800)
		//preferredSize = new Dimension (1100,800)
		//contents_=(new GraphEditPanel(){Service.setMainFrame(this)}, FourthSplit)
		contents_=(graphPanel, FourthSplit)
	}

	object MainSplit extends SplitPane {
		orientation = Orientation.Vertical
		contents_=(ThirdSplit, SecondSplit)
	}

	def top = new MainFrame{
		minimumSize = new Dimension (650,450)
		title = "Tinker - " + Service.documentCtrl.title
		menuBar = new TinkerMenu()
		contents = MainSplit
		listenTo(Service.documentCtrl)
		reactions += {
			case DocumentChangedEvent(_) =>
				graphPanel.display(true)
				inspectorPanel.display(true)
				title = "Tinker - " + Service.documentCtrl.title
		}
    Service.setTopFrame(this)
	}



}