
  exception RunCallFail = RunCall.Fail;

(* some utilities *)
  use "../../utils/pretty_str_helper.ML";
  use "../../utils/psgraph_names.ML"; 
  use_file "../../utils/unicode_helper.ML";
  use "../../utils/logging_handler.ML";
  use "../../utils/ml_exec.ML";

(* prover and goaltype *)  
  use "../../provers/prover.sig.ML";
  use "../../goaltype/goaltype.sig.ML";                                                                                                                      
  use "../../goaltype/goaltype.ML";

(* graph *)
  use "../../graph/graph_data.sig.ML";         
  use "../../graph/graph_data.ML";                                          
  use "../../graph/graph.sig.ML";
  use "../../graph/graph.ML";  
  use "../../graph/graph_utils.ML";
  use "../../graph/env_tac_utils.ML";
  
(* PSGraph *)
  use "../../psgraph/psgraph.sig.ML";        
  use "../../psgraph/psgraph.ML"; 
  
(* Evaluation *)
  use "../../eval/eval_data.sig.ML";                                         
  use "../../eval/eval_data.ML";  
  use "../../eval/eval.sig.ML";                                     
  use "../../eval/eval.ML";  
                                                 
(* interactive evaluation *)
  use "../../eval/ieval.sig.ML";                                       
  use "../../eval/ieval.ML";    

(* socket communication for the tinker gui *)
  use "../../interface/text_socket.ML";
  use "../../interface/tinker_protocol.ML";

(* prover related *)
  use "../../provers/proofpower/termlib/termlib.ML";
  use "../../provers/proofpower/termlib/term_features.ML";  
  use_file "../../provers/proofpower/pp_prover.ML";


(* instaintiate functors *) 
structure ClauseGoalTyp = ClauseGTFun(structure Prover = PPProver val struct_name = "ClauseGoalTyp"); 
structure Data = PSGraphDataFun(ClauseGoalTyp);
structure Graph = GraphFun(Data);
structure Graph_Utils = GraphUtilsFun(Graph);
structure Env_Tac_Utils = EnvTacUtilsFunc (structure Graph_Utils = Graph_Utils val struct_name = "Env_Tac_Utils" );
structure PSGraph = 
PSGraphFun(structure Graph = Graph structure Graph_Utils = Graph_Utils structure Env_Tac_Utils = Env_Tac_Utils);
(*structure PSComb = PSCombFun (structure PSGraph = PSGraph)*)
structure EData =  EDataFun( PSGraph);
structure EVal = EValFun(EData);
structure IEVal = InteractiveEvalFun (EVal);
structure TextSocket = TextSocket_FUN (structure Prover = PPProver);
structure Tinker = TinkerProtocol (structure IEVal = IEVal 
                                   structure TextSocket = TextSocket
                                   val gui_socket_port = 1790
                                   val prover_socket_port = 0);
(* load the library for term manipulation and goal type predicates *)
  use_file "../../provers/proofpower/clasueGT_lib.ML";
  use_file "../../provers/proofpower/env_tac_lib.ML";
  use_file "../../provers/proofpower/pp_intf.ML"; 


