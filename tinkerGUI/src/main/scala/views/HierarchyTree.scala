package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.Service
import tinkerGUI.controllers.HierarchyTreeController
import java.awt.{ Graphics2D, Color }
import java.awt.{Font => AWTFont, BasicStroke, RenderingHints, Color}

class TreeGraph() extends Panel{
	val controller = Service.hierTreeCtrl
	// need to get maxX and maxY from controller
	preferredSize = new Dimension(500,500)
	override def paintComponent(g: Graphics2D) {
		val w = this.size.width
		val h = this.size.height
		g.setColor(Color.WHITE)
		g.fillRect(0, 0, w, h)
		g.setColor(Color.BLACK)
		// g.setStroke(new BasicStroke(2))
		// g.drawLine(50, 30, 50, 90)
		// g.drawLine(50, 90, 100, 150)
		// g.setStroke(new BasicStroke(1))
		// controller.drawNode(g, "main", 50, 30)
		// controller.drawNode(g, "n e s t e d", 50, 90)
		// controller.drawNode(g, "i'm nested and i know it", 300, 300)
		controller.drawTree(g)
		this.preferredSize = controller.preferredSize
	}
	
}

object HierarchyTree extends Frame {
	val controller = Service.hierTreeCtrl
	minimumSize  = new Dimension(250,250)
	title = "Tinker - " + Service.mainCtrl.getTitle + " - hierarchy tree"
	contents = new ScrollPane(new TreeGraph())
}