  val cur_path = OS.FileSys.getDir();  
  use (cur_path ^ "/psgraph/src/core/build/proofpower/tinker.ML");

  open ListUtilities; (* this structure is from pp, and it is overrideed by psgraph*)

  use_file1 (cur_path ^ "/psgraph/src/dev/JFR/wrk083.sml");

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


(* definition of rec conv which is the trick conv to be lifed to tactic *)
i_rule_thm;
val rec rec_conv = 
(fn t =>
  ((i_conv ORELSE_C
	k_conv ORELSE_C
			(pair_conv THEN_C RAND_C(RANDS_C(TRY_C rec_conv))) ORELSE_C
			(unary_conv THEN_TRY_C RIGHT_C rec_conv) ORELSE_C
			(binary_conv THEN_C RIGHT_C (RAND_C(RANDS_C (TRY_C rec_conv)))) ORELSE_C
			(parametrized_conv THEN_C RIGHT_C (TRY_C rec_conv)))
				AND_OR_C simp_conv) t
		);


