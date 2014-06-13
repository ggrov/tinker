package tinkerGUI.views

import scala.swing._
import tinkerGUI.controllers.QuantoLibAPI

object MainGUI extends SimpleSwingApplication {
	def top = new MainFrame{
		title = "Tinker"
		size = new Dimension(800,800)
		minimumSize = new Dimension(400,400)
		menuBar = new TinkerMenu()
		contents = QuantoLibAPI.makeGraph
		QuantoLibAPI.addVertex(100, 100, "GN")
		QuantoLibAPI.addVertex(200, 200, "RT")
		QuantoLibAPI.addVertex(60, 200, "RT")
		QuantoLibAPI.addVertex(200, 150, "GN")
		QuantoLibAPI.addVertex(500, 130, "RT")
		QuantoLibAPI.addVertex(-50, -90, "GN")
		QuantoLibAPI.addBoundary(150, -30)
		QuantoLibAPI.addBoundary(60, 210)
		QuantoLibAPI.addEdge("v0", "v2")
		QuantoLibAPI.addEdge("v4", "b0")
		QuantoLibAPI.addEdge((245.0, 160.0), "v4")
		QuantoLibAPI.addEdge((-75.0, -75.0), (85.0, 85.0))
	}
}