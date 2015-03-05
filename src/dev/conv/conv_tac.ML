  val cur_path = OS.FileSys.getDir();
  OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");
  
  use "build_psgraph.ML";
  use_file1 (cur_path ^ "/psgraph/src/dev/conv/wrk083.sml");

  fun lift_conv_tac accm_conv conv : TACTIC = 
    (fn (assms, g) => 
      let 
        val thm = accm_conv g
        val trm = PPProver.concl_of_thm thm |> PPTermLib.subtrm_of_pos [1];
      in
         pure_rewrite_tac [conv trm] (assms, g)
      end);