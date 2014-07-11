package tinkerGUI.controllers

import scala.swing._
import java.awt.{ Graphics2D, Color, FontMetrics }
// import javax.swing.JComponent

class HierarchyTreeController() extends Publisher {
	
	var map: Map[String, Array[String]] = Map[String, Array[String]]()

	map = map + ("nested" -> Array("nested-1", "nested-2"))

	// map.foreach{k => println(k._1); k._2.foreach{s => println(s)}}

	def drawNode(g: Graphics2D, n: String, x: Int, y: Int){
		val r = g.getFontMetrics().getStringBounds(n, g)
		g.setColor(new Color(224,224,163))
		g.fillRect((x-(r.getWidth.toInt/2)-8), (y-(r.getHeight.toInt/2)-8), r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.setColor(Color.BLACK)
		g.drawRect((x-(r.getWidth.toInt/2)-8), (y-(r.getHeight.toInt/2)-8), r.getWidth.toInt+16, r.getHeight.toInt+16)
		g.drawString(n, (x-(r.getWidth.toInt/2)), (y+(r.getHeight.toInt/2)))
		// g.drawString(n, (x+w/2), (y+h))

		// println(g.getFontMetrics().getStringBounds(n, g))
		// g.drawRect(r.getX.toInt+50, r.getY.toInt+50, r.getWidth.toInt, r.getHeight.toInt)
	}
}