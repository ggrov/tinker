package tinkerGUI.views

import tinkerGUI.controllers.events.{DisableActionsForEvalEvent, DocumentChangedEvent, RedrawHierarchyTreeEvent}
import tinkerGUI.utils.TinkerDialog
import views.exceptions.InfiniteTreeException

import scala.math._
import scala.swing._
import scala.swing.event.MouseClicked
import tinkerGUI.controllers.Service
import java.awt.{BasicStroke, Graphics2D, Color}

class TreeGraph() extends Panel{
	preferredSize = new Dimension(500,500)

	var elementCoordinates : Array[(String,Int,Int,Int,Int,Array[String])] = Array()

	listenTo()

	def drawTree(g:Graphics2D): Unit ={
		elementCoordinates = Array()
		try{
			drawElement(g, "main", 100, 30, 1, Array())
		} catch {
			case e:InfiniteTreeException => TinkerDialog.openErrorDialog("<html>The hierarchy tree could not be drawn as <br>"+e.msg+"</html>")
		}
	}

	def drawElement(g: Graphics2D, node: String, x: Int, y: Int, depth: Int, parents:Array[String]): Int = {
		val children = Service.hierarchyCtrl.getGTChildren(node)
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
		this.preferredSize = new Dimension(max(preferredSize.getWidth.toInt, childrenWidth+200), max(preferredSize.getHeight.toInt, depth*50+200))
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
				//Service.documentCtrl.registerChanges()
				Service.editCtrl.editSubgraph(c._1, 0, Some(c._6))
			}
		}
	}

	override def paintComponent(g: Graphics2D) {
		val w = this.size.width
		val h = this.size.height
		g.setColor(Color.WHITE)
		g.fillRect(0, 0, w, h)
		g.setColor(Color.BLACK)
		drawTree(g)
		//this.preferredSize = controller.preferredSize
	}

	listenTo(this.mouse.moves, this.mouse.clicks)
	reactions += {
		case MouseClicked(_, pt, _, _, _) if !Service.evalCtrl.inEval =>
			hit(pt)
	}

	listenTo(Service.hierarchyCtrl)
	reactions += {
		case RedrawHierarchyTreeEvent() => this.repaint()
	}
}

object HierarchyTree extends Frame {
	minimumSize  = new Dimension(250,250)
	title = "Tinker - " + Service.documentCtrl.title + " - hierarchy tree"
	listenTo(Service.documentCtrl)
	reactions += {
		case DocumentChangedEvent(_) =>
			title = "Tinker - " + Service.documentCtrl.title + " - hierarchy tree"
	}
	contents = new ScrollPane(new TreeGraph())
}