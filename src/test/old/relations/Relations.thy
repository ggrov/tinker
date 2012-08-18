(*
  AUTHOR:   Dominic Mulligan
  DATE:     Wednesday 8th August
  FILENAME: Relations.thy
  PURPOSE:  Formalising several purely relational theorems for testing
            relational rippling heuristic.
*)
theory Relations imports Main IsaP begin

  inductive
    map :: "('a \<Rightarrow> 'b) \<Rightarrow> ('a list) \<Rightarrow> ('b list) \<Rightarrow> bool" where
      base: "map f [] []"
    | step: "map f t r \<Longrightarrow> map f (h#t) ((f h)#r)"
  inductive
    length :: "'a list \<Rightarrow> nat \<Rightarrow> bool" where
      base: "length [] 0"
    | step: "length t n \<Longrightarrow> length (h#t) (Suc n)"

  lemma map_base_thm:
    shows "!!l. ((map f [h] ((f h)#l)) \<longrightarrow> (l=[]))"
    apply(rule impI)
    proof -
      fix l
      assume a: "map f [h] ((f h)#l)"
      show "l=[]"
      apply(rule map.cases[OF a])
      apply auto
 oops
      

  lemma map_forward_imp_thm[rule_format]:
    shows"\<And>l. (map f (h#t) ((f h)#l) \<longrightarrow> map f t l)"
    apply(induct t)
    proof safe
      fix l
      assume A: "map f [h] ((f h)#l)"
      show "map f [] l"
	proof -
	oops

  theorem length_pres_map_thm:
    assumes a: "length l n"
    shows "\<exists>l'. map f l l' \<and> length l' n"
    apply(rule length.induct[OF a])
    apply(rule exI)
    apply(rule conjI)
    apply(rule map.base)
    apply(rule length.base)
    proof -
      fix t::"'b list"
      fix n h
      assume IH1: "length t n"
      assume IH2: "\<exists>l'. (map f t l') \<and> (length l' n)"
      show "\<exists>l'. map f (h#t) l' \<and> length l' (Suc n)"
	proof
	  from IH2 obtain l' where ihasm1: "map f t l'" and ihasm2: "length l' n" by blast
	  from ihasm1 have a: "map f (h#t) ((f h)#l')" by (rule map.step)
	  from this and ihasm2 have "length ((f h)#l') (Suc n)"
	    apply(subst length.step)
	    apply assumption
	     by (rule TrueI)
	  from this and a have "map f (h#t) ((f h)#l') \<and> length ((f h)#l') (Suc n)" by blast
	  from this have "\<exists>l'. map f (h#t) l' \<and> length l' (Suc n)" by blast
    oops

  (* 
    The following is the formalisation of a small programming language
    and a pair of compilers for it.  We also provide an evaluation
    function, as well as a semantic function.
  *)

  datatype program_op     = push "nat" | add

  datatype program_exp    = exp_const "nat"
                          | exp_plus "program_exp" "program_exp" (infixr ".+." 65)

  types 
    stack                 = "nat list"
    program               = "program_op list"

  consts
    compile1  :: "program_exp \<Rightarrow> program"
    compile2h :: "program_exp \<Rightarrow> (program * program)"
    semantic  :: "program_exp \<Rightarrow> nat"

  primrec
    "semantic (exp_const c)  = c"
    "semantic (a .+. b)      = (semantic a) + (semantic b)"
  primrec
    "compile1 (exp_const c)  = [push c]"
    "compile1 (a .+. b)      = (compile1 a) @ (compile1 b) @ [add]"
  primrec
    "compile2h (exp_const c) = ([push c], [])"
    "compile2h (a .+. b)     = ((fst (compile2h a)) @ (fst (compile2h b)),
                                add#((snd (compile2h a)) @ (snd (compile2h b))))"

  fun
    compile2 :: "program_exp \<Rightarrow> program" where
      "compile2 exp = ((fst (compile2h exp)) @ (snd (compile2h exp)))"

  inductive
    eval1 :: "program_op \<Rightarrow> stack \<Rightarrow> stack \<Rightarrow> bool" where
      push: "eval1 (push c) stack (c#stack)"
    | add:  "eval1 add (h1#h2#stack) ((h1+h2)#stack)"
  inductive
    eval  :: "program \<Rightarrow> stack \<Rightarrow> stack \<Rightarrow> bool" where
      none: "eval [] stack stack"
    | step: "\<lbrakk> eval1 oper stack1 stack2 ; eval p stack2 stack3 \<rbrakk> \<Longrightarrow> eval (oper#p) stack1 stack3"

  theorem compile1_thm:
    shows "eval (compile1 exp) stack ((semantic exp)#stack)"
    apply(rule program_exp.induct)
    apply(subst compile1.simps(1))
    apply(subst semantic.simps(1))
    apply(rule eval.step)
    apply(rule eval1.push)
    apply(rule eval.none)
    proof -
      fix program_exp1 program_exp2
      assume IH1: "eval (compile1 program_exp1) stack (semantic program_exp1 # stack)"
      assume IH2: "eval (compile1 program_exp2) stack (semantic program_exp2 # stack)"
      show "eval (compile1 (program_exp1 .+. program_exp2)) stack (semantic (program_exp1 .+. program_exp2)#stack)"
	proof -
    oops
    

  theorem compile2_thm: "eval (compile2 exp) stack ((semantic exp)#stack)"
    sorry


  (*
    The following is *a* formalisation of the reflexive transitive closure,
    and a proof that the definition corresponds to the more familiar one.
    Based on the formalisation in the Isabelle/HOL tutorial, page 132.
  *)

  inductive
    rtc1 :: "'a \<Rightarrow> 'a \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool" ("_ _ \<in> _*" [1000, 1000] 999) where
      reflex: "x x \<in> r*"
    | step: "\<lbrakk> r x y ; y z \<in>  r* \<rbrakk> \<Longrightarrow> x z \<in> r*"

  inductive
    rtc2 :: "'a \<Rightarrow> 'a \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool" ("_ _ \<in> _**" [1000, 1000] 999) where
      base: "r x y \<Longrightarrow> x y \<in> r**"
    | reflex: "x x \<in> r**"
    | step: "\<lbrakk> x y \<in> r** ; y z \<in> r** \<rbrakk> \<Longrightarrow> x z \<in> r**"

  lemma rtc1_trans:
    assumes a: "x y \<in> r*"
    assumes b: "y z \<in> r*"
    shows "x z \<in> r*"
    using a b
      proof (induct)
        case reflex thus ?case by assumption
	case step thus ?case
	  apply(subst rtc1.step)
	  apply(assumption)
	  apply(assumption)
	   by (rule TrueI)
      qed

  lemma rtc1_step_thm:
    assumes assm: "r x y"
    shows "x y \<in> r*"
    using assm
    proof -
      show "x y \<in> r*"
        apply(rule rtc1.step)
        apply(rule assm)
         by (rule rtc1.reflex)
    qed

  lemma rtc1_imp_thm:
    assumes assm: "x y \<in> r*"
    shows "x y \<in> r**"
    using assm
      proof(induct rule: rtc1.induct)
        fix x r
        show "x x \<in> r**" by (rule rtc2.reflex)
      next
        fix r
        fix x y z::'a
        assume IH1: "r x y"
        assume IH2: "y z \<in> r*"
        assume IH3: "y z \<in> r**"
        show "x z \<in> r**"
          proof -
          from IH1 have "x y \<in> r**" by (rule rtc2.base)
          thus "x z \<in> r**" by (rule rtc2.step)
      qed
    qed

  lemma rtc1_imp_thm2: 
    assumes a: "x y \<in> r*" 
    shows "x y \<in> r**"
    using a
    apply (rule rtc1.induct)
  proof -
    fix x r
    show "x x \<in> r**"
       by (rule rtc2.reflex)
  next
    fix r 
    fix x y z :: 'a
    assume IH1: "r x y"
    assume IH2: "y z \<in> r*"
    assume IH3: "y z \<in> r**"
    show "x z \<in> r**"
      apply(rule rtc2.step)
      proof - 
        show "x y \<in> r**"
          apply(rule rtc2.step)
            proof -
              show "x y \<in> r**"
                by (rule rtc2.base)
            next
              show "y y \<in> r**"
                by (rule rtc2.reflex)
            qed
     next
        show "y z \<in> r**"
          by assumption
      qed
  qed

  lemma rtc2_imp_thm:
    assumes assm: "x y \<in> r**"
    shows "x y \<in> r*"
    using assm
    apply(rule rtc2.induct)
    proof -
      fix r 
      fix x y::'a
      assume IH1: "r x y"
      show "x y \<in> r*"
        apply(rule rtc1.step)
        apply(assumption)
         by(rule rtc1.reflex)
    next
      fix x r
      show "x x \<in> r*" by (rule rtc1.reflex)
    next
      fix r
      fix x y z::'a
      assume IH1: "x y \<in> r*"
      assume IH2: "y z \<in> r*"
      show "x z \<in> r*"
        apply(rule rtc1_trans)
        apply(rule IH1)
         by (rule IH2)
    qed

  theorem rtc_thm: "x y \<in> r* = x y \<in> r**"
    by (auto simp only: rtc2_imp_thm rtc1_imp_thm)

  (* 
     Formalisation of Confluence, taken from the paper "Relational Rippling:
     A General Approach".  They call it Church-Rosser.
  *)
 
(*  
  inductive 
    rtc3 :: "nat \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool" 
                        ("_ _ _ \<in>  _***" [1000, 1000] 999) where
      reflex: "0 x x \<in> r***" 
    | step:  "(n x y \<in> r*** \<Longrightarrow> EX v. (r x v) \<and> (Suc n) v y \<in> r ***"
*)

  inductive
    rtc3 :: "nat \<Rightarrow> 'a \<Rightarrow> 'a \<Rightarrow> ('a \<Rightarrow> 'a \<Rightarrow> bool) \<Rightarrow> bool" ("_ _ _ \<in>  _***" [1000, 1000] 999) where
      reflex: "0 x x \<in> r***"
    | step:  "\<lbrakk> n x y \<in> r*** ; (r v x) \<rbrakk> \<Longrightarrow> (Suc n) v y \<in> r***"

  lemma confluence_base_equal_thm[fwd_impwrule, rule_format]:
    assumes a: "0 x y \<in> r***"
    shows "x=y"
    apply(rule rtc3.cases[OF a])
    proof -
      fix xa ra
      assume a: "0=0"
      assume b: "x=xa"
      assume c: "y=xa"
      assume d: "r=ra"
      show "x=y"
	proof -
	  from c have "xa=y" by (rule sym)
	  from b and c have "x=y" by auto
	  thus ?thesis by assumption
	qed
    next
      fix n xa ya ra v
      assume a: "0 = Suc n"
      assume b: "x=v"
      assume c: "y=ya"
      assume d: "r=ra"
      assume e: "n xa ya \<in> ra***"
      assume f: "ra v xa"
      show "x=y"
	proof -
	  have "Suc n=0" by (rule sym)
	  from this have "x=y" by (rule Suc_neq_Zero)
	  thus ?thesis by assumption
	qed
    qed

  lemma confluence_single_ident_thm:
    assumes a: "0 a b \<in> r***"
    assumes b: "0 a c \<in> r***"
    shows "b=c"
    proof -
      from a have "a=b" by (rule confluence_base_equal_thm)
      from this have x: "b=a" by (rule sym)
      from b have y: "a=c" by (rule confluence_base_equal_thm)
      thus "b=c"
        apply (subst trans [OF x y])
         by (rule refl)
    qed

  lemma confluence_single_forward_imp:
    assumes a: "(Suc n) x y \<in> r***"
    shows "\<exists>v. r x v \<and> n v y \<in> r***"
    apply(rule rtc3.cases[OF a])
    apply(rule Suc_neq_Zero)
    apply(assumption)
    proof -
      fix na xa ya ra v
      assume a: "Suc n = Suc na"
      assume b: "x=v"
      assume c: "y=ya"
      assume d: "r=ra"
      assume e: "na xa ya \<in> ra***"
      assume f: "ra v xa"
      show "\<exists>v. r x v \<and> n v y \<in> r***"
	proof -
	  from a have g: "n=na" by (subst Suc_Suc_eq[symmetric], assumption)
	  from b have h: "v=x" by (rule sym)
	  from d have i: "ra=r" by (rule sym)
	  from c have j: "ya=y" by (rule sym)
	  from g and i and j and e have k: "n xa y \<in> r***" by auto
	  from f and i and h have l: "r x xa" by auto
	  from k and l have "r x xa \<and> n xa y \<in> r***" by blast
	  from this have "\<exists>v. r x v \<and> n v y \<in> r***" by blast
	  thus ?thesis by assumption
	qed
    qed

  lemma confluence_single_thm[rule_format]:
    assumes cr: "\<And>x y z. \<lbrakk> r x y ; r x z \<rbrakk> \<Longrightarrow> (\<exists>v. r y v \<and> r z v)"
    shows "\<And>a b c. n a c \<in> r*** \<and> r a b \<longrightarrow> (\<exists>d. (n b d \<in> r***) \<and> (r c d))"
    apply(induct n)
    proof -
      fix a b c
      show "(0 a c \<in> r*** \<and> r a b) \<longrightarrow> (\<exists>d. 0 b d \<in> r*** \<and> r c d)"
	apply(rule impI)
	apply(erule conjE)
	apply(rule exI)
	apply(rule conjI)
	apply(rule rtc3.reflex)
	proof -
	  assume asm1: "0 a c \<in> r***"
	  assume asm2: "r a b"
	  show "r c b"
	    proof -
	      from asm1 have "a=c" by (rule confluence_base_equal_thm)
	      thus "r c b" using asm2 by auto
	    qed
	qed
    next
      fix n
      fix a b c
      assume a[rule_format]: "\<And>a b c. n a c \<in>  r*** \<and> r a b \<longrightarrow> (\<exists>d. n b d \<in>  r*** \<and> r c d)"
      show "(Suc n) a c \<in>  r*** \<and> r a b \<longrightarrow> (\<exists>d. (Suc n) b d \<in>  r*** \<and> r c d)"
	proof safe
	  assume Asm1: "(Suc n) a c \<in> r***"
	  assume Asm2: "r a b"
	  show G: "\<exists>d. (Suc n) b d \<in>  r*** \<and> r c d"
	    proof -
              from Asm1 obtain c' where ra1: "n c' c \<in> r***" and ra2: "r a c'" using confluence_single_forward_imp by best -- "Ripple step"
	      from Asm2 and ra2 have "(\<exists>v. r b v \<and> r c' v)" using cr by blast
	      from this and Asm2 and ra2 obtain v where cr1: "r b v" and cr2: "r c' v" using cr by blast
	      from ra1 and cr2 have asm: "n c' c \<in> r*** \<and> r c' v" by blast
	      from asm obtain d where cnc1: "n v d \<in> r***" and cnc2: "r c d" using a by blast
	      from cr1 and cnc1 have "(Suc n) b d \<in> r***" by (blast intro: rtc3.intros) -- "Ripple step"
	      from this and cnc2 have "(Suc n) b d \<in> r*** \<and> r c d" by blast
	      from this have "\<exists>d. (Suc n) b d \<in> r*** \<and> r c d" by blast
	      thus ?thesis by assumption -- "Fertilization"
	    qed
	qed
    qed

  theorem confluence_thm: -- "Lombart calls this the Church-Rosser theorem."
    assumes cr: "\<And>x y z. \<lbrakk> r x y ; r x z \<rbrakk> \<Longrightarrow> \<exists>v. r y v \<and> r z v"
    shows "\<And>x y z. n x y \<in> r*** \<and> m x z \<in> r*** \<longrightarrow> (\<exists>v. m y v \<in> r*** \<and> n z v \<in> r***)"
    apply(induct n)
    apply(rule impI)
    apply(erule conjE)
    apply(rule_tac x="z" in exI)
    apply(rule conjI)
    proof -
      fix x y z
      assume a: "0 x y \<in> r***"
      assume b: "m x z \<in> r***"
      show "m y z \<in> r***"
	proof -
	  from a have "x=y" by (rule confluence_base_equal_thm)
	  from this have "y=x" by (rule sym)
	  from this and b have "m y z \<in> r***" by auto
	  thus ?thesis by assumption
	qed
    next
      fix x y z
      assume a: "0 x y \<in> r***"
      assume b: "m x z \<in> r***"
      show "0 z z \<in> r***" by (rule rtc3.reflex)
    next
      fix n x y z
      assume a[rule_format]: "(\<And>x y z. n x y \<in>  r*** \<and> m x z \<in>  r*** \<longrightarrow> (\<exists>v. m y v \<in>  r*** \<and> n z v \<in>  r***))"
      show "(Suc n) x y \<in>  r*** \<and> m x z \<in>  r*** \<longrightarrow> (\<exists>v. m y v \<in>  r*** \<and> (Suc n) z v \<in>  r***)"
	proof safe
	  assume Asm1: "(Suc n) x y \<in> r***"
	  assume Asm2: "m x z \<in> r***"
	  show "\<exists>v. m y v \<in>  r*** \<and> (Suc n) z v \<in>  r***"
	    proof -
	      from Asm1 obtain x' where ra1: "n x' y \<in> r***" and ra2: "r x x'" using confluence_single_forward_imp by best -- "Ripple step"
	      from Asm2 and ra2 have "\<exists>d. m x' d \<in> r*** \<and> r z d" using confluence_single_thm[OF cr] by best -- "Ripple step"
	      from this obtain d where cnc1: "m x' d \<in> r***" and cnc2: "r z d" by blast
	      from ra1 and cnc1 have asm: "n x' y \<in> r*** \<and> m x' d \<in> r***" by blast
	      from asm obtain v where ca1: "m y v \<in> r***" and ca2: "n d v \<in> r***" using a by blast
	      from ca2 and cnc2 have "(Suc n) z v \<in> r***" by (blast intro: rtc3.intros) -- "Ripple step"
	      from ca1 and this have "m y v \<in> r*** \<and> (Suc n) z v \<in> r***" by auto
	      from this have "\<exists>v. m y v \<in> r*** \<and> (Suc n) z v \<in> r***" by auto
	      thus ?thesis by assumption -- "Fertilization"
	    qed
	qed
    qed

  (*
    Less than or equal to and greater than, following Lucas's idea.
  *)

  inductive
    succ :: "nat \<Rightarrow> nat \<Rightarrow> bool" where
      member: "succ x (Suc x)"
  inductive
    eq :: "'a \<Rightarrow> 'a \<Rightarrow> bool" (infixr "\<doteq>" 65) where
      member: "x \<doteq> x"
  inductive
    lt1 :: "nat \<Rightarrow> nat \<Rightarrow> bool" (infixr "\<prec>1" 65) where
      zero: "0 \<prec>1 x"
    | step: "x \<prec>1 y \<Longrightarrow> (Suc x) \<prec>1 (Suc y)"
  inductive
    lt2 :: "nat \<Rightarrow> nat \<Rightarrow> bool" (infixr "\<prec>2" 65) where
      base: "x \<prec>2 (Suc x)"
    | step: "x \<prec>2 y \<Longrightarrow> x \<prec>2 (Suc y)"
  inductive
    ltoe1 :: "nat \<Rightarrow> nat \<Rightarrow> bool" (infixr "\<preceq>1" 65) where
      zero: "0 \<preceq>1 x"
    | step: "x \<preceq>1 y \<Longrightarrow> (Suc x) \<preceq>1 (Suc y)"
  inductive
    ltoe2 :: "nat \<Rightarrow> nat \<Rightarrow> bool" (infixr "\<preceq>2" 65) where
      base: "x \<preceq>2 x"
    | step: "x \<preceq>2 y \<Longrightarrow> x \<preceq>2 (Suc y)"
  inductive
    ltoe3 :: "nat \<Rightarrow> nat \<Rightarrow> bool" (infixr "\<preceq>3" 65) where
      zero: "0 \<preceq>3 x"
    | equal: "x \<doteq> y \<Longrightarrow> x \<preceq>3 y"
    | less: "x \<prec>1 y \<Longrightarrow> x \<preceq>3 y"
  inductive
    ltoe4 :: "nat \<Rightarrow> nat \<Rightarrow> bool" (infixr "\<preceq>4" 65) where
      zero: "0 \<preceq>4 x"
    | equal: "x \<doteq> y \<Longrightarrow> x \<preceq>4 y"
    | less: "x \<prec>2 y \<Longrightarrow> x \<preceq>4 y"
  inductive
    gtoe1 :: "nat \<Rightarrow> nat \<Rightarrow> bool" (infixr "\<succeq>1" 65) where
      zero: "x \<succeq>1 0"
    | step: "x \<succeq>1 y \<Longrightarrow> (Suc x) \<succeq>1 (Suc y)"


  theorem eq_fun_imp_eq_thm[rule_format]:
    shows "(x::nat)=y \<longrightarrow> x\<doteq>y"
    apply(induct_tac x)
    proof -
      show "0=y \<longrightarrow> 0\<doteq>y"
        apply(rule impI)
        apply(erule ssubst)
         by (rule eq.member)
    next
      fix n
      assume IH: "n=y \<longrightarrow> n\<doteq>y"
      show "Suc n = y \<longrightarrow> Suc n \<doteq> y"
        apply(rule impI)
        apply(erule ssubst)
         by (rule eq.member)
    qed

  theorem eq_imp_eq_fun_thm[rule_format]:
    shows "(x::nat)\<doteq>y \<longrightarrow> x=y"
    apply(induct_tac x)
    proof -
      show "0\<doteq>y \<longrightarrow> 0=y"
        proof
          assume Assm: "0\<doteq>y"
          show "0=y"
            apply(rule eq.cases)
            apply(rule Assm)
            proof -
              fix x::nat
              assume a: "0=x"
              assume b: "y=x"
              show "0=y"
                apply(subst b)
                 by (rule a)
            qed
        qed
    next
      fix n
      assume IH: "n\<doteq>y \<longrightarrow> n=y"
      show "Suc n \<doteq> y \<longrightarrow> Suc n = y"
        proof
          assume Assm: "Suc n \<doteq> y"
          show "Suc n = y"
            apply (rule eq.cases)
            apply (rule Assm)
            proof - 
              fix x
              assume a: "Suc n = x"
              assume yx: "y = x"
              show "Suc n = y"
                apply (subst yx)
                 by (rule a)
            qed
        qed
    qed

  theorem eq_commut_thm:
    shows "(x::nat)\<doteq>y = y\<doteq>x"
    apply(induct_tac x)
    proof -
      show "0\<doteq>y = y\<doteq>0"
        apply(rule iffI)
        proof -
          assume IH: "0\<doteq>y"
          show "y\<doteq>0"
            proof -
              from IH have "0=y" by(rule eq_imp_eq_fun_thm)
              from this have "y=0" by (rule sym)
              thus "y\<doteq>0" by (rule eq_fun_imp_eq_thm)
            qed
        next
          assume IH: "y\<doteq>0"
          show "0\<doteq>y"
            proof -
              from IH have "y=0" by (rule eq_imp_eq_fun_thm)
              from this have "0=y" by (rule sym)
              thus "0\<doteq>y" by (rule eq_fun_imp_eq_thm)
            qed
        qed
    next
      fix n
      assume IH: "(n\<doteq>y) = (y\<doteq>n)"
      show "(Suc n \<doteq> y) = (y \<doteq> Suc n)"
        apply(rule iffI)
        proof -
          assume IH: "Suc n \<doteq> y"
          show "y \<doteq> Suc n"
            proof -
              from IH have "Suc n = y" by (rule eq_imp_eq_fun_thm)
              from this have "y = Suc n" by (rule sym)
              thus "y \<doteq> Suc n" by (rule eq_fun_imp_eq_thm)
            qed
        next
          assume IH: "y \<doteq> Suc n"
          show "Suc n \<doteq> y"
            proof -
              from IH have "y = Suc n" by (rule eq_imp_eq_fun_thm)
              from this have "Suc n = y" by (rule sym)
              thus "Suc n \<doteq> y" by (rule eq_fun_imp_eq_thm)
            qed
        qed
    qed

  theorem eq_iff_eq_fun_thm:
    shows "((x::nat)=y) = (x\<doteq>y)"
      by (auto simp add: eq_imp_eq_fun_thm eq_fun_imp_eq_thm)

  lemma eq_inject_fwd_thm:
    assumes a: "Suc x \<doteq> Suc y"
    shows "x \<doteq> y"
    using a
    proof -
      have "Suc x = Suc y" by (rule eq_imp_eq_fun_thm)
      from this have "x=y" by (subst Suc_Suc_eq[symmetric], assumption)
      thus "x \<doteq> y" by (rule eq_fun_imp_eq_thm)
    qed

  theorem lt1_reflex_thm:
    shows "x\<prec>1x"
    apply(induct_tac x)
    proof -
      show "0 \<prec>1 0" by (rule lt1.zero)
    next
      fix n
      assume IH: "n \<prec>1 n"
      show "Suc n \<prec>1 Suc n"
	apply(rule lt1.step)
	 by (rule IH)
    qed

  theorem ltoe1_reflex_thm:
    shows "y\<preceq>1y"
    apply(induct_tac y)
    proof -
      show "0\<preceq>10" by (rule ltoe1.zero)
    next
      fix n
      assume IH: "n\<preceq>1n"
      show "Suc n \<preceq>1 Suc n"
        apply(rule ltoe1.step)
         by (rule IH)
    qed

  lemma ltoe2_inject_bck_thm:
    assumes a: "Suc n \<preceq>2 Suc n"
    shows "n \<preceq>2 n"
    proof (induct n)
      show "0 \<preceq>2 0" by (rule ltoe2.base)
    next
      fix n
      assume IH: "n \<preceq>2 n"
      show "Suc n \<preceq>2 Suc n" by (blast intro: ltoe2.intros)
    qed

  lemma ltoe2_inject_fwd_thm:
    assumes a: "n \<preceq>2 n"
    shows "Suc n \<preceq>2 Suc n"
    proof (induct n)
      show "Suc 0 \<preceq>2 Suc 0" by (blast intro: ltoe2.intros)
    next
      fix n
      assume IH: "Suc n \<preceq>2 Suc n"
      show "Suc (Suc n) \<preceq>2 Suc (Suc n)" by (blast intro: ltoe2.intros)
    qed

  lemma ltoe2_inject_thm: "n \<preceq>2 n = (Suc n) \<preceq>2 (Suc n)"
    by (blast intro: ltoe2_inject_fwd_thm ltoe2_inject_bck_thm)

  theorem ltoe2_reflex_thm:
    shows "y\<preceq>2y"
    apply(induct_tac y)
    proof -
      show "0 \<preceq>2 0" by (rule ltoe2.base)
    next
      fix n
      assume IH: "n \<preceq>2 n"
      show "(Suc n) \<preceq>2 (Suc n)"
	apply(subst ltoe2_inject_thm[symmetric])
	 by (rule IH)
    qed

  lemma suc_suc_ltoe_imp_thm:
    shows "x \<le> y \<Longrightarrow> (Suc x) \<le> (Suc y)"
     by auto

  theorem ltoe1_imp_ltoe_fun_thm[rule_format]:
    shows "x\<preceq>1y \<longrightarrow> x\<le>y"
    apply(rule impI)
      thm ltoe1.induct[of x y]
    apply(erule ltoe1.induct)
    apply(rule le0)
    apply(rule suc_suc_ltoe_imp_thm)
     by assumption

  lemma lt1_inject_fwd_thm:
    assumes a: "Suc x \<prec>1 Suc y"
    shows "x \<prec>1 y"
    apply(rule lt1.cases[OF a])
    apply(rule Suc_neq_Zero)
    apply assumption
    proof -
      fix xa
      fix ya::nat
      assume a: "Suc x = Suc xa"
      assume b: "Suc y = Suc ya"
      assume c: "xa \<prec>1 ya"
      show "x \<prec>1 y"
	proof -
	  from a have d: "x=xa"
	    apply(subst Suc_Suc_eq[symmetric])
	     by assumption
	  moreover from b have e: "y=ya"
	    apply(subst Suc_Suc_eq[symmetric])
	     by assumption
	  thus "x \<prec>1 y" using d and e and c
	    apply(subst ssubst[OF d])
	    apply(subst ssubst[OF e])
	    apply assumption
	     by (rule TrueI)
	qed
    qed

  lemma lt1_inject_bck_thm:
    assumes a: "x \<prec>1 y"
    shows "Suc x \<prec>1 Suc y"
    apply(rule lt1.cases[OF a])
    apply(rule lt1.step)
    apply(erule ssubst)
    apply(rule lt1.zero)
    apply(erule subst)+
    apply(rule lt1.step)
     by assumption

  lemma lt1_inject_thm:
    shows "x \<prec>1 y = (Suc x) \<prec>1 (Suc y)"
     by (blast intro: lt1_inject_fwd_thm lt1_inject_bck_thm)

  lemma suc_n_not_lt2_n:
    assumes a: "Suc n \<prec>2 n"
    shows "!!R. R"
    apply(rule lt2.cases[OF a])
    apply(auto simp add: lt2.intros)
    proof -
      fix R y
      assume A: "Suc (Suc y) \<prec>2 y"
      show R
      sorry
    qed

  lemma lt2_not_refl:
    assumes a: "n \<prec>2 n"
    shows "!!R. R"
    apply(rule lt2.cases[OF a])
    proof -
      fix R x
      assume Assm1: "n=x"
      assume Assm2: "n = Suc x"
      show R
      proof -
        from Assm1 and Assm2 have "n=Suc n" by auto
        thus ?thesis by (auto simp add: n_not_Suc_n)
      qed
    next
      fix R x y
      assume Assm1: "n=x"
      assume Assm2: "n=Suc y"
      assume Assm3: "x \<prec>2 y"
      show R
      proof -
        from Assm1 and Assm2 have "Suc y = x" by auto
        from this and Assm3 have "Suc y \<prec>2 y" by auto
        thus ?thesis by (rule suc_n_not_lt2_n)
      qed
    qed

  lemma lt2_suc_suc_thm:
    shows "x \<prec>2 Suc (Suc x)"
    apply(induct x)
    apply(rule lt2.step)
    apply(rule lt2.base)
    apply(rule lt2.step)
     by (rule lt2.base)

  lemma lt2_imp_lt2_suc_thm:
    assumes a: "x \<prec>2 y"
    shows "x \<prec>2 (Suc y)"
    apply(rule lt2.cases[OF a])
    proof -
      fix xa
      assume a: "x=xa"
      assume b: "y=Suc xa"
      show "x \<prec>2 Suc y"
	proof -
	  from a have "xa=x" by (rule sym)
	  from this and b have c: "y=Suc x" by auto
	  from this have d: "x \<prec>2 Suc (Suc x)" by (blast intro: lt2.intros)
	  thus ?thesis by (auto simp add: c d)
	qed
    next
      fix xa ya
      assume a: "x=xa"
      assume b: "y=Suc ya"
      assume c: "xa \<prec>2 ya"
      show "x \<prec>2 Suc y"
        proof -
	  from a and c have "x \<prec>2 ya" by auto
	  have "y \<prec>2 Suc (Suc y)"
	    apply(subst lt2.step)
	    apply(subst lt2.base)
	     by (rule TrueI)
	  from this and b have "Suc ya \<prec>2 Suc (Suc y)" (* by auto *) sorry
    next
      show "x \<prec>2 Suc y"
      oops

  lemma lt2_trans_thm:
    assumes asm: "x \<prec>2 y"
    assumes b: "y \<prec>2 z"
    shows "x \<prec>2 z"
    apply(rule lt2.cases[OF b])
    proof -
      fix xa
      assume a: "y=xa"
      assume b: "z=Suc xa"
      show "x\<prec>2z"
	proof -
	  from a have "xa=y" by (rule sym)
	  from this and b have c: "z=Suc y" by auto
          from this and asm have "x\<prec>2 Suc y"
	    oops

  lemma suc_lt2_imp_lt2_thm:
    assumes asm: "Suc x \<prec>2 y"
    shows "x \<prec>2 y"
    apply(rule lt2.cases[OF asm])
    proof -
      fix xa
      assume a: "Suc x = xa"
      assume b: "y=Suc xa"
      show "x \<prec>2 y"
      proof -
        from a have "xa=Suc x" by (rule sym)
        from this and b have c: "y=Suc(Suc x)" by auto
        from this have d: "x \<prec>2 Suc(Suc x)"
	  apply(subst lt2.cases)
	  apply(rule asm)
	  apply(rule lt2_suc_suc_thm)
          apply(rule lt2_suc_suc_thm)
	   by (rule TrueI)
        thus "x \<prec>2 y" using c and d by auto
      qed
    next
      fix xa ya
      assume a: "Suc x = xa"
      assume b: "y=Suc ya"
      assume c: "xa \<prec>2 ya"
      show "x \<prec>2 y"
      apply(rule lt2.cases[OF asm])
      oops

  lemma lt2_inject_fwd_thm:
    assumes a: "Suc x \<prec>2 Suc y"
    shows "x \<prec>2 y"
    apply(rule lt2.cases[OF a])
    proof -
      fix xa
      assume a: "Suc x = xa"
      assume b: "Suc y = Suc xa"
      show "x \<prec>2 y"
	proof -
	  from b have c: "y=xa" by (subst Suc_Suc_eq[symmetric], assumption)
	  from a have d: "xa=Suc x" by (rule sym)
	  from c and d have "y=Suc x" by auto
	  thus "x \<prec>2 y" by (auto simp add: lt2.base)
	qed
    next
      fix xa ya
      assume a: "Suc x = xa"
      assume b: "Suc y = Suc ya"
      assume c: "xa \<prec>2 ya"
      show "x \<prec>2 y"
        proof -
          from b have d: "y = ya" by (subst Suc_Suc_eq[symmetric], assumption)
          from this have e: "ya=y" by (rule sym)
          from a and e and c have "Suc x \<prec>2 y" by auto
          thus "x \<prec>2 y"
          oops

  lemma lt2_inject_bck_thm:
    assumes a: "x \<prec>2 y"
    shows "Suc x \<prec>2 Suc y"
    apply(rule lt2.cases[OF a])
    proof -
      fix xa
      assume a: "x=xa"
      assume b: "y=Suc xa"
      show "Suc x \<prec>2 Suc y"
	proof -
	  from a and b have c: "y=Suc x" by auto
	  from this have "Suc x \<prec>2 Suc (Suc x)"
	    apply(subst lt2.base)
	      by (rule TrueI)
	  thus "Suc x \<prec>2 Suc y" using a and c by auto
	qed
    next
      fix xa ya
      assume a: "x=xa"
      assume b: "y=Suc ya"
      assume c: "xa \<prec>2 ya"
      show "Suc x \<prec>2 Suc y"
	oops

  lemma ltoe3_inject_fwd_thm:
    assumes a: "x \<preceq>3 y"
    shows "Suc x \<preceq>3 Suc y"
    apply(rule ltoe3.induct[OF a])
    proof -
      fix x
      show "(Suc 0) \<preceq>3 (Suc x)"
	apply(rule ltoe3.less)
	apply(rule lt1.step)
	 by (rule lt1.zero)
    next
      fix x y::nat
      assume IH: "x\<doteq>y"
      show "Suc x \<preceq>3 Suc y"
	apply(rule ltoe3.equal)
	apply(subst eq_iff_eq_fun_thm[symmetric])
	apply(subst Suc_Suc_eq)
	apply(subst eq_iff_eq_fun_thm)
	 by (rule IH)
    next
      fix x y
      assume IH: "x \<prec>1 y"
      show "Suc x \<preceq>3 Suc y"
	apply(rule ltoe3.less)
	apply(subst lt1_inject_thm[symmetric])
	 by (rule IH)
    qed

  lemma ltoe3_inject_bck_thm:
    assumes a: "Suc n \<preceq>3 Suc y"
    shows "n \<preceq>3 y"
    using a
    apply(rule ltoe3.cases)
    apply(subst Suc_neq_Zero)
    apply assumption
    apply (rule TrueI)
    proof -
      fix x ya
      assume a: "Suc n = x"
      assume b: "Suc y = ya"
      assume c: "x \<doteq> ya"
      show "n \<preceq>3 y"
	proof -
	  from a and b and c have "Suc n \<doteq> Suc y" by auto
	  from this have "n \<doteq> y" by (rule eq_inject_fwd_thm)
	  thus "n \<preceq>3 y" by (rule ltoe3.equal)
	qed
    next
      fix x ya
      assume a: "Suc n = x"
      assume b: "Suc y = ya"
      assume c: "x \<prec>1 ya"
      show "n \<preceq>3 y"
	proof -
	  from a have d: "x=Suc n" by (rule sym)
	  from b have e: "ya=Suc y" by (rule sym)
	  from d and e and c have "Suc n \<prec>1 Suc y" by auto
	  from this have "n \<prec>1 y" by (rule lt1_inject_fwd_thm)
	  thus "n \<preceq>3 y" by (rule ltoe3.less)
	qed
    qed

  lemma ltoe3_inject_thm:
    shows "x\<preceq>3y = (Suc x) \<preceq>3 (Suc y)"
    apply(rule iffI)
    apply(rule ltoe3_inject_fwd_thm)
    apply assumption
    apply(subst ltoe3_inject_bck_thm)
    apply assumption
     by (rule TrueI)

  theorem ltoe3_reflex_thm:
    shows "y \<preceq>3 y"
    apply(induct_tac y)
    proof -
      show "0 \<preceq>3 0" by (rule ltoe3.zero)
    next
      fix n
      assume IH: "n \<preceq>3 n"
      show "Suc n \<preceq>3 Suc n" by (subst ltoe3_inject_thm[symmetric], assumption)
    qed

  lemma ltoe4_inject_fwd_thm:
    assumes a: "Suc x \<preceq>4 Suc y"
    shows "x \<preceq>4 y"
    apply(rule ltoe4.cases[OF a])
    apply(rule Suc_neq_Zero)
    apply assumption
    proof -
      fix xa ya
      assume a: "Suc x = xa"
      assume b: "Suc y = ya"
      assume c: "xa\<doteq>ya"
      show "x \<preceq>4 y"
	proof -
	  from a have d: "xa=Suc x" by (rule sym)
	  from b have e: "ya=Suc y" by (rule sym)
	  from c have "xa=ya" by (rule eq_imp_eq_fun_thm)
	  from this and d and e have "Suc x=Suc y" by auto
	  from this have "x=y" by (subst Suc_Suc_eq[symmetric], assumption)
	  from this have "x\<doteq>y" by (rule eq_fun_imp_eq_thm)
	  thus "x \<preceq>4 y" by (rule ltoe4.equal)
	qed
    next
      fix xa ya
      assume a: "Suc x = xa"
      assume b: "Suc y = ya"
      assume c: "xa \<prec>2 ya"
      show "x \<preceq>4 y"
	proof -
	  from a have d: "xa=Suc x" by (rule sym)
	  from b have e: "ya=Suc y" by (rule sym)
	  from d and e and c have "Suc x \<prec>2 Suc y" by auto
	  oops

  theorem ltoe4_reflex_thm:
    shows "y \<preceq>4 y"
    apply(induct_tac y)
    proof -
      show "0 \<preceq>4 0" by (rule ltoe4.zero)
    next
      fix n
      assume Assm: "n \<preceq>4 n"
      show "Suc n \<preceq>4 Suc n"
        apply(rule ltoe4.cases [OF Assm])
        proof -
          fix x
          assume Assm1: "n=0"
          assume Assm2: "n=x"
          show "Suc n \<preceq>4 Suc n"
          proof -
            have g: "n\<doteq>n" by (rule eq.intros)
            thus ?thesis apply(subst ltoe4.equal) apply(rule eq_inject_fwd_thm) apply(rule eq.intros) by (rule TrueI)
          qed
        next
          fix x y
          assume Assm1: "n=x"
          assume Assm2: "n=y"
          assume Assm3: "x\<doteq>y"
          show "Suc n \<preceq>4 Suc n"
          proof -
            from Assm1 have a: "x=n" by (rule sym)
            from Assm2 have b: "y=n" by (rule sym)
            from a and b and Assm3 have "n\<doteq>n" by auto
            thus ?thesis apply (subst ltoe4.equal) apply(rule eq.intros) by (rule TrueI)
          qed
        next
          fix x y
          assume Assm1: "n=x"
          assume Assm2: "n=y"
          assume Assm3: "x \<prec>2 y"
          show "Suc n \<preceq>4 Suc n"
          proof -
            from Assm1 have a: "x=n" by (rule sym)
            from Assm2 have b: "y=n" by (rule sym)
            from a and b and Assm3 have "n \<prec>2 n" by auto
            thus ?thesis apply(subst ltoe4.less) sorry
          qed
        qed
    qed

  theorem eq_imp_ltoe_thm[rule_format]:
    shows "x\<doteq>y \<longrightarrow> x \<preceq>1 y"
    apply(rule impI)
    thm eq.induct[of x y]
    apply(erule eq.induct)
     by(rule ltoe1_reflex_thm)

end
