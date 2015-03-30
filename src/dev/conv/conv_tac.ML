  val cur_path = OS.FileSys.getDir();
  OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");
  
  use "build_psgraph.ML";
  use_file1 (cur_path ^ "/psgraph/src/dev/conv/wrk083.sml");

  fun lift_conv_tac (conv : CONV) (conv_args : CONV) TACTIC = 
    (fn (assms, g) => 
      let 
        val thm = conv_args g
        val trm = PPProver.concl_of_thm thm |> PPTermLib.subtrm_of_pos [1];
      in
        pure_rewrite_tac [conv trm] (assms, g)
      end);
      
  fun gen_pre_post_conv (conv : CONV) conv_args = 
   let 
    val thm = PPProver.concl_of_thm (conv trm)
   in
    PPTermLib.strip_comb thm  (* pred, post *)
   end;
   
   val gen_pre_conv = snd o gen_pre_post_conv;
   val gen_post_conv = fst o gen_pre_post_conv;