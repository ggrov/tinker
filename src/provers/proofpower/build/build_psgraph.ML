  val cur_path = OS.FileSys.getDir();
  OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");

(* some useful combinators *)
  fun I x = x;
  fun K x = fn _ => x;
  fun x |> f = f x;

(* basic goaltype *)
  use "../../../rtechn_names.ML"; 
  use "../../prover.sig.ML";   
  use "../../../goaltype/basic_goaltyp.sig.ML";

(* graph *)
  use "../../../debug_handler.ML";
  use "../../../graph/graph_data.sig.ML" ;         
  use "../../../graph/graph_data.ML" ;                                          
  use "../../../graph/io.ML";
  use "../../../graph/theory.ML";
  use "../../../graph/theory_io.sig.ML";    
  use "../../../graph/theory_io.ML";
       
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
  use "../../../debug_handler.ML";  
  use "../../../interface/text_socket.ML";
  use "../../../interface/tinker_protocol.ML";

(* prover related *)
  use "../termlib/termlib.ML";
  use "../termlib/term_feature.ML";  
  use "../../prover.sig.ML";
  use "../pp_prover.ML";
 
(* simple goaltyp *)
  use "../simple_goaltyp";
 
     
(* instaintiate functors *) 
  structure GT : BASIC_GOALTYPE = SimpleGoalTyp;
  structure Data = PSGraphDataFun(GT);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = SimpleGoalTyp  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory);
  structure PSGraph = PSGraphFun(Theory_IO);
  PSGraph.empty;
  structure PSComb = PSCombFun (structure PSGraph = PSGraph)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (IEVal);  
(*  use "../pp_intf.ML"; *)
  
  
(* enable the subgoal package printing *)
  reset_flag "subgoal_package_quiet";
