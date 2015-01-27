package tinkerGUI.views

import scala.swing._
import scala.swing.event.ButtonClicked
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.ElementEditController
import tinkerGUI.controllers.OneVertexSelectedEvent
import tinkerGUI.controllers.ManyVertexSelectedEvent
import tinkerGUI.controllers.OneEdgeSelectedEvent
import tinkerGUI.controllers.NothingSelectedEvent

class VertexEditContent(nam: String, typ: String, value: String, ctrl: ElementEditController) extends FlowPanel {
	val nodeValue = new TextField(value,12)
	val delButton = new Button(
		new Action("Delete node"){
			def apply(){
				ctrl.delete(nam)
			}
		})

	ctrl.addValueListener(nodeValue, (typ == "Nested"))

	contents += new FlowPanel(){
		contents += new Label("Node : " + nam)
	}
	contents += new FlowPanel(){
		contents += new Label("Type : " + typ)
	}
	typ match {
		case "Identity" =>
			contents += new FlowPanel(){
				contents += delButton
			}
		case "Atomic" =>
			val atomicTacticValue = new TextField(ctrl.getAtomicTacticValue(value), 12)
			ctrl.addAtmTctValueListener(atomicTacticValue, nodeValue.text)
			contents += new FlowPanel(){ 
				contents += new Label("Name : ")
				contents += nodeValue
			}
			contents += new FlowPanel(){ 
				contents += new Label("Tactic : ")
				contents += atomicTacticValue
			}
			contents += new FlowPanel(){
				contents += delButton
			}
			// contents += new Button(
			// 	new Action("Save changes"){
			// 		def apply() {
			// 			// ctrl.saveChanges(nodeValue.text, atomicTacticValue.text)
			// 		}
			// 	}){
			// }
		case "Nested" =>
			val orRadio = new RadioButton("OR") {selected = ctrl.getIsNestedOr(value)}
			val orElseRadio = new RadioButton("OR ELSE") {selected = !ctrl.getIsNestedOr(value)}
			val hierTypeRadioGroup = new ButtonGroup(orRadio, orElseRadio)
			val addSubButton = new Button(
				new Action("Add a sub-graph"){
					def apply(){
						ctrl.addNewSubgraph(nodeValue.text)
					}
				})
			contents += new FlowPanel(){ 
				contents += new Label("Name : ")
				contents += nodeValue
			}
			contents += new FlowPanel(){
				contents += orRadio
				contents += orElseRadio
			}
			contents += new FlowPanel(){
				contents += addSubButton
			}
			hierTypeRadioGroup.buttons.foreach(listenTo(_))
			reactions += {
				case ButtonClicked(b: RadioButton) =>
					if (b == orRadio){ctrl.setIsNestedOr(nodeValue.text, true)}
					else if (b == orElseRadio){ctrl.setIsNestedOr(nodeValue.text, false)}
			}
			contents += new FlowPanel(){
				contents += delButton
			}
		case "Breakpoint" =>
			contents += new FlowPanel() {
				contents += new Button(ctrl.removeBreakpoint(nam))
			}
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
			return res
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
			contents += new VertexEditContent(nam, typ, value, controller)
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
