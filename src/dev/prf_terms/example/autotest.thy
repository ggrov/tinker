theory autotest
imports  
   "../../../provers/isabelle//full/build/Parse"
   "../StratGraphs"
begin

ML_val{* proofs := 2 *}

ML{*print_depth 20*}

ML{*
val path = "/home/colin/Documents/phdwork/graphs/autotesting/"
*}

declare [[simp_trace]]

-- "examples - prop. logic"


lemma p: "A \<Longrightarrow> B \<Longrightarrow> (B \<and> A) \<and> (A \<and> B)"
  apply (rule conjI)
  apply (rule conjI)
  apply assumption
  apply assumption
  apply (rule conjI)
  apply assumption
  apply assumption
done

full_prf p

ML{*
val treep = PTParse.build_tree (PTParse.prf @{thm p})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treep;

PSGraph.PSTheory.write_dot (path ^ "termp.dot") graph
*}

lemma p1: "A \<Longrightarrow> B \<Longrightarrow> (B \<and> A) \<and> (A \<and> B)"
  apply auto
done

ML{*
val treep = PTParse.build_tree (PTParse.prf @{thm p1})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treep;

PSGraph.PSTheory.write_dot (path ^ "termp1.dot") graph
*}

lemma p2: "A \<Longrightarrow> B \<Longrightarrow> (B \<and> A) \<and> (A \<and> B)"
  apply (rule conjI)
  apply auto
done

ML{*
val treep = PTParse.build_tree (PTParse.prf @{thm p2})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treep;

PSGraph.PSTheory.write_dot (path ^ "termp2.dot") graph
*}


lemma p3: "A \<Longrightarrow> B \<Longrightarrow> (B \<and> A) \<and> (A \<and> B)"
  apply (rule conjI)
  apply (rule conjI)
  apply assumption
  apply assumption
  apply auto
done

ML{*
val treep = PTParse.build_tree (PTParse.prf @{thm p3})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treep;

PSGraph.PSTheory.write_dot (path ^ "termp3.dot") graph
*}

lemma p4: "A \<Longrightarrow> B \<Longrightarrow> (B \<and> A) \<and> (A \<and> B)"
  apply (rule conjI)+
  apply assumption+
  apply (rule conjI)
  apply assumption
  apply auto
done

ML{*
val treep = PTParse.build_tree (PTParse.prf @{thm p4})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treep;

PSGraph.PSTheory.write_dot (path ^ "termp4.dot") graph
*}

lemma q: "True \<and> True"
  apply (rule conjI)
  apply (rule TrueI)
  apply (rule TrueI)
  done

full_prf q

ML{*
val treeq = PTParse.build_tree (PTParse.prf @{thm q})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treeq;

PSGraph.PSTheory.write_dot (path ^ "termq") graph
*}

lemma q1: "True \<and> True"
  apply auto
done

ML{*
val treeq = PTParse.build_tree (PTParse.prf @{thm q1})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treeq;

PSGraph.PSTheory.write_dot (path ^ "termq1") graph
*}

lemma q2: "True \<and> True"
  apply (rule conjI)
  apply auto
done

ML{*
val treeq = PTParse.build_tree (PTParse.prf @{thm q2})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treeq;

PSGraph.PSTheory.write_dot (path ^ "termq2") graph
*}

lemma r:  "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"  full_prf
  apply (rule impI)   full_prf
  apply (rule impI)   full_prf
  apply (rule impI)   full_prf
  apply (erule impE)  full_prf
  apply assumption    full_prf
  apply (erule impE)  full_prf
  apply assumption    full_prf
  apply (erule impE)  full_prf
  apply assumption    full_prf
  apply assumption    full_prf
done

full_prf r


ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm r})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

PSGraph.PSTheory.write_dot (path ^ "termr") graph
*}

lemma r1:  "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"
  apply auto
done

ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm r1})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

PSGraph.PSTheory.write_dot (path ^ "termr1") graph
*}


-- "examples - nat numbers"

primrec sq :: "nat \<Rightarrow> nat" where
  "sq 0 = 0"
  | "sq (Suc n) = (sq n) + n + (Suc n)"

theorem MM1[simp]: "sq n = n * n"
  apply (induct n)
  apply auto
done
  
ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm MM1})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

PSGraph.PSTheory.write_dot (path ^ "termMM1") graph
*}


lemma aux[rule_format]: "!m. m <= n \<longrightarrow> sq n = ((n + (n-m)) * m) + sq (n - m)"
  apply (induct_tac n)
  apply auto
  apply (case_tac m)
  apply auto
done

ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm aux})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

PSGraph.PSTheory.write_dot (path ^ "termaux") graph
*}


theorem MM2: "100 \<le> n \<Longrightarrow> sq n = ((n + (n - 100)) * 100) + sq (n - 100)"
  apply (rule aux)
  apply auto
done

ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm MM2})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

PSGraph.PSTheory.write_dot (path ^ "termMM2") graph
*}


theorem MM3: "sq((10 * n) + 5) = ((n * (Suc n)) * 100) + 25"
  apply auto
  apply (simp add: add_mult_distrib)
  apply (simp add: add_mult_distrib2)
done

ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm MM3})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

PSGraph.PSTheory.write_dot (path ^ "termMM3") graph
*}


-- "examples - tower of hanoi"

declare [[simp_trace=false]]

datatype peg = A | B | C

declare [[simp_trace=true]]

type_synonym move = "peg * peg";

primrec other :: "peg \<Rightarrow> peg \<Rightarrow> peg" where
   "other A x = (if x = B then C else B)"
  |"other B x = (if x = A then C else A)"
  |"other C x = (if x = A then B else A)"

primrec move :: "nat \<Rightarrow> peg \<Rightarrow> peg \<Rightarrow> move list" where
  "move 0       src dst   = []"
  |"move (Suc n) src dst  = (move n src (other src dst)) @ [(src,dst)] @
                                (move n (other src dst) dst)"


theorem \<alpha>: "\<forall>x y. length (move n x y) = 2^n - 1"
  apply (induct n)
  apply simp
  apply auto
done


type_synonym config = "peg \<Rightarrow> nat list"

primrec lt :: "nat \<Rightarrow> nat list \<Rightarrow> bool" where
  "lt n [] = True"
| "lt n (x#xs) = (n < x \<and> lt n xs)"

primrec ordered :: "nat list \<Rightarrow> bool" where
  "ordered [] = True"
| "ordered (x#xs) = (lt x xs \<and> ordered xs)"

definition hanoi :: "config \<Rightarrow> bool" where
  "hanoi cfg \<equiv> \<forall>s. ordered (cfg s)"

definition step :: "config \<Rightarrow> move \<Rightarrow> config option" where
  "step c x \<equiv> let (src,dst) = x in
      if c src = [] then None
      else let src' = tl (c src);
                  m = hd (c src);
               dst' = m # (c dst);
                 c' = (c (src:=src')) (dst:=dst')
          in if hanoi c' then Some c' else None"

primrec exec :: "config \<Rightarrow> move list \<Rightarrow> config option" where
  "exec c [] = Some c"
| "exec c (x#xs) = (let cfg' = step c x in if cfg' = None then None else exec
                                                              (the cfg') xs)"

primrec tower :: "nat \<Rightarrow> nat list" where
  "tower 0 = []"
| "tower (Suc n) = tower n @ [Suc n]"

lemma \<beta> [simp]: "other x y \<noteq> x \<and> other x y \<noteq> y"
  apply (cases x)
  apply auto
done

lemma \<gamma>: "move 1 A C = [(A,C)]"
  apply simp
done

lemma \<delta>: "move 2 A C = [(A,B),(A,C),(B,C)]"
  apply (simp add: numeral_2_eq_2)
done

lemma \<epsilon>: "move 3 A C = [(A,C),(A,B),(C,B),(A,C),(B,A),(B,C),(A,C)]"
  apply (simp add: numeral_3_eq_3)
done

lemma \<zeta> [simp]: "\<forall> cfg. exec cfg (a@b) = (let cfg' = exec cfg a in if cfg' = None 
                        then None else exec (the cfg') b)"
 by (induct a, auto simp add:Let_def)

lemma neq_Nil_snoC: "\<forall>n. length xs = Suc n \<longrightarrow> (\<exists>x' xs'. xs = xs' @ [x'])"
  apply (induct xs)
  apply simp
  apply clarsimp
  apply (case_tac xs)
  apply simp
  apply clarsimp
done

lemma otherF [simp]: "x = other x y \<Longrightarrow> False"
  apply (cases x)
  apply (auto split: split_if_asm)
done

lemma \<eta> [simp]: "x \<noteq> y \<Longrightarrow> other x (other x y) = y"
  apply (cases x)
  apply (cases y)
  apply auto
  apply (cases y)
  apply auto
  apply (cases y)
  apply auto
done

lemma \<theta> [simp]: "x \<noteq> y \<Longrightarrow> other (other x y) y = x"
  apply (cases x)
  apply (cases y)
  apply auto
  apply (cases y)
  apply auto
done


primrec gt :: "nat \<Rightarrow> nat list \<Rightarrow> bool" where
  "gt n [] = True"
| "gt n (x#xs) = (x < n \<and> gt n xs)"

lemma \<iota> [simp]: "lt n (a@b) = (lt n a \<and> lt n b)"
  apply (induct a)
  apply auto
done

lemma \<kappa> [simp]: "gt n (a@b) = (gt n a \<and> gt n b)"
  apply (induct a)
  apply auto
done

lemma lt_mono [rule_format, simp]: "a < b \<longrightarrow> lt b xs \<longrightarrow> lt a xs"
  apply (induct xs)
  apply auto
done

lemma \<lambda> [simp]: "ordered (a@n#b) = (ordered a \<and> lt n b \<and> gt n a \<and> ordered b)"
  apply (induct a)
  apply simp
  apply auto
done

lemma gt_iff: "gt n xs = (\<forall>x \<in> set xs. x < n)"
  apply (induct xs)
  apply auto
done

lemma \<mu> [simp]: "xs \<noteq> [] \<longrightarrow> last xs \<in> set xs"
  apply (induct xs)
  apply auto
done

lemma \<nu> [simp]: "\<lbrakk>cfg src = ts' @ t' # xs; hanoi cfg; ts' \<noteq> [] \<rbrakk> \<Longrightarrow> last ts' < t'"
  apply (unfold hanoi_def)
  apply (erule_tac x = src in allE)
  apply clarsimp
  apply (simp add: gt_iff)
done

lemma neq_other: "\<lbrakk>s \<noteq> src; s \<noteq> dst; src \<noteq> dst \<rbrakk> \<Longrightarrow> s = other src dst"
  apply (cases src)
  apply auto
  apply (cases s)
  apply auto
  apply (cases s)
  apply auto
  apply (cases dst)
  apply auto
  apply (cases s)
  apply auto
  apply (cases s)
  apply auto
  apply (cases dst)
  apply auto
  apply (cases s)
  apply auto
  apply (cases s)
  apply auto
  apply (cases dst)
  apply auto
done

lemma ordered_appendI [rule_format]: "ordered a \<longrightarrow> lt t b \<longrightarrow> gt t a \<longrightarrow> 
                                        ordered b \<longrightarrow> ordered (a@b)"
  apply (induct a)
  apply auto
done

lemma \<xi> [simp]: "\<forall> cfg. exec cfg xs = Some cfg' \<longrightarrow> hanoi cfg \<longrightarrow> hanoi cfg'"
  apply (induct xs)
  apply simp
  apply auto
  apply (simp add: step_def Let_def split: split_if_asm)
done

declare [[simp_trace=false]]

lemma hanoi_lemma:
  "\<forall> cfg src dst t xs ys zs. cfg src = t @ xs \<longrightarrow> cfg dst = ys \<longrightarrow> 
  cfg (other src dst) = zs \<longrightarrow> length t = n \<longrightarrow> hanoi cfg \<longrightarrow> lt (last t) ys \<longrightarrow>
  lt (last t) zs \<longrightarrow> src \<noteq> dst \<longrightarrow> (\<exists>cfg'. exec cfg (move n src dst) = Some cfg' 
  \<and> cfg' src = xs \<and> cfg' dst = t @ ys \<and> cfg' (other src dst) = zs)"
    apply (induct n)
    apply simp
    apply clarsimp
    apply (case_tac "n=0")
    apply (simp add: Let_def)
    apply (case_tac t)
    apply simp
    apply simp
    apply (rule conjI)
    apply (clarsimp simp add: step_def Let_def hanoi_def)
    apply (erule_tac x = src in allE)
    apply simp
    apply (clarsimp simp add: step_def Let_def)
    apply clarsimp
    apply (subgoal_tac "\<exists>t' ts'. t = ts' @ [t']")
    prefer 2
    apply (simp add: neq_Nil_snoC)
    apply clarsimp
    apply (frule spec, erule allE, erule_tac x = "other src dst" in allE, 
      erule allE, erule allE, erule impE, assumption)
    apply (erule impE, rule refl)
    apply (erule impE, assumption)
    apply simp
    apply (subgoal_tac "last ts' < t'")
    apply (erule impE)
    apply (erule lt_mono, assumption)
    apply (erule impE)
    apply (erule lt_mono, assumption)
    apply (erule impE)
    apply rule
    apply (erule otherF)
    prefer 2
    apply simp
    apply clarsimp
    apply (clarsimp simp add: Let_def)
    apply (rule conjI)
    apply (clarsimp simp add: step_def Let_def hanoi_def)
    apply (rule conjI)
    apply (erule_tac x =src in allE)
    apply clarsimp
    apply clarsimp
    apply (drule neq_other, assumption, assumption)
    apply simp
    apply (frule_tac x ="other src dst" in spec)
    apply (drule_tac x="src" in spec)
    apply clarsimp
    apply (rule ordered_appendI, assumption+)
    apply (clarsimp simp add: step_def Let_def)
    apply (erule_tac x="cfg'(src := xs, dst := t' # cfg dst)" in allE)
    apply (erule_tac x="other src dst" in allE)
    apply (erule_tac x="dst" in allE)
    apply (erule allE)+
    apply (erule impE)
    apply simp
    apply (erule impE, rule refl)
    apply (erule impE)
    apply simp
    apply (erule impE)
    apply simp
    apply (rule lt_mono)
    apply (subgoal_tac "last ts' < t'")
    prefer 2
    apply simp
    apply assumption+
    apply (erule impE)
    apply (subgoal_tac "last ts' < t'")
    prefer 2
    apply simp
    apply (unfold hanoi_def)
    apply (erule_tac x = src in allE)
    apply (erule lt_mono)
    apply simp
    apply clarsimp
done



declare [[simp_trace=true]]

lemma \<ominus> [simp]: "length (tower n) = n"
  apply (induct n)
  apply auto
done
    
lemma \<pi>: "lt 0 (tower n)"
  apply (induct n)
  apply auto
done

lemma gt_mono [rule_format, simp]: "x < y \<longrightarrow> gt x xs \<longrightarrow> gt y xs"
  apply (induct xs)
  apply auto
done

lemma \<rho> [simp]: "gt (Suc n) (tower n)"
  apply (induct n)
  apply auto
  apply (rule gt_mono)
  defer
  apply assumption
  apply simp
done

lemma \<sigma> [simp]: "ordered (tower n)"
  apply (induct n)
  apply auto
done

lemma hanoi_start: "\<lbrakk>cfg A = tower n; cfg B = []; cfg C = [] \<rbrakk> \<Longrightarrow> hanoi cfg"
  apply (unfold hanoi_def)
  apply (rule allI)
  apply (case_tac s)
  apply auto
done

declare [[simp_trace=false]]

theorem hanoi: "\<lbrakk>cfg A = tower n; cfg B = []; cfg C = []\<rbrakk>
                \<Longrightarrow> \<exists>cfg'. exec cfg (move n A C) = Some cfg' \<and> cfg' A = [] \<and>
                    cfg' B = [] \<and> cfg' C = tower n"

  apply (frule hanoi_start)
  apply assumption
  apply assumption
  apply (insert hanoi_lemma [of n])
  apply (erule_tac x = cfg in allE)
  apply (erule_tac x = A in allE)
  apply (erule_tac x = C in allE)
  apply (erule_tac x = "tower n" in allE)
  apply (erule allE)+
  apply (erule impE)
  apply simp
  apply (erule impE, assumption)+
  apply (erule impE, simp)
  apply clarsimp
done


end
