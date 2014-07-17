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
}