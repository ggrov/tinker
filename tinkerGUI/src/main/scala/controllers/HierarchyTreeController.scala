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
	var elementParents : Map[String,Array[Array[String]]] = Map()
	def editElementParent = {
		//def adjust[A,B](m: Map[A,B], k: A)(f: B => B) = m.updated(k, f(m(k)))
		def rec(t:String,p:Array[String], map:Map[String,Array[Array[String]]]):Map[String,Array[Array[String]]] = {
			var m = map
			if(m contains t) m = m.updated(t, m(t):+p)
			else m += (t->Array(p))
			Service.getGTChildren(t).foreach{ c =>
				m = rec(c.name,p:+t, m)
			}
			m
		}
		elementParents = rec("main",Array(),Map())
		//println(elementParents.foldLeft("---"){case (s,(k,v)) => s+"\ntactic : "+k+" - parents : "+v.foldLeft(""){case (s,p) => s+"\n    "+p.mkString(" > ")}})
	}
	editElementParent
	var elementCoordinates : Array[(String, Int, Int, Int, Int, Array[String])] = Array()
	var preferredSize = new Dimension(200,200)

	def drawTree(g: Graphics2D){
		elementCoordinates = Array()
		try{
			drawElement(g, "main", 100, 30, 1, Array())
		} catch {
			case e:InfiniteTreeException => TinkerDialog.openErrorDialog("<html>The hierarchy tree could not be drawn as <br>"+e.msg+"</html>")
		}
	}

	def drawElement(g: Graphics2D, node: String, x: Int, y: Int, depth: Int, parents:Array[String]): Int = {
		val children = Service.getGTChildren(node)
		var childrenWidth = 0
		try{
			if(parents contains node){
				throw new InfiniteTreeException("the graph tactic "+node+" has itself as a child.")
			}
			children.foreach {c =>
				if(parents contains c.name){
					throw new InfiniteTreeException("the graph tactic "+c.name+" has itself as a child.")
				} else {
					var space = 15
					var totalSpace = space+((g.getFontMetrics.getStringBounds(c.name, g).getWidth.toInt /2)-8)
					if(childrenWidth == 0) { space = 0; totalSpace = 0}
					g.drawLine(x, y, x+childrenWidth+totalSpace, y+80)
					childrenWidth += drawElement(g, c.name, x+childrenWidth+totalSpace, y+80, depth+1, parents :+ node)
					childrenWidth += space
				}
			}
		} catch {
			case e: InfiniteTreeException => throw e
		}
		preferredSize = new Dimension(max(preferredSize.getWidth.toInt, childrenWidth+200), max(preferredSize.getHeight.toInt, depth*50+200))
		val nodeWidth = if (node == Service.getCurrent) drawActiveNode(g, node, x, y, parents) else drawNode(g, node, x, y, parents)
		if (childrenWidth > 0) childrenWidth
		else nodeWidth
	}

	def drawNode(g: Graphics2D, n: String, x: Int, y: Int, parents:Array[String]): Int ={
		val r = g.getFontMetrics.getStringBounds(n, g)
		g.setColor(new Color(224,224,163))
		g.fillRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setColor(Color.BLACK)
		g.drawRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.drawString(n, x - (r.getWidth.toInt / 2), y + (r.getHeight.toInt / 2))
		elementCoordinates = elementCoordinates :+ (n, x, y, (r.getWidth.toInt+16)/2, (r.getHeight.toInt+16)/2, parents)
		r.getWidth.toInt+16
	}

	def drawActiveNode(g: Graphics2D, n: String, x: Int, y: Int, parents:Array[String]): Int ={
		val r = g.getFontMetrics.getStringBounds(n, g)
		g.setColor(new Color(224,224,163))
		g.fillRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setColor(new Color(51,102,153))
		g.setStroke(new BasicStroke(3))
		g.drawRect(x - (r.getWidth.toInt / 2) - 8, y - (r.getHeight.toInt / 2) - 8, r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setStroke(new BasicStroke(1))
		g.drawString(n, x - (r.getWidth.toInt / 2), y + (r.getHeight.toInt / 2))
		g.setColor(Color.BLACK)
		elementCoordinates = elementCoordinates :+ (n, x, y, (r.getWidth.toInt+16)/2, (r.getHeight.toInt+16)/2, parents)
		r.getWidth.toInt+16
	}

	def hit(pt: java.awt.Point){
		elementCoordinates.foreach { c =>
			if(pt.getX.toInt > c._2-c._4 && pt.getX.toInt < c._2+c._4 && pt.getY.toInt > c._3-c._5 && pt.getY.toInt < c._3+c._5){
				Service.editSubGraph(c._1, 0, Some(c._6))
			}
		}
	}

	def redraw() = publish(HierarchyTreeEvent())
	listenTo(Service)
	reactions += {
		case GraphTacticListEvent() =>
			editElementParent
			publish(HierarchyTreeEvent())
	}
}