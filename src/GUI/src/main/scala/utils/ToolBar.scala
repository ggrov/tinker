/**
  * This file is a copy of the tool bar file from Quantomatic
  */

package tinkerGUI.utils

import swing._
import javax.swing.JToolBar

/** Class implementing a toolbar component.
	*
	*/
class ToolBar extends Component with SequentialContainer.Wrapper {

	/** Java peer object.*/
	override lazy val peer: JToolBar = new JToolBar

	/** Method adding a button to the toolbar.
		*
		* @param action Action attached to the button.
		*/
	def add( action: Action ) { peer.add( action.peer )}

	/** Method adding a component to the toolbar.
		*
		* @param component Component to add.
		*/
	def add( component: Component ) { peer.add( component.peer )}

	/** Method adding a separator.*/
	def addSeparator () {peer.addSeparator()};
}
