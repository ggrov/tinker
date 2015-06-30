package tinkerGUI.views

import tinkerGUI.controllers.events.DocumentChangedEvent

import scala.swing._
import tinkerGUI.controllers.Service

object MainGUI extends SimpleSwingApplication {

	object FourthSplit extends SplitPane {
		orientation = Orientation.Horizontal
		//minimumSize = new Dimension (300,800)
		//preferredSize = new Dimension (300,800)
		contents_=(new GraphInspectorPanel(), new ElementInfoPanel())
	}

	object ThirdSplit extends SplitPane {
		orientation = Orientation.Horizontal
		//minimumSize = new Dimension (300,800)
		//preferredSize = new Dimension (300,800)
		val tinkerLibTree = new TinkerLibraryTree()
		contents_=(tinkerLibTree.libraryFileTree, tinkerLibTree.previewPanel)
	}

	object SecondSplit extends SplitPane {
		orientation = Orientation.Vertical
		//minimumSize = new Dimension (1100,800)
		//preferredSize = new Dimension (1100,800)
		contents_=(new GraphEditPanel(){Service.setMainFrame(this)}, FourthSplit)
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
				title = "Tinker - " + Service.documentCtrl.title
		}

    Service.setTopFrame(this)
	}



}