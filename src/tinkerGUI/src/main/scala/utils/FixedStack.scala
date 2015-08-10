package tinkerGUI.utils

import scala.collection.mutable.ArrayBuffer

/** A simple stack with fixed size.
	*
	* i.e. you can not add more than n element in the stack.
	*
	* @param size The size of the stack.
	* @tparam T Type accepted by the stack.
	*/
class FixedStack[T](private val size:Int){

	/** The actual collection.*/
	private var stack:ArrayBuffer[T] = ArrayBuffer()

	/** Integer pointing to the top index of the stack.*/
	private var top:Int = -1

	/** List of functions listeners will execute on a change to the stack.*/
	private var listeners:ArrayBuffer[()=>Unit] = ArrayBuffer()

	/** Method pushing an element in the stack.
		*
		* @param elem Element to append to the stack.
		*/
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
		listeners.foreach(_.apply())
	}

	// this one will return an optional element
	// depending on the number of element in the stack
	/** Method poping an element from the stack
		*
		* @return Optional result, None if the stack is empty.
		*/
	def pop():Option[T] = {
		if(top < 0) None
		else {
			val elem = stack(top)
			stack -= elem
			top -= 1
			listeners.foreach(_.apply())
			Some(elem)
		}
	}

	// This one will throw an exception if the stack is empty
	/*/** Method poping an element from the stack
		*
		* @return Element that was on top of the stack.
		* @throws Exception If the stack was empty.
		*/
	def pop():T = {
		if(top < 0) throw new Exception("index out of bound")
		else {
			val elem = stack(top)
			stack -= elem
			top -= 1
			elem
		}
	}*/

	/** Method to check if the stack is empty or not.
		*
		* @return Boolean result.
		*/
	def isEmpty:Boolean = {
		stack.isEmpty
	}

	/** Method emptying the stack.
		*
		*/
	def empty() {
		top = -1
		stack.clear()
		listeners.foreach(_.apply())
	}

	/** Method simply reading the top of the stack, without poping it.
		*
		* @return Optional result, None if the stack is empty.
		*/
	def getTop:Option[T] = {
		if(top < 0) None
		else Some(stack(top))
	}

	/** Method printing the stack in a string.
		*
		* @return String result.
		*/
	override def toString:String = {
		"FixedStack("+stack.foldLeft(""){case (s,e) => s + e +", "}.dropRight(2)+")"
	}

	/** Method returning the stack in an array, without poping any element.
		*
		* @return Array of values in the stack
		*/
	def values:ArrayBuffer[T] = {
		new ArrayBuffer[T]() ++ stack
	}

	/** Method to register a callback in the listener list.*/
	def register(callback:()=>Unit) {
		listeners += callback
	}
}
