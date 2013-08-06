theory rippling
imports L 
begin 

section " Peano Arithmetic Theorems "

lemma add_0_right [simp, wrule]: "a + 0 = (a :: N)"
apply (induct a, auto)
done

lemma add_suc_right [simp, wrule]: "a + (suc b) = suc (a + b)"
apply psgraph
done

lemma add_commute[simp, wrule]: "a + b = b + (a :: N)" 
apply psgraph
done

lemma add_assoc[simp, wrule]: "(b + c) + a = b + (c + (a :: N))"
apply psgraph
done


lemma add_left_commute [simp, wrule]: "a + (b + c) = b + (a + (c :: N))" 
apply psgraph
done

lemma add_right_commute [simp, wrule]:  "(a + b) + c = (a + c) + (b :: N)"
apply psgraph
done

lemma add_right_cancel[simp, wrule]: "(m + k = n + k) = (m = (n :: N))"
apply psgraph
done

lemma add_left_cancel[simp, wrule]: "(k + m = k + n) = (m = (n :: N))"
apply psgraph
done


lemma mult_0_right [simp,wrule]: "m * 0 = 0"
apply psgraph
done

lemma mult_suc_right[simp, wrule]: "m * (suc b) = m + (m * b)" 
apply psgraph
done


lemma mult_1_right[simp, wrule]: "n * (suc 0) = n"
apply psgraph
done

lemma mult_commute[simp, wrule]:  "m * n = n * (m::N)"
apply psgraph
done

lemma add_mult_distrib[simp, wrule]: "(m + n) * k = (m * k) + ((n * k)::N)"
apply psgraph
done

lemma add_mult_distrib2 [simp, wrule]:  "k * (m + n) = (k * m) + ((k * n)::N)"
apply psgraph
done

lemma mult_left_commute[simp, wrule]: "x * (y * z) = y * ((x * z)::N)"
apply psgraph
done

lemma mult_right_commute [simp, wrule]: "(x * y) * z = (x * z) * (y::N)"
apply psgraph
done

lemma power_squared[simp]: "x ^ (suc (suc 0)) = x * x"
apply psgraph
done

lemma power_1[simp]: "x ^ (suc 0) = x"
apply psgraph
done

lemma power_add [simp]:  "i ^ (j + k) = i ^ j * i ^ (k ::N)"
apply psgraph
done

lemmas N_lemmas = 
add_0_right add_suc_right add_commute add_assoc add_left_commute
add_right_commute add_right_cancel add_left_cancel mult_0_right mult_suc_right 
mult_1_right mult_commute add_mult_distrib add_mult_distrib2 mult_left_commute 
mult_right_commute power_squared  power_1 power_add power_mult

(* lemma proved for N*)
ML{*@{thms N_lemmas} |> length*}

section "theory list"


lemma append_assoc[simp, wrule]:  "(x @ y) @ z = x @ (y @ z)"
apply psgraph
done

lemma append_nil2 [simp, wrule]: "l = l @ []"
apply psgraph
done

lemma len_append[simp, wrule]: "len (x @ y) = (len x) + (len y)"
apply psgraph
done

lemma rev_append_distr[simp,wrule]: "rev (a @ (b:: 'a List)) = rev b @ rev a"
apply psgraph
done 

lemma rev_rev [simp]: "rev (rev x) = x"
apply psgraph
done

lemma qrev_append [simp,wrule]: "qrev x xs @ ys = qrev x (xs @ ys)"
apply psgraph
done

lemma rev_qrev_gen:  "(qrev x y)= (rev x) @ y"
apply psgraph
done

lemma rev_qrev[simp]: "rev x = qrev x []"
apply psgraph
done

lemma len_add_suc [simp, wrule]: " len x + suc 0 = suc len x"
apply psgraph
done

lemma len_rev[simp, wrule]:  "len (rev x) = len x"
apply psgraph
done

lemma append_self_conv : "(xs @ ys = xs) = (ys = [])"
apply psgraph
done

lemma same_append_eq : "(xs @ ys = xs @ zs) = (ys = zs)"
apply psgraph
done

lemma rot_append [simp, wrule]:  "rot (len l, l @ k) = k @ l"
apply psgraph
done

lemma rot_len: "rot (len l, l) = l"
apply psgraph
done

lemmas L_lemmas = 
append_assoc append_nil2 len_append rev_append_distr append_self_conv same_append_eq 
rev_rev  qrev_append rev_qrev len_rev rev_qrev_gen len_add_suc len_rev rot_append rot_len 

ML{*@{thms L_lemmas} |> length*}

end
