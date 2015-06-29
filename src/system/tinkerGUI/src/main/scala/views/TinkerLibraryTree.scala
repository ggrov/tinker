package tinkerGUI.views

import tinkerGUI.controllers.events.PreviewEvent

import scala.swing._
import java.io.{FilenameFilter, File}
import quanto.gui.FileTree
import quanto.gui.FileOpened
import tinkerGUI.controllers.Service

class TinkerLibraryTree() extends Publisher {
	val controller = Service.libraryTreeCtrl

	// the following code is a copy from the quantomatic project, slightly modified
	val libraryFileTree = new FileTree
	libraryFileTree.preferredSize = new Dimension(250,360)
	libraryFileTree.filenameFilter = Some(new FilenameFilter {
		val extns = Set("hello", "psgraph")
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
		add(new FlowPanel() {
			contents += new Button(controller.addFileToGraph)
		}, BorderPanel.Position.North)
		add(controller.getLibraryView, BorderPanel.Position.Center)
	}

	listenTo(controller)
	reactions += {
		case PreviewEvent(_,_) =>
			previewPanel.repaint()
	}
}