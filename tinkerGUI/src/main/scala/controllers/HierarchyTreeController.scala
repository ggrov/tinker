package tinkerGUI.controllers

import scala.swing._
import java.awt.{ Graphics2D, Color, FontMetrics }
// import javax.swing.JComponent
import scala.collection.mutable.ArrayBuffer
import math._

class TreeElement(val name: String, val children: ArrayBuffer[TreeElement])

class HierarchyTreeController() extends Publisher {
	val root = new TreeElement("main", ArrayBuffer(
		new TreeElement("nested-1", ArrayBuffer(
			new TreeElement("nested-4", ArrayBuffer())
			)
		), 
		new TreeElement("nested-2", ArrayBuffer(
			new TreeElement("nested-5", ArrayBuffer()), 
			new TreeElement("nested-6", ArrayBuffer()),
			new TreeElement("nested-10", ArrayBuffer(
				new TreeElement("nested-11", ArrayBuffer(
					new TreeElement("nested-12", ArrayBuffer()),
					new TreeElement("nested-13", ArrayBuffer(
						new TreeElement("nested-5", ArrayBuffer()), 
						new TreeElement("nested-6", ArrayBuffer()),
						new TreeElement("nested-10", ArrayBuffer(
							new TreeElement("nested-11", ArrayBuffer(
								new TreeElement("nested-12", ArrayBuffer()),
								new TreeElement("nested-13", ArrayBuffer(

									))
								)
							))
						)))
					)
				))
			))
		), 
		new TreeElement("nested-3", ArrayBuffer(
			new TreeElement("nested-7", ArrayBuffer(
				new TreeElement("nested-8", ArrayBuffer()),
				new TreeElement("nested-9", ArrayBuffer())
				)
			))
		))
	)

	var preferredSize = new Dimension(200,200)

	def drawTree(g: Graphics2D){
		drawElement(g, root, 100, 30, 1)
	}

	def drawElement(g: Graphics2D, node: TreeElement, x: Int, y: Int, depth: Int): Int = {
		var childrenWidth = 0
		node.children.foreach {c =>
			var space = 30
			if(childrenWidth == 0) space = 0
			g.drawLine(x, y, x+childrenWidth+space, y+50)
			childrenWidth += drawElement(g, c, x+childrenWidth+space, y+50, depth+1)
			childrenWidth += space
		}
		preferredSize = new Dimension(max(preferredSize.getWidth().toInt, childrenWidth+200), max(preferredSize.getHeight().toInt, depth*50+200))
		var nodeWidth = drawNode(g, node.name, x, y)
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
		// g.drawString(n, (x+w/2), (y+h))

		// println(g.getFontMetrics().getStringBounds(n, g))
		// g.drawRect(r.getX.toInt+50, r.getY.toInt+50, r.getWidth.toInt, r.getHeight.toInt)
	}
}