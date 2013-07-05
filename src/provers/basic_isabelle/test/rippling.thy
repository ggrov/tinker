theory rippling
imports "../build/BIsaP"
begin


(* rippling *)
  ML_file "../../isabelle/rtechn/rippling/basic_ripple.ML"

(* induction *)
  ML_file "../../isabelle/rtechn/induct.ML"


(* apply induction *)
lemma "rev (a @ b) = rev b @ rev a"
apply (induct_tac "a")
apply auto
oops

ML{*
fun fix_alls_in_term alledt = 
    let
      val t = Term.strip_all_body alledt;
      val alls = rev (Term.strip_all_vars alledt);
      val varnames = map (fst o fst o Term.dest_Var) (Misc_Legacy.term_vars t)
      val names = Misc_Legacy.add_term_names (t,varnames);
      val fvs = map Free 
                    (Name.variant_list names (map fst alls)
                       ~~ (map snd alls));
    in ((subst_bounds (fvs,t))) end;

val t = @{prop "a"} |> Thm.cterm_of @{theory} |> Thm.trivial |> Thm.prop_of |> Logic.get_goal; t 1; 
val print = fn x => Syntax.pretty_term @{context} x |> Pretty.writeln;
val gall = @{term "(\<And>b. rev ([] @ b) = rev b @ rev []) \<Longrightarrow>
          (\<And>a1 a2 b. (\<And>b. rev (a2 @ b) = rev b @ rev a2) \<Longrightarrow> rev ((a1 # a2) @ b) = rev b @ rev (a1 # a2)) \<Longrightarrow>
          rev (a @ b) = rev b @ rev a"};
val g =  @{term "(\<And>b. rev ([] @ b) = rev b @ rev [])"};
val g1 = @{term "(\<And>a1 a2 b. (\<And>b. rev (a2 @ b) = rev b @ rev a2) \<Longrightarrow> rev ((a1 # a2) @ b) = rev b @ rev (a1 # a2))"};
val g2 = @{term "rev (a @ b) = rev b @ rev a "};
val nt = fix_alls_in_term  g1; 
val nt =  Logic.strip_imp_prems  nt |> hd |> fix_alls_in_term;
print nt;


  val gthm = Thm.cterm_of @{theory} @{prop "rev (a @ b) = rev b @ rev a"} |> Thm.trivial;
  val gtrm = Thm.concl_of gthm (*|> Syntax.pretty_term @{context} |> Pretty.writeln*);
(* if inductable *)
  InductRTechn.has_inductable_var @{theory} gtrm;
(* try both tactics 
  InductRTechn.induct_on_first_var_tac 1 gthm |> Seq.map Thm.prop_of |> Seq.list_of |> map print;
  InductRTechn.induct_tac 1 gthm |> Seq.map Thm.prop_of |> Seq.list_of |> map print;
*)
InductRTechn.induct_on_first_var_tac 1 gthm |> Seq.hd |> Thm.prop_of |> print;
val gthm = InductRTechn.induct_on_first_var_tac 1 gthm |> Seq.hd;
Thm.incr_indexes 2 gthm;
Thm.prop_of;
*}

(* example of how to use eqsust_tac with occL *)
lemma test2: "((M & True) & (M & True)) = (M & True)"
by auto

lemma test0 : "(A & False) = False"
by auto
lemma test1 : "(A & True) = (A)"
by auto

lemma test1' : " A = (True & A)"
by auto

(* test tactic *)
ML {*
  (*foo_tac -- the payload of what you want to do,
    note the dependency on ctxt: Proof.context*)
  fun foo_tac ctxt = EqSubst.eqsubst_tac ctxt [0] [@{thm test1}] 1
*}

method_setup foo = {*
  (*concrete syntax like "clarsimp", "auto" etc.*)
  Method.sections Clasimp.clasimp_modifiers >>
    (*Isar method boilerplate*)
    (fn _ => fn ctxt => SIMPLE_METHOD (CHANGED (foo_tac ctxt)))  
*}

lemma test: "((M0 & True) & (M1 & True)) = (M2 & True)"
apply foo
oops

section "wrule sets -> matching seq -> eqsubst -> measure"

(* some tests for substset: embedding; add rule from thm; get matched wrules *)
ML{*
 val skel = @{prop "((M0) & (M1)) = (M2 & True)"};
 val hyps = [skel, @{prop "M = N"}];
 val gt =  @{prop "((M0) & (M1)) = (M2 & True) ==> ((M0 & True) & ( True & M1)) = (M2 & True)"};
 val gt' =  @{prop " ((M0 & True) & ( True & M1)) = (M2 & True)"};

TermFeatures.ctxt_embeds @{context} (hd (tl hyps)) gt;
TermFeatures.ctxt_embeds @{context} (hd hyps) gt;

 val substset = Substset.empty;
 val thms = [("test1",@{thm "test1"}),("test1'(sym)", Substset.mk_sym_thm @{thm "test1'"}), ("test0", @{thm "test0"})];

 val rules = map (fn m => Substset.rule_of_thm m |> (fn SOME x => x)) thms;
 val substset = fold (Substset.add) rules substset;

 val matched = Substset.match @{theory} substset gt;

(* new way to init db *)
 BasicRipple.init_wrule_db();
 BasicRipple.add_wrules thms;
 val matched = BasicRipple.get_matched_wrules @{theory} gt';
*}

(* check whether exists measure decreasing rule, with given goal term and matched rules *)
ML{*
TermFeatures.has_measure_decreasing_rules @{context} skel matched gt';
*}

(* apply rippling tactic *)
ML{*
val gthm = Thm.cterm_of @{theory} gt |> Thm.trivial;
BasicRipple.ripple_tac @{context} 1 gthm |> Seq.list_of ;
*}

(* test subterm *)
ML{*
val t1 = @{term "a + b"};
val t2 = @{term "a + b + c"};

  fun is_subterm thy src sub =
    let
      val ctrm = (Thm.cterm_of thy src);
      val maxid = (#maxidx (rep_cterm ctrm))
      val searchinfo = (thy, maxid, Zipper.mktop src) 
    in 
      EqSubst.searchf_lr_unify_valid searchinfo sub
      |> Seq.flat |> Seq.pull
      |> (fn x => (case x of NONE => false | _ => true))
    end;

is_subterm @{theory} t1 t2;
is_subterm @{theory} t2 t1;
is_subterm @{theory} t2 t2;
*}

(* more debug codes *)
ML{*
(* func to get teh symmetric thm, see thm0 as belows *)
Thm.symmetric;
mk_meta_eq;

val thy = @{theory};
val ctxt = @{context};
val thm = @{thm "test1"};
val thm0 = Thm.symmetric (mk_meta_eq thm);
val concl = @{term "((M \<and> N) \<and> M \<and> N) = (M \<and> N)"};
val z = Zipper.mktop concl;
Syntax.pretty_term @{context} concl |> Pretty.writeln;

(* strip lhs *)
val (lhs,rhs) = Substset.strip_lhs_rhs thm;

*}

ML{*
  EqSubst.eqsubst_tac @{context} [0] [@{thm "rippling.test2"}];
  val deafultsearchf = EqSubst.search_lr_valid EqSubst.valid_match_start;
  val t = @{term "(M & N) & (P & Q)"};
  val t_zip = Zipper.mktop t;
  val t_zip_seq = deafultsearchf t_zip;
  Seq.list_of t_zip_seq |> List.length;
  val search_seq = Seq.map (fn z => (@{theory}, 1, z)) t_zip_seq;
  EqSubst.searchf_lr_unify_valid;
  
  tracing "hello";
*}


end
