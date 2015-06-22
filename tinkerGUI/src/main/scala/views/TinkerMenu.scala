package tinkerGUI.views

import tinkerGUI.controllers.events.DocumentChangedEvent

import scala.swing._
import tinkerGUI.controllers._
import event.Key
import javax.swing.KeyStroke
import java.awt.event.KeyEvent
// for test purpose only
import java.net._
import java.io._
import scala.io._
import scala.concurrent._
import ExecutionContext.Implicits.global
import scala.util.{Success, Failure}

class TinkerMenu() extends MenuBar{
	val CommandMask = java.awt.Toolkit.getDefaultToolkit.getMenuShortcutKeyMask

	val FileMenu = new Menu("File") { menu =>
		mnemonic = Key.F
		val NewAction = new Action("New") {
			menu.contents += new MenuItem(this) { mnemonic = Key.N }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_N, CommandMask))
			def apply() {
				Service.documentCtrl.newDoc()
			}
		}
		val OpenAction = new Action("Open") {
			menu.contents += new MenuItem(this) { mnemonic = Key.O }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_O, CommandMask))
			def apply() {
				Service.documentCtrl.openJson()
			}
		}
		val SaveAction = new Action("Save") {
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
		val SaveAsAction = new Action("Save As...") {
			menu.contents += new MenuItem(this) { mnemonic = Key.A }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_S, CommandMask | Key.Modifier.Shift))
			def apply() {
				Service.documentCtrl.saveAsJson()
			}
		}
		val QuitAction = new Action("Quit") {
			menu.contents += new MenuItem(this) { mnemonic = Key.Q }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_Q, CommandMask))
			def apply() {
				if(Service.documentCtrl.closeDoc()) sys.exit(0)
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
				Service.documentCtrl.undo()
			}
			listenTo(Service.documentCtrl)
			reactions += {
				case DocumentChangedEvent(_) =>
					enabled = !Service.documentCtrl.undoStack.isEmpty
					title = "Undo"
			}
		}
		val RedoAction = new Action("Redo") {
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
		val LayoutAction = new Action("Layout Graph") {
			menu.contents += new MenuItem(this) { mnemonic = Key.L }
			accelerator = Some(KeyStroke.getKeyStroke(KeyEvent.VK_L, CommandMask))
			def apply() {
				QuantoLibAPI.layoutGraph()
			}
		}
	}

	// for test purpose
	val debug = new Menu("debug"){ menu =>
		val createClient = new Action("Create client") {
			menu.contents += new MenuItem(this)
			def apply(){
				val c = new ClientSocket
				c.open()
			}
		}
		val printJson = new Action("Print JSON in Console") {
			menu.contents += new MenuItem(this)
			def apply(){
				Service.debugPrintJson()
			}
		}
	}

	contents += (FileMenu, EditMenu, debug)
}

class ClientSocket extends Frame {
	title = "Tinker - sockets communication, client simulator"
	minimumSize = new Dimension(300, 200)
	var connected = false
	var response = new Label("Response :")
	var clientSocket: Socket = null
	var out : PrintStream = null
	val txtArea = new TextArea(""){editable = false}
	val sendButton = new Button(new Action("Send message"){
		def apply() {
			if(clientSocket != null){
				out.println(txtArea.text)
				txtArea.text = ""
			}
		}
	}){
		enabled = false
	}
	val disconnectButton = new Button(new Action("Disconnect"){
		def apply(){
			out.println("{\"cmd\":\"CLOSE_CONNECT\"}")
			connected = false
			close()
		}
	}){
		enabled = false
	}
	val connectButton = new Button(new Action("Connect"){
		def apply(){
			clientSocket = new Socket(InetAddress.getByName("localhost"), 1790)
			out = new PrintStream(clientSocket.getOutputStream)
			var in = new BufferedSource(clientSocket.getInputStream).getLines
			if(in.next == "SRV_LISTENING"){
				connected = true
				enabled = false
				sendButton.enabled = true
				disconnectButton.enabled = true
				txtArea.editable = true
				listen
			}
		}
	})
	val box = new BoxPanel(Orientation.Vertical){
		contents += connectButton
		contents += disconnectButton
		contents += txtArea
		contents += sendButton
		contents += response
	}
	def listen{
		if(connected){
			val in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream))
			var input : Future[String] = future {
				in.readLine
			}
			input onComplete{
				case Success(s) =>
					getMessage(in, s)
				case Failure(t) => 
			}
		}
	}
	def getMessage(in: BufferedReader, firstLine: String){
		if(connected){
			val b = new StringBuilder()
			b.append(firstLine)
			while(in.ready){
				b.append("\n")
				b.append(in.readLine)
			}
			println(b.toString)
			response.text = "Response : \n"+b.toString
			box.repaint()
			listen
		}
	}
	contents = box
}