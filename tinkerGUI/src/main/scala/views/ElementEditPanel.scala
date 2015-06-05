package tinkerGUI.views

import tinkerGUI.model.AtomicTacticNotFoundException

import scala.swing._
import scala.swing.event.ButtonClicked
import tinkerGUI.controllers._
import tinkerGUI.utils.ArgumentParser
import java.awt.Font

class VertexEditContent(nam: String, typ: String, value: String) extends BoxPanel(Orientation.Vertical) {
	val titleFont = new Font("Dialog",Font.BOLD,14)
	contents += new FlowPanel(FlowPanel.Alignment.Center)(new Label("Node Information"){font = titleFont})
	
	val delButton = new Button(
		new Action("Delete node"){
			def apply(){
				// TODO new delete
				QuantoLibAPI.userDeleteElement(nam)
			}
		})
	val editButton = new Button(
		new Action("Edit tactic"){
			def apply(){
				Service.updateTactic(nam,value,typ=="Atomic")
			}
		})

	contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Node : " + nam))
	contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Type : " + typ))
	typ match {
		case "Identity" =>
			contents += new FlowPanel(FlowPanel.Alignment.Left)(delButton)
		case "Atomic" =>
			val tacticCoreId = try {
				Service.getATCoreId(ArgumentParser.separateNameFromArgument(value)._1)
			} catch {
				case e:AtomicTacticNotFoundException => "File error : could not find tactic"
			}
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Name : "+value))
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Tactic : "+tacticCoreId))
			contents += new FlowPanel(FlowPanel.Alignment.Left)() {
				contents += editButton
				contents += delButton
			}
		case "Nested" =>
			val orRadio = new RadioButton("OR") {selected = true}// ctrl.getIsNestedOr(value)}
			val orElseRadio = new RadioButton("OR ELSE") {selected =false} // !ctrl.getIsNestedOr(value)}
			val hierTypeRadioGroup = new ButtonGroup(orRadio, orElseRadio)
			val addSubButton = new Button(
				new Action("Add a sub-graph"){
					def apply(){
						//ctrl.addNewSubgraph(value)
					}
				})
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Label("Name : "+value))
			contents += new FlowPanel(FlowPanel.Alignment.Left)(){
				contents += orRadio
				contents += orElseRadio
			}
			hierTypeRadioGroup.buttons.foreach(listenTo(_))
			reactions += {
				case ButtonClicked(b: RadioButton) =>
					//if (b == orRadio) ctrl.setIsNestedOr(value, isOr = true)
					//else if (b == orElseRadio) ctrl.setIsNestedOr(value, isOr = false)
			}
			contents += new FlowPanel(FlowPanel.Alignment.Left)(){
				contents += addSubButton
				contents += editButton
				contents += delButton
			}
		case "Breakpoint" =>
			contents += new FlowPanel(FlowPanel.Alignment.Left)(new Button())//ctrl.removeBreakpoint(nam)))
		case "Goal" => // do nothing
	}

}

class VerticesEditContent(names: Set[String], ctrl: ElementEditController) extends FlowPanel {
	val mergeButton = new Button("Merge into nested node.")
	ctrl.addMergeListener(mergeButton, names)
	contents += new FlowPanel(){
		def prettyString(s: Set[String]) : String = {
			var res = s.head
			s.tail.foreach{ e =>
				res += ", " + e
			}
			res
		}
		contents += new Label("Nodes : " + prettyString(names))
	}
	contents += new FlowPanel(){
		contents += mergeButton
	}
}

class EdgeEditContent(nam: String, value: String, src: String, tgt: String, ctrl: ElementEditController) extends FlowPanel {
	val edgeValue = new TextField(value, 10)
	val edgeSrc = new TextField(src, 3)
	val edgeTgt = new TextField(tgt, 3)
	val delButton = new Button(
		new Action("Delete edge"){
			def apply(){
				ctrl.delete(nam)
			}
		})
	ctrl.addEdgeValueListener(nam, edgeValue)
	ctrl.addEdgeListener(nam, edgeSrc, edgeTgt)
	contents += new FlowPanel(){
		contents += new Label("Edge : " + nam)
	}
	contents += new FlowPanel(){
		contents += new Label("Goal types :")
		contents += edgeValue
	}
	contents += new FlowPanel(){
		contents += new Label("From : ")
		contents += edgeSrc
		contents += new Label("To : ")
		contents += edgeTgt
	}
	contents += new FlowPanel(){
		contents += new Button(ctrl.breakpoint(nam))
	}
	contents += new FlowPanel(){
		contents += delButton
	}
}

class ElementEditPanel() extends BoxPanel(Orientation.Vertical) {
	val controller = Service.eltEditCtrl
	//minimumSize = new Dimension(250, 250)
	preferredSize = new Dimension(250, 250)
	listenTo(controller)
	listenTo(Service)
	reactions += {
		case OneVertexSelectedEvent(nam, typ, value) =>
			contents.clear()
			controller.reset
			contents += new VertexEditContent(nam, typ, value)
			revalidate()
		case ManyVertexSelectedEvent(names) =>
			contents.clear()
			controller.reset
			contents += new VerticesEditContent(names, controller)
			revalidate()
		case OneEdgeSelectedEvent(nam, value, src, tgt) =>
			contents.clear()
			controller.reset
			contents += new EdgeEditContent(nam, value, src, tgt, controller)
			revalidate()
		case NothingSelectedEvent() =>
			contents.clear()
			controller.reset
			repaint()
	}
}
