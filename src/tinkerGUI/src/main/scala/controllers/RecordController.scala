package tinkerGUI.controllers

import java.io.{FileNotFoundException, File}
import javax.swing.filechooser.FileNameExtensionFilter

import quanto.util.json._
import tinkerGUI.controllers.events.{RecordStartStopEvent, RecordFileSetupEvent}
import tinkerGUI.model.PSGraph
import tinkerGUI.utils.TinkerDialog

import scala.swing.{Dialog, Publisher, FileChooser}

class RecordController(model:PSGraph) extends Publisher {

  var file:Option[File] = None
  var previousDir = DocumentService.previousDir
  var recording = false

  def setupFile(): Unit ={
    showOpenDialog() match {
      case Some(f:File) =>
        file = Some(f)
        if(promptExists(f)){
          def failureCallback(): Unit = {

          }
          def successCallback(values:Map[String,String]): Unit ={
            if(values("Title (*)")==""){
              TinkerDialog.openEditDialog("Details about this recording ( * mandatory fields)",values,successCallback,failureCallback)
            } else {
              val json = JsonObject("info"->JsonObject("title"->JsonString(values("Title (*)")), "author"->JsonString(values("Author")), "date"->JsonString(values("Date"))),"psgraphs"->JsonArray())
              json.writeTo(f)
              publish(RecordFileSetupEvent(true))
            }
          }
          TinkerDialog.openEditDialog("Details about this recording ( (*) mandatory fields)",Map("Title (*)"->"","Author"->"","Date"->""),successCallback,failureCallback)
        }
      case None =>
    }
  }

  def promptExists(f: File) = {
    if (f.exists()) {
      Dialog.showConfirmation(
        title = "File exists",
        message = "File exists, do you wish to overwrite?") == Dialog.Result.Yes
    }
    else true
  }

  def showOpenDialog(rootDir: Option[String] = None): Option[File] = {
    val chooser = new FileChooser()
    chooser.peer.setCurrentDirectory(rootDir match {
      case Some(d) => new File(d)
      case None => previousDir
    })
    chooser.fileFilter = new FileNameExtensionFilter("Json File (*.json)", "json")
    chooser.showOpenDialog(Service.getMainFrame) match {
      case FileChooser.Result.Approve =>
        val p = chooser.selectedFile.getAbsolutePath
        previousDir = chooser.selectedFile
        Some(new File(if(p.endsWith(".json")) p else p+".json"))
      case _ => None
    }
  }

  def startRecording(): Unit ={
    recording = true
    publish(RecordStartStopEvent(recording))
    record()
  }

  def record():Unit ={
    if(recording){
      file match{
        case Some(f:File) =>
          try{
            var json = Json.parse(f)
            json?"psgraphs" match {
              case j:JsonArray =>
                json = json.setPath("$.psgraphs",j :+ model.updateJsonPSGraph())
              case _ =>
                json = json.setPath("$.psgraphs",JsonArray(model.updateJsonPSGraph()))
            }
            json.writeTo(f)
          } catch {
            case e:JsonParseException =>
              println("problem while reading file "+e.getMessage)
            //startRecording()
            case e:FileNotFoundException =>
              println(e.getMessage)
          }
        case None =>
          println("problem while reading file")
      }
    }
  }

  def stopRecording():Unit ={
    recording = false
    publish(RecordStartStopEvent(recording))
  }

}
