package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.TinkerMenuController
import tinkerGUI.controllers.DocumentEvent
import event.Key
import javax.swing.KeyStroke
import java.awt.event.KeyEvent

class TinkerMenu() extends MenuBar{
	val controller = new TinkerMenuController(this)
	val CommandMask = java.awt.Toolkit.getDefaultToolkit.getMenuShortcutKeyMask

	val FileMenu = new Menu("File") { menu =>
		mnemonic = Key.F
		val NewAction = new Action("New") {
			menu.contents += new MenuItem(this) {mnemonic = Key.N}
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_N, CommandMask))
			def apply() {
				controller.newAction
			}
		}
		val OpenAction = new Action("Open") {
			menu.contents += new MenuItem(this) {mnemonic = Key.O}
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
			reactions += { case DocumentEvent(status) =>
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

	contents += (FileMenu)
}