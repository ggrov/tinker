package tinkerGUI.views

import java.awt.{Font, Cursor}
import javax.swing.ImageIcon

import tinkerGUI.controllers.events.PreviewEvent
import tinkerGUI.controllers.{QuantoLibAPI, Service}

import quanto.gui.{FileTree, FileOpened}
import tinkerGUI.utils.MutableComboBox

import scala.swing._
import java.io.{FilenameFilter, File}

import scala.swing.event.SelectionChanged

class TinkerLibraryTree() extends Publisher {
	val controller = Service.libraryTreeCtrl

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
	// end of copy

	val previewPanel = new BorderPanel(){
		minimumSize = new Dimension(100,200)

		val cb = new MutableComboBox[String]
		cb.items = controller.gtList
		val comboBox = new FlowPanel(FlowPanel.Alignment.Left)(cb)
		comboBox.visible = false

		val navigation = new FlowPanel(FlowPanel.Alignment.Right)(){
			contents += new Button(new Action(""){
				def apply() = {}
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("previous.png"), "Previous")
				tooltip = "Previous"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
			contents += new Button(new Action(""){
				def apply() = {}
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("next.png"), "Next")
				tooltip = "Next"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
			contents += new Button(new Action(""){
				def apply() = {}
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("zoom-in.png"), "Zoom in")
				tooltip = "Zoom in"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
			contents += new Button(new Action(""){
				def apply() = {}
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("zoom-out.png"), "Zoom out")
				tooltip = "Zoom out"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
			contents += new Button(new Action(""){
				def apply() = controller.addFileToGraph
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("add-to-graph.png"), "Add to graph")
				tooltip = "Add to graph"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
		}
		navigation.visible = false

		val noGraphLabel = new FlowPanel(FlowPanel.Alignment.Center)(new Label("Select a file in the library to preview it here."))

		val graphPanel = QuantoLibAPI.getLibraryPreview
		graphPanel.visible = false

		val titleFont = new Font("Dialog",Font.BOLD,14)
		val title = new Label("Library file preview"){font = titleFont}

		add(new BorderPanel() {
			add(new FlowPanel(FlowPanel.Alignment.Center)(title),BorderPanel.Position.North)
			add(comboBox, BorderPanel.Position.West)
			add(navigation, BorderPanel.Position.East)
			add(noGraphLabel, BorderPanel.Position.South)
		}, BorderPanel.Position.North)
		add(graphPanel, BorderPanel.Position.Center)
		listenTo(cb)
		reactions += {
			case SelectionChanged(`cb`) => controller.previewGTFromJson(cb.item,0)
		}
	}

	listenTo(controller)
	reactions += {
		case PreviewEvent(_,_) =>
			previewPanel.cb.items = controller.gtList
			previewPanel.cb.item = controller.selectedGt
			previewPanel.comboBox.visible = true
			previewPanel.navigation.visible = true
			previewPanel.graphPanel.visible = true
			previewPanel.noGraphLabel.visible = false
			previewPanel.title.text = controller.fileName+controller.fileExtn+" preview"
			previewPanel.repaint()
	}
}