structure SimpleGT_Lib  = 
struct
  local open LoggingHandler TermFeatures in
  fun GT_NOT gt ctxt tl t : bool = not (gt ctxt tl t);
  fun GT_OR gt_l ctxt tl t : bool = exists I (map (fn f => f ctxt tl t) gt_l)
(**************************************************************
  A List of Simple GT: ctxt -> assms -> concl -> bool 
  GT_top_symbol (symbol_list : string list)
  GT_has_symbol (symbol_list : string list)
  GT_hyp_embeds
  GT_is_inductable
  GT_measure_reduces
  GT_is_rippled
  GT_hyp_subst
  GT_hyp_bck_res
**************************************************************)
    fun top_level' symbol g = 
      case top_level_str g of
         NONE => false
       | SOME v => 
          (let val _ = logging "GOALTYPE" (v ^ " " ^  (ignore_module symbol)) in 
           v = (ignore_module symbol) end);
    
    fun top_level symbol_list g = map (fn symbol => top_level' symbol g) symbol_list;
    fun GT_top_symbol symbol_list _ _ g =  exists I (top_level symbol_list g)

    fun GT_has_symbol symbol _ _ g = has_constants symbol g;
 
    fun get_hyps_and_goal ptrm = 
      let
        val sg = ptrm |> fix_alls_in_term
        val hyps  = Logic.strip_imp_prems sg |> map fix_alls_as_var 
        val goal = Logic.strip_imp_concl sg (*|> TF.fix_alls_as_var*)
 (* TODO: this may cause some problem due to the same binding and name in both hyps and goal *)
      in
        (hyps, goal)
      end

    fun GT_hyp_embeds ctxt hyps goal =
      let 
         val hyps' = map fix_alls_in_term hyps
         val _ = Pretty.chunks ([Pretty.str "hyps in hyp_embed: "] @ (map (Syntax.pretty_term ctxt) hyps')) 
                 |> Pretty.string_of |> logging "GOALTYPE"
         val _ = Pretty.chunks ([Pretty.str "goal in hyp_embed: "] @ [((Syntax.pretty_term ctxt goal))]) 
                 |> Pretty.string_of |> logging "GOALTYPE"
      in 
        exists (fn hyp => ctxt_embeds ctxt hyp goal) hyps'
        |> (fn x => if x then (logging "GOALTYPE" "find embeddings !"; x) 
            else  (logging "GOALTYPE" "no embeddings !"; x))
      end;

    fun GT_is_inductable ctxt _ goal =
      let
         val thy =  Proof_Context.theory_of ctxt
      in
        is_inductable_structural thy goal
      end

    fun GT_measure_reduces ctxt hyps goal =
      let
         (*val thy = #pctxt pn |> Proof_Context.theory_of*)
         val hyps' = map fix_alls_in_term hyps
         val embedd_hyp =
          filter (fn hyp => ctxt_embeds ctxt  hyp goal) hyps' (* use the hyp with no bindings *)
          |> hd (* only get the first embedding *)
         val wrules = BasicRipple.get_matched_wrules ctxt goal
      in
        has_measure_decreasing_rules ctxt embedd_hyp wrules goal
        |> (fn x => if x then (logging "GOALTYPE" "find decreased measure !"; x) 
            else  (logging "GOALTYPE" "no decreased measure !"; x))
      end

    (* embedding is a subterm of goal, or if the embedding is eq type then 
      test if there is no wrule and either lhs or rhs of the embedding is a subterm of the goal*)
    fun GT_is_rippled ctxt hyps goal  = 
      let
        val thy = ctxt |> Proof_Context.theory_of
        val hyps' = map fix_alls_in_term hyps
        val embedd_hyp =
          filter (fn hyp => ctxt_embeds ctxt hyp goal) hyps'
          |> hd (* only get the first embedding *)
        fun mk_meta_eq_trm thry t = Thm.cterm_of thry t 
          |> Thm.trivial |> safe_mk_meta_eq |> Thm.concl_of;
        fun get_lhs_rhs thry trm = Logic.dest_equals (mk_meta_eq_trm thry trm) |> SOME
        handle _ => NONE;
        fun weak_fert trm = 
          case get_lhs_rhs thy trm of NONE => false
             | SOME(l,r) => (is_subterm thy goal l orelse is_subterm thy goal r)
      in
        if (is_subterm thy goal embedd_hyp) orelse (not(GT_measure_reduces ctxt hyps goal) andalso (weak_fert embedd_hyp))
        then true
        else false            
    end

    fun GT_hyp_subst ctxt hyps goal  = 
      let 
        val thy = ctxt |> Proof_Context.theory_of
        val hyps' = map fix_alls_in_term hyps
        val embedd_hyp =
          filter (fn hyp => ctxt_embeds ctxt hyp goal) hyps'
          |> hd (* only get the first embedding *)
        fun mk_meta_eq_trm thry t = Thm.cterm_of thry t 
          |> Thm.trivial |> safe_mk_meta_eq |> Thm.concl_of;
        fun get_lhs_rhs thry trm = Logic.dest_equals (mk_meta_eq_trm thry trm) |> SOME
        handle _ => NONE;
        fun weak_fert trm = 
          case get_lhs_rhs thy trm of NONE => false
             | SOME(l,r) => (is_subterm thy goal l orelse is_subterm thy goal r)
      in
        (weak_fert embedd_hyp)         
    end

    fun GT_hyp_bck_res ctxt hyps goal = 
      let 
        val thy = ctxt |> Proof_Context.theory_of
        val hyps' = map fix_alls_in_term hyps
        val embedd_hyp =
          filter (fn hyp => ctxt_embeds ctxt hyp goal) hyps'
          |> hd (* only get the first embedding *)
        val _ = Pretty.chunks ([Pretty.str "unif goal: "] @ 
                               [((Syntax.pretty_term ctxt goal))] @ 
                               [Pretty.str "with embeds: "] @
                               [((Syntax.pretty_term ctxt embedd_hyp))]
                               ) 
        |> Pretty.string_of |> logging "GOALTYPE"
      in
        is_subterm thy goal embedd_hyp
      end
   
  end (* local open *)
end(* struct *);

open SimpleGT_Lib;
