package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.MainGUIController
import tinkerGUI.controllers.DocumentTitleEvent

object MainGUI extends SimpleSwingApplication {
	val controller = Service.mainCtrl

	object FourthSplit extends SplitPane {
		orientation = Orientation.Horizontal
		contents_=(new BorderPanel(), new ElementEditPanel())
	}

	object ThirdSplit extends SplitPane {
		orientation = Orientation.Horizontal
		contents_=(new BorderPanel(), new BorderPanel())
	}

	object SecondSplit extends SplitPane {
		orientation = Orientation.Vertical
		contents_=(new GraphEditPanel(), FourthSplit)
	}

	object MainSplit extends SplitPane {
		orientation = Orientation.Vertical
		contents_=(ThirdSplit, SecondSplit)
	}

	def top = new MainFrame{
		title = "Tinker - " + controller.getTitle
		minimumSize = new Dimension(400,400)
		menuBar = new TinkerMenu()
		contents = MainSplit
		listenTo(controller)
		reactions += {
			case DocumentTitleEvent(t) =>
				title = "Tinker - " + t
		}
	}
}