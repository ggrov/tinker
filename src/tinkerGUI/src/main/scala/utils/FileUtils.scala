package tinkerGUI.utils

import java.io.{FileOutputStream, FileInputStream, IOException, File}

object FileUtils {

  def copyDirectory(source: File, destination: File) {
    if(!source.isDirectory){
      throw new IllegalArgumentException("Source ("+source.getPath+") must be a directory.")
    }
    if(!source.exists){
      throw new IllegalArgumentException("Source directory ("+source.getPath+") doesn't exist.")
    }
    if(destination.exists){
      throw new IllegalArgumentException("Destination ("+destination.getPath+") already exists.")
    }
    destination.mkdirs()
    for(f<-source.listFiles()){
      if(f.isDirectory){
        copyDirectory(f,new File(destination,f.getName))
      } else {
        copyFile(f,new File(destination,f.getName))
      }
    }
  }

  def copyFile(source: File, destination: File) {
    val sourceChannel = new FileInputStream(source).getChannel
    val destinationChannel = new FileOutputStream(destination).getChannel
    sourceChannel.transferTo(0,sourceChannel.size,destinationChannel)
    sourceChannel.close()
    destinationChannel.close()
  }

  def copy(source:File,destination:File) {
    try{
      if(source.isDirectory){
        copyDirectory(source,destination)
      } else {
        copyFile(source,destination)
      }
    } catch {
      case e:IOException => throw e
    }
  }
}
