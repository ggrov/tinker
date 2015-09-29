structure PPProverUtils = 
struct
    
  fun thm_eqn_cxt1 (thm : THM) : TERM * CONV = (
  let	val cnv = simple_eq_match_conv thm
    val lhs = fst(dest_eq(snd(strip_µ (concl thm))));
  in
    (lhs, cnv)
  end);
  
  fun cond_rewrite_canon thm = [
    strip_´_rule (all_µ_elim thm)
  ];
  
  fun z_cond_rewrite_canon thm = [
   strip_´_rule (all_µ_elim (conv_rule z_µ_elim_conv1 thm))
  ];
  
  val cond_rewrite_conv = prim_rewrite_conv
    empty_net
    cond_rewrite_canon
    (Value thm_eqn_cxt1)
    MAP_C
    [];
   
  val z_cond_rewrite_conv = prim_rewrite_conv
    empty_net
    z_cond_rewrite_canon
    (Value thm_eqn_cxt1)
    MAP_C
    [];
    
  (*val cond_rewrite_tac = conv_tac o ONCE_MAP_C o cond_rewrite_conv;*)
  (*val z_cond_rewrite_tac = conv_tac o ONCE_MAP_C o z_cond_rewrite_conv;*)
  val z_bc_tac = bc_tac o (map (conv_rule z_µ_elim_conv1));

  fun cond_rewrite_tac thm (asml, conc) =
   let val thm2 = cond_rewrite_conv [thm] conc
   in  MAP_EVERY (fn p => (LEMMA_T p
       (fn q => MAP_EVERY asm_tac (forward_chain_rule [thm] [q]))))
       (asms thm2)
       (asml, conc)
   end;
  fun z_cond_rewrite_tac thm (asml, conc) =
   let val thm2 = z_cond_rewrite_conv [thm] conc
   in  MAP_EVERY (fn p => (LEMMA_T p
       (fn q => MAP_EVERY asm_tac (forward_chain_rule [thm] [q]))))
       (asms thm2)
       (asml, conc)
   end;
end (* end of struct *)
