package tinkerGUI.utils

// the following code was found on a StackOverflow discussion :
// http://stackoverflow.com/questions/938753/scala-popup-menu

import javax.swing.JPopupMenu
import scala.swing.{ Component }
import scala.swing.SequentialContainer.Wrapper

/** Class for a popup menu, or context menu.
	*
	* Code was found here : http://stackoverflow.com/questions/938753/scala-popup-menu
	*
	* ==Usage:==
	* {{{
	* val popup = new PopupMenu{
	* 	contents += new MenuItem(new Action("my action name"){
	* 		def apply = { } // do something
	* 	})
	* }
	* popup.show(invokerComponent,x,y)
	* }}}
	*/
class PopupMenu extends Component with Wrapper {

	/** Java peer value.*/
	override lazy val peer: JPopupMenu = new JPopupMenu with PopupMenu.JPopupMenuMixin with SuperMixin {
		def popupMenuWrapper = PopupMenu.this
	}

	/** Method to sow the popup menu.
		*
		* @param invoker Component invoking the popup menu.
		* @param x X coordinate where to print the popup menu.
		* @param y Y coordinate where to print the popup menu.
		*/
	def show(invoker: Component, x: Int, y: Int): Unit = peer.show(invoker.peer, x, y)

	/* Create any other peer methods here */
}

/** Companion object for the PopupMenu class.
	*
	*/
object PopupMenu {
	private[PopupMenu] trait JPopupMenuMixin { def popupMenuWrapper: PopupMenu }
}
