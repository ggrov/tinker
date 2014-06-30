package tinkerGUI.controllers

import scala.swing._

object Service extends Publisher {
	val mainCtrl: MainGUIController = new MainGUIController()
	val graphEditCtrl: GraphEditController = new GraphEditController()
	val eltEditCtrl: ElementEditController = new ElementEditController()
	val menuCtrl: MenuController = new MenuController()
	val editControlsCtrl: EditControlsController = new EditControlsController()

	def getMainController = mainCtrl
	def getEltEditController = eltEditCtrl
	def getGraphEditController = graphEditCtrl
	def getEditControlsController = editControlsCtrl
	def getMenuController = menuCtrl
		// str match {
		// 	case "main" =>
		// 	case "menu" =>
		// 		return menuCtrl
		// 	case "graphEdit" =>
		// 		return graphEditCtrl
		// 	case "editControls" =>
		// 		return editControlsCtrl
		// 	case "eltEdit" =>
		// 		return eltEditCtrl
		// }

	def changeGraphEditMouseState(state: String){
		graphEditCtrl.changeMouseState(state)
	}
}