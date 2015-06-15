package tinkerGUI.views

import tinkerGUI.model.exceptions.{AtomicTacticNotFoundException, GraphTacticNotFoundException}

import scala.swing._
import tinkerGUI.controllers._
import tinkerGUI.utils.{TinkerDialog, ArgumentParser}
import java.awt.Font

class VertexEditContent(nam: String, typ: String, value: String) extends BoxPanel(Orientation.Vertical) {
	val titleFont = new Font("Dialog",Font.BOLD,14)
	contents += new FlowPanel(FlowPanel.Alignment.Center)(new Label("Node Information"){font = titleFont})
	
	val delButton = new Button(
		new Action("Delete node"){
			def apply(){
				QuantoLibAPI.userDeleteElement(nam)
			}
		})
	val editButton = new Button(
		new Action("Edit tactic"){
			def apply(){
				Service.updateTactic(nam,value,typ=="T_Atomic")
			}
		})

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
				new Action("Add a sub-graph"){
					def apply(){
						Service.addSubgraph(name)
					}
				})
			val inspectButton = new Button(
				new Action("Inspect tactic"){
					def apply(){
						Service.graphInspectorCtrl.inspect(name)
					}
				}
			)
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Name : "+value))
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Branch type : "+branchType))
			contents += new FlowPanel(FlowPanel.Alignment.Left)(){
				contents += addSubButton
				contents += editButton
				contents += inspectButton
				contents += delButton
			}
		case "G_Break" =>
			val removeBreakAction = new Action("Remove breakpoint"){
				def apply() {
					QuantoLibAPI.removeBreakpoint(nam)
				}
			}
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Button(removeBreakAction))
		case "G" => // do nothing
	}

}

class VerticesEditContent(names: Set[String]) extends BoxPanel(Orientation.Vertical) {
	var dialog = new Dialog()
	val mergeAction = new Action("Yes"){
		def apply {
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

class EdgeEditContent(nam: String, value: String, src: String, tgt: String) extends BoxPanel(Orientation.Vertical) {
	val titleFont = new Font("Dialog",Font.BOLD,14)
	contents += new FlowPanel(FlowPanel.Alignment.Center)(new Label("Edge Information"){font = titleFont})
	val editButton = new Button(
		new Action("Edit edge") {
			def apply() {
				Service.editEdge(nam,src,tgt,value)
			}
		}
	)
	val breakpointButton = new Button(
		if(QuantoLibAPI.hasBreak(nam)){
			new Action("Remove breakpoint") {
				def apply() {
					QuantoLibAPI.removeBreakpointFromEdge(nam)
				}
			}
		}
		else {
			new Action("Add breakpoint") {
				def apply() {
					QuantoLibAPI.addBreakpointOnEdge(nam)
				}
			}
		}
	)
	val delButton = new Button(
		new Action("Delete edge"){
			def apply(){
				QuantoLibAPI.userDeleteElement(nam)
			}
		})
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
	//minimumSize = new Dimension(250, 250)
	preferredSize = new Dimension(250, 250)
	listenTo(QuantoLibAPI)
	listenTo(Service)
	reactions += {
		case OneVertexSelectedEventAPI(nam, typ, value) =>
			contents.clear()
			contents += new VertexEditContent(nam, typ, value)
			revalidate()
		case ManyVerticesSelectedEventAPI(names) =>
			contents.clear()
			contents += new VerticesEditContent(names)
			revalidate()
		case OneEdgeSelectedEventAPI(nam, value, src, tgt) =>
			contents.clear()
			contents += new EdgeEditContent(nam, value, src, tgt)
			revalidate()
		case NothingSelectedEventAPI() | NothingSelectedEvent() =>
			contents.clear()
			repaint()
	}
}
