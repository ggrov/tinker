package tinkerGUI.model

import scala.collection.mutable.ArrayBuffer

class TreeElement(var name: String, var children: ArrayBuffer[TreeElement], var parent: String)

class HierarchyModel() {
	val root : TreeElement = new TreeElement("main", ArrayBuffer(), "")
	var activeElement : TreeElement = root
	var elementArray : ArrayBuffer[TreeElement] = ArrayBuffer(root)

	def addElement(name: String, parent: String){
		lookForElement(parent) match {
			case Some(e: TreeElement) =>
				val elt = new TreeElement(name, ArrayBuffer(), parent)
				e.children += elt
				elementArray += elt
			case None =>
		}
	}

	def addElement(name: String) {
		val elt = new TreeElement(name, ArrayBuffer(), activeElement.name)
		activeElement.children += elt
		elementArray += elt
	}

	def lookForElement(n: String): Option[TreeElement] ={
		elementArray.foreach {e =>
			if(e.name == n) {
				return Some(e)
			}
		}
		return None
	}

	def changeActive(n: String) {
		lookForElement(n) match {
			case Some(e: TreeElement) => activeElement = e
			case None => 
		}
	}

	def updateElementName(oldVal: String, newVal: String){
		lookForElement(oldVal) match {
			case Some(e: TreeElement) => e.name = newVal
			case None =>
		}
	}

	def buildParentList(n: String, l: Array[String]): Array[String] = {
		if(n == "main") return l
		else lookForElement(n) match {
			case Some(e: TreeElement) => buildParentList(e.parent, (l :+ e.parent))
			case None => l
		}
	}

	def delElement(n: String){
		lookForElement(n) match {
			case Some(e:TreeElement) =>
				elementArray -= e
				lookForElement(e.parent) match {
					case Some(p:TreeElement) =>
						p.children -= e
					case None =>
				}
			case None =>
		}
	}

	def changeParent(element: String, parent:String){
		lookForElement(element) match {
			case Some(e:TreeElement) =>
				lookForElement(e.parent) match {
					case Some(p:TreeElement) =>
						p.children -= e
					case None =>
				}
				e.parent = parent
				lookForElement(parent) match {
					case Some(p:TreeElement) =>
						p.children += e
					case None =>
				}
			case None =>
		}
	}
}