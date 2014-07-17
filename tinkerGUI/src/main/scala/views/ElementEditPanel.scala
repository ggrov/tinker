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
	val orRadio = new RadioButton("OR") {selected = ctrl.getIsNestedOr(value)}
	val orElseRadio = new RadioButton("OR ELSE") {selected = !ctrl.getIsNestedOr(value)}
	val hierTypeRadioGroup = new ButtonGroup(orRadio, orElseRadio)
	val delButton = new Button("Delete node")
	val addSubButton = new Button("Add a sub-graph")

	ctrl.addValueListener(nodeValue)
	ctrl.addDeleteListener(delButton, nam)
	ctrl.addNewSubListener(addSubButton, nodeValue.text, orRadio)

	contents += new FlowPanel(){
		contents += new Label("Node : " + nam)
	}
	contents += new FlowPanel(){
		contents += new Label("Type : " + typ)
	}
	typ match {
		case "Identity" => // add nothing
		case "Atomic" =>
			contents += new FlowPanel(){ 
				contents += new Label("RTech. : ")
				contents += nodeValue
			}
		case "Nested" =>
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
	}
	contents += new FlowPanel(){
		contents += delButton
	}

	hierTypeRadioGroup.buttons.foreach(listenTo(_))
	reactions += {
		case ButtonClicked(b: RadioButton) =>
			if (b == orRadio){ctrl.setIsNestedOr(nodeValue.text, true)}
			else if (b == orElseRadio){ctrl.setIsNestedOr(nodeValue.text, false)}
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
	val delButton = new Button("Delete edge")
	ctrl.addValueListener(edgeValue)
	ctrl.addDeleteListener(delButton, nam)
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
		contents += delButton
	}
}

class ElementEditPanel() extends BoxPanel(Orientation.Vertical) {
	val controller = Service.eltEditCtrl
	minimumSize = new Dimension(220, 250)
	listenTo(controller)
	listenTo(Service)
	reactions += {
		case OneVertexSelectedEvent(nam, typ, value) =>
			contents.clear()
			contents += new VertexEditContent(nam, typ, value, controller)
			revalidate()
		case ManyVertexSelectedEvent(names) =>
			contents.clear()
			contents += new VerticesEditContent(names, controller)
			revalidate()
		case OneEdgeSelectedEvent(nam, value, src, tgt) =>
			contents.clear()
			contents += new EdgeEditContent(nam, value, src, tgt, controller)
			revalidate()
		case NothingSelectedEvent() =>
			contents.clear()
			repaint()
	}
}
