theory json_test                                           
imports       
  "../build/BIsaP"    
begin
ML{*-
  val path = "/u1/staff/gg112/";
*}
ML{*
  val path = "/Users/yuhuilin/Desktop/" ;
*}
ML{*
fun impI_tac  _ i _ = rtac @{thm impI} i;
fun conjI_tac _ i _ = rtac @{thm conjI} i
fun id_tac  _ _ _ = all_tac;
fun assm_tac  _ i _ = atac i;

(* test gty pred *)
fun test_pred _ _ _ = true
fun test_failed_pred _ _ _ = false
*}
ML{* "top_symbol(HOL.implies)"; "top_symbol(HOL.conj)";*}
(* read and load a psgraph created by gui *)
ML{*
  val ps = PSGraph.read_json_file (path^"demo_id.psgraph");
  val ps0 = PSGraph.read_json_file (path^"demo_pred.psgraph");

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
ML{*
Tinker.start_ieval @{context} ps [] @{prop "(B \<longrightarrow> B)  \<and> (B\<longrightarrow> A \<longrightarrow> A)"};

*}


