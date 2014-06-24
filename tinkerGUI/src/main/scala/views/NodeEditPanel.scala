package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.NodeEditController
import tinkerGUI.controllers.OneVertexSelectedEvent
import tinkerGUI.controllers.NothingSelectedEvent

class NodeEditPanel() extends Publisher {
	val controller = new NodeEditController()
	
	val nodeName = new Label("Nothing selected.") {
		listenTo(controller)
		reactions += {
			case OneVertexSelectedEvent(str,_,_) =>
				text = "Node : " + str
			case NothingSelectedEvent() =>
				text = "Nothing selected."
		}
	}

	val nodeType = new Label("") {
		listenTo(controller)
		reactions += {
			case OneVertexSelectedEvent(_,str,_) =>
				text = "Type : " + str
			case NothingSelectedEvent() =>
				text = "" 
		}
	}

	val nodeValue = new TextField("",10){
		listenTo(controller)
		reactions += {
			case NothingSelectedEvent() =>
				text = ""
			case OneVertexSelectedEvent(_,_,str) =>
				text = str
		}
	}
	controller.addListener(nodeValue)

	val orRadio = new RadioButton("OR") {selected = true}
	val orElseRadio = new RadioButton("OR ELSE")
	val hierTypeRadioGroup = new ButtonGroup(orRadio, orElseRadio)

	val editFields = new FlowPanel(){
		listenTo(controller)
		reactions += {
			case NothingSelectedEvent() =>
				contents.clear()
				this.repaint()
			case OneVertexSelectedEvent(_,typ,_) =>
				contents.clear()
				contents += new FlowPanel(){
					contents += nodeName
				}
				contents += new FlowPanel(){
					contents += nodeType
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
					contents += new Button("Delete node")
				}
				this.repaint()
		}
	}

	def content = new BoxPanel(Orientation.Vertical) {
		contents += editFields
		minimumSize = new Dimension(200, 300)
	}
}