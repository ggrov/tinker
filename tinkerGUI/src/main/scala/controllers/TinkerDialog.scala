package tinkerGUI.controllers

import scala.swing._

object TinkerDialog {
	var max = new Dimension(400, 300)
	var min = new Dimension(250, 100)
	
	def openConfirmationDialog(message: String, actions: Array[Action]):Dialog = {
		var confirmationDialog:Dialog = new Dialog()
		confirmationDialog.maximumSize = max
		confirmationDialog.minimumSize = min
		confirmationDialog.title = "Tinker - Confirmation"
		confirmationDialog.contents = new GridPanel(2,1){
			contents += new Label(message)
			contents += new FlowPanel(){
				actions.foreach{ action =>
					contents += new Button(action)
				}
			}
		}
		confirmationDialog.open()
		confirmationDialog.centerOnScreen()
		return confirmationDialog
	}

	def openErrorDialog(message: String):Dialog = {
		var errorDialog:Dialog = new Dialog()
		errorDialog.maximumSize = max
		errorDialog.minimumSize = min
		errorDialog.title = "Tinker - Error"
		errorDialog.contents = new GridPanel(3,1){
			contents += new FlowPanel(){
				contents += new Label(message){
					icon = new javax.swing.ImageIcon(tinkerGUI.views.MainGUI.getClass.getResource("error.png"), "Error")
				}
			}
			contents += new FlowPanel(){
				contents += new Button(){
					action = new Action("OK"){def apply(){errorDialog.close()}}
				}
			}
			contents += new FlowPanel(){
				contents += new Label("<html><h5>If a problem persists, look at the project website : ggrov.github.io/tinker.</h5></html>")
			}
		}
		errorDialog.open()
		errorDialog.centerOnScreen()
		return errorDialog
	}

	def openEditDialog(message: String, fields: Map[String,String], success:(Map[String,String])=>Unit, failure:()=>Unit):Dialog = {
		var editDialog:Dialog = new Dialog()
		editDialog.maximumSize = max
		editDialog.minimumSize = min
		editDialog.title = "Tinker - Edition"
		var newValMap = Map[String, String]()
		var textfieldMap = Map[String, TextField]()
		editDialog.contents = new GridPanel(fields.size+2, 1){
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
							editDialog.close()
							success(newValMap)
						}
					}
				)
				contents += new Button(
					new Action("Cancel"){
						def apply(){
							editDialog.close()
							failure()
						}
					}
				)
			}
		}
		editDialog.open()
		editDialog.centerOnScreen()
		return editDialog
	}
}