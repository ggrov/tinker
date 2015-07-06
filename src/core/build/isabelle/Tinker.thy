(* JSON protocal and comnumnication interfaces with the tinker GUI *)
theory Tinker                                                                                                                                                                                           
imports           
  Eval                                                                       
begin
  (* socket communication for the tinker gui *)
  ML_file "../../interface/text_socket.ML"
  ML_file "../../interface/tinker_protocol.ML"
end
