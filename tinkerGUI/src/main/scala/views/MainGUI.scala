package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.MainGUIController
import tinkerGUI.controllers.DocumentTitleEvent

object MainGUI extends SimpleSwingApplication {
	val controller = Service.mainCtrl

	object FourthSplit extends SplitPane {
		orientation = Orientation.Horizontal
		minimumSize = new Dimension (300,800)
		preferredSize = new Dimension (300,800)
		contents_=(new SubGraphEditPanel(), new ElementEditPanel())
	}

	object ThirdSplit extends SplitPane {
		orientation = Orientation.Horizontal
		minimumSize = new Dimension (300,800)
		preferredSize = new Dimension (300,800)
		val tinkerLibTree = new TinkerLibraryTree()
		contents_=(tinkerLibTree.libraryFileTree, tinkerLibTree.previewPanel)
	}

	object SecondSplit extends SplitPane {
		orientation = Orientation.Vertical
		minimumSize = new Dimension (1100,800)
		preferredSize = new Dimension (1100,800)
		contents_=(new GraphEditPanel(){Service.setMainFrame(this)}, FourthSplit)
	}

	object MainSplit extends SplitPane {
		orientation = Orientation.Vertical
		contents_=(ThirdSplit, SecondSplit)
	}

	def top = new MainFrame{
		minimumSize = new Dimension (1400,800)
		title = "Tinker - " + controller.getTitle
		menuBar = new TinkerMenu()
		contents = MainSplit
		listenTo(controller)
		reactions += {
			case DocumentTitleEvent(t) =>
				title = "Tinker - " + t
		}

    Service.setTopFrame(this)
	}



}