package tinkerGUI.views

import tinkerGUI.controllers.events.DocumentChangedEvent
import tinkerGUI.controllers.{DocumentService, QuantoLibAPI, Service}

import scala.swing._
import event.Key
import javax.swing.KeyStroke
import java.awt.event.KeyEvent

class TinkerMenu() extends MenuBar{
	val CommandMask = java.awt.Toolkit.getDefaultToolkit.getMenuShortcutKeyMask

	val FileMenu = new Menu("File") { menu =>
		mnemonic = Key.F
		new Action("New") {
			menu.contents += new MenuItem(this) { mnemonic = Key.N }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_N, CommandMask))
			def apply() {
				Service.documentCtrl.newDoc()
			}
		}
		new Action("Open") {
			menu.contents += new MenuItem(this) { mnemonic = Key.O }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_O, CommandMask))
			def apply() {
				Service.documentCtrl.openJson()
			}
		}
		menu.contents += new Menu("Recent files"){ m =>
			def updateList(): Unit ={
				m.contents.clear()
				Service.documentCtrl.recentProofs.values.reverse.foreach{case(k,v)=>
					m.contents += new MenuItem(new Action(k) {
						def apply() {
							Service.documentCtrl.openJson(Some(v))
						}
					})
				}
				m.contents += new Separator()
				m.contents += new MenuItem(new Action("Clear recent files"){
					def apply() {
						Service.documentCtrl.recentProofs.empty()
					}
				})
			}
			updateList()
			Service.documentCtrl.recentProofs.register(updateList)
		}
		menu.contents += new Separator()
		new Action("Save") {
			menu.contents += new MenuItem(this) { mnemonic = Key.S }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_S, CommandMask))
			enabled = false
			def apply() {
				Service.documentCtrl.saveJson()
			}
			listenTo(Service.documentCtrl)
			reactions += { case DocumentChangedEvent(status) =>
				enabled = status
			}
		}
		new Action("Save As...") {
			menu.contents += new MenuItem(this) { mnemonic = Key.A }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_S, CommandMask | Key.Modifier.Shift))
			def apply() {
				Service.documentCtrl.saveAsJson()
			}
		}
		new Action("Export as svg") {
			menu.contents += new MenuItem(this)
			def apply(): Unit = {
				DocumentService.exportSvg()
			}
		}
		menu.contents += new Separator()
		new Action("Quit") {
			menu.contents += new MenuItem(this) { mnemonic = Key.Q }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_Q, CommandMask))
			def apply() {
				Service.closeApp()
			}
		}
	}

	val EditMenu = new Menu("Edit"){menu =>
		mnemonic = Key.E
		new Action("Undo") {
			menu.contents += new MenuItem(this) { mnemonic = Key.U }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_Z, CommandMask))
			enabled = false
			def apply() {
				Service.documentCtrl.undo()
			}
			listenTo(Service.documentCtrl)
			reactions += {
				case DocumentChangedEvent(_) =>
					enabled = !Service.documentCtrl.undoStack.isEmpty
					title = "Undo"
			}
		}
		new Action("Redo") {
			menu.contents += new MenuItem(this) { mnemonic = Key.R }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_Z, CommandMask | Key.Modifier.Shift))
			enabled = false
			def apply() {
				Service.documentCtrl.redo()
			}
			listenTo(Service.documentCtrl)
			reactions += {
				case DocumentChangedEvent(_) =>
					enabled = !Service.documentCtrl.redoStack.isEmpty
					title = "Redo"
			}
		}
		new Action("Change proof name"){
			menu.contents += new MenuItem(this)
			def apply() {
				Service.editCtrl.changeProofName()
			}
		}
		new Action("Open tactic editor"){
			menu.contents += new MenuItem(this)
			def apply(){
				Service.editCtrl.tacticEditor.open()
			}
		}
		new Action("Open goal types editor"){
			menu.contents += new MenuItem(this)
			def apply(){
				Service.editCtrl.goaltypeEditor.open()
			}
		}
		new Action("Layout Graph") {
			menu.contents += new MenuItem(this) { mnemonic = Key.L }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_L, CommandMask))
			def apply() {
				QuantoLibAPI.layoutGraph()
			}
		}
	}

	// for test purpose
	val Debug = new Menu("Debug"){ menu =>
		mnemonic = Key.D
		new Action("Open eval log window"){
			menu.contents += new MenuItem(this)
			def apply(){
				Service.evalCtrl.logStack.openFrame("Tinker - eval log")
			}
		}
		new Action("Open edit log window"){
			menu.contents += new MenuItem(this)
			def apply(){
				Service.editCtrl.logStack.openFrame("Tinker - edit log")
			}
		}
		new Action("Print JSON in Console") {
			menu.contents += new MenuItem(this)
			def apply(){
				Service.debugPrintJson()
			}
		}
		new Action("Start recording") {
			menu.contents += new MenuItem(this)
			def apply() {
				if(Service.evalCtrl.recording){
					Service.evalCtrl.setRecording(false)
				} else {
					Service.evalCtrl.setRecording(true)
				}
				this.title = if(Service.evalCtrl.recording) "Stop recording" else "Start recording"
			}
		}
	}

	contents += (FileMenu, EditMenu, Debug)
}