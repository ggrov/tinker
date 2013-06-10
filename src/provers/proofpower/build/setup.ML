(* some useful combinators *)
  fun I x = x;
  fun K x = fn _ => x;
  fun x |> f = f x;

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
  
(* goal type data and matching *)
  use "../../../goaltype/goaltyp_data.ML";
  use "../../match_param.ML";
  use "../../../goaltype/class.ML";  
  use "../../../goaltype/link.ML";

(* full goaltyp *)

  use "../../../goaltype/full/goaltyp.ML";  
  use "../../../goaltype/full/gnode.ML";  
  use "../../../goaltype/full/goaltyp_json.ML";  
  use "../../../goaltype/full/goaltyp_match.ML";
  use "../../../goaltype/full/goaltyp_i.ML";
  
  use "../pp_match_param.ML";
  
(*  simple goaltyp 

  use "../../../goaltype/simple/gnode.ML";
  use "../../../goaltype/simple/goaltyp_json.ML";  
  use "../../../goaltype/simple/goaltyp_match.ML";
  use "../../../goaltype/simple/goaltyp_i.ML";
*)


structure GoalTypData : GOALTYP_DATA = GoalTypDataFun (PpProver);
structure Class : CLASS = ClassFun (GoalTypData);
structure Link : LINK = LinkFun(structure GoalTypData = GoalTypData structure Prover = PpProver);
structure GoalTyp = GoalTypFun(structure Link = Link structure Class = Class);
structure GoalTypJson = GoalTypJsonFun  (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = PpProver);
structure MatchParam = PpMatchParamFun (structure GoalTypData = GoalTypData
                                         structure Prover = PpProver )
structure GoalTypMatch = GoalTypMatchFun (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = PpProver
                                         structure Atomic = PpAtomic
                                         structure MatchParam = MatchParam);
structure BasicGoalTyp = BasicGoalTypFun (structure GoalTyp = GoalTyp
                                          structure Atomic : ATOMIC = PpAtomic
                                          structure GoalTypJson : GOALTYP_JSON = GoalTypJson
                                          structure GoalTypMatch : GOALTYP_MATCH = GoalTypMatch)

structure Theory = PSTheoryFun(structure GoalTyp = BasicGoalTyp);
structure PSGraph = PSGraphFun(structure PSTheory = Theory
                               structure Atomic = PpAtomic);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Atomic = PpAtomic
                           structure PSGraph = PSGraph);

structure EVal = EValFun(EData);
  

