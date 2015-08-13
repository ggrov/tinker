(* an simple example for conv tac *)
fun thm_conv thm = 
  (fn trm =>
   pure_once_rewrite_conv [thm] trm);

val land_comm_thm =  (
  push_goal ([],¬µ x y · (x ± y) = (y ± x)®);
  a (prove_tac []); 
  pop_thm ()
);
val land_comm_conv = thm_conv land_comm_thm;

val land_F_abs_thm = (
  push_goal ([],¬µ x · (F ± x) = F®);
  a (prove_tac []); 
  pop_thm ()
);

val land_F_abs_conv = thm_conv land_F_abs_thm;

val rec demo_rec_conv = (fn trm => ((land_comm_conv THEN_C ((LEFT_C demo_rec_conv) ORELSE_C id_conv) THEN_C land_F_abs_conv) trm));

set_goal ([],¬ c ± (b ± (a ± F))®);
a (conv_tac  demo_rec_conv);
drop_main_goal();


  val cur_path = OS.FileSys.getDir();  
  use (cur_path ^ "/psgraph/src/build/proofpower/tinker.ML");

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
