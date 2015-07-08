theory json_test                                           
imports       
  "../build/BIsaP"    
begin

ML{*- 
  val path = "/u1/staff/gg112/";
  val guiPath = "/u1/staff/gg112/tinker/src/tinkerGUI/release/";
*}

ML{*
  val path = "/Users/yuhuilin/Desktop/psgraph/" ;
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx"
*}

ML{*-
  val path = "/home/pierre/Documents/HW/Tinker/tinkerGit/tinker/src/core/demo/AdvisoryBoardMeeting2015/"
  val tinker_path ="/home/pierre/Documents/HW/Tinker/tinkerGit/tinker/" 
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "linux"
*}

ML{*
  set_guiPath guiPath sys;
*}

ML{*-
  open_gui_single();
*}

ML{*-
 close_gui_single ();
*}
ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
*}


ML{*
 GT_top_symbol ["conj"] () () @{term "A \<or> B"};
*}


ML{*
val impI_thm = @{thm impI};
fun rule_tac thm _ i =  rtac thm i;
fun impI_tac  _ i  = rtac @{thm impI} i;
fun conjI_tac _ i  = rtac @{thm conjI} i
fun id_tac  _ _  = all_tac;
fun assm_tac  _ i = atac i;

(* test gty pred *)
fun test_pred _ _ _ = true
fun test_failed_pred _ _ _ = false
fun test_true1 _ _ _ = true

*}
(* read and load a psgraph created by gui *)
ML{*
  val ps = PSGraph.read_json_file (path^"demo_new.psgraph");
  PSGraph.write_json_file (path^"demo1.psgraph") ps; 
*}

ML{* 
  val edata0 = EVal.init ps @{context} [] @{prop "(B \<longrightarrow> B)  \<and> (B\<longrightarrow> A \<longrightarrow> A)"} |> hd; 
IEVal.output_string 
          "CMD_INIT_PSGRAPH" 
           (IEVal.mk_cmd_str_arg_json [
              "OPT_EVAL_STOP", "OPT_EVAL_NEXT"]) (SOME edata0);

*} 

ML{* -
  TextSocket.safe_close();
*}
ML{*-
Tinker.start_ieval @{context} ps [] @{prop "(A)  \<longrightarrow>  (A \<and>  A \<and> A)"};
*}

lemma "(A)  \<longrightarrow>  (A \<and>  A \<and> A)"
apply (tactic {* tinker_tac ps @{context} *})

