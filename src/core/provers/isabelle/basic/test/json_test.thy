theory json_test                                           
imports       
  "../build/BIsaP"   
begin

ML{*



val env = StrName.NTab.of_list [("x", E_Str "is E_Str"), ("y", E_Trm @{term "a + b"}), ("thm", E_Thm @{thm impI}),
("ml", E_ML "ml code"), ("el",  E_L [E_Str "is E_Str",  E_Trm @{term "a + b"}])]; 

pretty_env @{context} env |> Pretty.writeln ;
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_L of env_data list
*}
ML{*- 
  val path = "/u1/staff/gg112/";
  val guiPath = "/u1/staff/gg112/tinker/src/tinkerGUI/release/";
*}

ML{*
  val path = "/Users/yuhuilin/Desktop/psgraph/" ;
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_32"
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

ML{*  
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
val conjI_thm = @{thm conjI};
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
  val ps = PSGraph.read_json_file (path^"demo_env.psgraph");
  PSGraph.write_json_file (path^"demo1.psgraph") ps; 
*}

ML{* 
  val edata0 = EVal.init ps @{context} [] @{prop "(B \<longrightarrow> B)  \<and> (B\<longrightarrow> A \<longrightarrow> A)"} |> hd; 
IEVal.output_string 
          "CMD_INIT_PSGRAPH" 
           (IEVal.mk_cmd_str_arg_json [
              "OPT_EVAL_STOP", "OPT_EVAL_NEXT"]) (SOME edata0);

*} 

ML{*-
  TextSocket.safe_close();
*}
ML{*-
Tinker.start_ieval @{context} ps [] @{prop "(A)  \<longrightarrow>  ((B \<longrightarrow>A) \<and>  (B \<longrightarrow>A) \<and> (B \<longrightarrow>A))"};
*}


