signature BASIC_RIPPLE = 
sig
end

structure BasicRipple = 
struct
  exception ripple_exp of string;
  val atomic_tracing = LoggingHandler.logging "GOALTYPE"
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

(*
  fun ripple_subst_tac ctxt i thm = 
   let 
    val sg = 
      Thm.prop_of thm 
      |> (fn t => Logic.get_goal t i) 
      |> TermFeatures.fix_alls_in_term;
    val hyps  = Logic.strip_imp_prems sg |> map TermFeatures.fix_alls_in_term
    val goal = Logic.strip_imp_concl sg |> TermFeatures.fix_alls_in_term
    val skel = filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps |> hd     
    val wrules = get_matched_wrules (Proof_Context.theory_of ctxt) goal
    val params =  
      let
        fun gen_occl' l  i = if i > 0 then gen_occl' ([i] :: l)  (i - 1)  else l;
        fun gen_occL (ll, r) = gen_occl' [] i
      in
        map (fn (x,y) => (]  x, y)) wrules
      end
    fun apply_subst (occ, rule) =   
      EqSubst.eqsubst_tac ctxt occ [(Substset.thm_of_rule rule)] i thm |> Seq.hd |> Seq.single
   in 
     Seq.maps apply_subst (Seq.of_list params) 
     |> (fn x => (atomic_tracing ("rippling: " ^ Int.toString (length(Seq.list_of x))) ; x)) 
   end
*)

  fun ripple_tac ctxt i thm = 
  let 
    val _ = atomic_tracing "****call ripple_tac****";
    val sg = 
      Thm.prop_of thm 
      |> (fn t => Logic.get_goal t i) 
      |> TermFeatures.fix_alls_in_term;
    val hyps  = Logic.strip_imp_prems sg |> map TermFeatures.fix_alls_as_var
    val goal = Logic.strip_imp_concl sg (*|> TermFeatures.fix_alls_in_term*)
    val _ = Pretty.chunks ([Pretty.str "hyps in rippling: "] @ (map (Syntax.pretty_term ctxt) hyps)) 
           |> Pretty.string_of |> atomic_tracing
    val _ = Pretty.chunks ([Pretty.str "goal in rippling: "] @ [((Syntax.pretty_term ctxt goal))]) 
           |> Pretty.string_of |> atomic_tracing
    val skel = filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps |> hd (* only get the first embedding *)
    val _ = Pretty.chunks ([Pretty.str "skel in rippling: "] @ [((Syntax.pretty_term ctxt skel))]) 
           |> Pretty.string_of |> atomic_tracing
    val wrules = get_matched_wrules ctxt goal
    val params = TermFeatures.get_decreased_measure_params ctxt skel wrules goal;
    val pretty_params = map TermFeatures.Data.pretty_subst_params params;
    val _ = atomic_tracing ("**** apply rippling ****: " ^ (Pretty.string_of (Pretty.chunks pretty_params)))
    fun pre_ripple_tac (occ, rule) =   
      EqSubst.eqsubst_tac ctxt occ [(Substset.thm_of_rule rule)] i thm |> Seq.hd |> Seq.single
  in 
    Seq.maps pre_ripple_tac (Seq.of_list params) 
    |> (fn x => (atomic_tracing ("rippling: " ^ Int.toString (length(Seq.list_of x))) ; x))
  end
    
end;
