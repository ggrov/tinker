(* JSON protocal and comnumnication interfaces with the tinker GUI *)
theory Tinker                                                                                                                                                                                           
imports           
  Eval                                                                       
begin
  (* socket communication for the tinker gui *)
  ML_file "../../interface/text_socket.ML"
  ML_file "../../interface/tinker_protocol.ML"
  ML_file "../../interface/gui_launcher.ML"
ML{*
  val get = CInterface.get_sym ("/inti/" ^"guiLauncher.so")  "gui";

*}
end
