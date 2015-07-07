package tinkerGUI.views

import tinkerGUI.controllers.events.PreviewEvent
import tinkerGUI.controllers.Service

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
		add(new FlowPanel() {
			contents += cb
			contents += new Button(new Action("Add to graph"){def apply() = controller.addFileToGraph})
		}, BorderPanel.Position.North)
		add(controller.getLibraryView, BorderPanel.Position.Center)
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
			previewPanel.repaint()
	}
}