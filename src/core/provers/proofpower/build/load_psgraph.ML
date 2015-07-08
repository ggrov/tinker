(* some useful combinators *)
  fun I x = x;
  fun K x = fn _ => x;
  fun x |> f = f x;

(* basic goaltype *)
  use "../../../psgraph_names.ML"; 
  use "../../../logging_handler.ML";
  use "../../../ml_exec.ML";
  use "../../prover.sig.ML";   
  use "../../../goaltype/basic_goaltyp.sig.ML";
(* graph *)
  use "../../../graph/graph_data.sig.ML" ;         
  use "../../../graph/graph_data.ML" ;                                          
  use "../../../graph/io.ML";
  use "../../../graph/theory.ML";
  use "../../../graph/theory_io.sig.ML";    
  use "../../../graph/theory_io.ML";
  use "../../../graph/env_tac_lib.ML";

       
(* PSGraph *)
  use "../../../psgraph/psgraph.sig.ML";        
  use "../../../psgraph/psgraph.ML";    
  use "../../../psgraph/psgraph_comb.ML"; 
  
(* Evaluation *)
  use "../../../eval/eval_data.sig.ML";                                         
  use"../../../eval/eval_data.ML";  
  use "../../../eval/eval.sig.ML";                                     
  use"../../../eval/eval.ML";  
                                                 
  (* interactive evaluation *)
  use "../../../eval/ieval.sig.ML";                                       
  use "../../../eval/ieval.ML";    
  (* socket communication for the tinker gui *)
  use "../../../interface/text_socket.ML";
  use "../../../interface/tinker_protocol.ML";
  use "../../../interface/gui_launcher.ML";

(* prover related *)
  use "../termlib/termlib.ML";
  use "../termlib/term_features.ML";  
  use "../../prover.sig.ML";
  use "../pp_prover.ML";


