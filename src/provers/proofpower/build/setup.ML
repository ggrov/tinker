(* some useful combinators *)
  fun I x = x;
  fun K x = fn _ => x;
  fun x |> f = f x;
  
  use "../termlib/termlib.ML";
  use_file "../termlib/term_feature.ML";
  
  use "../../prover.ML";
  use "../pp_prover.ML";
  use "../../atomic.ML";
  use "../pp_atomic.ML";

  use "../../../rtechn_names.ML";
  
(* rtechn *)
  use "../../../rtechn_names.ML";
  use "../../../rtechn/rtechn.ML"; 
  use "../../../rtechn/rtechn_json.ML";  
  
(* basic goal type*)
  use "../../../goaltype/basic_goaltyp.ML";    

(* graph *)
  use "../../../graph/graph_comb.ML"; (* generic for graphs - move to quantomatic? *)
  use "../../../graph/substdata.ML";        
  use "../../../graph/vertex.ML";                            
  use "../../../graph/edge.ML";  
  use "../../../graph/graph.ML";                     
  use "../../../graph/theory.ML";  
  
(* psgraph *)
  use "../../../psgraph/psgraph.ML";   
  use "../../../psgraph/psgraph_comb.ML";  

(* eval *)
  use "../../../eval/eval_data.ML";              
  use "../../../eval/eval_atomic.ML";      
  use "../../../eval/eval_graph.ML";                                    
  use "../../../eval/eval.ML"; 
  

(* full goaltype

  use "../../../goaltype/goaltyp_data.ML";
  use "../../match_param.ML";
  use "../../../goaltype/class.ML";  
  use "../../../goaltype/link.ML";

  use "../../../goaltype/full/goaltyp.ML";  
  use "../../../goaltype/full/gnode.ML";  
  use "../../../goaltype/full/goaltyp_json.ML";  
  use "../../../goaltype/full/goaltyp_match.ML";
  use "../../../goaltype/full/goaltyp_i.ML";
  use "../../../goaltype/full_goaltyp.ML";
  use "../pp_match_param.ML";
  
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
  use "../../../interface/text_socket.ML";
  use "../../../interface/ui_socket.ML";

(* json protocol, they are alreay in Quantolib *)
  use "../../../interface/json_protocol/controller_util.ML";
  use "../../../interface/json_protocol/controller_module.ML";
  use "../../../interface/json_protocol/modules/psgraph.ML";
  use "../../../interface/json_protocol/controller_registry.ML";
  use "../../../interface/json_protocol/protocol.ML";
  
  
  use "../pp_intf.ML";
  

