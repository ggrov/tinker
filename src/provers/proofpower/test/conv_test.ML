open_theory "combin";
val _ = push_pc"basic_hol1";
simple_eq_match_conv thm_no;
simple_ho_eq_match_conv;
simple_eq_match_conv thm  ¬(Ìx· 1 + x + ((Ìx %=>% x + 1) 2)) 3®;

set_goal([], ¬  (Ìx·f (t x)) = f o t ®);
a(rewrite_tac[o_def]);
val thm_no = pop_thm();
drop_main_goal();

val g : GOAL = ([¬(Ìx· 1 + x) 3 > 5®], ¬(Ìm n· (m > n)) ((Ìx· 1 + x) 3)  5®);
val thm = Â_conv  ¬(Ìx· 1 + x + y) 3®;

set_goal g; 
a (conv_tac (LEFT_C Â_conv));
pure_rewrite_tac [thm];


fun gen_pre_post_conv (conv : CONV) trm = 
 let 
  val thm = PPProver.concl_of_thm (conv trm)
 in
  PPTermLib.strip_comb thm |> snd (* pred, post *)
 end;
(* should combined with has symbol *)

fun lift_conv_as_tac conv (trm : TERM) = pure_rewrite_tac [conv trm];
fun apply_conv_to_goal_tac conv (goal : GOAL) = 
  pure_rewrite_tac [conv (snd goal)] goal; 
conv_tac;

set_goal g;
a (lift_conv_as_tac Â_conv  ¬(Ìx· 1 + x) 3®);
drop_main_goal ();

set_goal g;
a (apply_conv_to_goal_tac Â_conv);
drop_main_goal ();


(* examples *)
mk_current_thm;
conv_rule;
conv_tac;
mk_eq;
refl_conv  ¬(Ìx· 1 + x) 3®;
open pp'Kernel;
pp'refl_conv;
val refl_conv : CONV = (
	fn tm =>
	let	val res = pp'refl_conv tm;
	in	prof "refl_conv";
		ki_notify(KIReflConv(tm, res));
		res
	end
);
val simple_Â_conv : CONV = (
	fn tm =>
	let	val res = pp'simple_Â_conv tm;
	in	prof "simple_Â_conv";
		ki_notify(KISimpleÂConv(tm, res));
		res
	end
);