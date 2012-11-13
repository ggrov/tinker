theory tac_test 
imports
  "../build/Eval"            
begin

(* add simple rtechn *)
ML{*
 val artechn = RTechn.id
            |> RTechn.set_name "assumption"
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"))
            |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
            |> RTechn.set_outputs (W.NSet.single Wire.default_wire);
val gf = LIFT (GraphEnv.graph_of_rtechn artechn);
fun add_assume_graph th = let val (g,th') = gf th in th' |> EvalTac.add_graph ("assume",g) end;
*}
setup {* add_assume_graph *}
ML{*
 val rtechn = RTechn.id
            |> RTechn.set_name "rule conjI"
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "conjI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);
val cgf = LIFT (GraphEnv.graph_of_rtechn rtechn);
fun add_conjI_graph th = let val (g,th') = cgf th in th' |> EvalTac.add_graph ("conjI",g) end;
*}

setup {* add_conjI_graph *}

ML{*
 val rtechn = RTechn.id
            |> RTechn.set_name "rule impI"
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);
val igf = LIFT (GraphEnv.graph_of_rtechn rtechn);
fun add_impI_graph th = let val (g,th') = igf th in th' |> EvalTac.add_graph ("impI",g) end;
*}
setup {* add_impI_graph *}

setup {*
 (fn th => let val (g,th') = (igf THENG cgf) th in th' |> EvalTac.add_graph ("cimp",g) end)
*}

(* ignore *)
declare [[strategy_path = "/ggrov/test"]]

declare [[strategy = "assume"]]

ML{*
    val ctxt = @{context};
    val thm = Goal.init @{cterm "A ==> A"};
     val gs_prf = mk_goal ctxt thm
     val th = Proof_Context.theory_of ctxt
     val graph = get_graph th (Config.get ctxt strategy)
     val edata0 =  RTechnEval.init_prf th gs_prf graph
*}
 
ML{*
  
  val prf = RTechnEval.EData.get_pplan edata0;
  val (SOME g) = StrName.NTab.lookup (RTechnEval.EData.get_goals edata0) "h";
  val prf1 = PPlanEnv.apply_tactic_all_asm (g,prf) (K (atac 1)) |> Seq.list_of |> hd |> snd;
  val (SOME g2) = PPlan.lookup_node prf1 "h";
  val th1 = PPExpThm.export_name prf1 "h" |> PPExpThm.prj_thm |> Goal.conclude;
  val th2 = PPExpThm.export_name prf1 "g" |> PPExpThm.prj_thm |> Goal.conclude;
  rtac th1 1 th2 |> Seq.list_of;
  th1 RS th2;
*}

(* doesn't work! -> is it the export function? *)
ML{*
RTechnEval.EData.get_pplan edata0
|> (fn t => PPExpThm.export_name t "g" |> PPExpThm.prj_thm);

val ed =     edata0
     |> RTechnEval.eval_full
     |> Seq.list_of |> hd |> RTechnEval.EData.get_pplan
*}

(* is the problem init? *)

lemma "B \<longrightarrow> A \<and> C"
 using [[strategy = "cimp"]]
   apply proof_strategy   
   oops

(* should this apply to only first subgoal or all? *)
lemma "A \<Longrightarrow> (X \<longrightarrow> B \<longrightarrow> C)"
 apply (rule impI)
 using [[strategy = "impI"]]
   apply proof_strategy   
   oops

(* alternative 2 *)
(* take first construct and try to prove that => then RS*)


(* FIXME: this isn't correct! - extra assumptions which are uncorrectly treated as assumption!
   - maybe the same for assume tac? *)

lemma dummy: "X \<Longrightarrow> Y \<Longrightarrow> X \<and> Y " sorry

lemma "X ==> Y --> X \<and> Y"
 (* give strategy name too? *)
 apply (rule impI)
 using [[strategy = "conjI"]]
   apply proof_strategy 
   done  
 oops

ML{*
val ctxt = @{context}; 
val thm = !cthm;
     val gs_prf = mk_goal ctxt thm
     val th = Proof_Context.theory_of ctxt
     val graph = get_graph th (Config.get ctxt strategy)
     val edata0 =  RTechnEval.init_prf th gs_prf graph

val prf = RTechnEval.EData.get_pplan edata0;
val (SOME gnode) =  StrName.NTab.lookup (RTechnEval.EData.get_goals edata0) "h";
val (gs,prf1) = PPlanEnv.apply_rule (gnode,prf) @{thm "conjI"} |> Seq.list_of |> hd;
 val th1 = PPExpThm.export_name prf1 "g" |> PPExpThm.prj_thm |> Goal.conclude; 
 val th1 = PPExpThm.export_name prf1 "h" |> PPExpThm.prj_thm |> Goal.conclude; 
*}

(*
lemma "A ==> A"
 (* give strategy name too? *)
 using [[strategy = "assume"]]
   apply proof_strategy 
   apply auto
 oops
*)

end;


