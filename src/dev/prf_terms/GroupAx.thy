theory GroupAx
imports Main
begin

ML_val{* proofs := 2 *}

typedecl G

axiomatization
  mult :: "G => G => G" (infixl "**" 60) and
  e :: "G" and
  inv :: "G => G"
where
 ax1: "e ** a = a" and
 ax2:  "(a ** b) ** c = a **(b ** c)" and
 ax3: "inv a ** a = e" and
 ax1s: "a = e ** a" and
 ax2s: "a ** (b ** c) = (a ** b) ** c" and
 ax3s: "e = inv a ** a"


fun
  gexp :: "G => nat => G"
where
  l1: "gexp g 0 = e"
| l2: "gexp g (Suc n) = (gexp g n) ** g" 


lemma inv_rev:   "a ** inv a = e"
 proof -
  have "a ** inv a = e ** (a ** inv a)"                        by (simp only: ax1)  
  hence "a ** inv a = e ** a ** inv a"                         by (simp only: ax2)
  hence "a ** inv a = inv (inv a) ** inv a ** a ** inv a"      by (simp only: ax3)
  hence "a ** inv a = inv (inv a) ** (inv a ** a) ** inv a"    by (simp only: ax2)
  hence "a ** inv a = inv (inv a) ** e ** inv a"               by (simp only: ax3)
  hence "a ** inv a = inv (inv a) ** (e ** inv a)"             by (simp only: ax2)
  hence "a ** inv a = inv (inv a) ** inv a"                    by (simp only: ax1)
  thus  "a ** inv a = e"                                       by (simp only: ax3)
 qed
  
full_prf inv_rev 


lemma inv_rev1: "a ** inv a = e"
 
oops
 
lemma id_rev: "a ** e = a"
proof -
  have "e ** a = a"                             by (rule ax1)
  hence "(a ** inv a) ** a = a"                 by (subst inv_rev)
  hence "a ** (inv a ** a) = a"                 by (subst ax2[symmetric])
  thus ?thesis                                  by (subst ax3[symmetric])
qed

full_prf id_rev

lemma id_rev1: "a ** e = a"
  apply (subst ax3s)
  apply (subst ax2s)
  apply (subst inv_rev)
  apply (rule ax1)
done

full_prf id_rev1


lemma left_div: 
  assumes "a ** b = a ** c"
  shows "b = c"
    proof -
      have "inv a ** (a ** b) = inv a ** (a ** c)"      by (simp only: assms)        
      hence "(inv a ** a) ** b = (inv a ** a) ** c"     by (simp only: ax2)
      hence "e ** b = e ** c"                           by (simp only: ax3)
      thus ?thesis                                      by (simp only: ax1)
    qed

full_prf left_div

lemma right_div:
  assumes "b ** a = c ** a"
  shows "b = c"
    proof -
      have "(b ** a) ** inv a = (c ** a) ** inv a"      by (simp only: assms)
      hence "b ** (a ** inv a) = c ** (a ** inv a)"     by (simp only: ax2)
      hence "b ** e = c ** e"                           by (simp only: inv_rev)
      thus ?thesis                                      by (simp only: id_rev)
    qed

full_prf right_div

lemma id_comm: "e ** a = a ** e"
proof -
  have a: "e ** a = a"              by (rule ax1)
  also have b: "a ** e = a"         by (rule id_rev)
  from a b have "e ** a = a ** e"   by (subst a b)
  thus ?thesis                      by auto
qed

full_prf id_comm

lemma id_comm_alt: "e ** a = a ** e"    full_prf
  apply (subst id_rev)                  full_prf
  apply (rule ax1)                      full_prf
done

full_prf id_comm_alt

lemma inv_comm: "a ** inv a = inv a ** a"
proof -
  have a: "a ** inv a = e"                    by (rule inv_rev)
  also have b: "inv a ** a = e"               by (rule ax3)
  from a b have "a ** inv a = inv a ** a"     by (subst a b)
  thus ?thesis                                by auto
qed

full_prf inv_comm
    
lemma id_unique:
  assumes id1: "a ** f = a"
  shows "e = f"
    proof -
      have "a ** e = a"               by (rule id_rev)
      hence "a ** e = a ** f"         by (subst id1)
      thus "e = f"                    by (rule left_div)
    qed

full_prf id_unique

lemma inv_unique:
  assumes inv1: "l ** a = e"
  shows "l = inv a"
    proof - 
      have "l = l ** e"                    by (rule id_rev[symmetric])
      hence "l = l ** (inv a ** a)"        by (subst ax3)
      hence "l = l ** (a ** inv a)"        by (subst inv_comm)
      hence "l = (l ** a) ** inv a"        by (simp only: ax2)
      hence "l = e ** inv a"               by (subst inv1[symmetric])
      thus "l = inv a"                     by (subst ax1[symmetric])
    qed
      
full_prf inv_unique      
 
lemma inv_inv: "inv (inv a) = a"
proof -
  have a: "inv (inv a) ** inv a = e"                  by (rule ax3)
  also have b: "a ** inv a = e"                       by (rule inv_rev)
  from a b have "inv (inv a) ** inv a = a ** inv a"   by (subst a b) 
  thus ?thesis                                        by (rule right_div)
qed
 
full_prf inv_inv

lemma lat_sq:
  assumes "a ** x = b" 
  shows "x = inv a ** b"
    proof -
      have "inv a ** (a ** x) = inv a ** b"       by (simp only: assms)
      hence "(inv a ** a) ** x = inv a ** b"      by (simp only: ax2[symmetric])
      hence "e ** x = inv a ** b"                 by (simp only: ax3)
      thus ?thesis                                by (simp only: ax1)
    qed

full_prf lat_sq

lemma inv_id:
  shows "inv e = e"
    proof - 
      have "inv e ** e = e"                       by (rule ax3)
      thus ?thesis                                by (simp only: id_rev)
    qed

full_prf inv_id

end
