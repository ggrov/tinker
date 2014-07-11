package tinkerGUI.model

import scala.collection.mutable.ArrayBuffer

class TreeElement(var name: String, var children: ArrayBuffer[TreeElement])

class HierarchyModel() {
	val root : TreeElement = new TreeElement("main", ArrayBuffer())
	var activeElement : TreeElement = root
	var elementArray : ArrayBuffer[TreeElement] = ArrayBuffer(root)

	def addElement(name: String, parent: String){
		lookForElement(parent) match {
			case Some(e: TreeElement) =>
				val elt = new TreeElement(name, ArrayBuffer())
				e.children += elt
				elementArray += elt
			case None =>
		}
	}

	def addElement(name: String) {
		val elt = new TreeElement(name, ArrayBuffer())
		println("created " + name)
		activeElement.children += elt
		elementArray += elt
	}

	def lookForElement(n: String): Option[TreeElement] ={
		println("looking for " + n)
		elementArray.foreach {e =>
			if(e.name == n) {
				println("found " + n)
				return Some(e)
			}
		}
		println("didn't found" + n)
		return None
	}

	def changeActive(n: String) {
		println("changing active to " + n)
		lookForElement(n) match {
			case Some(e: TreeElement) => activeElement = e
			case None => println("hello")
		}
	}

	def updateElementName(oldVal: String, newVal: String){
		lookForElement(oldVal) match {
			case Some(e: TreeElement) => e.name = newVal
			case None =>
		}
	}
}