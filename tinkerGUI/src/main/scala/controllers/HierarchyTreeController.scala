package tinkerGUI.controllers

import scala.swing._
import java.awt.{ Graphics2D, Color, FontMetrics, BasicStroke }
// import javax.swing.JComponent
import scala.collection.mutable.ArrayBuffer
import math._
import tinkerGUI.model.TreeElement

class HierarchyTreeController() extends Publisher {
	val root = Service.getHierarchyRoot

	var preferredSize = new Dimension(200,200)

	def drawTree(g: Graphics2D){
		drawElement(g, root, 100, 30, 1)
	}

	def drawElement(g: Graphics2D, node: TreeElement, x: Int, y: Int, depth: Int): Int = {
		var childrenWidth = 0
		node.children.foreach {c =>
			var space = 30
			if(childrenWidth == 0) space = 0
			g.drawLine(x, y, x+childrenWidth+space, y+80)
			childrenWidth += drawElement(g, c, x+childrenWidth+space, y+80, depth+1)
			childrenWidth += space
		}
		preferredSize = new Dimension(max(preferredSize.getWidth().toInt, childrenWidth+200), max(preferredSize.getHeight().toInt, depth*50+200))
		var nodeWidth = 0
		if (node == Service.getHierarchyActive) nodeWidth = drawActiveNode(g, node.name, x, y)
		else nodeWidth = drawNode(g, node.name, x, y)
		if (childrenWidth > 0) childrenWidth
		else nodeWidth
	}

	def drawNode(g: Graphics2D, n: String, x: Int, y: Int): Int ={
		val r = g.getFontMetrics().getStringBounds(n, g)
		g.setColor(new Color(224,224,163))
		g.fillRect((x-(r.getWidth.toInt/2)-8), (y-(r.getHeight.toInt/2)-8), r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setColor(Color.BLACK)
		g.drawRect((x-(r.getWidth.toInt/2)-8), (y-(r.getHeight.toInt/2)-8), r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.drawString(n, (x-(r.getWidth.toInt/2)), (y+(r.getHeight.toInt/2)))
		r.getWidth.toInt+16
	}

	def drawActiveNode(g: Graphics2D, n: String, x: Int, y: Int): Int ={
		val r = g.getFontMetrics().getStringBounds(n, g)
		g.setColor(new Color(224,224,163))
		g.fillRect((x-(r.getWidth.toInt/2)-8), (y-(r.getHeight.toInt/2)-8), r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setColor(new Color(51,102,153))
		g.setStroke(new BasicStroke(3))
		g.drawRect((x-(r.getWidth.toInt/2)-8), (y-(r.getHeight.toInt/2)-8), r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setStroke(new BasicStroke(1))
		g.drawString(n, (x-(r.getWidth.toInt/2)), (y+(r.getHeight.toInt/2)))
		g.setColor(Color.BLACK)
		r.getWidth.toInt+16
	}

	def redraw = publish(HierarchyTreeEvent())
}