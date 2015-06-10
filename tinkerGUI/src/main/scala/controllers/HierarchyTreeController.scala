package tinkerGUI.controllers

import tinkerGUI.utils.TinkerDialog

import scala.swing._
import java.awt.{ Graphics2D, Color, FontMetrics, BasicStroke }
import math._

/** Exception class for having an infinite tree, i.e. one tactic having itself as a child.
	*
	* @param msg Custom message.
	*/
case class InfiniteTreeException(msg:String) extends Exception(msg)

class HierarchyTreeController() extends Publisher {
	var elementCoordinates : Array[(String, Int, Int, Int, Int)] = Array()
	var preferredSize = new Dimension(200,200)

	def drawTree(g: Graphics2D){
		elementCoordinates = Array()
		try{
			drawElement(g, "main", 100, 30, 1, Array("main"))
		} catch {
			case e:InfiniteTreeException => TinkerDialog.openErrorDialog("<html>The hierarchy tree could not be drawn as <br>"+e.msg+"</html>")
		}
	}

	def drawElement(g: Graphics2D, node: String, x: Int, y: Int, depth: Int, parents:Array[String]): Int = {
		val children = Service.getGTChildren(node)
		var childrenWidth = 0
		try{
			children.foreach {c =>
				if(parents contains c.name){
					throw new InfiniteTreeException("the graph tactic "+c.name+" has itself as a child.")
				} else {
					var space = 15
					var totalSpace = space+((g.getFontMetrics.getStringBounds(c.name, g).getWidth.toInt /2)-8)
					if(childrenWidth == 0) { space = 0; totalSpace = 0}
					g.drawLine(x, y, x+childrenWidth+totalSpace, y+80)
					childrenWidth += drawElement(g, c.name, x+childrenWidth+totalSpace, y+80, depth+1, parents :+ c.name)
					childrenWidth += space
				}
			}
		} catch {
			case e: InfiniteTreeException => throw e
		}
		preferredSize = new Dimension(max(preferredSize.getWidth.toInt, childrenWidth+200), max(preferredSize.getHeight.toInt, depth*50+200))
		val nodeWidth = if (node == Service.getCurrent) drawActiveNode(g, node, x, y) else drawNode(g, node, x, y)
		if (childrenWidth > 0) childrenWidth
		else nodeWidth
	}

	def drawNode(g: Graphics2D, n: String, x: Int, y: Int): Int ={
		val r = g.getFontMetrics.getStringBounds(n, g)
		g.setColor(new Color(224,224,163))
		g.fillRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setColor(Color.BLACK)
		g.drawRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.drawString(n, x - (r.getWidth.toInt / 2), y + (r.getHeight.toInt / 2))
		elementCoordinates = elementCoordinates :+ (n, x, y, (r.getWidth.toInt+16)/2, (r.getHeight.toInt+16)/2)
		r.getWidth.toInt+16
	}

	def drawActiveNode(g: Graphics2D, n: String, x: Int, y: Int): Int ={
		val r = g.getFontMetrics.getStringBounds(n, g)
		g.setColor(new Color(224,224,163))
		g.fillRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setColor(new Color(51,102,153))
		g.setStroke(new BasicStroke(3))
		g.drawRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setStroke(new BasicStroke(1))
		g.drawString(n, x - (r.getWidth.toInt / 2), y + (r.getHeight.toInt / 2))
		g.setColor(Color.BLACK)
		elementCoordinates = elementCoordinates :+ (n, x, y, (r.getWidth.toInt+16)/2, (r.getHeight.toInt+16)/2)
		r.getWidth.toInt+16
	}

	def hit(pt: java.awt.Point){
		elementCoordinates.foreach { c =>
			if(pt.getX.toInt > c._2-c._4 && pt.getX.toInt < c._2+c._4 && pt.getY.toInt > c._3-c._5 && pt.getY.toInt < c._3+c._5){
				Service.editSubGraph(c._1, 0)
			}
		}
	}

	def redraw() = publish(HierarchyTreeEvent())
}