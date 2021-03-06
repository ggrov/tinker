  open_theory "hol";
  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");


  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_64";
  
  set_guiPath guiPath sys;
  open_gui_single();

  val _ = LoggingHandler.active_all_tags ();
  val _ = LoggingHandler.clear_active_tags();
  val _ = map LoggingHandler.ins_active_tag ["ENV_DATA"];
  val _ = LoggingHandler.print_active();

val _ = push_pc"basic_hol1";
simple_eq_match_conv thm_no;
simple_ho_eq_match_conv;
simple_eq_match_conv thm  �(�x� 1 + x + ((�x %=>% x + 1) 2)) 3�;

set_goal([], �  (�x�f (t x)) = f o t �);
a(rewrite_tac[o_def]);
val thm_no = pop_thm();
drop_main_goal();

val g : GOAL = ([�(�x� 1 + x) 3 > 5�], �(�m n� (m > n)) ((�x� 1 + x) 3)  5�);
val thm = �_conv  �(�x� 1 + x + y) 3�;

set_goal g; 
a (conv_tac (LEFT_C �_conv));
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
a (lift_conv_as_tac �_conv  �(�x� 1 + x) 3�);
drop_main_goal ();

set_goal g;
a (apply_conv_to_goal_tac �_conv);
drop_main_goal ();


(* examples *)
mk_current_thm;
conv_rule;
conv_tac;
mk_eq;
refl_conv  �(�x� 1 + x) 3�;
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
val simple_�_conv : CONV = (
	fn tm =>
	let	val res = pp'simple_�_conv tm;
	in	prof "simple_�_conv";
		ki_notify(KISimple�Conv(tm, res));
		res
	end
);