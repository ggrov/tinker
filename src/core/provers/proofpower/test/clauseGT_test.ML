  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");

 use "build_clause_GT.ML"; 


  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/";
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_64";
  
  set_guiPath guiPath sys;
  (*open_gui_single();*)

  val _ = LoggingHandler.active_all_tags ();

  fun rule_tac (arg as [PPProver.A_Str pretty]) = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);
  fun impI_tac _ = step_strip_tac;
  fun conjI_tac _ = step_strip_tac;
  fun assm_tac  _ = step_strip_tac;
  val id_tac0 = id_tac; 
  fun id_tac _ =  id_tac0;

  val data = ClauseGoalTyp.add_atomic "top_symbol" top_symbol ClauseGoalTyp.default_data; 
  val scan_def = ClauseGoalTyp.scan_data PPProver.default_ctxt;
  val def1 = "topconcl(Z) :- top_symbol(concl,Z).";
  val pdef1 = scan_def def1;
  val data = ClauseGoalTyp.update_data_defs (K pdef1) data;
   
(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file (path^"clause_demo.psgraph")|> PSGraph.set_goaltype_data data; 

  PPIntf.set_psg_goal (SOME ([], ¬A´A´A®)) (SOME ps);

  TextSocket.safe_close();



  val (pnode,pplan) = PPProver.init PPProver.default_ctxt [] ¬A´A´A®;                         
ClauseGoalTyp.match data pnode (ClauseGoalTyp.scan_goaltyp  PPProver.default_ctxt "any") (PPProver.get_pnode_env pnode);

ClauseGoalTyp.match data pnode (ClauseGoalTyp.scan_goaltyp  PPProver.default_ctxt "top_symbol(concl,implies)") (PPProver.get_pnode_env pnode);

ClauseGoalTyp.project_terms (PPProver.get_pnode_env pnode) pnode ClauseGoalTyp.Concl |> maps top_level_str';


top_symbol(IsaProver.get_pnode_env pnode) pnode [C.Var "X", C.Name "implies"];
"top_symbol(concl,implies)";
 "top_symbol(X,Implies)";


PPProver.pretty_trm ([],"") 
ttt ¬A´A´A®;

[("%and%", "&"),("%implies%", "==>")];


StrName.NTab.lookup (symbol_table) (String.str (#"%and%"));

fun ttt trm = String.concat (PrettyPrinter.format_term true trm) |> String.translate decode_str|> Pretty.str;

val s = String.concat (PrettyPrinter.format_term true ¬A´A´A®);

decode_str (#"%and%");