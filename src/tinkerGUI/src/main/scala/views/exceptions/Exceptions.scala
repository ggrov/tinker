package tinkerGUI.views.exceptions

/** Exception if the hierarchy tree we are drawing is infinite.*/
case class InfiniteTreeException(msg:String) extends Exception(msg)
