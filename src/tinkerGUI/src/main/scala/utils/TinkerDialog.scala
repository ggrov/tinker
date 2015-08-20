package tinkerGUI.utils

import scala.swing._
import scala.swing.event.KeyReleased

/** Object implementing generic dialogs for tinker.
	*
	* Enable to display four types of dialogs :
	* - one asking for confirmation of action ;
	* - one reporting errors ;
	* - one simply displaying messages ;
	* - one enabling field completion.
	*/
object TinkerDialog {

	/** Maximum dimensions of the dialog window.*/
	var max = new Dimension(400, 300)

	/** Minimum dimensions of the dialog window.*/
	var min = new Dimension(250, 100)

	/** Method opening a confirmation dialog.
		*
		* @param message Custom message do display, e.g. "You are about to do something dangerous. Do you wish to continue ?".
		* @param actions List of possible actions, e.g. "Yes" and "No".
		* @return Dialog instance. Must be closed by the actions.
		*/
	def openConfirmationDialog(message: String, actions: Array[Action]):Dialog = {
		val confirmationDialog: Dialog = new Dialog()
		confirmationDialog.resizable = false
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
		confirmationDialog
	}

	/** Method opening an error dialog.
		*
		* @param message Custom message, e.g. "Something went wrong there.".
		* @return Dialog instance.
		*/
	def openErrorDialog(message: String):Dialog = {
		val errorDialog:Dialog = new Dialog()
		errorDialog.resizable = false
		errorDialog.maximumSize = max
		errorDialog.minimumSize = min
		errorDialog.title = "Tinker - Error"
		errorDialog.contents = new GridPanel(2,1){
			contents += new FlowPanel(){
				contents += new Label("<html><body style='width:400px'>"+message+"</body></html>"){
					maximumSize = new Dimension(max)
					icon = new javax.swing.ImageIcon(tinkerGUI.views.MainGUI.getClass.getResource("error.png"), "Error")
				}
			}
			contents += new FlowPanel(){
				contents += new Button(){
					action = new Action("OK"){def apply(){errorDialog.close()}}
				}
			}
//			contents += new FlowPanel(){
//				contents += new Label("<html><h5>If a problem persists, look at the project website : ggrov.github.io/tinker.</h5></html>")
//			}
		}
		errorDialog.open()
		errorDialog.centerOnScreen()
		errorDialog
	}

	/** Method opening a dialog displaying a message.
		*
		* @param message Custom message, e.g. "Something happened.".
		* @return Dialog instance.
		*/
	def openInformationDialog(message: String):Dialog = {
		val infoDialog:Dialog = new Dialog()
		infoDialog.resizable = false
		infoDialog.maximumSize = max
		infoDialog.minimumSize = min
		infoDialog.title = "Tinker - Message"
		infoDialog.contents = new GridPanel(3,1){
			contents += new FlowPanel(){
				contents += new Label("<html><body style='width:400px'>"+message+"</body></html>")
			}
			contents += new FlowPanel(){
				contents += new Button(){
					action = new Action("OK"){def apply(){infoDialog.close()}}
				}
			}
		}
		infoDialog.open()
		infoDialog.centerOnScreen()
		infoDialog
	}

	/** Method opening and edit dialog.
		*
		* @param message Custom message, e.g. "You are editing this.".
		* @param fields Map of the fields, e.g. "Name" -> value. Value can be empty.
		* @param success Success callback, i.e. what to do with the new values when the user clicks "Done".
		* @param failure Failure callback, i.e. what to do when the user clicks "Cancel".
		* @return Dialog instance.
		*/
	def openEditDialog(message: String, fields: Map[String,String], success:(Map[String,String])=>Unit, failure:()=>Unit):Dialog = {
		val editDialog:Dialog = new Dialog()
		editDialog.resizable = false
		editDialog.maximumSize = max
		editDialog.minimumSize = min
		editDialog.title = "Tinker - Edition"
		var newValMap = Map[String, String]()
		var textfieldMap = Map[String, TextComponent]()
		var radios:List[RadioButton] = List()
		editDialog.contents = new GridPanel(fields.size+2, 1){
			contents += new FlowPanel() {
				contents += new Label(message)
			}
			fields.foreach{ case (k,v)=>
				contents += new FlowPanel() {
					contents += new Label(k+" : ")
					if(k=="Branch type") {
						val orRadio = new RadioButton("OR"){selected = v=="OR"}
						val orelseRadio = new RadioButton("ORELSE"){selected = v=="ORELSE"}
						new ButtonGroup(orRadio, orelseRadio)
						radios = List(orRadio, orelseRadio)
						contents ++= radios
						textfieldMap += (k -> new TextField())
					} else if(k=="From" || k=="To"){
						val t = new TextField(v, 5)
						contents += t
						textfieldMap += (k -> t)
					} else if(k=="Name"||k=="Proof name"||k=="Goal"){
						val t = new UnicodeTextField(v, 15)
						contents += t
						textfieldMap += (k -> t)
					} else {
						val t = new UnicodeTextArea(v, 3, 20)
						contents += new ScrollPane(t)
						textfieldMap += (k -> t)
					}
				}
			}
			contents += new FlowPanel(){
				contents += new Button(
					new Action("Done"){
						def apply() {
							textfieldMap.foreach { case (k, v) =>
								if (k == "Branch type") {
									var text = ""
									radios.foreach { case r => if (r.selected) text = r.text }
									newValMap += (k -> text)
								} else {
									newValMap += (k -> v.text)
								}
							}
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
		editDialog
	}
}