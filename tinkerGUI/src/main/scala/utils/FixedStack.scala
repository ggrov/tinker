package tinkerGUI.utils

import scala.collection.mutable.ArrayBuffer

/** A simple stack with fixed size.
	*
	* i.e. you can not add more than n element in the stack.
	*
	*/
class FixedStack[T](private val size:Int){

	private var stack:ArrayBuffer[T] = ArrayBuffer()
	private var top:Int = -1

	def push(elem:T) {
		top += 1
		stack += elem
		if(top >= size) {
			// here you can either dropped the first element
			stack.remove(0)
			top -= 1
			// or throw an exception
			// throw new Exception("stack overflow")
		}
	}

	// this one will return an optional element
	// depending on the number of element in the stack
	def pop():Option[T] = {
		if(top < 0) None
		else {
			val elem = stack(top)
			stack -= elem
			top -= 1
			Some(elem)
		}
	}

	// This one will throw an exception if the stack is empty
	/*def pop():T = {
		if(top < 0) throw new Exception("index out of bound")
		else {
			val elem = stack(top)
			stack -= elem
			top -= 1
			elem
		}
	}*/

	def isEmpty:Boolean = {
		stack.isEmpty
	}

	def empty() {
		top = -1
		stack.clear()
	}

	def getTop():Option[T] = {
		if(top < 0) None
		else Some(stack(top))
	}

	override def toString:String = {
		"FixedStack"+stack.foldLeft("("){case (s,e) => s + e +", "}.dropRight(2)+")"
	}
}
