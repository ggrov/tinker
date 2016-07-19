theory heap_example
imports Rippling "heap/HEAP1"
begin  

ML{*         
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/rippling/"
  val ps_file = "heap_rippling.psgraph";

  val clause_def = "";
  val data =  data  
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);

  val rippling = PSGraph.read_json_file (SOME data) (pspath ^ ps_file);
*}

setup {* PSGraphIsarMethod.add_graph ("rippling",rippling) *}



thm F1_inv_def
thm Disjoint_def
thm sep_def
thm nat1_map_def

declare  VDMMaps.l_dom_dom_ar [wrule]
lemma finite_Diff[wrule]: "finite A \<Longrightarrow> finite (A - B) = finite A"
by (metis finite_Diff)

(* the first simple rippling example in the book *)
lemma "finite (dom(f)) \<and> the (f(r)) \<noteq> s \<and> nat1 s \<and> r \<in> dom(f) \<and> s \<le> the(f(r)) \<Longrightarrow> finite(dom({r} -\<triangleleft> f))"
apply (elim conjE)+ 
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME rippling) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
apply (tinker rippling)
done


ML{*
   val t = @{prop "finite (dom(f)) \<and> the (f(r)) \<noteq> s \<and> nat1 s \<and> r \<in> dom(f) \<and> s \<le> the(f(r)) \<Longrightarrow> finite(dom({r} -\<triangleleft> f))"}; 
   val (pnode,pplan) = IsaProver.init @{context} [] t;
*}
ML{*
val e = EVal.init rippling @{context} [] t |> hd;
val (IEVal.Cont e0) = IEVal.eval_any e;
val (IEVal.Cont e1) = IEVal.eval_any e0;
*}

ML{*
val pp = EData.get_pplan e1;
val p1 = IsaProver.get_open_pnode_by_name pp "a";
val env = Prover.get_pnode_env p1;
;

val p2 = IsaProver.set_pnode_env (ENV_bind env [IsaProver.A_Trm (IsaProver.get_pnode_concl p1), IsaProver.A_Var "g"] env |> hd)
p1 ;
*}
ML{*
Clause_GT.type_check data p2 (Clause_GT.scan_goaltyp @{context} "has_wrule(?g)");
*}

ML{*
  Prover.pretty_pnode pnode |> Pretty.writeln;
   Clause_GT.type_check data pnode (Clause_GT.scan_goaltyp @{context} "hyp_embeds()")
*}

ML{*-
val g = @{prop "finite (dom(f)) \<and> the (f(r)) \<noteq> s \<and> nat1 s \<and> r \<in> dom(f) \<and> s \<le> the(f(r)) \<Longrightarrow> finite(dom({r} -\<triangleleft> f))"};
val thm = Tinker.start_ieval @{context} (SOME rippling) (SOME []) (SOME g) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
ML{*-
TextSocket.safe_close();
*}

(* The PO of new fsb *)
context level1_new
begin
theorem locale1_new_FSB: "PO_new1_feasibility"
unfolding PO_new1_feasibility_def new1_postcondition_def
oops

end
end
