(*
 evaluation of nested
*)
structure EvalNested =
struct

  structure EData = EvalD_DF;
  exception graph_exp of string * Strategy_Theory.Graph.T
 
  fun lhs_seq graph v = 
    v |> EvalGraph.mk_match_graph graph
      |> Seq.of_list
      |> Seq.maps (EvalGraph.eval_match_and_instantiate_rhs graph)
      |> Seq.map GraphEnv.half_edge_to_boundary

  fun v_gnode g = (case V.NSet.tryget_singleton (GraphEnv.get_goalnodes_of_graph g)
                    of NONE => raise graph_exp ("graph does not contain exactly 1 goalnode",g)
                     | SOME v => v)
  fun v_rtechn g = (case V.NSet.tryget_singleton (GraphEnv.get_rtechns_of_graph g)
                     of NONE => raise graph_exp ("graph does not contain exactly 1 rtechn",g)
                     | (SOME v) => v)

  fun mk_nested_edata old_edata graph = 
    old_edata
    |> EData.set_graph graph
    |> EData.set_goals StrName.NTab.empty
    |> EData.add_goal (EData.get_goal old_edata (GNode.get_goal (GraphEnv.v_to_gnode graph (v_gnode graph))))

  fun rule_inverse rule = 
    Strategy_Theory.Rule.mk (Strategy_Theory.Rule.get_rhs rule,
                             Strategy_Theory.Rule.get_lhs rule)
  val apply_inv_rule  =
    EvalGraph.rewrite_lazy o rule_inverse;

  fun eval_nested_rule evalf edata v rule = 
    let
      val graph = EData.get_graph edata
      fun eval_one' lhs =
        let 
           val gnode = (GraphEnv.v_to_gnode lhs (v_gnode lhs))
           fun mk_eval_rules edata' = 
              apply_inv_rule rule (EData.get_graph edata')
              |> Seq.map (fn rhs => Strategy_Theory.Rule.mk (lhs,rhs))
           fun update_old_edata edata' graph' =
              edata |> EData.set_pplan (EData.get_pplan edata') (* updates proof in context *)
                    |> EData.del_goal (GNode.get_goal gnode) (* deletes goal from ctxt (now in prf) *)
                    |> EData.add_goals (EData.get_goals edata' |> StrName.NTab.values)
                    |> EData.set_graph graph'
           fun update_parent edata' =
             edata' |> mk_eval_rules
                    |> Seq.maps (fn r => EvalGraph.rewrite_lazy r graph)
                    |> Seq.map (update_old_edata edata')
        in
          lhs |> EvalGraph.rewrite_lazy rule
              |> Seq.map (mk_nested_edata edata)
              |> Seq.maps evalf
              |> Seq.maps update_parent
        end
   in
      Seq.maps eval_one' (lhs_seq graph v)
   end;

  (* assume not represented as a variable *)
  fun eval_nested_get_rules tag edata v =
    let 
       val rt = GraphEnv.v_to_rtechn (EData.get_graph edata) v  
       val rulenames = case tag of 
          NONE => Strategy_Theory.Ruleset.get_all_rule_names_list (EData.get_ruleset edata)
         |  (SOME t) => (Strategy_Theory.Ruleset.get_rules_in_tag (EData.get_ruleset edata) t
                         |> R.NSet.list_of)
       val rulelist = map (Strategy_Theory.Ruleset.get_rule (EData.get_ruleset edata)) rulenames
       fun isvalid rule = (Strategy_Theory.Rule.get_lhs rule)
                        |> GraphEnv.get_rtechns_of_graph
                        |> V.NSet.list_of
                        |> map (GraphEnv.v_to_rtechn (Strategy_Theory.Rule.get_lhs rule))
                        |> exists (fn rt' => RTechn.eq (rt,rt'))
   in
     filter isvalid rulelist
  end;  


  fun eval_nested evalf tag edata v =
    let 
       val rulelist = eval_nested_get_rules tag edata v
   in
     Seq.maps (eval_nested_rule evalf edata v) (Seq.of_list rulelist)
  end;

end (* struct *)



(************************ 
 FROM eval.ML

*************************)

(* NOT SO OLD STUFF (after moving to new quanto) *)

(*
(************************************************************
  
      EVALUATION STRATEGIES

*************************************************************)

  fun evaluate edata v = 
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    | SOME rt =>
       if (RTechn.is_atomic rt) then eval_atomic edata v rt 
       else if (RTechn.is_merge rt) then raise evaluate_exp (SOME v, "merge not supported")
       else if (RTechn.is_identity rt) then raise evaluate_exp (SOME v, "identity not supported")
       else if (RTechn.is_hgraph rt) then eval_nested edata v
       else if (RTechn.is_or rt) then eval_or edata v
       else if (RTechn.is_orelse rt) then raise evaluate_exp (SOME v, "orelse not supported")
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
     ;

   (* should check if it is a nested and then move goalnodes back  *)

   datatype result = Good of EData.T | Bad | Cont of EData.T

   (* to do : add this into contxt to allow users to define their own functions *)
   fun searchf new old "breath_first" = old @ new
    |  searchf new old "depth_first" = new @ old
    |  searchf new old _ = new @ old;

   fun update_branches_all edata branches =
     case Seq.list_of branches of
       [] => Bad
     | ys => (* to do: replace by search data *)(DebugHandler.debug_print DebugHandler.EVAL ("Eval number of branches: " ^ (Int.toString (length ys)));
          (case searchf ys (EData.get_branches edata) (EData.get_searchf edata) of
             [] => Bad (* should never happen *)
           | (x::xs) => (* fixme: this should be based on the search strategy *)
               Cont (edata 
                     |> EData.set_current x 
                     |> EData.set_branches xs)));

  fun update_branches_single edata branches =
     case Seq.pull branches of
       NONE => Bad
     | SOME (y,ys) => (* to do: replace by search data *)
     ((case searchf [y] (EData.get_branches edata) (EData.get_searchf edata) of
             [] => Bad (* should never happen *)
           | (x::xs) => (* fixme: this should be based on the search strategy *)
               Cont (edata 
                     |> EData.set_current x 
                     |> EData.set_branches xs)));

  val update_branches = 
    case Prover.psgraph_prover_i 
    of "isabelle" => update_branches_all
     | "proofpower" => update_branches_single
                   
   (* fixme: only normalise goal nodes for picked branched *)
   fun pick_first_branch edata [] = Bad
    |  pick_first_branch edata (x::xs) = 
         case update_branches edata x of 
           Bad => pick_first_branch edata xs
(*         | res => res; *)
         | Good res => Good (normalise_gnode res)
         | Cont res => Cont (normalise_gnode res);

   fun evaluate_backtrack edata = 
     case EData.get_branches edata  
     of [] => Bad
      | branch  => 
          Cont( EData.set_current (hd branch) edata 
                |> EData.set_branches (tl branch) 
                |> normalise_gnode) 
    
   fun evaluate_any edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     EGraph.Util.all_tactics (EData.get_graph edata)
     |> Seq.of_list
     |> Seq.maps (evaluate edata)
     |> update_branches edata

   fun get_tactic [] _ = raise evaluate_exp (NONE,"No applicable tactic")
    |  get_tactic (x::xs) edata =
         case next_tactic (EData.get_graph edata) x of
           SOME v => v
         | NONE => get_tactic xs edata;

   (* follows evaluation strategy *)
   fun evaluate_next edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     evaluate edata (get_tactic (EData.get_gnodes edata) edata)
     |> update_branches edata

   (* similar to evaluate_any, but only evaluate a single one *)
   fun evaluate_single edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     EGraph.Util.all_tactics (EData.get_graph edata)
     |> map (evaluate edata)
     |> pick_first_branch edata

   (* similar to evaluate_any, but only evaluate a single one *)
   fun evaluate_arbitrary edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     EGraph.Util.all_tactics (EData.get_graph edata)
     |> map (evaluate edata)
     |> pick_first_branch edata

   (* depth first search  *)
   fun evaluate_full edata = 
     case evaluate_arbitrary edata of
       Good edata' =>
         (case EData.next_branch edata' of
            NONE => [EData.get_pplan edata']
           | SOME (res,edata'') =>  (EData.get_bpplan res) :: (evaluate_full edata''))
       | Bad => 
         (case EData.next_branch edata of
            NONE => []
           | SOME (_,edata'') => evaluate_full edata'')
       | Cont edata' => evaluate_full edata';

   (* depth first search  *)
   fun evaluate_full_one edata = 
     (case evaluate_arbitrary edata of
       Good edata' => [EData.get_pplan edata']
     | Bad => (case EData.next_branch edata of
            NONE => []
           | SOME (_,edata') => evaluate_full_one (normalise_gnode edata'))
     | Cont edata' => evaluate_full_one edata')    


  (* FOR DEBUGGING PURPOSES *)

  (* should return (atomic,gnode) pairs (for given vertex) *)
  fun debug_get_gnodes_input edata v = 
     EGraph.matched_lhs (EData.get_graph edata) v
     |> Seq.list_of
     |> maps (fn (_,g) =>  EGraph.Util.all_gnodes g);

  fun debug_get_appf_gnode_vertex edata v =
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => []
    | SOME rt => 
       if (RTechn.is_atomic rt) 
       then (debug_get_gnodes_input edata v
             |> maps (fn g => [(rt,case (RTechn.get_appf rt) of RTechn.Appf atom => atom ,g)])) 
       else []; 

  fun debug_get_appf_gnode edata = 
     EGraph.Util.all_tactics (EData.get_graph edata)
     |> maps (debug_get_appf_gnode_vertex edata);
 
  fun debug_apply_appf edata = 
    debug_get_appf_gnode edata
    |> Seq.of_list
    |> Seq.maps (fn (_,appf,gn) => (EAtom.apply_appf edata gn appf))
    |> Seq.list_of;


  (*
   fun debug_eval_tac_Vert edata v = 
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    | SOME rt =>
       if (RTechn.is_atomic rt) 
  
then eval_atomic edata v rt 
*)


(* 
  and eval_one edata =
    eval_one_restricted (GraphEnv.get_rtechns_of_graph (EData.get_graph edata)) edata

  and eval_full edata = 
    case eval_one edata of
      NONE => if edata_terminated edata then (Seq.single edata) else Seq.empty
    | SOME edatas => Seq.maps eval_full edatas;
 
  fun eval_any edata =   
     GraphEnv.get_rtechns_of_graph (EData.get_graph edata)
     |> V.NSet.seq_of
     |> Seq.maps (one_step edata);
*)

  (* assumes nested , terminated and exact same boundary *)
  fun fold_nested edata =
   let  
    val res = EData.get_graph edata |> EGraph.normalise_combine_gnodes;
    val (SOME lhs) = EData.parent_lhs edata;
    val [gnode_name] = EGraph.Util.all_gnodes lhs;
    val lhs' = EGraph.Util.del_gnode gnode_name lhs
    val out_gnodes = EGraph.Util.all_gnodes res
    val rhs = fold (move_gnode res) out_gnodes lhs'
    val rule = EGraph.Theory.Rule.mk (lhs,rhs);
    val branch = EData.pop_bactive (EData.get_current edata);
    fun upd_gnodes branch =
     let
       val gnodes = 
             evalf (EGraph.Util.all_gnodes res)   
                   (EData.get_bgnodes branch)
                   (EData.get_bevalf branch)
    in 
      EData.set_bgnodes gnodes branch
    end
   in (* to do: update active? *)
     EGraph.Util.rewrite_lazy rule (EData.get_bgraph branch)
     |> Seq.map (fn g => EData.set_bgraph g branch)
     |> Seq.map upd_gnodes 
   end;

  fun eval_or edata v = 
   let 
     val rtechn = EGraph.Util.rtechn_of (EData.get_graph edata) v
     val name = rtechn
              |> RTechn.get_name
              |> RT.dest
     val unfrules = StrName.NTab.get (EData.PSGraph.get_or_tacs (EData.get_psgraph edata)) name
   in
     Seq.maps (unfold_nested edata v rtechn) (Seq.of_list unfrules)
   end;

  fun eval_nested edata v = 
   let 
     val rtechn = EGraph.Util.rtechn_of (EData.get_graph edata) v
     val name = rtechn
              |> RTechn.get_name
              |> RT.dest
     val unfrule = StrName.NTab.get (EData.PSGraph.get_g_tacs (EData.get_psgraph edata)) name
   in
     unfold_nested edata v rtechn unfrule 
   end

 (* to do: set eval properties properties *)
  (* note: input gnode removed from' parent, but will be added on folding *)
  fun unfold_nested edata v rtechn unfrule = 
   let 
     val lhs_seq = EGraph.matched_lhs (EData.get_graph edata) v
     fun update_searchf branch = (* should maybe be removed for or for optimisations *)
       case RTechn.get_searchf rtechn of
         NONE => branch
        | SOME str => EData.set_bsearchf str branch; 
     fun update_evalf branch = (* should maybe be removed for or for optimisations *)
       case RTechn.get_evalf rtechn of
         NONE => branch
        | SOME str => EData.set_bevalf str branch; 
     fun rm_gnodes lhs = 
      EData.update_gnodes 
        (delete_gnodes (EGraph.Util.all_gnodes lhs))
     fun upd (_,lhs) = EGraph.Util.rewrite_lazy unfrule lhs
                     |> Seq.map (fn rhs => EData.push_bactive rhs lhs [] (EData.get_current (rm_gnodes lhs edata))
                                           |> update_searchf |> update_evalf)
   in
     Seq.maps upd lhs_seq
   end

  val normalise_gnode = EData.update_graph EGraph.normalise_gnode;

 fun mk_atomic_rhs edata rt lhs =
    let
      val out_edges = 
        EGraph.Util.output_boundary lhs 
        |> map (fn (_,(x,_),_) => x)
      val out_types =  map (EGraph.Util.gtyp_of lhs) out_edges;
      val [gnode_name] = EGraph.Util.all_gnodes lhs;
      val gnode =  EGraph.Util.gnode_of lhs gnode_name
      val result_seq = EAtom.apply_atomic edata gnode rt out_types
      fun apply_one (edata',part) = 
           lhs |> EGraph.Util.del_gnode gnode_name
               |> EGraph.add_outs out_edges part 
               |> (fn rhs => (edata',(lhs,rhs)))
      fun apply_all (edata',[]) = (* no subgoals *)
          lhs |> EGraph.Util.del_gnode gnode_name
              |> (fn rhs => (edata',(lhs,rhs)))
              |> Seq.single      
        | apply_all (edata',parts) =
              parts
              |> map EAtom.partition_to_gnodes
              |> Seq.of_list
              |> Seq.map (fn p => apply_one (edata',p));
    in
      Seq.maps apply_all result_seq
    end

  fun eval_atomic edata v rt = 
   let
     val graph = EData.get_graph edata
     val lhs_seq = EGraph.matched_lhs (EData.get_graph edata) v
     fun upd_edata_gnode (lhs,rhs) branch = 
       let
         val left_gs = EGraph.Util.all_gnodes lhs
         val right_gs = EGraph.Util.all_gnodes rhs
         val current = EData.get_bgnodes branch
         val updated = 
           evalf right_gs 
                 (delete_gnodes left_gs current) 
                 (EData.get_evalf edata)
       in
         EData.set_bgnodes updated branch
       end
      (* delete input node(s) *)
     fun update (branch,(lhs,rhs)) =
       Seq.map (fn g => EData.set_bgraph g branch |> upd_edata_gnode (lhs,rhs))
               (EGraph.Util.rewrite_lazy (Theory.Rule.mk (lhs,rhs)) graph);
   in 
    lhs_seq 
    |> Seq.maps ((mk_atomic_rhs edata rt) o snd) 
    |> Seq.maps update 
   end; 

 (* working with evaluation strategy *)

 (* should not be required as you should really only work on first goal node! *)
 fun delete_gnode gnode [] = []
  |  delete_gnode gnode (g::gs) = 
       if GoalTyp.gnode_eq(gnode,g) 
        then delete_gnode gnode gs
        else g::(delete_gnode gnode gs)

  val delete_gnodes = fold delete_gnode;

  (* to do : add this into contxt to allow users to 
      define their own functions, maybe more information required? *)
  fun evalf new old "breath_first" = old @ new
   |  evalf new old "depth_first" = new @ old
   |  evalf new old _ = new @ old;
*)

(* OLD STUFF *)

(*


  fun init_prf (th:theory) (pnds,prf) graph = 
    let
       val wset = GraphEnv.get_input_wires graph;
       val ptab = 
         fold
           (fn pnode => StrName.NTab.ins (PNode.get_name pnode,pnode))
            pnds
           (StrName.NTab.empty);
       val edata0 = EData.init_of prf graph ptab [] th;
       val ggraphs = pnds 
                   |> map (EvalOutput.lift_pnode_by_wires (EData.get_fmatch edata0) wset)
                   |> map (fn (w,g) => GraphEnv.lift_gnode g w)
       val g1 = fold GraphComb.then_g ggraphs graph;
    in 
       edata0 
       |> EData.set_graph g1
    end;

  fun init_g (th:theory) trms = 
    init_prf (th:theory) (PPlan.init_gls (Proof_Context.init_global th) trms);

  fun init_f (th:theory) trms graphf = 
    let
       val (g0,th') = graphf th
    in
      init_g th' trms g0
    end;

  fun is_terminated active_rtechns graph =
    let 
      val g' = Strategy_Theory.Graph.minimise graph
      val iedge = Strategy_Theory.Graph.get_in_edges g' #> E.NSet.list_of;
      val inode = (map (Strategy_Theory.Graph.get_edge_source g')) o iedge;
      val inodes = maps inode active_rtechns
      val check = not o (GraphEnv.is_gnode g');
    in
     forall check inodes
    end;

  fun graph_terminated graph = 
     is_terminated (V.NSet.list_of (GraphEnv.get_rtechns_of_graph graph)) graph;

  val edata_terminated = graph_terminated o EData.get_graph;
*)


(*************************

FROM EVAL_ATOMIC.ML

***************************)

(* OLD STUFF TO DELETE *)

(* 

  fun apply_atomic edata gnode rtechn goal_typs = 
   let 
     fun appf atom = apply_appf edata gnode atom
     fun apply_one (pnds,pplan) =
         Seq.single (EData.get_current edata
           |> EData.set_bpplan pplan
           |> EData.add_bgoals pnds,
         partition pnds gnode goal_typs)
      handle partition_exp _ => Seq.empty
   in
    case (RTechn.get_appf rtechn) of
       RTechn.Appf atom => appf atom 
                       (*|> Seq.list_of
                       |> map apply_one
                       |> Seq.of_list*)
                       |> Seq.maps apply_one
      | _ => Seq.empty (* TODO: raise exception *)

  fun apply_appf edata gnode (RTechn.Rule fact_nms) =
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn (fnm,fact) => Prover.apply_rule fnm fact (pnode,pplan)) facts
          |> (fn x =>
          (case (Seq.pull x) of NONE  
           => add_debug_msg 
                (Pretty.chunks [Pretty.str ("Fail to apply RULES " ^
                                (StrName.NSet.list_of fact_nms |> map Pretty.str |> Pretty.block |> Pretty.string_of) ^ 
                                " to "), 
                                Prover.pretty_concl pnode]) 
           | _ => ()
          ;x))
        end
    |  apply_appf edata gnode (RTechn.ERule fact_nms) =
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn (fnm,fact) => Prover.apply_erule fnm fact (pnode,pplan)) facts
          |> (fn x =>
          (case (Seq.pull x) of NONE  
           => add_debug_msg 
                (Pretty.chunks [Pretty.str ("Fail to apply ERULES " ^
                                (StrName.NSet.list_of fact_nms |> map Pretty.str |> Pretty.block |> Pretty.string_of) ^ 
                                " to "), 
                                Prover.pretty_concl pnode]) 
           | _ => ()
          ;x))
        end
     (* it never fails: it tries of them once (should revisit this though) *)
   |  apply_appf edata gnode (RTechn.FRule (class_nm,fact_nms)) =
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          (* the class to apply to *)
          val hyps = GoalTyp.get_fact_names class_nm gnode 
                     |> fact_list pnode
          (* the fact to apply *) 
          val facts = fact_list pnode fact_nms
          (* one application of a frule of a fact to a hyp *)
          fun try_apply_as_list hyp fact (pn,pp) = 
             (case Prover.apply_frule hyp fact (pn,pp) |> Seq.list_of of
                [] => [([pn],pp)]
               | xs => xs)
          fun try_apply_frule' hyp fact (pnds,pp) =
             maps (fn pn => try_apply_as_list hyp fact (pn,pp)) pnds
          fun try_apply_frule hyp fact pnpps =
             maps (try_apply_frule' hyp fact) pnpps
          fun apply_frule hyp pnpps =
            fold (try_apply_frule hyp) facts pnpps
        in (* fold: ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b *)
           fold apply_frule hyps [([pnode],pplan)] 
           |> Seq.of_list
        end
   |  apply_appf edata gnode (RTechn.Subst fact_nms) = 
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn (fnm,fact) => Prover.apply_subst fnm fact (pnode,pplan)) facts
                    |> (fn x =>
          (case (Seq.pull x) of NONE  
           => add_debug_msg 
                (Pretty.chunks [Pretty.str ("Fail to apply SUBST " ^
                                (StrName.NSet.list_of fact_nms |> map Pretty.str |> Pretty.block |> Pretty.string_of) ^ 
                                " to "), 
                                Prover.pretty_concl pnode]) 
           | _ => ()
          ;x))
        end
   |  apply_appf edata gnode (RTechn.SubstAsm (class_nm,fact_nms)) =  (* why not a wire? *)
         let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val hyps = GoalTyp.get_fact_names class_nm gnode 
                     |> fact_seq pnode 
          val eqs = fact_seq pnode fact_nms
          (* one application of subst of a eq to a fact *)
          fun apply_subst_asm' hyp eq = Prover.apply_subst_asm hyp eq (pnode,pplan)
          (* application of all equalities to a hyp *)
          fun apply_subst_asm hyp = Seq.maps (apply_subst_asm' hyp) eqs
        in
           Seq.maps apply_subst_asm hyps
        end
   |  apply_appf edata gnode (EData.PSGraph.Theory.Data.nvdataactic (tac_data,name)) =
        apply_tactic edata gnode name tac_data
   |  apply_appf _ _ _ = raise eval_appf_exp "unknown application type";

*)



(***************************
   FROM EVAL_GRAPH
****************************)
signature EVAL_GRAPH =
sig
  structure GoalTyp : BASIC_GOALTYPE
  structure Prover : PROVER
end

functor EvalGraphFun(EData : EVAL_DATA) =
struct
  structure EData = EData;
  structure Prover = EData.PSGraph.Theory.Data.GoalTyp.Prover;
  structure Theory = EData.PSGraph.Theory;
  structure Graph = Theory.Graph;
  structure GData = EData.PSGraph.Theory.Data;

  (* move into separate/different file? *) 
  structure Util =
  struct
      (* actual rewriting *)
    fun rewrite_lazy rule graph = 
      let 
        val graph' = Graph.normalise graph;
        val matches = Theory.Rewriter.find_matches rule graph';
        fun rewr match = 
          Theory.Rewriter.rewrite_at rule match
          |> snd
      in
        Seq.map rewr matches
      end;
    val rewrite = Seq.list_of oo rewrite_lazy;

  (* simplify ? *)
  fun input_boundary g = 
    let val bvertexes = Graph.get_inputs g (* Vertex.NSet.T *)
        fun dest_name bv e =(bv,(e,Graph.get_edge_data g e),Graph.get_edge_target g e)
        fun mk_pairs v = Graph.get_out_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

  fun output_boundary g = 
    let val bvertexes = Graph.get_outputs g (* Vertex.NSet.T *)
        fun dest_name bv e =(Graph.get_edge_source g e,(e,Graph.get_edge_data g e),bv)
        fun mk_pairs v = Graph.get_out_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

    fun edge_dest g e = Graph.get_edge_target g e;
    fun edge_src g e = Graph.get_edge_source g e;
    fun edge_data g e = Graph.get_edge_data g e;

   (* checks data *)
    fun lookup_ivertex_data g v = 
      case Graph.get_vertex_data g v of 
          (Graph.NVert nv) => SOME nv
        | _ => NONE

   val vertex_data = the oo lookup_ivertex_data;

   fun out_edges graph v = 
      Graph.get_out_edges graph v 
      |> E.NSet.list_of;

   fun in_edges graph v = 
      Graph.get_in_edges graph v 
      |> E.NSet.list_of;

    fun insert_node_on_edge node edge graph0 =
      let val (l,graph') = Graph.add_vertex (Graph.NVert node) graph0
          val from' = edge_src graph' edge
          val to' = edge_dest graph' edge
          val edata = edge_data graph' edge
          val graph' = Graph.delete_edge edge graph'
          val (src, graph') = Graph.add_edge (Directed,edata) from' l graph'
          val (dest, graph') = Graph.add_edge (Directed,edata) l to' graph'
      in
        (src,dest,graph')
      end;

    (* assumes: 1/1 - so just replace by wire node *)
    val del_gnode = Graph.update_vertex_data (K Graph.WVert);

   fun mk_binput edata dest graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) n dest g);

   fun mk_boutput edata source graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) source n g);

   (* checks type *)
   fun is_gtyp graph e = 
     case edge_data graph e of (GData.GT _) => true | _ => false;
   fun is_tactic graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.T_Atomic _) => true
       | SOME (GData.T_Graph _) => true
       | SOME GData.T_Identity => true
       | _ => false; 
   fun is_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.G _) => true
       | _ => false; 


   (* lookup node *)
   (* fun lookup_rtechn graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.RT rt) => SOME rt
       | _ => NONE; *)
   fun lookup_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.G gn) => SOME gn
       | _ => NONE; 

   (* projects goal types - exception if not existing *)
   fun goaltype_of graph e = 
     case edge_data graph e of (GData.GT g) => g   (* |  _ => raise error *);
(*
   fun rtechn_of graph v = 
     case vertex_data graph v of (GData.RT rt) => rt; 
*)
   fun gnode_of graph v = 
     case vertex_data graph v of (GData.G gn) => gn
(*
   fun single_gnode_of graph v = 
     case vertex_data graph v of (GData.GN (GData.GN_Node gnode)) => gnode;
*)

   fun mk_gnode gnode = GData.G gnode;


   fun get_vertex_list graph =  
     Graph.get_vertices graph
     |> V.NSet.list_of

   (* projects *)
   fun all_tactics graph = 
     get_vertex_list graph
     |> filter (is_tactic graph);

   fun all_gnodes graph = 
     get_vertex_list graph
     |> filter (is_gnode graph);

(*
   fun prj_single_gnodes (GData.GN_Node gn) = [gn]
    |  prj_single_gnodes (GData.GN_Pair (g1,g2)) =
         prj_single_gnodes g1 @ prj_single_gnodes g2
    |  prj_single_gnodes _ = []

   fun all_single_gnodes graph = 
     all_gnodes graph
     |> map (gnode_of graph)
     |> maps prj_single_gnodes;
*)

  end (* structure Util *)
 
  (* FIXME: makes one for each input - can be generalised by vars on the edges
     instead - then we only need on lhs per rule  *)
  fun mk_lhs graph v =
    let 
     val ins = Graph.get_in_edges graph v  
     val outs = Graph.get_out_edges graph v
     val gtyp = Util.goaltype_of
     val gnode = Graph.NVert (GData.G_Var "g")
     (* val tactic  = Util.tactic_of graph v *)
     (* graph with rtechn *)
     val (v_rt,g) = Graph.empty
               |> Graph.add_vertex (Graph.get_vertex_data graph v)
     (* adding goalnode variable *)
     val (v_gvar,g) = Graph.add_vertex gnode g 
     (* one lhs for each input node *)
     fun mk_lhs' inp = g
         |> Graph.add_edge_anon (Directed,GData.GT (gtyp graph inp)) v_gvar v_rt
         |> Util.mk_binput (GData.GT (gtyp graph inp)) v_gvar
         |> E.NSet.fold (fn outp => Util.mk_boutput (GData.GT (gtyp graph outp)) v_rt) outs
         |> E.NSet.fold (fn o_inp => Util.mk_binput (GData.GT (gtyp graph o_inp)) v_rt) 
                        (E.NSet.delete' inp ins) 
    in 
     map mk_lhs' (E.NSet.list_of ins)      (* one match per input *)
   end;

  (* Should be one rtechn and one graph *)
  fun match_lhs graph lhs =
     Theory.Rewriter.find_matches
           (Theory.Rule.mk(lhs,lhs)) (* make a dummy rule *)
           graph
     |> Seq.map (fn m => (Theory.Match.get_subst m, Graph.apply_data_subst (Theory.Match.get_subst m) lhs));
        
  fun matched_lhs graph v = Seq.maps (match_lhs graph) (mk_lhs graph v |> Seq.of_list)

 (* vertex list -> partition -> graph -> graph *)
 fun add_outs [] [] graph = graph
  |  add_outs  (i::is) (p::ps) graph = 
       add_outs is ps (#3 (Util.insert_node_on_edge p i graph));

  (* RULES FOR REWRITING *)

(*
 val split_gnode_pairs = 
  let
    val edge = GData.GT_Var "e";
    val bnode = GData.GN (GData.GN_Pair (GData.GN_Var "h",GData.GN_Var "t"));
    val fnode = GData.GN (GData.GN_Var "h");
    val snode = GData.GN (GData.GN_Var "t");
    val (inp,g0) = Graph.add_vertex Graph.WVert Graph.empty;
    val (outp,g0) = Graph.add_vertex Graph.WVert g0;
    val (bn,left) = Graph.add_vertex (Graph.NVert bnode) g0; 
    val left = left |> Graph.add_edge_anon (Directed,edge) inp bn
                    |> Graph.add_edge_anon (Directed,edge) bn outp;
    val (fno,right) = Graph.add_vertex (Graph.NVert fnode) g0; 
    val (sno,right) = Graph.add_vertex (Graph.NVert snode) right;
    val right = right |> Graph.add_edge_anon (Directed,edge) inp sno
                      |> Graph.add_edge_anon (Directed,edge) sno fno
                      |> Graph.add_edge_anon (Directed,edge) fno outp;
  in
     Theory.Rule.mk (left,right)
  end;
*)

 fun symmetric_rule rule = Theory.Rule.mk (Theory.Rule.get_rhs rule,Theory.Rule.get_lhs rule);
(*
 val combine_gnodes_to_pair = symmetric_rule split_gnode_pairs;
*)

(*
 val del_empty_gnode = 
  let
    val edge = GData.GT_Var "e";
    val node = GData.GN (GData.GN_Empty);
    val (inp,g0) = Graph.add_vertex Graph.WVert Graph.empty;
    val (outp,g0) = Graph.add_vertex Graph.WVert g0;
    val (bn,left) = Graph.add_vertex (Graph.NVert node) g0; 
    val left = left |> Graph.add_edge_anon (Directed,edge) inp bn
                    |> Graph.add_edge_anon (Directed,edge) bn outp;
    val right = Graph.add_edge_anon (Directed,edge) inp outp g0
  in
     Theory.Rule.mk (left,right)
  end;
*)

(*
 val gnode_rs = Theory.Ruleset.empty
            |> Theory.Ruleset.add_fresh_rule (R.mk "del_empty",del_empty_gnode)
            |> (fn (rn,rs) => Theory.Ruleset.activate_rule rn rs)
            |> Theory.Ruleset.add_fresh_rule (R.mk "split_pair",split_gnode_pairs)
            |> (fn (rn,rs) => Theory.Ruleset.activate_rule rn rs)

 val gnode_one_step  = Theory.RulesetRewriter.apply gnode_rs
                     #> Seq.map snd;

 fun normalise_gnode g = 
   case Seq.pull (gnode_one_step g) of
      NONE => g
     | SOME (g',_) => normalise_gnode g';

 fun normalise_combine_gnodes g = 
   case Seq.pull (Util.rewrite_lazy combine_gnodes_to_pair g) of
     NONE => g
   | SOME (g',_) => normalise_combine_gnodes g';

*)
      
end (* functor *)

