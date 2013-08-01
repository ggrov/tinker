theory rippling
imports eval_defs 
begin 

ML{*
val gt = @{prop "a + b = b + a"};
val gthm = Thm.cterm_of @{theory} gt |> Thm.trivial;
 induct_tac @{context} 1 gthm |> Seq.list_of;

*}
(* setup rippling rewriting rules *)
ML{*
  BasicRipple.init_wrule_db(); 
  BasicRipple.add_wrules N_thms;
  BasicRipple.add_wrules L_thms;
*}

lemma append_assoc[simp]: "(x @ y) @ z = x @ (y @ z)"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("append_assoc", @{thm "append_assoc"}),
   ("append_assoc(sym)", Substset.mk_sym_thm @{thm "append_assoc"})];*}

lemma append_nil2 [simp]:  "l = l @ []"
(*apply psgraph*)
apply (induct l, simp_all)
done

lemma len_append: "len (x @ y) = (len x) + (len y)"
apply psgraph
done

lemma map_append: "map f (x @ y) = (map f x) @ (map f y)"
apply psgraph
done

lemma rev_append_distr[simp]: "rev (a @ b) = rev b @ rev a"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("rev_append_distr", @{thm "rev_append_distr"}), 
   ("rev_append_distr(sym)", Substset.mk_sym_thm @{thm "rev_append_distr"})];*}

lemma rev_rev [simp]:  "rev (rev x) = x"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("rev_rev", @{thm "rev_rev"}), 
   ("rev_rev(sym)", Substset.mk_sym_thm @{thm "rev_rev"})];*}






(* Peano Arithmetic Theorems *)
lemma add_0_right [simp]: "a + 0 = (a :: N)"
apply psgraph
done
 
(*apply (ipsgraph induct_ripple)*)

ML{* BasicRipple.add_wrules 
  [("add_0_right", @{thm "add_0_right"})] *}

lemma add_suc_right [simp]: "a + (suc b) = suc (a + b)"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("add_suc_right", @{thm "add_suc_right"}), 
   ("add_suc_right(sym)", Substset.mk_sym_thm @{thm "add_suc_right"})]; *}

lemma add_commute [simp]: "a + b = b + (a :: N)" 
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("add_commute", @{thm "add_commute"}), 
   ("add_commute(sym)", Substset.mk_sym_thm @{thm "add_commute"})]; *}

lemma add_assoc[simp]: "(b + c) + a = b + (c + (a :: N))"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("add_assoc", @{thm "add_assoc"}), 
   ("add_assoc(sym)", Substset.mk_sym_thm @{thm "add_assoc"})]; *}

lemma add_left_commute: "a + (b + c) = b + (a + (c :: N))" 
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("add_left_commute", @{thm "add_left_commute"}), 
   ("add_left_commute(sym)", Substset.mk_sym_thm @{thm "add_left_commute"})]; *}

lemma add_right_commute:  "(a + b) + c = (a + c) + (b :: N)"
apply psgraph
done

lemma add_right_cancel[simp]: "(m + k = n + k) = (m = (n :: N))"
apply psgraph
done

lemma add_left_cancel[simp]: "(k + m = k + n) = (m = (n :: N))"
apply psgraph
done


lemma mult_0_right [simp]: "m * 0 = 0"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("mult_0_right", @{thm "mult_0_right"})]; *}

lemma mult_suc_right: "m * (suc b) = m + (m * b)" 
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("mult_suc_right", @{thm "mult_suc_right"}), 
   ("mult_suc_right(sym)", Substset.mk_sym_thm @{thm "mult_suc_right"})]; *}

lemma mult_1_right[simp]: "n * (suc 0) = n"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("mult_1_right", @{thm "mult_1_right"}), 
   ("mult_1_right(sym)", Substset.mk_sym_thm @{thm "mult_1_right"})]; *}


lemma mult_commute[simp]:  "m * n = n * (m::N)"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("mult_commute", @{thm "mult_commute"}), 
   ("mult_commute(sym)", Substset.mk_sym_thm @{thm "mult_commute"})]; *}

lemma add_mult_distrib[simp]: "(m + n) * k = (m * k) + ((n * k)::N)"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("add_mult_distrib", @{thm "add_mult_distrib"}), 
   ("add_mult_distrib(sym)", Substset.mk_sym_thm @{thm "add_mult_distrib"})]; *}

lemma add_mult_distrib2 [simp]:  "k * (m + n) = (k * m) + ((k * n)::N)"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("add_mult_distrib2", @{thm "add_mult_distrib2"}), 
   ("add_mult_distrib2(sym)", Substset.mk_sym_thm @{thm "add_mult_distrib2"})]; *}

lemma mult_left_commute: "x * (y * z) = y * ((x * z)::N)"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("mult_left_commute", @{thm "mult_left_commute"}), 
   ("mult_left_commute(sym)", Substset.mk_sym_thm @{thm "mult_left_commute"})]; *}


lemma mult_right_commute: "(x * y) * z = (x * z) * (y::N)"
apply psgraph
done

ML{* BasicRipple.add_wrules 
  [("mult_right_commute", @{thm "mult_right_commute"}), 
   ("mult_right_commute(sym)", Substset.mk_sym_thm @{thm "mult_right_commute"})]; *}

lemma SP_add_0_0_left:  "0 + 0 + a = (a :: N)"
apply psgraph
done

lemma SP_add_0_a_right: "a + 0 + a = (a :: N) + a"
apply psgraph
done

lemma SP_add_suc_suc_right: "suc a + (suc b) = suc suc (a + b)"
apply psgraph
done

lemma SP_add_a_a_commute: "a + a + b = b + ((a :: N) + a)"
apply psgraph
done

lemma SP_mult_0_left_n_plus_m: "0 * (n + m::N)= 0"
apply psgraph
done

lemma SP_mult_0_left_m_k: "0 * (m::N) * k = 0"
apply psgraph
done

lemma SP_mult_0_right_n_plus_m: "(n + m::N) * 0 = 0"
apply psgraph
done

lemma SP_mult_suc_right_and_distr_mult : "(m * suc b) * k = m * k + (m * b) * k"
apply psgraph
done

lemmas N_lemmas = 
add_0_right add_suc_right add_commute add_assoc add_left_commute
add_right_commute add_right_cancel add_left_cancel mult_0_right mult_suc_right 
mult_1_right mult_commute add_mult_distrib add_mult_distrib2 mult_left_commute 
mult_right_commute SP_add_0_0_left SP_add_0_a_right SP_add_suc_suc_right SP_add_a_a_commute 
SP_mult_0_left_n_plus_m SP_mult_0_left_m_k SP_mult_0_right_n_plus_m SP_mult_suc_right_and_distr_mult

(* lemma proved for N*)
ML{*@{thms N_lemmas} |> length*}

end
