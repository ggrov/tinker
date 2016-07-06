 open_theory "topology";  
 set_merge_pcs["basic_hol1", "'sets_alg"];
 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
 val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
 val pspath = tinker_path ^ "src/dev/JFR/psgraph/conv/";
 open ListUtilities; (* this structure is from pp, and it is overrideed by psgraph *)

 use_file (tinker_path ^ "src/dev/JFR/conv_setup.ML");

(****************************************************)
(* original proofs                                  *)
(****************************************************)
fun basic_continuity_tac (thms : THM list): TACTIC = (fn gl as (asms, _) =>
	basic_morphism_tac (continuity_params (thms @ map asm_rule asms)) [] gl
);

set_goal([], ¨µ ‘ : 'a SET SET∑
	‘ ç Topology
¥	(Ãx∑ (x, x)) ç (‘, ‘ ∏âT ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(basic_continuity_tac[]);
pop_thm()
));

(****************************************************)
(* PSGraph version                                  *)
(****************************************************)
set_goal([], ¨µ ‘ : 'a SET SET∑
	‘ ç Topology
¥	(Ãx∑ (x, x)) ç (‘, ‘ ∏âT ‘) Continuous
Æ);
a(REPEAT strip_tac);
a pre_conv_app;
a (conv_tac (LEFT_C (TRY_C Ã_unpair_conv)));
use_file (tinker_path ^ "src/dev/JFR/conv_ps_init.ML");
PPIntf.apply_ps_i ps;
(*a conversion_tac;*)
a post_conv_app;
