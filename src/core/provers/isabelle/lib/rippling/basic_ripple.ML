signature BASIC_RIPPLE = 
sig
end

structure BasicRipple = 
struct
  exception ripple_exp of string;
  val atomic_tracing = LoggingHandler.logging "TACTIC"
  (*val atomic_tracing = writeln*)
  fun get_wrules ctxt = 
    let 
      val thy = (Proof_Context.theory_of ctxt);
      val named_thms' = (WRule.get ctxt) |> map (fn thm => (Thm.derivation_name thm, thm))
      val named_thms = 
        named_thms' 
        |> maps (fn (n,t) => [(n, t),(n^"(sym)", t RS @{thm sym})])
        |> filter (fn (_, t) => 
                    let val (lhs, rhs) = Substset.strip_lhs_rhs t in
                    not(TermFeatures.is_subterm thy rhs lhs) end)
      val rules = map (fn m => Substset.rule_of_thm m |> (fn SOME x => x)) named_thms  
    in
      fold (Substset.add) rules Substset.empty 
    end

  fun get_matched_wrules ctxt trm = Substset.match (Proof_Context.theory_of ctxt) (get_wrules ctxt) trm;


  fun ripple_tac ctxt i thm = 
  let 
    (*val _ = atomic_tracing "****call ripple_tac****";*)
    val sg = 
      Thm.prop_of thm 
      |> (fn t => Logic.get_goal t i) 
      |> TermFeatures.fix_alls_in_term;
    val hyps  = Logic.strip_imp_prems sg |> map TermFeatures.fix_alls_as_var
    val goal = Logic.strip_imp_concl sg (*|> TermFeatures.fix_alls_in_term*)
   (* val _ = str_chunks ([ "hyps in rippling: "] @ (map (Prover.string_of_trm ctxt) hyps)) 
            |> atomic_tracing
    val _ = str_chunks (["hyps in rippling: "] @ (map (Prover.string_of_trm ctxt) hyps)) 
           |> atomic_tracing
    val _ = str_chunks (["goal in rippling: "] @ [((Prover.string_of_trm ctxt goal))])|> atomic_tracing*)
    val skel = filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps |> hd (* only get the first embedding *)
    val _ = str_chunks ([ "skel in rippling: "] @ [((Prover.string_of_trm ctxt skel))])|> atomic_tracing
    val wrules = get_matched_wrules ctxt goal
    val params = TermFeatures.get_decreased_measure_params ctxt skel wrules goal;
(*    val pretty_params = map TermFeatures.Data.pretty_subst_params params;
    val _ = atomic_tracing ("**** apply rippling ****: " ^ (Pretty.string_of (Pretty.chunks pretty_params)))*)
    fun ripple_tac0 (occ, rule) =   
      EqSubst.eqsubst_tac ctxt occ [(Substset.thm_of_rule rule)] i thm 
   in 
    Seq.maps ripple_tac0 (Seq.of_list params) 
    (*|> (fn x => (atomic_tracing ("rippling: " ^ Int.toString (length(Seq.list_of x))) ; x))*)
  end

  fun gen_occl' l  i = if i > 0 then gen_occl' ([i] :: l)  (i - 1)  else l;
  val gen_occl = gen_occl' [];

(* this version only apply the matched rules but does not check measurement *)
  fun ripple_subst_tac0 ctxt i thm  = 
  let 
    (*val _ = atomic_tracing "****call ripple_tac****";*)
    val sg =  Thm.cprem_of thm i |> Thm.term_of;
    val hyps  = Logic.strip_imp_prems sg 
    val goal = Logic.strip_imp_concl sg 
    (*val _ = str_chunks ([ "hyps in rippling: "] @ (map (Prover.string_of_trm ctxt) hyps)) 
            |> atomic_tracing
    val _ = str_chunks (["hyps in rippling: "] @ (map (Prover.string_of_trm ctxt) hyps)) 
           |> atomic_tracing
    val _ = str_chunks (["goal in rippling: "] @ [((Prover.string_of_trm ctxt goal))])|> atomic_tracing *)
    (*val skel = filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps |> hd (* only get the first embedding *)
    val _ = str_blocks ", " ([ "skel in rippling: "] @ [((Prover.string_of_trm ctxt skel))])|> atomic_tracing *)
    val wrules = 
      get_matched_wrules ctxt goal 
      |> map (fn (occ,th) => (gen_occl occ, Substset.thm_of_rule th)) (* thm and a list of occs *)
      |> maps (fn (occs, th) => map (fn occ => (occ, th)) occs)
    val _ = str_blocks ""  ([ "numbers of matched wave rules: "] @ [Int.toString (List.length wrules)])|> atomic_tracing
   in 
    Seq.maps (fn (occ, th) => EqSubst.eqsubst_tac ctxt occ [th] i thm ) (Seq.of_list wrules)
  end

  fun ripple_subst_tac ctxt i st = 
  case SOME (Thm.cprem_of st i) handle THM _ => NONE of
    SOME _ => ripple_subst_tac0 ctxt i st
  | NONE => Seq.empty;
    
end;
