
signature EVAL =
sig
  structure EData : EVAL_DATA

  exception Breakpoint of EData.T;
  exception apply_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode
  exception node_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode * EData.PSGraph.Theory.Data.nvdata
  exception partition_exp of
    { pnodes :  EData.PSGraph.Theory.Data.GoalTyp.Prover.pnode list,
      input :  EData.PSGraph.Theory.Data.GoalTyp.gnode option, 
      goaltypes : EData.PSGraph.Theory.Data.GoalTyp.T list } 

  val is_all_gns_on_boundary : EData.T -> bool
  val is_gn_on_boundary : EData.T -> string (* gname *) -> bool
  val has_psgraph_terminated : EData.T -> bool
  val is_top_level_psgraph : EData.T -> bool
  
(*
  val apply_atomic : 
        EData.T 
      -> EData.PSGraph.Theory.Data.GoalTyp.gnode (* the goal node  *)
      -> EData.PSGraph.Theory.Data.nvdata (* application function *)
      -> EData.PSGraph.Theory.Data.GoalTyp.T list (* outputs *)
      -> (EData.branch * EData.PSGraph.Theory.Data.GoalTyp.gnode list list) Seq.seq

  val apply_tactic :
        EData.T 
      -> EData.PSGraph.Theory.Data.GoalTyp.gnode (* the goal node *)
      -> EData.PSGraph.Theory.Data.nvdata (* tactic assumption *)
      -> (EData.PSGraph.Theory.Data.GoalTyp.Prover.pnode list * EData.PSGraph.Theory.Data.GoalTyp.Prover.pplan) Seq.seq
*)
  val init : EData.PSGraph.T -> EData.PSGraph.Theory.Data.GoalTyp.Prover.context 
    -> EData.PSGraph.Theory.Data.GoalTyp.Prover.goal 
    -> EData.T list
  val exit_hgraph_no_goal_node : EData.T -> EData.branch Seq.seq
  val eval_goal_gnodename :  bool -> V.name -> EData.T 
    -> EData.branch Seq.seq
  val eval_goal_goalname :  bool -> string -> EData.T 
    -> EData.branch Seq.seq

end



