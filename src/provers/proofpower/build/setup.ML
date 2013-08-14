(* some useful combinators *)
  fun I x = x;
  fun K x = fn _ => x;
  fun x |> f = f x;
  
  use_file "../termlib/termlib.ML";
  use_file "../termlib/term_feature.ML";
  
  use_file "../../prover.ML";
  use_file "../pp_prover.ML";
  use_file "../../atomic.ML";
  use_file "../pp_atomic.ML";

  use_file "../../../rtechn_names.ML";
  
(* rtechn *)
  use_file "../../../rtechn_names.ML";
  use_file "../../../rtechn/rtechn.ML"; 
  use_file "../../../rtechn/rtechn_json.ML";  
  
(* basic goal type*)
  use_file "../../../goaltype/basic_goaltyp.ML";    

(* graph *)
  use_file "../../../graph/graph_comb.ML"; (* generic for graphs - move to quantomatic? *)
  use_file "../../../graph/substdata.ML";        
  use_file "../../../graph/vertex.ML";                            
  use_file "../../../graph/edge.ML";  
  use_file "../../../graph/graph.ML";                     
  use_file "../../../graph/theory.ML";  
  
(* psgraph *)
  use_file "../../../psgraph/psgraph.ML";   
  use_file "../../../psgraph/psgraph_comb.ML";  

(* eval *)
  use_file "../../../eval/eval_data.ML";              
  use_file "../../../eval/eval_atomic.ML";      
  use_file "../../../eval/eval_graph.ML";                                    
  use_file "../../../eval/eval.ML"; 
  

(* full goaltype

  use_file "../../../goaltype/goaltyp_data.ML";
  use_file "../../match_param.ML";
  use_file "../../../goaltype/class.ML";  
  use_file "../../../goaltype/link.ML";

  use_file "../../../goaltype/full/goaltyp.ML";  
  use_file "../../../goaltype/full/gnode.ML";  
  use_file "../../../goaltype/full/goaltyp_json.ML";  
  use_file "../../../goaltype/full/goaltyp_match.ML";
  use_file "../../../goaltype/full/goaltyp_i.ML";
  use_file "../../../goaltype/full_goaltyp.ML";
  use_file "../pp_match_param.ML";
  
structure GoalTypData : GOALTYP_DATA = GoalTypDataFun (PPProver);
structure Class : CLASS = ClassFun (GoalTypData);
structure Link : LINK = LinkFun(structure GoalTypData = GoalTypData structure Prover = PPProver);
structure GoalTyp = GoalTypFun(structure Link = Link structure Class = Class);
structure GoalTypJson = GoalTypJsonFun  (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = PPProver);
structure MatchParam = PpMatchParamFun (structure GoalTypData = GoalTypData
                                         structure Prover = PPProver )
structure GoalTypMatch = GoalTypMatchFun (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = PPProver
                                         structure Atomic = PPAtomic
                                         structure MatchParam = MatchParam);
                                          
structure GoalTyp_I = GoalTypIFun (structure GoalTyp = GoalTyp
                                          structure Atomic : ATOMIC = PPAtomic
                                          structure GoalTypJson : GOALTYP_JSON = GoalTypJson
                                          structure GoalTypMatch : GOALTYP_MATCH = GoalTypMatch);
structure FullGoalTyp : FULL_GOAL_TYP = GoalTyp_I
*)
  
(*  simple goaltyp *)
  use_file "../simple_goaltyp";

structure GoalTyp : BASIC_GOALTYPE = SimpleGoalTyp;


structure Theory = PSTheoryFun(structure GoalTyp = GoalTyp);
structure Theory = PSTheoryFun(structure GoalTyp = GoalTyp);
structure PSGraph = PSGraphFun(structure PSTheory = Theory
                               structure Atomic = PPAtomic);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Atomic = PPAtomic
                           structure PSGraph = PSGraph);

structure EVal = EValFun(EData);

(* socket *)
  use_file "../../../interface/text_socket.ML";
  use_file "../../../interface/ui_socket.ML";

(* json protocol, they are alreay in Quantolib *)
  use_file "../../../interface/json_protocol/controller_util.ML";
  use_file "../../../interface/json_protocol/controller_module.ML";
  use_file "../../../interface/json_protocol/modules/psgraph.ML";
  use_file "../../../interface/json_protocol/controller_registry.ML";
  use_file "../../../interface/json_protocol/protocol.ML";
  
  
  use_file "../pp_intf.ML";
  

