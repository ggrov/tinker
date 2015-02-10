
signature EVAL =
sig
  structure EData : EVAL_DATA
  structure Theory : PS_THEORY
  (*sharing EData.PSGraph.Theory.Graph.Sharing = Theory.Graph.Sharing
  sharing EData.PSGraph.Theory.Data.Sharing.GoalTyp = Theory.GoalTyp.BasicSharing*)
  sharing Theory.Sharing = EData.Sharing.PSGraph.Theory

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

 structure Util :
  sig 
(*    val vertex_data : Graph.T -> V.name -> Graph.nvdata 
    val symmetric_rule : Theory.Rule.T -> Theory.Rule.T
    val rewrite_lazy : Theory.Rewriter.Rule.T -> Graph.T -> Graph.T Seq.seq
    val rewrite : Theory.Rewriter.Rule.T -> Graph.T -> Graph.T list
    val output_boundary : Graph.T -> (V.name * (E.name * Graph.edata) * V.name) list
*)
    val out_edges : EData.PSGraph.Theory.Graph.T -> V.name -> E.NSet.name list 
(*   val mk_lhs : Graph.T -> V.name -> Graph.T list
    val mk_gnode : GoalTyp.gnode -> GData.nvdata 
    val mk_boutput : Graph.edata -> V.name -> Graph.T -> Graph.T
    val mk_binput : Graph.edata -> V.name -> Graph.T -> Graph.T
    val matched_lhs : Graph.T -> V.name -> (Graph.subst * (Graph.subst * Graph.T)) Seq.seq
    val match_lhs : Graph.T -> Graph.T -> (Graph.subst * (Graph.subst * Graph.T)) Seq.seq
    val lookup_ivertex_data : Graph.T -> V.name -> Graph.nvdata option
    val lookup_gnode : Graph.T -> V.name -> GoalTyp.gnode option 
    val is_tactic : Graph.T -> V.name -> bool
    val is_gtyp : Graph.T -> E.name -> bool 
    val is_gnode : Graph.T -> V.name -> bool
    val insert_node_on_edge : Graph.nvdata -> E.name -> Graph.T -> E.name * E.name * Graph.T
    val input_boundary : Graph.T -> (V.name * (E.name * Graph.edata) * V.name) list
    val in_edges : Graph.T -> V.name -> E.NSet.name list 
    val goaltype_of : Graph.T -> E.name -> GoalTyp.T *)
    val gnode_of :  EData.PSGraph.Theory.Graph.T -> V.name -> EData.PSGraph.Theory.Data.GoalTyp.gnode
    val all_gnodes :  EData.PSGraph.Theory.Graph.T -> V.name list
(*    val get_vertex_list : Graph.T -> V.NSet.name list
    val edge_src : Graph.T -> E.name -> V.name 
*)
    val edge_dest : EData.PSGraph.Theory.Graph.T -> E.name -> V.name
(*
    val edge_data : Graph.T -> E.name -> Graph.edata val del_gnode : V.name -> Graph.T -> Graph.T
    val all_tactics : Graph.T -> V.name list 
    val add_outs : E.name list -> Graph.nvdata list -> Graph.T -> Graph.T *)
  end
end


(*

sig val try_get_out : Graph.T -> V.name -> V.name option val try_get_in : Graph.T -> V.name -> V.name option
  val partition_to_gnodes : GoalTyp.gnode list list -> GData.nvdata list list
  val partition_one' :
     GoalTyp.data ->
     GoalTyp.T list ->
     GoalTyp.gnode ->
     Prover.pnode -> GoalTyp.gnode list list -> GoalTyp.gnode list list -> GoalTyp.gnode list list list
  val partition_one :
     GoalTyp.data ->
     GoalTyp.T list -> GoalTyp.gnode -> Prover.pnode -> GoalTyp.gnode list list -> GoalTyp.gnode list list list
  exception partition_exp of {input: GoalTyp.gnode, pnodes: Prover.pnode list, goaltypes: GoalTyp.T list}
  val partition : GoalTyp.data -> Prover.pnode list -> GoalTyp.gnode -> GoalTyp.T list -> GoalTyp.gnode list list list
  exception node_exp of string * GoalTyp.gnode * Theory.Data.nvdata
  val next_tactic_vertex : Graph.T -> V.name -> V.name option
  val next_tactic_edge : Graph.T -> E.NSet.name -> V.name option
  val next_tactic : Graph.T -> GoalTyp.gnode -> V.name option
  val move_gnode : Graph.T -> V.name -> Graph.T -> E.name * E.name * Graph.T
  val lift : GoalTyp.gnode -> GoalTyp.data * GoalTyp.T -> Prover.pnode -> GoalTyp.gnode option
  val init_with_assm : EData.PSGraph.T -> Prover.context -> Prover.term list -> Prover.term -> EData.T list
  val init_of : EData.PSGraph.T -> Prover.pnode list * Prover.pplan -> EData.T list
  val init_goals : EData.T -> Prover.pnode list -> EData.T list val init_goal : Prover.pnode -> EData.T -> EData.T list
  val init : EData.PSGraph.T -> Prover.context -> Prover.term -> EData.T list
  val has_terminated : EData.T -> bool
  val eval_goal_atomic_node_names : 'a -> 'b -> V.name -> V.name -> EData.T -> (EData.branch * 'c) Seq.seq
  val eval_goal_atomic_goalnode : 'a -> V.name -> EData.T -> (EData.branch * 'b) Seq.seq
  val eval_goal_atomic : 'a -> string -> EData.T -> (EData.branch * 'b) Seq.seq
  val apply_tactic : EData.T -> GoalTyp.gnode -> GData.nvdata -> (Prover.pnode list * Prover.pplan) Seq.seq
  exception apply_exp of string * GoalTyp.gnode
  val apply_atomic :
     EData.T ->
     GoalTyp.gnode -> GData.nvdata -> GoalTyp.T list -> (EData.branch * GoalTyp.gnode list list list) Seq.seq
  structure Util :
  sig val vertex_data : Graph.T -> V.name -> Graph.nvdata val symmetric_rule : Theory.Rule.T -> Theory.Rule.T
    val rewrite_lazy : Theory.Rewriter.Rule.T -> Graph.T -> Graph.T Seq.seq
    val rewrite : Theory.Rewriter.Rule.T -> Graph.T -> Graph.T list
    val output_boundary : Graph.T -> (V.name * (E.name * Graph.edata) * V.name) list
    val out_edges : Graph.T -> V.name -> E.NSet.name list val mk_lhs : Graph.T -> V.name -> Graph.T list
    val mk_gnode : GoalTyp.gnode -> GData.nvdata val mk_boutput : Graph.edata -> V.name -> Graph.T -> Graph.T
    val mk_binput : Graph.edata -> V.name -> Graph.T -> Graph.T
    val matched_lhs : Graph.T -> V.name -> (Graph.subst * (Graph.subst * Graph.T)) Seq.seq
    val match_lhs : Graph.T -> Graph.T -> (Graph.subst * (Graph.subst * Graph.T)) Seq.seq
    val lookup_ivertex_data : Graph.T -> V.name -> Graph.nvdata option
    val lookup_gnode : Graph.T -> V.name -> GoalTyp.gnode option val is_tactic : Graph.T -> V.name -> bool
    val is_gtyp : Graph.T -> E.name -> bool val is_gnode : Graph.T -> V.name -> bool
    val insert_node_on_edge : Graph.nvdata -> E.name -> Graph.T -> E.name * E.name * Graph.T
    val input_boundary : Graph.T -> (V.name * (E.name * Graph.edata) * V.name) list
    val in_edges : Graph.T -> V.name -> E.NSet.name list val goaltype_of : Graph.T -> E.name -> GoalTyp.T
    val gnode_of : Graph.T -> V.name -> GoalTyp.gnode val get_vertex_list : Graph.T -> V.NSet.name list
    val edge_src : Graph.T -> E.name -> V.name val edge_dest : Graph.T -> E.name -> V.name
    val edge_data : Graph.T -> E.name -> Graph.edata val del_gnode : V.name -> Graph.T -> Graph.T
    val all_tactics : Graph.T -> V.name list val all_gnodes : Graph.T -> V.name list
    val add_outs : E.name list -> Graph.nvdata list -> Graph.T -> Graph.T end
  structure Theory : PS_THEORY structure Prover : PROVER structure Graph : BANG_GRAPH
  structure GoalTyp : BASIC_GOALTYPE structure GData : PSGRAPH_DATA structure EData : EVAL_DATA end
*)


