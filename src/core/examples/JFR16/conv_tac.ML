 open_theory "topology";  
 set_merge_pcs["basic_hol1", "'sets_alg"];
 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
 val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
 val pspath = tinker_path ^ "src/core/examples/JFR16/psgraph/conv/";
 open ListUtilities; (* this structure is from pp, and it is overrideed by psgraph *)

 use_file (tinker_path ^ "src/core/examples/JFR16/conv_setup.ML");

(****************************************************)
(* original proofs                                  *)
(****************************************************)
fun basic_continuity_tac (thms : THM list): TACTIC = (fn gl as (asms, _) =>
	basic_morphism_tac (continuity_params (thms @ map asm_rule asms)) [] gl
);

set_goal([], �� � : 'a SET SET�
	� � Topology
�	(�x� (x, x)) � (�, � ��T �) Continuous
�);
a(REPEAT strip_tac);
a(basic_continuity_tac[]);
pop_thm()
));

(****************************************************)
(* PSGraph version                                  *)
(****************************************************)
set_goal([], �� � : 'a SET SET�
	� � Topology
�	(�x� (x, x)) � (�, � ��T �) Continuous
�);
a(REPEAT strip_tac);
use_file (tinker_path ^ "src/core/examples/JFR16/conv_ps_init.ML");
a pre_conv_app;
a (conv_tac (LEFT_C (TRY_C �_unpair_conv)));
PPIntf.apply_ps_i ps;
(*a conversion_tac;*)
a post_conv_app;