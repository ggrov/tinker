(* TO DO
     - hierarchies 
     - meta-variables

*)
(* Fixme: should this also be a quanto graph? what are the boundaries? *)
structure PPlan = 
struct
  (* fixme: maybe best to change to tree rep where nesting is a separate tree? *)
  datatype PTree = PLeaf of unit
                 | PHierarchy of PTree * (PTree list) (* body and cont - should maybe be a forrest? *)
                 | PBranch of PTree list

  datatype T = Prf of {
    ptab : PNode.T StrName.NTab.T,
    all_nms : StrName.NSet.T,
    open_nms : StrName.NSet.T,
    root_nms : StrName.NSet.T }

  fun get_ptab (Prf prf) = #ptab prf;
  fun get_open_nms (Prf prf) = #open_nms prf;
  fun get_all_nms (Prf prf) = #all_nms prf;
  fun get_root_nms (Prf prf) = #root_nms prf;  

  val lookup_node = StrName.NTab.lookup o get_ptab;

  fun update_ptab f (Prf prf) = 
       Prf {ptab = f (#ptab prf), open_nms = #open_nms prf, 
            all_nms = #all_nms prf, root_nms = #root_nms prf};
  fun update_open_nms f (Prf prf) = 
       Prf {ptab = #ptab prf, open_nms = f (#open_nms prf), 
            all_nms = #all_nms prf, root_nms = #root_nms prf};
  fun update_all_nms f (Prf prf) = 
       Prf {ptab = #ptab prf, open_nms = #open_nms prf, 
            all_nms = f (#all_nms prf), root_nms = #root_nms prf};
  fun update_root_nms f (Prf prf) = 
       Prf {ptab = #ptab prf, open_nms = #open_nms prf, 
            all_nms = #all_nms prf, root_nms = f (#root_nms prf)};

  (* fixme: needs more checks? *)
  val set_ptab = update_ptab o K;  
  val set_open_nms = update_open_nms o K; 
  val set_all_nms = update_all_nms o K; 
  val set_root_nms = update_root_nms o K; 

  (* note: no duplication check *)
  fun insert_all_nd e = update_all_nms (StrName.NSet.add (PNode.get_name e));

  fun insert_root_nd e = update_root_nms (StrName.NSet.ins_fresh (PNode.get_name e))
                       #> insert_all_nd e;
  fun insert_open_nd e = update_open_nms (StrName.NSet.ins_fresh (PNode.get_name e))
                       #> insert_all_nd e;
  fun insert_ptab_nd e = update_ptab (StrName.NTab.ins (PNode.get_name e,e))
                       #> insert_all_nd e;

  val insert_open_list = fold insert_open_nd;

  fun remove_open_nd e = update_open_nms (StrName.NSet.delete (PNode.get_name e));

  val init_prf =  Prf {ptab = StrName.NTab.empty, open_nms = StrName.NSet.empty, 
                       all_nms = StrName.NSet.empty, root_nms = StrName.NSet.empty};

  fun add_root nd = insert_root_nd nd
                  #> insert_open_nd nd
                  #> insert_all_nd nd
                  #> insert_ptab_nd nd; (* do we want to add it here? shouldn't it be on the graph? *)

  fun update_ptab_nd e = update_ptab (StrName.NTab.update (PNode.get_name e,e));

  val fresh_name = StrName.NSet.new;
  fun fresh_goal gs = fresh_name gs "g";

  fun var_names (Free (v,_)) = [v]
   |  var_names (Abs (_,_,t)) = var_names t
   |  var_names (t1 $ t2) = var_names t1 @ var_names t2
   |  var_names _ = []

  (* remove duplicates *)
  val var_names' = StrName.NSet.list_of o StrName.NSet.of_list o var_names 
 
  val is_bound_in_ctxt = Option.isSome oo Variable.lookup_fixed;

  fun unb_var_names ctxt = (filter (not o (is_bound_in_ctxt ctxt))) o var_names';

  fun add_variable_fixes t ctxt = Variable.add_fixes (unb_var_names ctxt t) ctxt;


  (* turns P1 ==> ... ==> Pn into Pn with P1 to P(n-1) added as assumptions *)
  fun upd_assumptions (asms,bvars,ctxt,goal) =
   case Logic.strip_imp_prems goal of
     [] => NONE
   | xs =>
      let
        val assms' = map (Thm.cterm_of (Proof_Context.theory_of ctxt)) xs
        val (asms', ctxt') = Assumption.add_assumes assms' ctxt;
        val goal' = Logic.strip_imp_concl goal
      in
       SOME (asms @ asms',bvars,ctxt',goal')
      end;
  
  (* turns !! x .. z. P x .. z into P x .. z with x .. z fixed in ctxt (and possible renamed) *)
   fun upd_bvars (asms,bvars,ctxt,goal) =
     case Term.strip_all_vars goal of
       [] => (asms,bvars,ctxt,goal)
     | varst =>
        let
         val bodyt = Term.strip_all_body goal;
         val vars = map fst varst;
         (* (I think) variant_fixes renames if required *)
         val (bvars',ctxt') = Variable.variant_fixes vars ctxt;
         val varst = ListPair.zip (bvars',map snd varst);
         val goal' = Term.subst_bounds (map Free varst,bodyt);
       in
        (asms,bvars @ bvars',ctxt',goal') 
       end;

  fun update_assm_vars ctxt0 goal = 
   let 
     val (fixes,ctxt1) = add_variable_fixes goal ctxt0     
     fun mainloop data = 
       let
         val newdata = upd_bvars data 
       in case upd_assumptions data of
          NONE => newdata
        | SOME res => mainloop res
      end
   in 
     mainloop ([],fixes,ctxt1,goal)
   end;
   
  (* doesn't really work with !! - turn it into variable *)
  fun init_goal nms ctxt0 goal = 
   let 
     val (asms,bvars,ctxt,goal') = update_assm_vars ctxt0 goal;
     val goal'' = Thm.cterm_of (Proof_Context.theory_of ctxt) goal'
     fun ins_asm a (lgns,map) = 
       let 
         val (n,map') =  StrName.NTab.add ("h",a) map
       in
         (StrName.NSet.ins_fresh n lgns,map')
       end
     val (lassms,assms) = fold ins_asm asms (StrName.NSet.empty,StrName.NTab.empty)
   in
     PNode.mk_goal (fresh_goal nms) ctxt0 ctxt (Goal.init goal'')
     |> PNode.set_assms assms
     |> PNode.set_lassms lassms
     |> PNode.set_fixes bvars
   end;

  fun gnode_of prf gnode goal = 
   let 
     val (asms,bvars,ctxt,goal') = update_assm_vars (PNode.get_ctxt gnode) goal;
     val goal'' = Thm.cterm_of (Proof_Context.theory_of ctxt) goal'
     fun ins_asm a (lgns,map) = 
       let 
         val (n,map') = StrName.NTab.add ("h",a) map
       in
         (StrName.NSet.ins_fresh n lgns,map')
       end
     val (lassms,assms) = fold ins_asm asms (StrName.NSet.empty,PNode.get_assms gnode)
   in
    PNode.mk_goal (fresh_goal (get_all_nms prf)) (PNode.get_ctxt gnode) ctxt (Goal.init goal'')
    |> PNode.set_assms assms
    |> PNode.set_lassms lassms
    |> PNode.set_goal_prev gnode
    |> PNode.set_fixes bvars
   end;

  fun init ctxt goal = 
   let val goal = init_goal StrName.NSet.empty ctxt goal 
   in (goal,init_prf |> add_root goal)
   end;

  (* create technique which inserts new nodes + updates everything *)

 fun add_open prf gnode goal =
   let 
     val gnode = gnode_of prf gnode goal
   in 
     (gnode, insert_open_nd gnode prf)
   end;   

 fun apply_prf prf0 gnode thm = 
   let 
     val newgnode = PNode.set_goal thm gnode (*  set with new thm *)
     fun app t (gs,prf) = 
       let 
         val (g,prf') = add_open prf gnode t
       in 
         (g::gs,prf') 
       end;
     val (subgoals,prf') = fold app (Thm.prems_of thm) ([],prf0);
     val new_names = fold (fn n => fn nms => (PNode.get_name n)::nms) subgoals []
     val newgnode = PNode.set_result (SOME new_names) newgnode (* add names *)
     (* must map new prev to all new nodes *)
     val prf'' = prf'
               |> remove_open_nd newgnode
               |> update_ptab_nd newgnode
   in
     (subgoals,prf'')
   end;

  (* for forward steps where facts are just added *)
  fun add_facts facts prf gnode = 
    let 
     fun ins_asm a (lgns,map) =
       let 
         val (n,map') = StrName.NTab.add ("h",a) map
       in
         (StrName.NSet.ins_fresh n lgns,map')
       end
     val (lassms,assms) = fold ins_asm facts (StrName.NSet.empty,PNode.get_assms gnode)
     val gnode' = 
         PNode.mk_goal (fresh_goal (get_all_nms prf)) (PNode.get_ctxt gnode)  (PNode.get_ctxt gnode) (PNode.get_goal gnode)
         |> PNode.set_assms assms (* not sure a new fact should be treated as a new assumption? *)
         |> PNode.set_lassms lassms (* as above *)
         |> PNode.set_goal_prev gnode
     val newgnode = gnode 
                   |> PNode.set_result (SOME [PNode.get_name gnode'])
     val prf' = prf
              |> insert_open_nd gnode'
              |> remove_open_nd newgnode
              |> update_ptab_nd newgnode
     in
       ([gnode'],prf')
     end;     

  (* application *)
  exception application_exp of string * PNode.T

  (* tactic application *)

  fun check_app (gnode,prf) = 
   if StrName.NSet.contains (get_open_nms prf) (PNode.get_name gnode)
   then true
   else raise application_exp ("goal not open",gnode);

  fun apply_tac t (gnode,prf) =
   (check_app (gnode,prf);
   (t (PNode.get_ctxt gnode) (PNode.get_goal gnode) |> Seq.map (apply_prf prf gnode)));

  fun apply_all_asm_tac t (gnode,prf) = 
   (check_app (gnode,prf);
    (PNode.get_goal gnode
    |> (((Method.insert_tac (PNode.get_all_assms gnode) 1)) THEN  (t (PNode.get_ctxt gnode)))
    |> Seq.map (apply_prf prf gnode)));

end
