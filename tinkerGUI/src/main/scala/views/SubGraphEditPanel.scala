package tinkerGUI.views

import scala.swing._
import scala.swing.event._
import java.awt.Font
import java.awt.Cursor

class SubGraphEditPanel() extends FlowPanel {
	minimumSize = new Dimension(220, 250)
	val link = new Label() {
		text = "hello"
		foreground = new Color(0, 128, 255)
	}
	contents += link
	listenTo(link.mouse.moves, link.mouse.clicks)
	reactions += {
		case MouseEntered(_, _, _) =>
			link.cursor = new Cursor(java.awt.Cursor.HAND_CURSOR)
		case MouseClicked(_, _, _, _, _) =>
			println("change graph")
	}
}