package tinkerGUI.views

import tinkerGUI.controllers.{QuantoLibAPI, Service}
import tinkerGUI.controllers.events._
import tinkerGUI.utils.MutableComboBox

import scala.swing._
import scala.swing.event.{SelectionChanged, UIElementResized}
import javax.swing.ImageIcon
import java.awt.{Cursor, Font, Insets}


class GraphInspectorPanel() extends BorderPanel {
	// TODO make tactic navigation menu when necessary

	val tacticNavigationButtons = new FlowPanel(FlowPanel.Alignment.Left)(){

		contents += new Button(new Action(""){
			def apply(): Unit = {
				Service.inspectorCtrl.toggleLock()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("inspectUnlocked.png"), "Lock")
			tooltip = "Lock inspector"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case InspectorLockEvent(l:Boolean) =>
					if(l){
						icon = new ImageIcon(MainGUI.getClass.getResource("inspectLocked.png"), "Unlock")
						tooltip = "Unlock inspector"
					} else {
						icon = new ImageIcon(MainGUI.getClass.getResource("inspectUnlocked.png"), "Lock")
						tooltip = "Lock inspector"
					}
			}
		}
		contents += new Button(new Action("") {
			def apply() {
				Service.inspectorCtrl.showPrev()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("previous.png"), "Prev")
			tooltip = "Previous"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case DisableNavigationEvent(a:Array[String]) =>
					enabled = !(a contains "prev")
			}
		}
		contents += Service.inspectorCtrl.indexOnTotal
		contents += new Button(new Action("") {
			def apply() {
				Service.inspectorCtrl.showNext()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("next.png"), "Next")
			tooltip = "Next"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case DisableNavigationEvent(a:Array[String]) =>
					enabled = !(a contains "next")
			}
		}
		contents += new Button(new Action("") {
			def apply() {
				QuantoLibAPI.zoomInSubgraphPreview()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("zoom-in.png"), "Zoom in")
			tooltip = "Zoom in"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case DisableNavigationEvent(a:Array[String]) =>
					enabled = !(a contains "zoomin")
			}
		}
		contents += new Button(new Action("") {
			def apply() {
				QuantoLibAPI.zoomOutSubgraphPreview()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("zoom-out.png"), "Zoom out")
			tooltip = "Zoom out"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case DisableNavigationEvent(a:Array[String]) =>
					enabled = !(a contains "zoomout")
			}
		}
		contents += new Button(new Action("") {
			def apply() {
				Service.inspectorCtrl.edit()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("edit-pen.png"), "Edit")
			tooltip = "Edit"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case DisableNavigationEvent(a:Array[String]) =>
					enabled = !(a contains "edit")
			}
		}
		contents += new Button(new Action(""){
			def apply() {
				Service.inspectorCtrl.add()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("add.png"), "Add")
			tooltip = "Add"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case DisableNavigationEvent(a:Array[String]) =>
					enabled = !(a contains "add")
			}
		}
		contents += new Button(new Action("") {
			def apply() {
				Service.inspectorCtrl.delete()
			}
		}){
			icon = new ImageIcon(MainGUI.getClass.getResource("delete.png"), "Delete")
			tooltip = "Delete"
			borderPainted = false
			margin = new Insets(0,0,0,0)
			contentAreaFilled = false
			opaque = false
			cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
			listenTo(Service.inspectorCtrl)
			reactions += {
				case DisableNavigationEvent(a:Array[String]) =>
					enabled = !(a contains "del")
			}
		}
	}

	var tacticNavigation = new BoxPanel(Orientation.Vertical){}

	val noSubgraphLabel = new Label("This tactic does not have any subgraphs.")

	val header = new BorderPanel {

		val titleFont = new Font("Dialog",Font.BOLD,14)
		add(new FlowPanel(FlowPanel.Alignment.Center)(new Label("Tactic inspector"){font = titleFont}),BorderPanel.Position.North)

		add(new FlowPanel(FlowPanel.Alignment.Left)(){
			var list = Service.inspectorCtrl.gtList
			list = list :+ "Select a tactic"
			val cb = new MutableComboBox[String]
			cb.items = list
			cb.item = "Select a tactic"
			listenTo(Service.inspectorCtrl)
			reactions += {
				case UpdateGTListEvent() =>
					val selected = cb.item
					var list = Service.inspectorCtrl.gtList
					list = list :+ "Select a tactic"
					cb.items = list
					cb.item = if(list contains selected) selected else "Select a tactic"
				case UpdateSelectedTacticToInspectEvent(name:String) =>
					cb.item = name
			}
			contents += cb
			listenTo(cb)
			reactions += {
				case SelectionChanged(`cb`) => Service.inspectorCtrl.inspect(cb.item)
			}
		},BorderPanel.Position.West)

		add(new FlowPanel(FlowPanel.Alignment.Right)(tacticNavigation),BorderPanel.Position.East)
		add(new FlowPanel(FlowPanel.Alignment.Center)(noSubgraphLabel),BorderPanel.Position.South)
	}

	//header.visible = false

	val subgraphPanel = QuantoLibAPI.getSubgraphPreview

	add(header, BorderPanel.Position.North)
	add(subgraphPanel, BorderPanel.Position.Center)

	minimumSize = new Dimension(200, 200)
	//preferredSize = new Dimension(400, 550)

	subgraphPanel.visible = false
	noSubgraphLabel.visible = false
	tacticNavigation.visible = false

	if(this.size.width >= 400){
		tacticNavigation.contents += tacticNavigationButtons
	} else if (this.size.width < 400){
		tacticNavigation.contents += new MenuBar(){
			contents += new Menu("") {
				contents += tacticNavigationButtons
				icon = new ImageIcon(MainGUI.getClass.getResource("menu.png"), "Menu")
				tooltip = "Navigation menu"
				borderPainted = false
				margin = new Insets(0,0,0,0)
				contentAreaFilled = false
				opaque = false
				horizontalAlignment = Alignment.Left
				// TODO : override get popuplocation
			}
			minimumSize = new Dimension(200,100)
		}
	}
	var prevWidth = this.size.width

	listenTo(Service.inspectorCtrl)
	reactions += {
		case PreviewEvent(show,hasSubgraph) =>
			if(show){
				if(hasSubgraph){
					subgraphPanel.visible = true
					noSubgraphLabel.visible = false
				} else {
					noSubgraphLabel.visible = true
					subgraphPanel.visible = false
				}
				tacticNavigation.visible = true
			} else {
				subgraphPanel.visible = false
				noSubgraphLabel.visible = false
				tacticNavigation.visible = false
			}
			this.repaint()
	}

	listenTo(this)
	reactions += {
		case UIElementResized(source) =>
			if(source.equals(this)){
				if(source.size.width >= 400 && prevWidth < 400){
					tacticNavigation.contents.clear()
					tacticNavigation.contents += tacticNavigationButtons
				} else if (source.size.width < 400 && prevWidth >= 400){
					tacticNavigation.contents.clear()
					tacticNavigation.contents += new MenuBar(){
						contents += new Menu("") {
							contents += tacticNavigationButtons
							icon = new ImageIcon(MainGUI.getClass.getResource("menu.png"), "Menu")
							tooltip = "Navigation menu"
							borderPainted = false
							margin = new Insets(0,0,0,0)
							contentAreaFilled = false
							opaque = false
							horizontalAlignment = Alignment.Right
							xLayoutAlignment = 1.0
							yLayoutAlignment = 1.0
						}
						minimumSize = new Dimension(200,100)
					}
				}
				prevWidth = this.size.width
			}
	}

	def display(visible:Boolean){
		header.visible = visible
	}
}