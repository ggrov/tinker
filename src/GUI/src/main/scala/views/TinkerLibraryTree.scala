package tinkerGUI.views

import java.awt.{Font, Cursor}
import javax.swing.ImageIcon

import tinkerGUI.controllers.events.{UpdateGTListEvent, DisableNavigationEvent, PreviewEvent}
import tinkerGUI.controllers.{QuantoLibAPI, Service}

import quanto.gui.{FileTree, FileOpened}
import tinkerGUI.utils.MutableComboBox

import scala.swing._
import java.io.{FilenameFilter, File}

import scala.swing.event.SelectionChanged

class TinkerLibraryTree() extends Publisher {
	val controller = Service.libraryTreeCtrl

	val titleFont = new Font("Dialog",Font.BOLD,14)

	// the following code is a copy from the quantomatic project, slightly modified
	val libraryFileTree = new FileTree
	//libraryFileTree.preferredSize = new Dimension(250,360)
	libraryFileTree.minimumSize = new Dimension(100,200)
	libraryFileTree.filenameFilter = Some(new FilenameFilter {
		val extns = Set("psgraph")
		def accept(parent: File, name: String) = {
			val extn = name.lastIndexOf('.') match {
				case i if i > 0 => name.substring(i+1)
				case _ => ""
			}
			if (extns.contains(extn)) true
			else {
				val f = new File(parent, name)
				f.isDirectory && !(f.isHidden || f.getName.startsWith(".")) // don't show hidden (dot) directories
			}
		}
	})
	libraryFileTree.root = Some("tinker_library")

	listenTo(libraryFileTree)
	reactions += {
		case FileOpened(f) =>
			controller.previewFile(f)
	}

	val libraryTreePanel = new BorderPanel(){
		add(new FlowPanel(FlowPanel.Alignment.Center)(new Label("Library"){font = titleFont}), BorderPanel.Position.North)
		add(libraryFileTree, BorderPanel.Position.Center)
	}
	// end of copy

	val libraryPreviewPanel = new BorderPanel(){
		minimumSize = new Dimension(100,200)

		val cb = new MutableComboBox[String]
		cb.items = controller.gtList
		val comboBox = new FlowPanel(FlowPanel.Alignment.Left)(cb){
			var noSelectionChangeFlag = false
			listenTo(controller)
			reactions += {
				case UpdateGTListEvent() =>
					noSelectionChangeFlag = true
					cb.items = controller.gtList
					cb.item = controller.selectedGt
					noSelectionChangeFlag = false
			}
			listenTo(cb)
			reactions += {
				case SelectionChanged(`cb`) if !noSelectionChangeFlag => controller.previewGTFromJson(cb.item,0)
			}
		}
		comboBox.visible = false

		val indexOnTotalLabel = new Label(controller.indexOnTotalText)
		val navigation = new FlowPanel(FlowPanel.Alignment.Right)(){
			contents += new Button(new Action(""){
				def apply() = { controller.previewGTFromJson(cb.item,controller.currentIndex-1) }
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("previous.png"), "Previous")
				tooltip = "Previous"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				listenTo(controller)
				reactions +={
					case DisableNavigationEvent(a) =>
						enabled = !(a contains "previous")
				}
			}
			contents += indexOnTotalLabel
			contents += new Button(new Action(""){
				def apply() = { controller.previewGTFromJson(cb.item,controller.currentIndex+1) }
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("next.png"), "Next")
				tooltip = "Next"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				listenTo(controller)
				reactions +={
					case DisableNavigationEvent(a) =>
						enabled = !(a contains "next")
				}
			}
			contents += new Button(new Action(""){
				def apply() = {QuantoLibAPI.zoomInLibraryPreview()}
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("zoom-in.png"), "Zoom in")
				tooltip = "Zoom in"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				listenTo(controller)
				reactions +={
					case DisableNavigationEvent(a) =>
						enabled = !(a contains "zoomin")
				}
			}
			contents += new Button(new Action(""){
				def apply() = {QuantoLibAPI.zoomOutLibraryPreview()}
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("zoom-out.png"), "Zoom out")
				tooltip = "Zoom out"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				listenTo(controller)
				reactions +={
					case DisableNavigationEvent(a) =>
						enabled = !(a contains "zoomout")
				}
			}
			contents += new Button(new Action(""){
				def apply() = controller.addFileToGraph()
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("add-to-graph.png"), "Add to graph")
				tooltip = "Add to graph"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				listenTo(controller)
				reactions +={
					case DisableNavigationEvent(a) =>
						enabled = !(a contains "addtograph")
				}
			}
		}
		navigation.visible = false

		val noGraphLabel = new FlowPanel(FlowPanel.Alignment.Center)(new Label("Select a file in the library to preview it here."))

		val graphPanel = QuantoLibAPI.getLibraryPreview
		graphPanel.visible = false

		val title = new Label("Library file preview"){font = titleFont}

		add(new BorderPanel() {
			add(new FlowPanel(FlowPanel.Alignment.Center)(title),BorderPanel.Position.North)
			add(comboBox, BorderPanel.Position.West)
			add(navigation, BorderPanel.Position.East)
			add(noGraphLabel, BorderPanel.Position.South)
		}, BorderPanel.Position.North)
		add(graphPanel, BorderPanel.Position.Center)



		listenTo(controller)
		reactions += {
			case PreviewEvent(showGraph,_) =>
				comboBox.visible = true
				navigation.visible = true
				graphPanel.visible = showGraph
				noGraphLabel.visible = false
				title.text = controller.fileName+controller.fileExtn+" preview"
				indexOnTotalLabel.text = controller.indexOnTotalText
				this.repaint()
		}
	}

}