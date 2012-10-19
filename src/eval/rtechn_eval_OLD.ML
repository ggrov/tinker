signature RTECHN_EVAL =
sig
  exception Wire_exp of string
  exception Box_exp of string

 (* exception output_exp of V.name *)
(*
  val has_input_all : RState.T -> V.name list


  val consume_all_inputs : RState.T -> V.name -> RTechnComb.graph -> RTechnComb.graph
  val write_result_io : RState.T -> V.name -> RTechnComb.graph -> RTechnComb.graph
  val eval_atomic : RState.T -> RTechnComb.graph -> V.name -> (RState.T * RTechnComb.graph) Seq.seq

  val eval_step : (V.name list -> V.name list -> V.name list *  V.name list) (* eval strategy,list of vnames *)
         -> RTechnComb.graph 
         -> RState.T 
         -> (RState.T * RTechnComb.graph * V.name list) Seq.seq

  (* only wires on output boundary should have values in result! *)
  val eval_all : RTechnComb.graph -> RState.T -> (RState.T * RTechnComb.graph) Seq.seq

  val init : Proof.context -> string list -> WireNode.T -> RTechnComb.graph -> RState.T * RTechnComb.graph
*)
end (* sig *)

(* lazy (seq) or strict (list) ?? *)
structure EvalStrat =
struct
 fun depth_first new old = [old]
   (* what about duplicates *)

 fun breadh_first new old = [old]
end

structure RTechnEval =
struct

  structure EData = EvalD_DF;

  exception evaluate_exp of V.name option * string;

  fun init (th:theory) trms graphf = 
    let
       val (g0,th') = graphf th
       val wset = GraphEnv.get_input_wires g0;
       val (pnds,prf) = PPlan.init_gls (Proof_Context.init_global th') trms 
       val ptab = 
         fold
           (fn pnode => StrName.NTab.ins (PNode.get_name pnode,pnode))
            pnds
           (StrName.NTab.empty);
       val edata0 = EData.init_of prf g0 ptab [] th';
       val ggraphs = pnds 
                   |> map (EvalOutput.lift_pnode_by_wires (EData.get_fmatch edata0) wset)
                   |> map (fn (w,g) => GraphEnv.lift_gnode g w)
       val g1 = fold GraphComb.theng ggraphs g0;
    in (* fixme: find all active techniques *)
       edata0 
       |> EData.set_graph g1
    end;

  val default_gname = V.mk "G";

(*  fun prev_gnode_vertices g v = 
    if GraphComb.is_rtechn g v then [NONE]
     else if GraphComb.is_goalnode g v then [SOME v]
     else  GraphComb.get_in_edges g v
        |> E.NSet.list_of
        |> maps (prev_gnode_edge g)
  and prev_gnode_edge g e = prev_gnode_vertices g (GraphComb.edge_src g e);

  fun check_all g [] = true
   | check_all g (NONE::_) = false
   | check_all g ((SOME v)::vs) = is_nempty_gnode g v andalso check_all g vs

  fun check_one g [] = false
   | check_one g (NONE::vs) = check_one g vs
   | check_one g ((SOME v)::vs) = is_nempty_gnode g v orelse check_one g vs

  fun check rst v g ls =
   let 
     val is_merge = GraphComb.v_to_rtechn g v
                  |> RTechn_Ctxt.RState.get_rtechn rst  
                  |> RTechn.is_merge
   in 
     if is_merge 
       then check_one g ls
       else check_all g ls
   end;    

  fun is_enabled rst g v =
    GraphComb.get_in_edges g v (* Fixme: doesn't take care of edge points *)
    |> E.NSet.list_of
    |> maps (prev_gnode_edge g) (* should only be one per anyway *)
    |> check rst v g;
*)
(*
  datatype initg = StringGoals of string list
                 | TermGoals of term list;
*)
(*
  (* of terms or string --  assumes string *)
  fun init (th:theory) init_goals input_wire graphf = 
   let
    val (graph0,th') = graphf th
    val _ = writeln "hello"
    val ctxt = ProofContext.init_global th';
    val (gs,pp) = case init_goals of 
                    (StringGoals goalstrs) => init_pplan_of_strings ctxt goalstrs
                  | (TermGoals goaltrms) => init_pplan_of_terms ctxt goaltrms
    val rst0 = RState.init_from_pp pp
    val mwire = WireNode.get_main_wire input_wire
    val gtyp = input_wire |> WireNode.get_fwire |> FWire.get_goal
    val gnds = GNode.GoalSet.of_list (map (GNode.mk_goal_no_facts gtyp) gs)
    (* wirekey,rstate *)
    fun new_wname rst = mwire
                    |> BWire.string_of
                    |> GNode_Ctxt.Wire.of_str
                    |> GNode_Ctxt.Wire.fresh_name rst
                    |> (fn wname => (wname,GNode_Ctxt.Wire.add (wname,mwire) rst))
    (* wirekey set,rstate *)
    fun new_gnds rst =
      let 
        fun mk_node_ctxt gn (gs,rst') = 
          let 
            val gnm = GNode.get_goal gn |> GNode_Ctxt.of_str |> GNode_Ctxt.fresh_name rst'
            val rst'' = GNode_Ctxt.add (gnm,gn) rst'
          in
           (gs @ [gnm],rst'')
          end
       in
         GNode.GoalSet.fold mk_node_ctxt gnds ([],rst)
         |> (fn (ls,rst) => (StrIntName.NSet.of_list ls,rst))
       end
    val input_boundary = GraphComb.get_boundary_inputs graph0
                         |> map (fn (a,b,c) => b) (* name * data pair *)
    fun add_matching_nds [] rst graph status = (status,(graph,rst))
     |  add_matching_nds ((en,wd)::es) rst graph status = 
          if input_wire <: (FWire_Ctxt.RState.get_wire rst wd) 
            then
              let 
                val (wname,rst') = new_wname rst
                val (gndsms,rst'') = new_gnds rst'
              in
                add_matching_nds 
                  es 
                  rst'' 
                  (GraphComb.insert_goalnode (en,graph) (default_gname,(wname,gndsms))) 
                  true
              end
            else add_matching_nds es rst graph status
    val (status,(graph1,rst1)) = add_matching_nds input_boundary rst0 graph0 false
    (* should really be by matching!! *)
    val enabled = graph1 
                |> GraphComb.get_rtechns_of_graph (* maybe only for input wires *)
                |> V.NSet.list_of 
                |> filter (is_enabled rst1 graph1)
   in
    case (enabled,status) of
       ([],false) => raise evaluate_exp (NONE,"Initialisation: no matching wire in graph and no enabled rtechn")
     | ([],true)  => (graph1,rst1,enabled) (* raise evaluate_exp "Initialisation: no enabled rtechn" *)
     | (_,false)  => raise evaluate_exp (NONE,"Initialisation: no matching wire in graph")
     | (_,true)   => (graph1,rst1,enabled)
   end;
*)

  (* search/eval *)

  (* FIXME: could loop if not wf *)


  fun next_rtechn_vertices g v = 
    if GraphComb.is_rtechn g v then [v]
     else  GraphComb.get_out_edges g v
        |> E.NSet.list_of
        |> maps (next_rtechn_edge g)
  and next_rtechn_edge g e = next_rtechn_vertices g (GraphComb.edge_dest g e);

  fun get_next_all_enabled rst g v =
    GraphComb.get_out_edges g v
    |> E.NSet.list_of
    |> maps (next_rtechn_edge g)
    |> filter (is_enabled rst g);

  fun is_output_goalnode g v = (* i.e. all output edges are to a boundary *)
      GraphComb.get_out_edges g v
   |> E.NSet.list_of
   |> map (GraphComb.edge_dest g)
   |> List.all (not o (GraphComb.is_vdata g))

  (* holds means termination *)
  fun only_output_nempty g =
    GraphComb.get_goalnodes_of_graph g
    |> V.NSet.filter (not o GraphComb.is_empty_goalnode g)
    |> V.NSet.forall (is_output_goalnode g);

  fun is_terminated is_empty (g,rst,enab) = is_empty enab andalso only_output_nempty g;

  (* aux fun *)
  fun split_pair' res [] = res 
   |  split_pair' (r1,r2) ((a,b)::xs) = split_pair' (r1@[a],r2@[b]) xs;
  val split_pair = split_pair' ([],[]);

  fun delete_inputs v g = 
    let 
      val (_,(in_edges,out_edges)) = RTechn_Theory.Graph.get_vertex g v
  (*
      val rt = RTechn_Ctxt.RState.get_rtechn rst (GraphComb.v_to_rtechn g v)
                 handle _ => raise evaluate_exp (SOME v,"Vertex not a reasoning technique")
  *)
      val (ainp_edgs,ainp_els) = 
         in_edges
         |> E.NSet.list_of
         |> map (fn e => (e,GraphComb.edge_src g e))
         |> filter (fn (_,v) => GraphComb.is_goalnode g v)
         |> split_pair;
      val new_inp_edges = 
        fold 
          (fn e => fn es => E.NSet.union_merge es (RTechn_Theory.Graph.in_enames g e))
          ainp_els
          E.NSet.empty;
      val mv_input_nds_edges =
        E.NSet.fold
         (GraphComb.change_edge_dest v) 
         new_inp_edges;
      val del_input_edges = 
        fold
          RTechn_Theory.Graph.delete_edge
          ainp_edgs;
      val del_input_nodes = 
        fold
          RTechn_Theory.Graph.delete_vertex
          ainp_els;
   in
      g |> mv_input_nds_edges
        |> del_input_edges
        |> del_input_nodes 
   end;


  (* should really do this by matching!! *)
  fun check_valid_unfold rt_name rule = 
    let 
       fun prj_vertex NONE = raise evaluate_exp (NONE, "Non-valid unfold rule in ruleset")
        |  prj_vertex (SOME v) = v;
       val lhs = RTechn_Theory.Rule.get_lhs rule
    in lhs
      |> GraphComb.get_rtechns_of_graph
      |> V.NSet.tryget_singleton
      |> prj_vertex
      |> GraphComb.v_to_rtechn lhs
      |> (fn v => RTechnKey.name_eq (v,rt_name))
    end;

  fun get_rule _ [] = raise evaluate_exp (NONE, "no matching rule for hgraph")
   |  get_rule rs [rnm] = RTechn_Theory.Ruleset.get_rule rs rnm
   |  get_rule _ _ = raise evaluate_exp (NONE, "more than one matching rule for hgraph");

  fun lookup_hgraph_rule rt_name rs rs_nms =
    rs_nms
    |> R.NSet.filter (fn rnm => check_valid_unfold rt_name (RTechn_Theory.Ruleset.get_rule rs rnm))
    |> R.NSet.list_of
    |> get_rule rs;

  fun get_or_rules _ [] = raise evaluate_exp (NONE, "no matching rule for or box")
   |  get_or_rules rs rns = map (RTechn_Theory.Ruleset.get_rule rs) rns

  fun lookup_or_rules rt_name rs rs_nms =
    rs_nms
    |> R.NSet.filter (fn rnm => check_valid_unfold rt_name (RTechn_Theory.Ruleset.get_rule rs rnm))
    |> R.NSet.list_of
    |> get_or_rules rs;
   
  fun init_hgraph rst g = 
    let 
      val enabled = 
         g |> GraphComb.get_rtechns_of_graph (* maybe only for input wires *)
           |> V.NSet.list_of 
           |> filter (is_enabled rst g)
    in
      (g,rst,enabled)
    end;

  (* just creates graph to evaluate with inputs added *)
  fun get_hgraph (g,rst,v) = 
    let
      fun th_of st = RState.get_ctxt st |> Proof_Context.theory_of
      val th = th_of rst
      val rt_name = GraphComb.v_to_rtechn g v;
      val rs = RTechn_RS.RState.get_ruleset rst;
      val rs_nms = RTechn_RS.rs_get_unfold rs;
      val rule = lookup_hgraph_rule rt_name rs rs_nms
      val dest_g = RTechn_Theory.Rule.get_rhs rule;
    in
      GraphComb.copy_input (v,(th,g)) (th,dest_g)
    |> init_hgraph rst
    end 

  (* all of these have to mutual recursive functions!!! *)
  fun eval_rule (g,rst,v) rule =
   let
      val dest_g = RTechn_Theory.Rule.get_rhs rule;
      fun th_of st = RState.get_ctxt st |> Proof_Context.theory_of
      val th = th_of rst
      val new_gseq = GraphComb.copy_input (v,(th,g)) (th,dest_g)
           |> init_hgraph rst
           |> GSearch.depth_fs (is_terminated EvalDF.is_empty) (EvalDF.apply eval_step get_next_all_enabled)
      fun upd (dest_g',rst',_) =
        GraphComb.copy_output (th_of rst',dest_g') (v,(th_of rst',g))
        |> delete_inputs v
        |> (fn final_g => (final_g,rst'))
    in
      Seq.map upd new_gseq
    end  

  and eval_hgraph (g,rst,v) = 
    let
      val rt_name = GraphComb.v_to_rtechn g v;
      val rs = RTechn_RS.RState.get_ruleset rst;
      val rs_nms = RTechn_RS.rs_get_unfold rs;
      val rule = lookup_hgraph_rule rt_name rs rs_nms
    in
      eval_rule (g,rst,v) rule
    end 

 and eval_or (g,rst,v) = 
    let
      val rt_name = GraphComb.v_to_rtechn g v;
      val rs = RTechn_RS.RState.get_ruleset rst;
      val rs_nms = RTechn_RS.rs_get_or_unfold rs;
      val rule_list = lookup_or_rules rt_name rs rs_nms
    in
      Seq.maps (eval_rule (g,rst,v)) (Seq.of_list rule_list)
    end 

 and eval_try (g,rst,v) = 
    let
      val rt_name = GraphComb.v_to_rtechn g v;
      val rs = RTechn_RS.RState.get_ruleset rst;
      val rs_try_nms = RTechn_RS.rs_get_try rs;
      val rs_else_nms = RTechn_RS.rs_get_else rs;
      val try_rule = lookup_hgraph_rule rt_name rs rs_try_nms
      val else_rule = lookup_hgraph_rule rt_name rs rs_else_nms
    in
      case Seq.pull (eval_rule (g,rst,v) try_rule) of
         NONE          => eval_rule (g,rst,v) else_rule (* fails: orelse branch *)
       | (SOME (s,ss)) => Seq.cons s ss (* succeeds: try branch *)
    end 

 and eval_merge (g,rst,v) = (* fixme: currently no deletion in context - not sure what to keep/delete? *)
    let 
      val (vdata,(in_edges,out_edges)) = RTechn_Theory.Graph.get_vertex g v
      val rt = RTechn_Ctxt.RState.get_rtechn rst (GraphComb.v_to_rtechn g v)
                 handle _ => raise evaluate_exp (SOME v,"Vertex not a reasoning technique")
      val ainp_els = in_edges
                   |> E.NSet.list_of
                   |> map (GraphComb.edge_src g)
                   |> filter (GraphComb.is_goalnode g)
      fun try_to_goalnode v = [GraphComb.v_to_goalnode g v] handle _ => []; 
      val inp_nds = maps try_to_goalnode ainp_els;
      (* fixme: not type checking? *)
      fun combine_res (n1,s1) (_,s2) = (n1,StrIntName.NSet.union_merge s1 s2);
      val out_node = case inp_nds of 
             [] => NONE
           | (x::xs) => SOME (fold combine_res xs x) 
      fun move_output nd = 
        E.NSet.fold 
         (fn e => fn g => (GraphComb.insert_goalnode (e,g) (V.mk "G",nd)))
         out_edges;
   in
    case out_node of 
      NONE => Seq.empty (* single (g,rst) *) (* or fail? *)
    | (SOME nd) => Seq.single
       (delete_inputs v g |> move_output nd,
        rst)
   end

  and eval_step (g,rst,v) = 
    if GraphComb.is_goalnode g v
     then raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    else 
      let val rt = RTechn_Ctxt.RState.get_rtechn rst (GraphComb.v_to_rtechn g v)
      in
       if (RTechn.is_atomic rt) then EvalAtomic.eval_atomic (g,rst,v)
       else if (RTechn.is_merge rt) then eval_merge (g,rst,v)
       else if (RTechn.is_hgraph rt) then eval_hgraph (g,rst,v)
       else if (RTechn.is_or rt) then eval_or (g,rst,v)
       else if (RTechn.is_try rt) then eval_try (g,rst,v) 
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
      end

  and step evalf = evalf eval_step get_next_all_enabled;

  val step_df = step EvalDF.apply;

  val step_bf = step EvalBF.apply;




  fun apply_search (evalf,is_empty,pust_to_empty) searchf th wire graph goals =
      init th goals wire graph
      |> searchf (is_terminated is_empty) evalf;

  val apply_evaldf_searchdf = apply_search (step_df,EvalDF.is_empty,EvalDF.of_list) GSearch.depth_fs ;

  fun all_inp_nodes g e vs = 
    let
        val v = GraphComb.edge_src g e
        fun inpedge v' = case E.NSet.list_of (RTechn_Theory.Graph.in_enames g v') of
              [e] => e
            | _ => raise EvalAtomic.atomic_eval_exp (v',"Vertex (or pre vertex) does not have 1 input")
    in
     if GraphComb.is_goalnode g v
     then V.NSet.add v vs (* is goalnode *)
     else if GraphComb.is_rtechn g v
     then V.NSet.empty (* no goalnodes on input *)
     else all_inp_nodes g (inpedge v) (V.NSet.add v vs) (* more edgepoints... *)
   end;

fun should_be_boundary g v =
  not(GraphComb.is_vdata g v) andalso
  (E.NSet.is_empty (GraphComb.get_in_edges g v) orelse
  E.NSet.is_empty (GraphComb.get_out_edges g v))
fun add_boundary v g =
  if should_be_boundary g v 
   then RTechn_Theory.Graph.add_to_boundary v g
   else g;
fun fix_boundary g = 
  V.NSet.fold
   add_boundary 
   (RTechn_Theory.Graph.get_vnames g)
   g;
 fun get_subgraph vs g = 
   g |> RTechn_Theory.Graph.normalise
     |> RTechn_Theory.Graph.get_open_subgraph vs
     |> RTechn_Theory.Graph.minimise (* bug in eval if not... *)
     |> fix_boundary; (* add to boundary *)

 fun create_eval_lhs (g,rst,v) =
    let val (vdata,(in_edges,out_edges)) = RTechn_Theory.Graph.get_vertex g v
        val in_nodes = E.NSet.fold (all_inp_nodes g) in_edges V.NSet.empty
    in
      get_subgraph (V.NSet.add v in_nodes) g
   end;

  fun create_eval_rule (g,rst,v) =  
    let val (vdata,(in_edges,out_edges)) = RTechn_Theory.Graph.get_vertex g v
        val in_nodes = E.NSet.fold (all_inp_nodes g) in_edges V.NSet.empty
        val lhs = get_subgraph (V.NSet.add v in_nodes) g
        val newseq = eval_step (lhs,rst,v)
        fun update (rhs,rst) = (RTechn_Theory.Rule.mk (lhs,rhs),rst)
    in
       Seq.map update newseq
   end;

  (* to apply by rewriting *)
  fun rewr' g rule m = 
    RTechn_Theory.GraphSubst.rewrite g (RTechn_Theory.Rule.get_lhs rule) m (RTechn_Theory.Rule.get_rhs rule)
    |> snd;

  fun rewr g rule =
    RTechn_Theory.RulesetRewriter.rule_matches rule g
    |> (fn (r,ms) => Seq.map (rewr' g r) ms);

  fun rewr_and_rst g (r,rst) =
    rewr g r
    |> Seq.map (fn g' => (g',rst));

  fun eval_by_rewriting (g,rst,v) =
    create_eval_rule (g,rst,v)
    |> Seq.maps (rewr_and_rst g); 

end (* struct *)


