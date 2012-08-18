
(* FIXME: Make into fuctor taking a lemma_conj_data as parameter *)

structure LemmaSpec = 
struct

(* -------------------------------------------------------------------- *)
(* ---- Exploring projections of a term with meta-variables        ---- *)
(* -------------------------------------------------------------------- *)

exception proj_exp of Term.term;

(* Assume z is a zipper at a Var. Returns a list of instenvs for projecting
the variable onto different args *)
fun project thy (n,ty) ienv =
    let 
      val (tys,resty) = Term.strip_type ty
                        
      fun mkabs [] i abst = abst 
        | mkabs (ty::tys) i abst = 
          mkabs tys (i+1) (Abs("argabs"^Int.toString i ,ty, abst))
      fun mk_bounds _ [] = []
        | mk_bounds i (typ::typs) = 
          let
            val ienv'= snd (TypUnify.unify (typ, resty) ienv) 
          in
            ((Bound i), ienv')::(mk_bounds (i+1) typs) 
          end
          handle TypUnify.TUNIFY => (mk_bounds (i+1) typs) 
                                    
      val poss_projs  = map (fn (b,ienv') => (mkabs (rev tys) 0 b, ienv')) 
                            (mk_bounds 0 (rev tys))
    in
      map 
        (fn (var_inst,ienv') => 
         InstEnv.add_var_inst (n, (InstEnv.inst_typ_tvars ienv' ty, var_inst)) ienv')
        poss_projs
    end;


(* this thing produces a list of instantiation environment,
   each combining different projections for the meta-varaibles in the
   term. *)
fun projections_of_vars thy ienv t = 
    Seq.of_list 
       (Var.NTab.fold (fn nty => fn envs => maps (project thy nty) envs) 
                     (Trm.trm_var_tab_of t) [ienv])
    handle InstEnv.bad_ienv_exp x => raise proj_exp t;


(* Get the possible projections of meta-variables in the goal,
as Trm -types. *)

(*fun proj_trms_pplan pplan goal = 
    let 
      val t = Prf.get_ndname_ctrm pplan goal
      val ienv  = PPlan.get_ienv pplan
    in
      Seq.map (fn env => InstEnv.inst_trm env t)
              (projections_of_vars (PPlan.get_theory pplan) ienv t)
    end;
*)
fun proj_trms_pplan init_ienv pplan goal = 
    let 
      (* Make sure any previous instantiations in init_ienv are applied to t *)
      val t = InstEnv.inst_trm init_ienv (Prf.get_ndname_ctrm pplan goal)
      (*val ienv  = PPlan.get_ienv pplan*)
    in
      Seq.map (fn env => InstEnv.inst_trm env t)
              (projections_of_vars (PPlan.get_theory pplan) init_ienv t)
    end;

fun proj_ienv_pplan init_ienv pplan goal = 
    let 
      (* Make sure any previous instantiations in init_ienv are applied to t *)
      val t = InstEnv.inst_trm init_ienv (Prf.get_ndname_ctrm pplan goal)
    in
      projections_of_vars (PPlan.get_theory pplan) init_ienv t
    end;
(*val proj_trms_rst = proj_trms_pplan o RState.get_pplan; *)

fun expl_projections goal rst = 
    let
      val ppl = RState.get_pplan rst
      val ienv = PPlan.get_ienv ppl
      val t = RstPP.goal_concl rst goal
    in
      RTechnEnv.givename (RstName.str ("Exploring projections on goal: "^goal))
                         (fn rst' =>
                             Seq.map (fn env => RState.set_pplan (Prf.inst_prf env ppl) 
                                                                 (RState.set_rtechn NONE rst'))
                                     (projections_of_vars (RstPP.get_theory rst') ienv t)) 
                         rst
    end;
  
(* -------------------------------------------------------------------- *)
(* ----   Speculate initial schematic lemma                        ---- *)
(* -------------------------------------------------------------------- *)

(* Speculate lemmas for an equational goal. We speculate two lemmas
for each skeleton. One lemma is for the blocked rhs and one for the 
blocked lhs *)
(* UNUSED: 
fun lemmaspec_eq skels goal rst =
    let 
      val ppl = RState.get_pplan rst
      (*val ctxt = Prf.get_ndname_cx ppl goal*)
      val goal_t = RstPP.goal_concl rst goal
      val goal_zip = Zipper.mktop goal_t
      val goal_params =  Trm.TrmParams.get_plist (Trm.params_of goal_t)                  
                     
      val old_metavars = RstPP.get_ienv rst
      val thy = RstPP.get_theory rst
              
              
      val skel_zips = map Zipper.mktop skels
                  
                  
      val lhs = Subst.move_to_lhs_of_eq goal_zip
      val rhs = Subst.move_to_rhs_of_eq goal_zip
              
      (* Make two lists, one for skeletons of left side, one for right sides. Removing possible duplicates. *)
      fun split (lefts, rights) [] = (lefts, rights)
          | split (lefts, rights) (s::skels) = 
            split ((Zipper.trm (Subst.move_to_lhs_of_eq s))::lefts,
                   (Zipper.trm (Subst.move_to_rhs_of_eq s))::rights)
                  skels;
          
      val (left_skels, right_skels) = 
      let 
        val (ls,rs) = split ([],[]) skel_zips 
        val rm_dup = Library.distinct (fn (t1,t2) => Trm.trm_name_eq t1 t2)
      in 
        (rm_dup ls, rm_dup rs)
      end;

      (*    val skel_sides = map (fn z => ( Zipper.trm (Subst.move_to_lhs_of_eq z), 
                                            Zipper.trm (Subst.move_to_rhs_of_eq z))) 
                                 skel_zips
       *)
          
      (* NOTE: Assuming that there is and OR choice between the left and right lemmas, they might use the
                                                                        same variable names here. *) 
      val init_lefts = map (snd o MetaVarLib.insert_metavars old_metavars goal_params) left_skels
      val init_rights = map (snd o MetaVarLib.insert_metavars old_metavars goal_params) right_skels
                    
      (*
       val init_sides = 
           map (fn (left, right) => 
                let 
                  val (metavars_l, l_side) = 
                      metaterm_of old_metavars thy goal_params left
                in
                  (l_side, snd (metaterm_of metavars_l thy goal_params right))
                end)
               skel_sides
       *)
                    
      val left_lemmas = map (fn left => Zipper.set_trm left rhs) init_lefts;
      val right_lemmas = map (fn right => Zipper.set_trm right
                                                         (Subst.move_to_rhs_of_eq
                                                            (Zipper.goto_top
                                                               (Zipper.set_trm (Zipper.trm rhs) lhs))))
                             init_rights;
          
    (* Pair of scehmatic lemmas for both sides of a blocked equational term *)
    (*            val lemmas = map (fn (left, right) => 
                             (Zipper.set_trm left rhs,
                              Zipper.set_trm right
                                         (Subst.move_to_rhs_of_eq
                                            (Zipper.goto_top
                                                 (Zipper.set_trm (Zipper.trm rhs) lhs))))
                         ) init_sides
     *)

    in
      map Zipper.top_trm (left_lemmas @ right_lemmas)
    (*map (fn (l,r) => [Zipper.top_trm l, Zipper.top_trm r]) lemmas *)
    end;
*)
(* Speculate a lemma for a term that isn't an equation *)

fun move_below_Trueprop z =
    (case Zipper.trm z 
      of (Const("HOL.Trueprop",ty)$x) => 
          move_below_Trueprop (Zipper.move_down_right z)
       | _ => z);


(* Build a lemma for an non-equality. The lemma is still and equality though *)
(* UNUSED: 
fun lemmaspec_non_eq skels goal rst =
    let 
      val ppl = RState.get_pplan rst
      
      val goal_t = RstPP.goal_concl rst goal
      val typ = Term.type_of goal_t

      (* move below Trueprop*)
      val goal_zip = move_below_Trueprop (Zipper.mktop goal_t)

      val goal_params =  Trm.TrmParams.get_plist (Trm.params_of goal_t)                                 
      val old_metavars = RstPP.get_ienv rst
      val thy = RstPP.get_theory rst

      val skel_zips = map (move_below_Trueprop o Zipper.mktop) skels

      (* The right hand sides*)
      val meta_trms = map (fn z => MetaVarLib.insert_metavars old_metavars goal_params 
                                               (Zipper.trm z)) 
                          skel_zips
      fun mk_lem rhs = 
          Zipper.top_trm (Zipper.set_trm (HOL_LemmaConjData.mk_eq (Zipper.trm goal_zip, rhs)) 
                                     goal_zip);
    in
      (* Note: this is logic dependent. Should we abstract this somehow?
         But lemma-speculation does on other hand not make sense
         without Higher-order *)
      map (mk_lem) (map snd meta_trms)
    end;
 *)
(* Unused: 
fun lemmaspec skels goal rst =
    let
      val goal_zip = Zipper.mktop (RstPP.goal_concl rst goal)           
    in
      (* Check if this is and equality *)
      case (Subst.move_to_concl_eq goal_zip) of
        SOME z => lemmaspec_eq skels goal rst      
      | NONE =>  lemmaspec_non_eq skels goal rst
           
    end;
*)


(* -------------------------------------------------------------------- *)
(*      Lemma Speculation using eterms to speculate alternative lemmas  *)
(*      that will rewrite some wave-front of a the goal                 *)
(* -------------------------------------------------------------------- *)


(* If this eterm represents an equation, give back (LHS,RHS) as a pair *)
fun left_right_of_eterm (Ectxt.eApp (a, ar)) =
    (case a of
       Ectxt.eConst (("HOL.Trueprop", _), _) =>
       left_right_of_eterm ar
     | Ectxt.eApp ((Ectxt.eConst (("HOL.eq", _), _)), al) => SOME (al,ar)
     | _ => NONE) 
  | left_right_of_eterm _ = NONE;
    

(* possible FIXME: exclude subterms of function type? *)
(* It's supposed to go through an embedding term, (of the blocked goal)
   and select sub-terms that are candidates for being unblocked
   by a speculated lemma. That means that they have to contain at
   least one wave-front to unblock.
e.g. 
et = rotate (len z) (embWF (embWH (z @ embSVar ?ab aa) @ [a]))
gives back: 
(true, 
 [rotate (len z) (embWF (embWH (z @ embSVar ?ab aa) @ [a])), 
  embWF (embWH (z @ embSVar ?ab aa) @ [a])])
*)
fun lem_subtrms_aux (et as Ectxt.eApp _) = 
    let 
      val (ehd, etl) = Ectxt.dest_app et
      val ts = map lem_subtrms_aux etl
      val ts2 = (maps snd ts);
      val wf_here = 
          case Ectxt.get_top_wf ehd of 
            (* check below if no wf here *)
            NONE => false
          | _ => true
      val wf_below = List.exists I (map fst ts)
    in
      (wf_here orelse wf_below, 
       if wf_here then
         et :: (if wf_below then [ETerm.set_top_wf NONE et] else []) @ ts2
       else 
         if wf_below then et :: ts2
         else ts2)
    end
  | lem_subtrms_aux (Ectxt.eAbs((s,y,et),wf)) = 
    let 
      val wf_here = Option.isSome wf; 
      val (has_wf_down, et1s) = lem_subtrms_aux et
    in 
      if wf_here then
        if has_wf_down then 
          (true, (Ectxt.eAbs((s,y,et),wf)) 
                 :: (Ectxt.eAbs((s,y,et), NONE)) 
                 :: et1s)
        else (true, [(Ectxt.eAbs((s,y,et),wf))])
      else
        if has_wf_down then 
          (true, Ectxt.eAbs((s,y,et),wf)::et1s)
        else (false, [])
    end
  (* probably want to recurse into the sub-embedding... but would need
  to work on embed.T, not just eterms. what to do... ? *)
  | lem_subtrms_aux (Ectxt.eIntoBound ((en,i),wf)) = 
    (Option.isSome wf, [])
  (* Don't want skeleton-subterms that's just a constant or variable *)
  | lem_subtrms_aux ((Ectxt.eConst (_,wf))) = 
    (Option.isSome wf, [])
  (* do we want to do something with relational differences? *) 
  | lem_subtrms_aux (Ectxt.eRelFree (_,wf)) = 
    (Option.isSome wf, [])
  | lem_subtrms_aux (Ectxt.eBound (d,wf)) = 
    (Option.isSome wf, []) 
  (* Not sure what to do with sinks *)
  | lem_subtrms_aux (Ectxt.eSrcVar(_, wf)) = 
    (Option.isSome wf, [])
  | lem_subtrms_aux (Ectxt.eDestVar (_,wf)) = 
    (Option.isSome wf, []);


 
fun lem_subtrms e = 
      lem_subtrms_aux (Embed.get_eterm e)
      |> snd
      (*The subterms that are candiadates to be unblocked may contain bound variables,
        but not their binders, filter these out. *)
      |> filter (fn et => 
                    let 
                      val t = Embed.src (Embed.set_eterm et e)
                    in
                      null (Term.loose_bnos t)
                      andalso 
                      (case t of (_$_) => true
                                | (Abs _) => true
                                | _ => false)
                    end)
      |> map (fn et => Embed.set_eterm et e);

exception mk_lemma_exp of (string * Term.typ) list * DB_Embed.T

fun mk_lemma goal_params e = 
     let 
        val lhs = (Embed.tgt e) (* question from lucas: does this need to be 
                                 instantiated in the case of having meta-vars 
                                 that instantiate types etc *)
        val rhs = (Embed.src e)
        (*val mvar_rhs = snd (MetaVarLib.insert_metavars old_mvars goal_params rhs) *)
        val mvar_rhs = snd (MetaVarLib.insert_metavars_embedding 
                              goal_params e)
    (*  val _ = Thm.cterm_of (InstEnv.get_theory (Embed.get_ienv e)) lhs;
        val _ = Thm.cterm_of (InstEnv.get_theory (Embed.get_ienv e)) mvar_rhs;
        val _ = Thm.cterm_of (InstEnv.get_theory (Embed.get_ienv e)) (HOL_LemmaConjData.mk_eq (lhs, mvar_rhs)); *)
     in
       if (lhs = rhs) then NONE (* Exclude silly `identity' lemmas, should have at least one wf on lhs. *)
       else SOME (HOL_LemmaConjData.mk_eq (lhs, mvar_rhs))
     end
    handle Term.TERM x => raise mk_lemma_exp (goal_params, e);
(* | _ => raise mk_lemma_exp (goal_params, e); *)

val sort_size = 
    Library.sort 
      (fn (t1,t2) => Library.int_ord 
                       ((Term.size_of_term t1), (Term.size_of_term t2)));

exception lemmaspec2_exp of Embed.T list * PPlan.gname;

(* Remove a trueprop from an embedding-term *)
fun dest_Trueprop_eterm (a as (Ectxt.eApp (al, ar))) =
    (case al of
       Ectxt.eConst (("HOL.Trueprop", _), _) => ar
     | _ => a)
  | dest_Trueprop_eterm a = a;

(* Speculation to construct a schematic lemma that will rewrite
some subterm (containing at least one wave-front) in the goal. *)
fun lemmaspec2 embedings goal rst =  
    let 
      val goal_params =  Trm.TrmParams.get_plist 
                             (Trm.params_of (RstPP.goal_concl rst goal))   
      val old_mvars = RstPP.get_ienv rst;
    in
      (maps (fn e => 
                let 
                  val eterm = Embed.get_eterm e in
                  case (left_right_of_eterm eterm) of
                      NONE => 
                      [Embed.set_eterm (dest_Trueprop_eterm eterm) e]  (* Goal isn't an equation,*)
                                                                       (* so rm Trueprop          *) 
                    | SOME (el, er) => [Embed.set_eterm el e, (* Truprop removed by               *)
                                       Embed.set_eterm er e]  (* left_right_of_eterm in this case *)
                end)
           embedings) (* Goal is equation *)
    (* Might get duplicates from splitting equations, remove *)
    (* IMPROVE: from lucas: write an equality function for embeddings! *)
        |> Library.distinct (fn (el,er) => (Embed.mk_prettyterm el) = (Embed.mk_prettyterm er))
        |> maps lem_subtrms
        |> map_filter (mk_lemma goal_params)
   (* FIXED: by lucas: using embeddings directly removes these
      already...  Remove duplicates from the same wave-front have diff
      directions, Moa: can you check/ask me about this. *)
        |> Library.distinct (fn (l1,l2) => l1 = l2)
        |> sort_size
        |> map HOLogic.mk_Trueprop
    end
   (* handle *** _ => raise lemmaspec2_exp (embedings, goal); *)

fun spec_imp_lemma embeddings goal rst = 
    let 
       val goal_zip = Zipper.mktop (RstPP.goal_concl rst goal)
    in
      case (Subst.move_to_concl_eq goal_zip) of
        SOME z => [] (* Only speculate implication if isn't equation *)
      | NONE => map Embed.src embeddings
                    |> map (fn skel_inst => 
                               HOLogic.mk_imp (skel_inst, 
                                               Zipper.trm (move_below_Trueprop goal_zip)))
                    |> map HOLogic.mk_Trueprop
    end;

(*
val rst = ripple ("a","rev(rev(x) @ y) = rev(y) @ x");
val ms = RippleCInfo.measures_of rst "m";
val atrms = map RippleSkel.RippleMeasure.aterm_of ms;
val a = hd atrms;
val (al,ar) = the (lr a);
 Trm.print (the_context()) (RippleATerms.pterm_of al);
  Trm.print (the_context()) (RippleATerms.pterm_of ar);
val v = snd  (LemmaSpec.lem_subtrms (ar,[]));
val v2 = snd  (LemmaSpec.lem_subtrms (al,[]));

map (Trm.print (the_context()) o RippleATerms.pterm_of) v;
map (Trm.print (the_context()) o RippleATerms.pterm_of) v2;
map (Trm.print (the_context()) o RippleATerms.inst_skel_term) v2;
*)
end;
