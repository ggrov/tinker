structure PPlanEnv = 
struct

  fun apply_rule thm (gnode,prf) = PPlan.apply_tac (K (rtac thm 1)) (gnode,prf)

  fun apply_frule thm (gnode,prf) = PPlan.apply_tac (K (ftac thm 1)) (gnode,prf) 

  fun apply_erule thm (gnode,prf) = PPlan.apply_tac (K (etac thm 1)) (gnode,prf)

  fun apply_tactic tac (gnode,prf) = PPlan.apply_tac (K tac) (gnode,prf) 


end (* struct *)
