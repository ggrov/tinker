package tinkerGUI.utils

import javax.swing.JComboBox

import scala.swing.{Swing, Component, event}

/** Mutable combo box for scala.
 	*
	* Code was found here : https://gist.github.com/voronaam/7206119
	*
	* Very basic Mutable ComboBox for Scala.
	* ==Usage:==
	* {{{
	* val box = new MutableComboBox[String]
	* box.items = List("1", "11", "222")
	* listenTo(box)
	* reactions += {
	* 	case SelectionChanged(`box`) => println(box.item)
	* }
	* }}}
	*
	* Note that there is no separate "selection" member. This combobox publishes event on its own
 	*/
class MutableComboBox[T] extends Component {

	/** Java peer.*/
	override lazy val peer = new JComboBox[T]() with SuperMixin

	peer.addActionListener(Swing.ActionListener { e =>
		publish(event.SelectionChanged(MutableComboBox.this))
	})

	/** Method to set the items in the combobox.
		*
		* @param s List of items.
		*/
	def items_=(s: Seq[T]) {
		peer.removeAllItems()
		s.foreach(peer.addItem)
	}

	/** Method to get the items in the combobox.
		*
		* @return List of items.
		*/
	def items = (0 until peer.getItemCount).map(peer.getItemAt)

	/** Method to get the index of the selected item.
		*
		* @return Index of the selected item.
		*/
	def index: Int = peer.getSelectedIndex

	/** Method to set the selected item.
		*
		* @param n Index of the item to select.
		*/
	def index_=(n: Int) { peer.setSelectedIndex(n) }

	/** Method to get the selected item.
		*
		* @return Selected item.
		*/
	def item: T = peer.getSelectedItem.asInstanceOf[T]

	/** Method to set the selected item.
		*
		* @param a Item to select.
		*/
	def item_=(a: T) { peer.setSelectedItem(a) }
}
