functor UnicodeHelperFUN (val symb_tab : (string * string) list) =
struct
(* symbols and unicodes, as a intermidiate coding to avoid parsing those non-ascii symbols in Json
  this is a translation between PSGraph and GUI *)
  val gui_uni : (string * string) list = [
     ("¬", "<_uni_symb_lnot_>"),
     ("∧", "<_uni_symb_land_>"),
     ("∨","<_uni_symb_lor_>"),
     ("⟶", "<_uni_symb_implies_>"),
     ("⇒", "<_uni_symb_implies2_>"),
     ("⟹", "<_uni_symb_metaimpies_>"),
     ("⟷", "<_uni_symb_equiv_>"),
     ("⇔", "<_uni_symb_equiv2_>"),
     ("∀", "<_uni_symb_forall_>"),
     ("∃", "<_uni_symb_exists_>"),
     ("≠", "<_uni_symb_neq_>"),
     
     ("∪", "<_uni_symb_union_>"),
     ("∩", "<_uni_symb_inter_>"),
     ("∈", "<_uni_symb_in_>"),
     ("∉", "<_uni_symb_notin_>"),
     ("⊂", "<_uni_symb_lsubset_>"),
     ("⊃", "<_uni_symb_rsubset_>"),
     ("⊆", "<_uni_symb_lsubseteq_>"),
     ("⊇", "<_uni_symb_rsubseteq_>"),
     ("⊲", "<_uni_symb_domres_>"),
     ("⊳", "<_uni_symb_ranres_>"),
   
     ("·","<_uni_symb_blackdot_>"),
     ("⟨", "<_uni_symb_l_angle_brk_>"),
     ("⟩", "<_uni_symb_r_angle_brk_λ>"),
     ("×", "<_uni_symb_cross_>"),
     ("→", "<_uni_symb_fun_>"),
     ("𝕌", "<_uni_symb_bbU_>"),
     ("Z", "<_uni_symb_bbZ_>"),
     ("ℕ", "<_uni_symb_bbN_>"),
     
     ("λ", "<_uni_symb_lambda_>"),
     ("σ", "<_uni_symb_sigma_>"),
     ("γ", "<_uni_symb_gammar_>"),
     ("η", "<_uni_symb_eta_>"),
     
     ("⋎", "<_uni_symb_down_corner_>"),
     ("⌜","<_uni_symb_left_corner_>"),
     ("⌝", "<_uni_symb_right_corner_>"),

     ("ⓩ", "<_uni_symb_left_z_corner_>"),
     ("≜", "<_uni_symb_left_z_assign_>")
    ]
  val prover_uni = symb_tab

  fun subst0 str (tab: (string*string) list) (tab0: (string*string) list) = 
   let fun substr (s,i,j) = if (i = j ) then "" else String.substring (s,i,j-i) in 
   if String.size str = 0 then ""
   else(
    if tab0 = [] 
    then String.substring (str, 0, 1) ^ 
          subst0 (substr(str, 1, String.size str)) tab tab
    else (
     if String.isPrefix (fst(hd tab0)) str 
     then snd(hd tab0) ^ subst0 (substr(str, String.size (fst(hd tab0)), String.size str)) tab tab
     else subst0 str tab (tl tab0)
    )
   )
  end
  fun subst tab str = subst0 str tab tab
  val rev_uni = map (fn (x,y) => (y,x))
  val encode_gui_json = subst gui_uni (* encode gui symbol to unicode string*)
  val decode_gui_json = subst (rev_uni gui_uni) (* decode unicode string to gui symbol *)

  val encode_prover_json = subst prover_uni (* encode prover symbol to unicode string*)
  val decode_prover_json = subst (rev_uni prover_uni) (* decode unicode string to prover symbol *)



end