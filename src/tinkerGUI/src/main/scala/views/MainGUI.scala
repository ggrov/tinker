package tinkerGUI.views

import tinkerGUI.controllers.events.DocumentChangedEvent
import tinkerGUI.controllers.{CommunicationService, Service}

import scala.swing._
import scala.swing.event.{Key, KeyReleased}

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

	val initDialog = new Dialog(){ dialog =>
		title = "Tinker start"
		val newProject = new FlowPanel(){
			val project = new TextField(15)
			contents += new Label("New project :")
			contents += project
			contents += new Button(new Action("Create"){
				def apply() = {
					if(project.text.nonEmpty){
						dialog.close()
						Service.documentCtrl.newDoc(project.text)
					}
				}
			})
		}
		val openProject = new FlowPanel(new Button(new Action("Open existing project"){
			def apply() = {
				dialog.close()
				Service.documentCtrl.openJson()
			}
		}))
		val connect = new FlowPanel(new Button(new Action("Connect to core"){
			def apply() = {
				dialog.close()
				if(!CommunicationService.connecting && !CommunicationService.connected) CommunicationService.openConnection
			}
		}))
		contents = new GridPanel(3,1){
			contents += newProject
			contents += openProject
			contents += connect
		}
		centerOnScreen()
		this.peer.setAlwaysOnTop(true)
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

		if(!Service.initApp()){
			initDialog.open()
		}
		centerOnScreen()
		override def closeOperation() { Service.closeApp() }
	}

}