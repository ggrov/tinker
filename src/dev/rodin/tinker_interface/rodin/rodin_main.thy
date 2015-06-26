theory rodin_main

imports "../../../../build/isabelle/BasicGoalTyp"
begin   
ML_file "../../../../logging_handler.ML"  
ML_file "./interface/text_socket_modified.ML"

ML_file "./interface/unicode_helper.ML"
ML_file "./interface/rodin_socket.ml"
ML_file "./interface/raw_source.ML"
ML_file "./interface/json.ML"
ML_file "./interface/io.ML"
ML_file "./interface/json_io.ML" 
ML_file "./interface/interface.ML" 
ML_file "./interface/rodin_prover.ML"
ML{*

  RodinProver.get_open_pnodes ""; 
  Rodin.close "";
*}

end

