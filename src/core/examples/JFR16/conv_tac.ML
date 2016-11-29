 val tinkerhome = OS.FileSys.getDir() ^ "/psgraph";
 open_theory "topology";  
 set_merge_pcs["basic_hol1", "'sets_alg"];
 use (tinkerhome ^ "/src/core/build/proofpower/tinker");
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

set_goal([], ¬µ Ô : 'a SET SET·
	Ô  Topology
´	(Ìx· (x, x))  (Ô, Ô ¸‰T Ô) Continuous
®);
a(REPEAT strip_tac);
a(basic_continuity_tac[]);
pop_thm()
));


(****************************************************)
(* PSGraph version                                  *)
(****************************************************)
set_goal([], ¬µ Ô : 'a SET SET·
	Ô  Topology
´	(Ìx· (x, x))  (Ô, Ô ¸‰T Ô) Continuous
®);
a(REPEAT strip_tac);
use_file (tinker_path ^ "src/core/examples/JFR16/conv_ps_init.ML");
a pre_conv_app;
a (conv_tac (LEFT_C (TRY_C Ì_unpair_conv)));
PPIntf.apply_ps ps;
(*a conversion_tac;*)
a post_conv_app;

=====
val i_conv
i_rule_thm;
k_rule_thm;

pattern_match

 fun bool_to_cl env ret = if ret then [env] else []

 fun pattern_match env pnode [p,t] = 
  let
   val ctxt = PPProver.get_pnode_ctxt pnode
  in
   (case Clause_GT.project_terms env pnode p of
    [pat] =>
      (case Clause_GT.project_terms env pnode t of
       [trm] => 
         Pattern.matches thy (pat,ignore_true_prop trm)
        |> bool_to_cl env
       | _ => [])
    | _ => [])
  end
 | pattern_match _ _ _ = LH.log_undefined "GOALTYPE" "match" [];


¬(Ì x· (x, x))  (Ô, Ô ¸‰T Ô) Continuous® |> dest_app
|> fst |> dest_app;

¬Pair ((Ì x· x), (Ì x· x))
            (Ô, Ô ¸‰T Ô) Continuous®

i_rule_thm;
k_rule_thm;
pair_rule_thm;
unary_thms;