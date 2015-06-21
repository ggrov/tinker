
signature EVAL =
sig
  structure EData : EVAL_DATA
  (*structure Theory : PS_THEORY*)
  (*sharing EData.PSGraph.Theory.Graph.Sharing = Theory.Graph.Sharing
  sharing EData.PSGraph.Theory.Data.Sharing.GoalTyp = Theory.GoalTyp.BasicSharing*)
  (*sharing Theory.Sharing = EData.Sharing.PSGraph.Theory*)

  exception apply_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode
  exception node_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode * EData.PSGraph.Theory.Data.nvdata
  exception partition_exp of
    { pnodes :  EData.PSGraph.Theory.Data.GoalTyp.Prover.pnode list,
      input :  EData.PSGraph.Theory.Data.GoalTyp.gnode, 
      goaltypes : EData.PSGraph.Theory.Data.GoalTyp.T list } 

  (* generalise *)
  val partition : (* raises partition exception *)
     EData.PSGraph.Theory.Data.GoalTyp.data ->
     EData.PSGraph.Theory.Data.GoalTyp.Prover.pnode list (* new proof nodes *)
     -> EData.PSGraph.Theory.Data.GoalTyp.gnode (* old gnode [parent] *)
     -> EData.PSGraph.Theory.Data.GoalTyp.T list (* output types *)
     -> EData.PSGraph.Theory.Data.GoalTyp.gnode list list list (* one list for each goal type - outer when non-orthogonal outputs *)

  val partition_to_gnodes : 
   EData.PSGraph.Theory.Data.GoalTyp.gnode list list  
   -> EData.PSGraph.Theory.Data.nvdata  list list

  val has_current_graph_terminated : EData.T -> bool
  val has_psgraph_terminated : EData.T -> bool

  val apply_atomic : 
        EData.T 
      -> EData.PSGraph.Theory.Data.GoalTyp.gnode (* the goal node  *)
      -> EData.PSGraph.Theory.Data.nvdata (* application function *)
      -> EData.PSGraph.Theory.Data.GoalTyp.T list (* outputs *)
      -> (EData.branch * EData.PSGraph.Theory.Data.GoalTyp.gnode list list list) Seq.seq

  val apply_tactic :
        EData.T 
      -> EData.PSGraph.Theory.Data.GoalTyp.gnode (* the goal node *)
      -> EData.PSGraph.Theory.Data.nvdata (* tactic assumption *)
      -> (EData.PSGraph.Theory.Data.GoalTyp.Prover.pnode list * EData.PSGraph.Theory.Data.GoalTyp.Prover.pplan) Seq.seq
  val init : EData.PSGraph.T -> EData.PSGraph.Theory.Data.GoalTyp.Prover.context 
    -> EData.PSGraph.Theory.Data.GoalTyp.Prover.term list 
    -> EData.PSGraph.Theory.Data.GoalTyp.Prover.term 
    -> EData.T list
  val exit_hgraph_no_goal_node : EData.T -> EData.branch Seq.seq
  val eval_goal_gnodename :  bool -> V.name -> EData.T 
    -> (EData.branch (* *  EData.PSGraph.Theory.Data.GoalTyp.gnode list list list*)) Seq.seq
  val eval_goal_goalname :  bool -> string -> EData.T 
    -> (EData.branch (* * EData.PSGraph.Theory.Data.GoalTyp.gnode list list list*)) Seq.seq

end



