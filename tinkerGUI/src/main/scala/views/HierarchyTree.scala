package tinkerGUI.views

import scala.swing._	
import scala.swing.event.MouseClicked
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.HierarchyTreeEvent
import tinkerGUI.controllers.DocumentTitleEvent
import tinkerGUI.controllers.HierarchyTreeController
import java.awt.{ Graphics2D, Color }

class TreeGraph() extends Panel{
	val controller = Service.hierTreeCtrl
	preferredSize = new Dimension(500,500)
	override def paintComponent(g: Graphics2D) {
		val w = this.size.width
		val h = this.size.height
		g.setColor(Color.WHITE)
		g.fillRect(0, 0, w, h)
		g.setColor(Color.BLACK)
		controller.drawTree(g)
		this.preferredSize = controller.preferredSize
	}
	listenTo(this.mouse.moves, this.mouse.clicks)
	reactions += {
		case MouseClicked(_, pt, _, _, _) =>
			controller.hit(pt)
	}
	listenTo(controller)
	reactions += {
		case HierarchyTreeEvent() => this.repaint()
	}
}

object HierarchyTree extends Frame {
	val controller = Service.hierTreeCtrl
	minimumSize  = new Dimension(250,250)
	title = "Tinker - " + Service.mainCtrl.getTitle + " - hierarchy tree"
	listenTo(Service.mainCtrl)
	reactions += {
		case DocumentTitleEvent(t) =>
			title = "Tinker - " + t + " - hierarchy tree"
	}
	contents = new ScrollPane(new TreeGraph())
}