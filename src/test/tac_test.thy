theory tac_test 
imports
  "../build/Eval"           
begin

(* keep table of names to strategies in context? *)

(* a lot of stuff that needs to be in place *)
ML{*
 structure STab = Table(type key = string val ord = String.compare);

 structure Data = Theory_Data(struct 
    type T = Strategy_Theory.Graph.T STab.table
    val empty =  STab.empty;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 exception undefined_strat_exp of string;

 fun get_graph th name =
    case STab.lookup (Data.get th) name of 
      NONE => raise undefined_strat_exp name
    | SOME v => v;

 val strategy = (Attrib.setup_config_string @{binding "strategy"} (K "unknown"));
 val strategy_path = (Attrib.setup_config_string @{binding "strategy_path"} (K ""));

 fun mk_goal ctxt thm =
  let 
    val goal = PNode.mk_goal ("g") ctxt ctxt thm;
    val prf = PPlan.init_prf |> PPlan.add_root goal 
  in
    PPlan.apply_prf prf goal thm
  end;

 (* should strategy be a function on theory? *)
 fun strategy_tac ctxt thm =
   let
     val gs_prf = mk_goal ctxt thm
     val th = Proof_Context.theory_of ctxt
     val graph = get_graph th (Config.get ctxt strategy)
     val edata0 =  RTechnEval.init_prf th gs_prf graph
   in
     edata0
     |> RTechnEval.eval_full
     |> Seq.map RTechnEval.EData.get_pplan
     |> Seq.map (fn t => PPExpThm.export_name t "g" |> PPExpThm.prj_thm)
  end;


 (* should strategy be a function on theory? *)
 fun apply_strat ctxt thm =
   mk_goal ctxt thm
  |> snd
  |> (fn t => PPExpThm.export_name t "g")
  |> PPExpThm.prj_thm 
  |> Seq.single;

fun dummy_tac thm = 
  mk_goal @{context} thm
  |> snd
  |> (fn t => PPExpThm.export_name t "g")
  |> PPExpThm.prj_thm 
  |> Seq.single
*}


declare [[strategy_path = "/ggrov/test"]]

method_setup proof_strategy = 
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (strategy_tac ctxt))) *} 
  "application of active proof strategy"



lemma "A ==> A"
 (* give strategy name too? *)
 using [[strategy = "assume"]]
   apply proof_strategy
 oops

end;


