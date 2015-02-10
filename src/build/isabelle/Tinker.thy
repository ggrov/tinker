(* JSON protocal and comnumnication interfaces with the tinker GUI *)
theory Tinker                                                                                                                                                                                           
imports           
  EVal                                                                       
begin
  (* socket communication for the tinker gui *)
  ML_file "../../interface/text_socket.ML"
  ML_file "../../interface/tinker_protocol.ML"
(*  ML_file "../../interface/ui_socket.ML" *)

ML{*
  DebugHandler.set_debug_flag DebugHandler.TINKER;
*}

end
