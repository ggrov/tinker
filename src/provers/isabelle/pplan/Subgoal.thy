theory Subgoal imports Main
begin

(* way of initialising goals to support schematic variables *)
ML{*
(* may have to make it a prop *)
val t  = Proof_Context.read_term_pattern @{context} "?F x ==> x";
val ct = Thm.cterm_of @{theory} t;
Goal.init ct;
*}

ML{*
val t  = Proof_Context.read_term_pattern @{context} "A ==> ?B ==> (C ==> D) ==> ?B";
val ct = Thm.cterm_of @{theory} t;
val st = Goal.init ct;
*}

(* better way to handle goals  and subgoal and export *)

(* subgoal focus *)
ML{*
Goal.extract 1 2 st |> Seq.list_of;
Subgoal.focus @{context} 1 st;

Subgoal.retrofit;

Subgoal.FOCUS;

Subgoal.FOCUS (fn focus => resolve_tac (#prems focus) 1);
*}

(* goal extract *)
ML{*
val st = Goal.init @{cterm "A ==> A \<and> A"};
val st' = rtac @{thm "conjI"} 1 st |> Seq.list_of |> hd;
  val [s1] = Goal.extract 1 1 st' |> Seq.list_of;
  val x1 = assume_tac 1 s1 |> Seq.list_of |> hd;
  val [s2] = Goal.extract 2 1 st' |> Seq.list_of;
  val x2 = assume_tac 1 s2 |> Seq.list_of |> hd;
  val st'' = Goal.retrofit 2 1 x1 st' |> Seq.list_of |> hd;
  Goal.retrofit 1 1 x2 st'' |> Seq.list_of;
*}



ML {*
  Goal.init @{cpat "Trueprop ?XXX"}
*}

schematic_lemma "\<And>x. A x \<Longrightarrow> ?a x \<and> B \<and> C"
  apply (intro conjI)
  apply -
  ML_val {*
    val st = #goal @{Isar.goal};
    Seq.list_of (Goal.extract 3 1 st);
    Subgoal.focus_prems @{context} 2 st;
  *}
  oops

schematic_lemma "\<And>x. A x \<Longrightarrow> C (?a x)"
  apply -
  ML_val {*
    val st = #goal @{Isar.goal};
    Seq.list_of (Goal.extract 1 1 st);
    Subgoal.focus_prems @{context} 1 st;
  *}
  oops

lemma "(X \<Longrightarrow> Y \<Longrightarrow> A) \<Longrightarrow> A"
  apply (tactic {* Subgoal.FOCUS (fn focus => resolve_tac (#prems focus) 1) @{context} 1 *})
  oops

lemma True and True by - rule+

typedef aaa = "{0, 1, 2::nat}"
proof
  let "\<exists>x. x \<in> ?A" = ?thesis
  show "0 \<in> ?A" by simp
qed

notepad
begin
  
  {
    fix x :: 'a
    have "B x" sorry
  }
  note `\<And>x::'a. B x`
  note `B a`
  note `B b`

next

  fix a b :: nat
  let "?x < b" = "a < b"

  have "a < b"  (is "?lhs < ?rhs")
  proof -
    let "?lhs < ?rhs" = ?thesis



  {
    assume A
    have B sorry
  }
  note `A \<Longrightarrow> B`

  have "\<And>x::'a. B x" by fact

end
end
