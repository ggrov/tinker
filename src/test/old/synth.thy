theory synth 
imports IsaP
begin

setup {* Sign.add_consts_i [(@{binding "f0"}, @{typ "nat => nat => nat"}, NoSyn)] *}

ML {*
val func_name = (Sign.full_name @{theory} (Binding.qualified_name "f0"));
Sign.the_const_type @{theory} func_name;
*}

ML {*
val all_consts = 
    (map Term.dest_Const [@{term "f0"}, @{term "Suc"}, @{term "0 ::nat"}, @{term "op ="}]);

val init_ctab = ConstInfo.ConstInfoTab.empty 
  |> ConstInfo.add_const_to_cinfo @{theory} all_consts false ("op =", Sign.the_const_type @{theory} "op =")
  |> ConstInfo.add_const_to_cinfo @{theory} all_consts false 
      (func_name, Sign.the_const_type @{theory} func_name)
  |> fold ConstInfo.add_constraints_from_eq_thms [@{thm IsaP_reflexive},  @{thm IsaP_eq_commute}]
  |> ConstInfo.add_datatype_to_cinfo @{theory} all_consts "nat";

val max_term_size = 11;
val max_vars = 3;
val init_sterm = Synthesis.init_any_sterm @{theory} init_ctab 5 3;
*}


ML {*
val ctxt = ProofContext.set_mode (ProofContext.mode_schematic) @{context};
fun read_term s = Syntax.read_term ctxt s;

val init_seq = 
    Synthesis.synthesise_upto_given_term' 
      Synthesis.is_hole_in_lhs init_ctab (read_term "f0 (Suc a) b = ?w") init_sterm;
*}

ML {*
val t = read_term "Suc (f0 (Suc a) b)";
val init_seq = 
    Synthesis.dbg_synthesise_upto_given_term
      Synthesis.is_hole_in_lhs init_ctab (t) init_sterm;
*}

ML {*
val l = Seq.list_of init_seq;
length (l);
map Synthesis.print_sterm l;
*}

end;
