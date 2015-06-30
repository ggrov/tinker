package tinkerGUI.views

import javax.swing.ImageIcon

import tinkerGUI.controllers.events._
import tinkerGUI.model.exceptions.{AtomicTacticNotFoundException, GraphTacticNotFoundException}

import scala.swing._
import tinkerGUI.controllers._
import tinkerGUI.utils.{TinkerDialog, ArgumentParser}
import java.awt.{Cursor, Font}

class VertexEditContent(nam: String, typ: String, value: String, enableEdit: Boolean) extends BoxPanel(Orientation.Vertical) {
	val titleFont = new Font("Dialog",Font.BOLD,14)
	contents += new FlowPanel(FlowPanel.Alignment.Center)(new Label("Node Information"){font = titleFont})
	
	val delButton = new Button(
		new Action(""){
			def apply(){
				Service.documentCtrl.registerChanges()
				QuantoLibAPI.userDeleteElement(nam)
			}
		}){
		icon = if(typ=="T_Atomic") {
			new ImageIcon(MainGUI.getClass.getResource("delete-atomic.png"), "Edit")
		} else if (typ=="T_Graph") {
			new ImageIcon(MainGUI.getClass.getResource("delete-nested.png"), "Edit")
		} else {
			new ImageIcon(MainGUI.getClass.getResource("delete-identity.png"), "Edit")
		}
		tooltip = "Delete node"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = enableEdit
	}
	val editButton = new Button(
		new Action(""){
			def apply(){
				Service.documentCtrl.registerChanges()
				Service.editCtrl.updateTactic(nam,value,typ=="T_Atomic")
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("edit-pen.png"), "Edit")
		tooltip = "Edit tactic"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = enableEdit
	}

	contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Node : " + nam))
	contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label(typ match{
		case "T_Identity" => "Type : Identity tactic"
		case "T_Atomic" => "Type : Atomic tactic"
		case "T_Graph" => "Type : Graph tactic"
		case "G_Break" => "Type : Breakpoint"
		case "G" => "Type : Goal"
	}))
	typ match {
		case "T_Identity" =>
			contents += new FlowPanel(FlowPanel.Alignment.Left)(delButton)
		case "T_Atomic" =>
			val tacticCoreId = try {
				Service.getATCoreId(ArgumentParser.separateNameFromArgument(value)._1)
			} catch {
				case e:AtomicTacticNotFoundException => "Error : could not find tactic"
			}
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Name : "+value))
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Tactic : "+tacticCoreId))
			contents += new FlowPanel(FlowPanel.Alignment.Left)() {
				contents += editButton
				contents += delButton
			}
		case "T_Graph" =>
			val name = ArgumentParser.separateNameFromArgument(value)._1
			val branchType = try {
				Service.getBranchTypeGT(name)
			} catch {
				case e:GraphTacticNotFoundException => "Error : could not find tactic"
			}
			val addSubButton = new Button(
				new Action(""){
					def apply(){
						//Service.documentCtrl.registerChanges()
						Service.editCtrl.addSubgraph(name)
					}
				}){
				icon = new ImageIcon(MainGUI.getClass.getResource("add.png"), "Add subgraph")
				tooltip = "Add subgraph"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
				enabled = enableEdit
			}
			val inspectButton = new Button(
				new Action(""){
					def apply(){
						Service.inspectorCtrl.inspect(name)
					}
				}){
				icon = new ImageIcon(MainGUI.getClass.getResource("inspect.png"), "Inspect tactic")
				tooltip = "Inspect tactic"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Name : "+value))
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Branch type : "+branchType))
			contents += new FlowPanel(FlowPanel.Alignment.Left)(){
				contents += addSubButton
				contents += editButton
				contents += inspectButton
				contents += delButton
			}
		case "G_Break" =>
			val removeBreak = new Button(
				new Action("") {
					def apply() {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.removeBreakpoint(nam)
					}
				}){
				icon = new ImageIcon(MainGUI.getClass.getResource("remove-break.png"), "Remove breakpoint")
				tooltip = "Remove breakpoint"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
			contents += new FlowPanel(FlowPanel.Alignment.Left)(removeBreak)
		case "G" => // do nothing
	}

}

class VerticesEditContent(names: Set[String], enableEdit: Boolean) extends BoxPanel(Orientation.Vertical) {
	var dialog = new Dialog()
	val mergeAction = new Action("Yes"){
		def apply {
			Service.documentCtrl.registerChanges()
			QuantoLibAPI.mergeSelectedVertices()
			dialog.close()
		}
	}
	val cancelAction = new Action("Cancel"){
		def apply {
			dialog.close()
		}
	}
	val mergeButton = new Button(
		new Action("Merge nodes"){
			def apply() {
				dialog = TinkerDialog.openConfirmationDialog("<html>You are about to merge these nodes.</br>Do you wish to continue ?</html>", Array(mergeAction, cancelAction))
			}
			enabled = enableEdit
		}
	)
	contents += new FlowPanel(FlowPanel.Alignment.Left)(){
		def prettyString(s: Set[String]) : String = {
			var res = s.head
			s.tail.foreach{ e =>
				res += ", " + e
			}
			res
		}
		contents += new Label("Nodes : " + prettyString(names))
	}
	contents += new FlowPanel(FlowPanel.Alignment.Left)(){
		contents += mergeButton
	}
}

class EdgeEditContent(nam: String, value: String, src: String, tgt: String, enableEdit: Boolean) extends BoxPanel(Orientation.Vertical) {
	val titleFont = new Font("Dialog",Font.BOLD,14)
	contents += new FlowPanel(FlowPanel.Alignment.Center)(new Label("Edge Information"){font = titleFont})
	val editButton = new Button(
		new Action("") {
			def apply() {
				Service.documentCtrl.registerChanges()
				Service.editCtrl.editEdge(nam,src,tgt,value)
			}
		}
	){
		icon = new ImageIcon(MainGUI.getClass.getResource("edit-pen.png"), "Edit")
		tooltip = "Edit edge"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = enableEdit
	}
	val breakpointButton =
		if(QuantoLibAPI.hasBreak(nam)){
			new Button(
				new Action("") {
				def apply() {
					Service.documentCtrl.registerChanges()
					QuantoLibAPI.removeBreakpointFromEdge(nam)
				}
			}){
				icon = new ImageIcon(MainGUI.getClass.getResource("remove-break.png"), "Remove breakpoint")
				tooltip = "Remove breakpoint"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
		}
		else {
			new Button(
				new Action("") {
					def apply() {
						Service.documentCtrl.registerChanges()
						QuantoLibAPI.addBreakpointOnEdge(nam)
					}
				}){
				icon = new ImageIcon(MainGUI.getClass.getResource("add-break.png"), "Add breakpoint")
				tooltip = "Add breakpoint"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			}
		}
	val delButton = new Button(
		new Action(""){
			def apply(){
				Service.documentCtrl.registerChanges()
				QuantoLibAPI.userDeleteElement(nam)
			}
		}){
		icon = new ImageIcon(MainGUI.getClass.getResource("delete-edge.png"), "Delete")
		tooltip = "Delete edge"
		borderPainted = false
		margin = new Insets(0,0,0,0)
		contentAreaFilled = false
		opaque = false
		cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		enabled = enableEdit
	}
	contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Edge : " + nam))
	contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Goal types : "+value))
	contents += new FlowPanel(FlowPanel.Alignment.Left)(){
		contents += new Label("From : "+src)
		contents += new Label("To : "+tgt)
	}
	contents += new FlowPanel(FlowPanel.Alignment.Left)(){
		contents += editButton
		contents += breakpointButton
		contents += delButton
	}
}

class ElementInfoPanel() extends BoxPanel(Orientation.Vertical) {
	minimumSize = new Dimension(200, 200)
	//preferredSize = new Dimension(250, 250)

	var enableEdit = true

	listenTo(Service.evalCtrl)
	reactions += {
		case DisableActionsForEvalEvent(inEval) =>
			enableEdit = !inEval
	}

	listenTo(QuantoLibAPI)
	reactions += {
		case OneVertexSelectedEvent(nam, typ, value) =>
			contents.clear()
			contents += new VertexEditContent(nam, typ, value, enableEdit)
			revalidate()
		case ManyVerticesSelectedEvent(names) =>
			contents.clear()
			contents += new VerticesEditContent(names, enableEdit)
			revalidate()
		case OneEdgeSelectedEvent(nam, value, src, tgt) =>
			contents.clear()
			contents += new EdgeEditContent(nam, value, src, tgt, enableEdit)
			revalidate()
		case NothingSelectedEvent() =>
			contents.clear()
			repaint()
	}
}
