package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.ElementEditController
import tinkerGUI.controllers.OneVertexSelectedEvent
import tinkerGUI.controllers.OneEdgeSelectedEvent
import tinkerGUI.controllers.NothingSelectedEvent

class VertexEditContent(nam: String, typ: String, value: String, ctrl: ElementEditController) extends FlowPanel {
	val nodeValue = new TextField(value,10)
	val orRadio = new RadioButton("OR") {selected = true}
	val orElseRadio = new RadioButton("OR ELSE")
	val hierTypeRadioGroup = new ButtonGroup(orRadio, orElseRadio)
	val delButton = new Button("Delete node")
	ctrl.addValueListener(nodeValue)
	ctrl.addDeleteListener(delButton, nam)
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
	}
	contents += new FlowPanel(){
		contents += delButton
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
	val controller = new ElementEditController()

	// val content = new BoxPanel(Orientation.Vertical) {
		minimumSize = new Dimension(220, 250)
		listenTo(controller)
		reactions += {
			case OneVertexSelectedEvent(nam, typ, value) =>
				contents.clear()
				contents += new VertexEditContent(nam, typ, value, controller)
				revalidate()
			case OneEdgeSelectedEvent(nam, value, src, tgt) =>
				contents.clear()
				contents += new EdgeEditContent(nam, value, src, tgt, controller)
				revalidate()
			case NothingSelectedEvent() =>
				contents.clear()
				repaint()
		// }
	}
}
