package tinkerGUI.controllers

import scala.swing._

object TinkerDialog extends Dialog {
	maximumSize = new Dimension(400, 300)
	minimumSize = new Dimension(250, 100)
	
	def openConfirmationDialog(message: String, actions: Array[Action]){
		title = "Tinker - Confirmation"
		contents = new GridPanel(2,1){
			contents += new Label(message)
			contents += new FlowPanel(){
				actions.foreach{ action =>
					contents += new Button(action)
				}
			}
		}
		open()
		centerOnScreen()
	}

	def openErrorDialog(message: String){
		title = "Tinker - Error"
		contents = new GridPanel(3,1){
			contents += new FlowPanel(){
				contents += new Label(message){
					icon = new javax.swing.ImageIcon(tinkerGUI.views.MainGUI.getClass.getResource("error.png"), "Error")
				}
			}
			contents += new FlowPanel(){
				contents += new Button(){
					action = new Action("OK"){def apply(){close()}}
				}
			}
			contents += new FlowPanel(){
				contents += new Label("<html><h5>If a problem persists, look at the project website : ggrov.github.io/tinker.</h5></html>")
			}
		}
		open()
		centerOnScreen()
	}

	def openEditDialog(message: String, fields: Map[String,String], updateValueCallback: (Map[String,String]) => Unit) = {
		title = "Tinker - Edition"
		var newValMap = Map[String, String]()
		var textfieldMap = Map[String, TextField]()
		contents = new GridPanel(fields.size+2, 1){
			contents += new FlowPanel() {
				contents += new Label(message)
			}
			fields.foreach{ case (k,v)=>
				contents += new FlowPanel() {
					contents += new Label(k+" : ")
					val t = new TextField(v, 15)
					contents += t
					textfieldMap = textfieldMap + (k -> t)
				}
			}
			contents += new FlowPanel(){
				contents += new Button(
					new Action("Done"){
						def apply() {
							textfieldMap.foreach{ case (k,v) => newValMap = newValMap + (k -> v.text)}
							updateValueCallback(newValMap)
							close()
						}
					}
				)
				contents += new Button(
					new Action("Cancel"){
						def apply(){close()}
					}
				)
			}
		}
		open()
		centerOnScreen()
	}
}