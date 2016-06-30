 open_theory "topology";  
 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
 val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
 val pspath = tinker_path ^ "src/dev/JFR/psgraph/conv/";
 open ListUtilities; (* this structure is from pp, and it is overrideed by psgraph *)

use_file (tinker_path ^ "src/dev/JFR/conv_setup.ML");
(****************************************************)
val ps = PSGraph.read_json_file (SOME data) (pspath^"rec_conv.psgraph");

(* definition of the GT *)


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


fun basic_continuity_tac (thms : THM list): TACTIC = (fn gl as (asms, _) =>
	basic_morphism_tac (continuity_params (thms @ map asm_rule asms)) [] gl
);

fun continuity_params (thms : THM list) :
	{facts: THM list,
	 unary: TERM list,
	 binary: TERM list,
	 witness_tac: TACTIC,
	 parametrized: TERM list} = (
	let	val (uns, bins, pars, obs) = get_patterns ([], [], [], []) thms;
	in
		{unary = fst_const :: snd_const :: uns,
		 binary = bins,
		 parametrized = pars,
		 facts = thms @ continuity_fact_thms,
		 witness_tac = ¶_object_by_type_tac (([], product_t_const) :: obs)}
	end
);