theory au_test                                                 
imports         
  Main        
  "../../build/PPlan"                                                                    
  "../../build/HOL_IsaP" (* needed for induction stuff *)
  MemMchR32
uses
  "../features/term_fo_au.ML"  
  "../features/term_features.ML"                                                                                                                                           
begin

(* the goal *)
term "\<not> F (EB_Log0.beq op1Data\<up> (EB_Rel.bfunimg regArray\<up> op1Index\<up>))"

thm hyp_6[unlifted]

lemmas l1 = hyp_19[unlifted]
lemmas l2 = hyp_20[unlifted]

ML{*
Thm.concl_of @{thm l1};
Thm.concl_of @{thm l2};
val t1 = FirstOrderAU.generalise (Thm.concl_of @{thm l1},Thm.concl_of @{thm l2}) |> Logic.varify_global;
val t2 = FirstOrderAU.generalise (Thm.concl_of @{thm hyp_19},Thm.concl_of @{thm hyp_20});

Pretty.writeln (Syntax.pretty_term @{context} (Thm.concl_of @{thm l1}));
Pretty.writeln (Syntax.pretty_term @{context} t1);
*}




(* generalise type *)
ML{*

*}

(* generalise sort if different *) 
ML{*

*}

(* generalise type *)
ML{*

*}

ML{*
val t1 = @{term "t1::nat"};
val t2 = @{term "t2::nat"};
val t2b = @{term "t2"};
val t3 = @{term "0::nat"};


FirstOrderAU.generalise (@{term "t1::nat"}, @{term "t2::nat"})
*}

end



