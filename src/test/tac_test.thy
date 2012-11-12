theory tac_test 
imports
  "../build/Eval"            
begin

(* keep table of names to strategies in context? *)

(* a lot of stuff that needs to be in place *)
ML{*
 structure Data = Theory_Data(struct 
    type T = Strategy_Theory.Graph.T StrName.NTab.T
    val empty =  StrName.NTab.empty;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 exception undefined_strat_exp of string;

 fun get_graph th name =
    case StrName.NTab.lookup (Data.get th) name of 
      NONE => raise undefined_strat_exp name
    | SOME v => v;

 val add_graph = Data.map o StrName.NTab.ins;
 val add_graph_list =  Data.map o (fold StrName.NTab.ins);

 val strategy = (Attrib.setup_config_string @{binding "strategy"} (K "unknown"));
 val strategy_path = (Attrib.setup_config_string @{binding "strategy_path"} (K ""));

 fun mk_goal ctxt thm =
  let 
    val goal = PNode.mk_goal ("g") ctxt ctxt thm;
    val prf = PPlan.init_prf |> PPlan.add_root goal 
  in
    PPlan.apply_prf prf goal thm
  end;

  val cthm = Unsynchronized.ref @{thm "allI"};

 (* should strategy be a function on theory? *)
 fun strategy_tac ctxt thm =
   let
     val gs_prf = mk_goal ctxt thm
     val th = Proof_Context.theory_of ctxt
     val graph = get_graph th (Config.get ctxt strategy)
     val edata0 =  RTechnEval.init_prf th gs_prf graph
     val _ = cthm := thm
   in
     edata0
     |> RTechnEval.eval_full
     |> Seq.map RTechnEval.EData.get_pplan
     |> Seq.map (fn t => PPExpThm.export_name t "g" |> PPExpThm.prj_thm)
  end;
 
  fun strategy_then_assm_tac ctxt =
    (strategy_tac ctxt) THEN ALLGOALS (fn n => TRY (atac n));
*}

(* adds assume tactic *)
setup {* TacticTab.add_tactic ("atac",K (K (atac 1))) *}

(* add simple rtechn *)
ML{*
 val artechn = RTechn.id
            |> RTechn.set_name "assumption"
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"))
            |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
            |> RTechn.set_outputs (W.NSet.single Wire.default_wire);
val gf = LIFT (GraphEnv.graph_of_rtechn artechn);
fun add_assume_graph th = let val (g,th') = gf th in th' |> add_graph ("assume",g) end;
*}
setup {* add_assume_graph *}
ML{*
 val rtechn = RTechn.id
            |> RTechn.set_name "rule conjI"
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "conjI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);
val cgf = LIFT (GraphEnv.graph_of_rtechn rtechn);
fun add_conjI_graph th = let val (g,th') = cgf th in th' |> add_graph ("conjI",g) end;
*}
setup {* add_conjI_graph *}

ML{*
 val rtechn = RTechn.id
            |> RTechn.set_name "rule impI"
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);
val cgf = LIFT (GraphEnv.graph_of_rtechn rtechn);
fun add_impI_graph th = let val (g,th') = cgf th in th' |> add_graph ("impI",g) end;
*}
setup {* add_impI_graph *}

(* ignore *)
declare [[strategy_path = "/ggrov/test"]]

(* FIXME: doesn't work -> need to look into how tactics works and how it currently works.. *)
method_setup proof_strategy = 
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (strategy_then_assm_tac ctxt))) *} 
  "application of active proof strategy"

(*
  to do
    - find out what the export issue is!
    - eval properly!
    - register a few graphs!

*)

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

(* should this apply to only first subgoal or all? *)
lemma "A \<Longrightarrow> (X \<longrightarrow> B \<longrightarrow> C) \<and> D"
 apply (rule conjI)
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
   apply assumption+  
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


