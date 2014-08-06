package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers._
import event.Key
import javax.swing.KeyStroke
import java.awt.event.KeyEvent
// for test purpose only
import java.net._
import java.io._
import scala.io._

class TinkerMenu() extends MenuBar{
	val controller = Service.menuCtrl
	val CommandMask = java.awt.Toolkit.getDefaultToolkit.getMenuShortcutKeyMask

	val FileMenu = new Menu("File") { menu =>
		mnemonic = Key.F
		val NewAction = new Action("New") {
			menu.contents += new MenuItem(this) { mnemonic = Key.N }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_N, CommandMask))
			def apply() {
				controller.newAction
			}
		}
		val OpenAction = new Action("Open") {
			menu.contents += new MenuItem(this) { mnemonic = Key.O }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_O, CommandMask))
			def apply() {
				controller.openAction
			}
		}
		val SaveAction = new Action("Save") {
			menu.contents += new MenuItem(this) { mnemonic = Key.S }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_S, CommandMask))
			enabled = false
			def apply() {
				controller.saveAction
			}
			listenTo(controller)
			reactions += { case DocumentStatusEvent(status) =>
				enabled = status
			}
		}
		val SaveAsAction = new Action("Save As...") {
			menu.contents += new MenuItem(this) { mnemonic = Key.A }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_S, CommandMask | Key.Modifier.Shift))
			def apply() {
				controller.saveAsAction
			}
		}
		val QuitAction = new Action("Quit") {
			menu.contents += new MenuItem(this) { mnemonic = Key.Q }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_Q, CommandMask))
			def apply() {
				controller.quitAction
			}
		}
	}

	val EditMenu = new Menu("Edit"){menu =>
		mnemonic = Key.E
		val UndoAction = new Action("Undo") {
			menu.contents += new MenuItem(this) { mnemonic = Key.U }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_Z, CommandMask))
			enabled = false
			def apply() {
				controller.undoAction
			}
			listenTo(controller)
			reactions += {
				case DocumentActionStackEvent(canUndo, _, undoActionName, _) =>
					enabled = canUndo
					title = "Undo " + undoActionName
			}
		}
		val RedoAction = new Action("Redo") {
			menu.contents += new MenuItem(this) { mnemonic = Key.R }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_Z, CommandMask | Key.Modifier.Shift))
			enabled = false
			def apply() {
				controller.redoAction
			}
			listenTo(controller)
			reactions += {
				case DocumentActionStackEvent(_, canRedo, _, redoActionName) =>
					enabled = canRedo
					title = "Redo " + redoActionName
			}
		}
		val LayoutAction = new Action("Layout Graph") {
			menu.contents += new MenuItem(this) { mnemonic = Key.L }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_L, CommandMask))
			def apply() {
				controller.layoutAction
			}
		}
	}

	// for test purpose
	val communication = new Menu("communication"){ menu =>
		val createClient = new Action("Create client") {
			menu.contents += new MenuItem(this)
			def apply(){
				println("Going to create client")
				var socket = new Socket(InetAddress.getByName("localhost"), 1790)
				println("Client created")
				val out = new PrintStream(socket.getOutputStream)
				println("Client speaking : sending message to server.")
				out.println("1.")
				var in = new BufferedSource(socket.getInputStream).getLines
				println("Client received : "+in.next)
				out.println("2.")
				in = new BufferedSource(socket.getInputStream).getLines
				println("Client received : "+in.next)
				out.println("3.")
				in = new BufferedSource(socket.getInputStream).getLines
				println("Client received : "+in.next)
				out.println("4.")
				in = new BufferedSource(socket.getInputStream).getLines
				println("Client received : "+in.next)
				out.println("5.")
				in = new BufferedSource(socket.getInputStream).getLines
				println("Client received : "+in.next)
				out.println("CMD_CLOSE")
				in = new BufferedSource(socket.getInputStream).getLines
				println("Client received : "+in.next)
			}
		}
	}

	contents += (FileMenu, EditMenu, communication)
}