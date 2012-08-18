(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      prf.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Updated:    18 May 2006
    Date:       20 Dec 2005
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Proofs                                                             *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* currently done so that get_isa_thm works - remove in future when
proofs are implemented to be completely conservative *)
signature PRF =
sig
  include APRF;

  exception prf_exp of string;

  (* conjecturing *)
  val conj_term_in_cx_of : gname * Term.term -> gname -> T -> gname * T
  val conj_string_in_cx_of : gname * string -> gname -> T -> gname * T
  val conj_term_at_top : gname * Term.term -> T -> gname * T
  val conj_string_at_top : gname * string -> T -> gname * T
  (* internal conj stuff *)
  val conjecture : RTree.T -> Cx.cxname -> T -> gname * T
  val conj_term_in_cx : gname * Term.term -> Cx.cxname -> T -> gname * T


  (* all and local assumptions *)
  val get_ndname_aasm_ntrms : T -> gname -> (gname * Trm.T) list
  val get_ndname_lasm_ntrms : T -> gname -> (gname * Trm.T) list

  (* get the term of a node *)
  val get_ndname_ltrm : T -> gname -> Trm.T 
  val get_ndname_ftrm : T -> gname -> Trm.T
  val get_ndname_aasms : T -> gname -> gname list
  val get_ndname_lasms : T -> gname -> gname list


  (* rtrees with local and all assumptions *)
  val get_fixed_ndname_wlrtree : T -> gname -> RTree.T
  val get_fixed_ndname_wartree : T -> gname -> RTree.T

  (* varify !! params *)
  val get_ndname_varified_ltrm : T -> gname -> Trm.T
  val get_ndname_varified_lasm_nltrms : T -> gname -> (gname * Trm.T) list
  val get_ndname_varified_aasm_natrms : T -> gname -> (gname * Trm.T) list
  val get_ndname_varified_lasm_nctrms : T -> gname -> (gname * Trm.T) list
  val get_ndname_varified_ctrm : T -> gname -> Trm.T

  (* open goals *)
  val is_open_goal : T -> gname -> bool
  
  (* unification within a proof plan *)
  val new_tvar : TVar.name * Trm.sort -> T -> Var.name * T
  val new_var : Var.name * Trm.typ -> T -> Var.name * T
  val unify_typs : (Trm.typ * Trm.typ) list -> T -> T option
  val unify : (Trm.T * Trm.T) list -> T -> T Seq.seq

  (* making goal theorems from nodes *)
  (* get back theorems (goal is to be proved in/by Isabelle) *)
  val get_fixed_concl_goal_thm : T -> gname -> Thm.thm
  val get_fixed_concl_goal_thm_winst : T -> gname -> Thm.thm
  val get_fixed_local_goal_thm : T -> gname -> Thm.thm
  val get_fixed_full_goal_thm : T -> gname -> Thm.thm

  val get_alled_nd_goal_thm : T -> nd -> Thm.thm
  val get_alled_nd_goal_thm_winst : T -> nd -> Thm.thm

  val get_alled_goal_thm : T -> gname -> Thm.thm
  val get_alled_goal_thm_winst : T -> gname -> Thm.thm

  val mk_fixed_trm_goal_thm : T -> Trm.T -> Thm.thm
  val mk_fixed_trm_goal_thm_winst : T -> Trm.T -> Thm.thm

  (* results for export into Isabelle world have meta-vars fixed *)
  val get_assumed_lthm : T -> gname -> Thm.thm

  (* Quick Hack: uses oracle to make an Isabelle theorem,
     only works if not subgoals - in future will be made fully
     conservative *)
  val get_isa_thm : T -> gname -> Thm.thm

  (* take a result in one context and move it to another context,  
     lifting appropriately *)
  val lift_and_show_above 
      : gname (* lift and show this (G) *)
        -> gname list (* making these asumptions of G into subgoals *)
        -> gname (* in the same context as this goal *)
        -> T -> ((gname * (* new fact name *)
                  gname list) * (* gnames from asssumptions *)
                  T) (* new proof plan with lifted result *)

  (* basic proof rules *) 
  val apply_resol_fwd 
      : (gname * gname) 
        -> gname 
        -> T 
        -> ((gname list (* subgoals *)
             * gname (* new fact *)
            ) * T) Seq.seq

  val apply_rule_thm : Thm.thm -> gname -> T -> (gname list * T) Seq.seq
  val apply_frule_thm : Thm.thm -> gname -> T -> (gname * T) Seq.seq
  val apply_erule_thm : Thm.thm -> gname -> gname -> T -> (gname list * T) Seq.seq

  val apply_subst : gname (* equation name *)
                    -> gname (* result name to apply the equation to *)
                    -> Zipper.T (* where to apply the equation *)
                    -> T (* prf containing result and equation *)
                    -> ((gname (* new result after eq subst *)
                         * gname list) (* subgoals from eq conditions *)
                        * T) Seq.seq


  (* put a theorem into the prf env *)
  val insert_thm : Thm.thm -> T -> gname * T

  (* start a sub method application - restrict open goals so we know
  which subgoals come out of the method application *)
  val start_meth : gname list -> T -> T
  (* end and close submethod application *)
  val end_meth : 
      mname (* method name *)
      -> gname list (* facts that are derived in subprf to be exported *)
      -> gname list (* goal list that are refined in subprf *)
      -> T (* subprf which you have applied start_meth and then more operations to. *)
      -> T (* prf before you applied start_meth *)
      -> (gname list * T) (* new subgoals, prf *)

end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

structure DB_Prf 
= struct
  open APrf;

  exception prf_exp of string;

  (* implicit prf gname *)
  val is_open_goal = Goaln.NSet.contains o get_open_gnames;
  
  (* unification within a prf env *)
  fun unify_typs tys p = 
      (SOME (inst_prf (fold (snd oo TypUnify.unify) tys
                            (get_ienv p))
                      p))
      handle TypUnify.TUNIFY => NONE
           | TypUnify.TYPE_MATCH => NONE;

  fun unify ts p = 
      Seq.map (fn ienv2 => inst_prf ienv2 p) (MyUnify.unifiers (get_ienv p, ts));

  fun new_tvar nsrt p = 
      let val (n2,ienv2) = InstEnv.new_uninst_tvar nsrt (get_ienv p)
      in (n2,set_ienv ienv2 p) end;

  fun new_var nty p = 
      let val (n2,ienv2) = InstEnv.new_uninst_var nty (get_ienv p)
      in (n2,set_ienv ienv2 p) end;

(* given an Isabelle term (has prems and a single concl) find params 
   and asms *)
(* IMPROVE: don't need to re-check adding of all frees in t for each
assumption; done in add_fixedt... *)
  fun split_isatrm ptab t = 
      let val (ps as (newps,allps),t2) = Cx.add_fixedt_to_ptab ptab t
      in (ps, (Trm.prems_of t2, Trm.concl_of t2)) end;

(* make a result tree for an Isabelle term *)
  fun rtree_of_isatrm ptab name t = 
      let val ((newps,allps),(asms,concl)) = split_isatrm ptab t
      in RTree.mk name newps concl (map (rtree_of_isatrm allps name) asms)
      end;

  fun get_ndname_varified_ctrm p gname = 
      let
        val rt = rtree_of_gname p gname
        val rt2 = snd (RTree.varify_top_fixes (get_ienv p) rt)
      in RTree.trm_of rt2 end;

(* get the varified local asumptions of this goalname - 
  This makes the top level parameters into meta vars. *)
fun mk_varified_rtrees p rtrees = 
    fold (fn rt => fn (ienv,asms2) => 
                      let val (ienv2, rt2) = 
                              RTree.varify_top_fixes ienv rt
                      in (ienv2,rt2::asms2) end)
         rtrees (get_ienv p,[]);

  val get_result_aasm_trms = 
      map RTree.trm_of oo get_result_aasm_rtrees;
    
  val get_result_aasm_ntrms = 
      map (fn rt => (RTree.get_name rt, RTree.trm_of rt))
        oo get_result_aasm_rtrees

  fun get_result_varified_aasm_natrms ffp r = 
      map (fn rt => (RTree.get_name rt, RTree.trm_of rt)) 
          (snd (mk_varified_rtrees ffp (get_result_aasm_rtrees ffp r)))

  val get_result_lasm_trms = 
      map RTree.trm_of oo get_result_lasm_rtrees;

  val get_result_lasm_ntrms = 
      map (fn rt => (RTree.get_name rt, RTree.trm_of rt))
          oo get_result_lasm_rtrees

  fun get_result_varified_lasm_nltrms ffp r = 
      map (fn rt => (RTree.get_name rt, RTree.trm_of rt)) 
          (snd (mk_varified_rtrees ffp (get_result_lasm_rtrees ffp r)))

  fun get_ndname_lasm_ntrms p = 
      get_result_lasm_ntrms p o get_result p;

  fun get_ndname_aasm_ntrms p = 
      get_result_aasm_ntrms p o get_result p;

(* get a single varified result *)
  fun get_ndname_varified_ltrm p gname = 
      let
        val rt = rtree_of_gname_wlasms p gname;
        val rt2 = snd (RTree.varify_top_fixes (get_ienv p) rt)
      in RTree.trm_of rt2 end;
 
  (* rtrees with from ndnames with local params as Frees *)
  fun get_fixed_ndname_wlrtree p = 
      RTree.drop_lfixes o rtree_of_result_wlasms p o get_result p;
  fun get_fixed_ndname_wartree p = 
      RTree.drop_lfixes o rtree_of_result_waasms p o get_result p;


  val get_ndname_aasms = 
      Goaln.NSet.list_of oo get_ndname_aasmstab;
  val get_ndname_lasms  = 
      Goaln.NSet.list_of oo get_ndname_lasmstab;


  (* get name and varified assumption terms  *)
  fun get_ndname_varified_lasm_nltrms p = 
      get_result_varified_lasm_nltrms p o get_result p;
(* 
  fun get_ndname_varified_lasm_natrms p = 
      get_result_varified_lasm_natrms p o get_result p;
*)
(*   fun get_ndname_varified_aasm_nltrms p = 
      get_result_varified_aasm_nltrms p o get_result p;
*)

  fun get_ndname_varified_aasm_natrms p = 
      get_result_varified_aasm_natrms p o get_result p;

  fun get_ndname_varified_aasm_nctrms p n = 
      map (fn n2 => (n2,get_ndname_varified_ctrm p n)) 
          (get_ndname_aasms p n);

  fun get_ndname_varified_lasm_nctrms p n = 
      map (fn n2 => (n2,get_ndname_varified_ctrm p n2)) 
          (get_ndname_lasms p n);

  (* get term with local context assumptions *)
  fun get_ndname_ltrm p = 
      (RTree.trm_of o rtree_of_result_wlasms p) o get_result p;
  (* get term with all assumptions *)
  fun get_ndname_ftrm p = 
      (RTree.trm_of o rtree_of_result_waasms p) o get_result p;

  (* get goal theorems from proof, including flexes *)
  fun get_assumed_lthm p nid = 
      Thm.assume (Thm.cterm_of (get_theory p) (get_ndname_ltrm p nid));

  (* output goal thms have protected conclusion *)
  (* get goal theorems from proof, including flexes *)
  fun get_alled_nd_goal_thm p nd = 
      let 
        val cx = get_nd_cx p nd;
        val params = Cx.get_fixed_trm_ps cx;
        val flexes = InstEnv.get_flexes (get_ienv p)
      in
        (Flexes.mk_triv_ff_protected_thm 
           (get_theory p) flexes 
           (Trm.allify_params params (nd_get_trm nd)))
      end;
  fun get_alled_nd_goal_thm_winst p nd = 
      IsaStep.add_openvars_sg_to_thm 
        (get_open_vars p)
        (get_alled_nd_goal_thm p nd);
  fun mk_fixed_trm_goal_thm p t = 
      Flexes.mk_triv_ff_protected_thm 
        (get_theory p) (InstEnv.get_flexes (get_ienv p)) t;
  fun mk_fixed_trm_goal_thm_winst p t = 
      IsaStep.add_openvars_sg_to_thm 
        (get_open_vars p)
        (mk_fixed_trm_goal_thm p t);

      (* implicit goal name *)

 (* IMPROVE: add a check so that the bellow goal thm constructions
 cannot be called on assumptions *)

(* Universal quantifiers for meta-variables *)
  fun get_alled_goal_thm p = 
      get_alled_nd_goal_thm p o get_nd p;
  fun get_alled_goal_thm_winst p = 
      get_alled_nd_goal_thm_winst p o get_nd p;
(* Just conclusion, ? *)
  fun get_fixed_concl_goal_thm p = 
      mk_fixed_trm_goal_thm p o get_ndname_ctrm p;
  fun get_fixed_concl_goal_thm_winst p = 
      mk_fixed_trm_goal_thm_winst p o get_ndname_ctrm p;
(* With local assumptions *)
  fun get_fixed_local_goal_thm p = 
      mk_fixed_trm_goal_thm p o RTree.trm_of o get_fixed_ndname_wlrtree p;
  fun get_fixed_local_goal_thm_winst p = 
      mk_fixed_trm_goal_thm_winst p o RTree.trm_of o get_fixed_ndname_wlrtree p;
(* With all the assumptions *)
  fun get_fixed_full_goal_thm p = 
      mk_fixed_trm_goal_thm p o RTree.trm_of o get_fixed_ndname_wartree p;
  fun get_fixed_full_goal_thm_winst p = 
      mk_fixed_trm_goal_thm_winst p o RTree.trm_of o get_fixed_ndname_wartree p;

  (* the term as it should look from the outside, within its context:
  vars become new params, old params, all params, and table saying how
  varaibles were changed into params *)
  fun mk_local_export_trm ptab t = 
      let
        val localvars = Var.NTab.list_of (Trm.trm_var_tab_of t);
        val (t2, (vs_to_ps, ptab2)) = 
            (List.foldr 
               (fn (v as ((s,i),ty),(t,(ns,ptab))) => 
                   let val (s2,ptab2) = Trm.TrmParams.add1 (s,ty) ptab
                   in
                     (Term.subst_Vars [((s,i),Trm.mk_free (s2,ty))] t,
                      (Var.NTab.update ((s,i),(s2,ty)) ns, 
                       ptab2))
                   end)
               (t,(Var.NTab.empty,ptab))
               localvars);
      in (t2, ptab, vs_to_ps, ptab2) end;

(* 
  (* a is an assumption of wrt_g, make it into an rtree for use with wrt_g *)
  fun get_local_asm_rtree_wrt p wrt_g a = 
      let 
        val ((g_name,g_nd),(gncx as (g_cxname,g_cx))) = get_result p wrt_g
        val (ar as ((a_name,a_nd),(ancx as (a_cxname,a_cx)))) = get_result p a

        val p_cxname = Cx.first_common_ancestor gncx ancx;
        val p_cx = get_cx p p_cxname;
        (* parameters of a_cx not in p. *)
        val local_params = Cx.get_trmps_of_ptab (Cx.params_beyond a_cx p_cx);
        val asm_names = Cx.asms_beyond a_cx p_cx;
      in
        (rtree_of_result_wlasms p ar)
          (* |> RTree.set_local_params local_params *)
      end;

  (* a is an assumption of wrt_g, make it into a thm for use on wrt_g *)
  fun get_isa_asm_thm_wrt p wrt_g a = 
      let 
        val cx = get_nd_cx p nd;
        val params = Cx.get_fixed_trm_ps cx;
        val flexes = InstEnv.get_flexes (get_ienv p)
      in
        (Flexes.mk_triv_ff_protected_thm 
           (get_theory p) flexes 
           (Trm.allify_params params (nd_get_trm nd)))
      end;


      (* let 
        val rtree = get_local_asm_rtree_wrt p wrt_g a
        val t = RTree.trm_of rtree
      in  *)
        (get_fixed_local_goal_thm p a)
          |> (Seq.hd o (SkipProof.cheat_tac (get_theory p)))
          |> (fn thm => thm RS Drule.protectD)
          |> Thm.put_name a;
      (* end; *)
  *)

  (* get the result of the node as a theorem as if it had been proved. *)
(*   fun get_local_export_trm ffp g *)
  fun get_isa_thm p g = 
      let val goalthm = get_alled_goal_thm p g
          val old_quick_and_dirty = !quick_and_dirty;
          val _ = quick_and_dirty := true;
          val thm = if Goaln.NSet.is_empty (get_open_gnames p) then 
             (Seq.hd (Skip_Proof.cheat_tac (get_theory p) goalthm))
               |> (fn thm => thm RS Drule.protectD)
               |> Drule.export_without_context
               |> Thm.put_name_hint g
               else raise ERROR "get_isa_thm: there are still open subgoals"
          val _ = quick_and_dirty := old_quick_and_dirty;
      in thm end;

(* conjecturing *)
fun conjecture_i conjrtree cxname p = 
    let
      val ncx = (cxname, get_cx p cxname)
      val rtree = RTree.put_in_ncx ncx conjrtree
      val (rt,p2) = conjecture_rtree rtree cxname p 
    in (rt, p2) end;
val conjecture = apfst RTree.get_name ooo conjecture_i;

fun conj_term_in_cx (n,t) cxn p = 
    conjecture (rtree_of_isatrm (Cx.get_fixes (get_cx p cxn)) n t) cxn p;

fun conj_term_in_cx_of (n,t) gn_for_cx p = 
    conj_term_in_cx (n,t) (get_ndname_cxname p gn_for_cx) p;

fun conj_string_in_cx_of (n,s) gn_for_cx p = 
    conj_term_in_cx_of (n,read_prop p s) gn_for_cx p;

fun conj_term_at_top (n, t) p = 
    conj_term_in_cx (n, t) (get_top_cxname p) p;
fun conj_string_at_top (n, s) p = 
    conj_term_at_top (n, read_prop p s) p;

(* closinga goal: remove from open and set method *)
fun close_goal m gname p = 
    close_open_goal_with m gname p;

(* inserting a theorem as a proved fact *)
(* IMPROVE: make typ-vars type params on the inserted theorem *)
(*  handy function! *)
(* 
fun tvar_to_param (a as (vs_to_ps,(newtps,tps))) ((vn as (n,i),srt),tv) = 
    (case TVar.NTab.lookup vs_to_ps vn of 
       NONE => 
       let 
         val (n2, tps2) = Trm.TypParams.NTab.add (n,srt) tps
         val newtps2 = Trm.TypParams.NTab.update (n2,srt) newtps
         val tfree = Trm.mk_tfree (n2,srt)
         val vs_to_ps2 = TVar.NTab.update (vn, tfree) vs_to_ps
       in ((ps_to_vs, (tps2, newtps2)), tfree) end
     | SOME tfree => (a,tfree));
*)
(* FIXME: flex-flex pairs of thm need to be included *)
fun insert_thm_i th p = 
    let 
      (* val n = NameSpace.base (Thm.get_name th); *)
      val (_,t) = th |> Drule.forall_intr_vars |> Thm.prop_of
                     (* rename any left-over typ vars *)
                     |> InstEnv.rename_trm_vars (InstEnv.init_renaming (get_ienv p))
      val conj_rtree = (rtree_of_isatrm Cx.empty_ptab "a" t)
      val (rtree,p2) = 
          p |> conjecture_i conj_rtree (get_top_cxname p);
    in
      (rtree, p2 |> (close_goal (methkind_thm th,[]) 
                                (RTree.get_name rtree)))
    end;
val insert_thm = apfst RTree.get_name oo insert_thm_i; 

  (* helper function for addfst thing to a list *)
fun addfst_to_list f (l, x) = 
    let val (a,x2) = (f x) in (a::l, x2) end;


(* boxing up bits of a proof *)
fun start_meth gnames p = 
    let val _ = map (assert_is_open p) gnames
        (* val _ = Pretty.writeln 
                  (Pretty.block [Pretty.str "start_meth: ",
                                 Pretty.list 
                                 "[" "]" 
                                 (map Goaln.pretty_name gnames)]) *);
  in set_open_gnames (Goaln.NSet.of_list gnames) p
  end;

(* apply a method - ie box up a subproof, assumes meth gives the
subprf. Note: submethod expansion is associative, and you can go
direct from bottom to top - although because of ML eval order, we do
all intermediate steps. This allows incremental unfolding. 
gnames should be the same as the start_meth goalnames. 
last argument is prf before the start_meth. 
*)
fun end_meth mname newfnames gnames subprf p = 
    let
      (* val _ = Pretty.writeln 
                (Pretty.block [Pretty.str "end_meth: ",
                               Pretty.list 
                                 "[" "]" 
                                 (map Goaln.pretty_name gnames),
                               Pretty.str "; meth: ",
                               Pretty.str mname]
                ); *)
      val (subgoals, p2) = 
          mk_subprf_into_meth mname newfnames gnames subprf p
      (* make sure all uninst vars in subprf, even those only in 
         flex-flexes exist in p - to avoid name clashes and ensure 
         that the ienv is correct for the new super prf *)
      val p3 = 
          p2 |> (set_ienv ((get_ienv p2)
                             |> (InstEnv.merge_uninsts_of_fst 
                                   (get_ienv subprf))
                             |> InstEnv.set_flexes (InstEnv.get_flexes 
                                                      (get_ienv subprf))))
    in (subgoals, p3) end;

(* don't do subprfs. *)
(* fun start_meth gnames p = p;
fun end_meth mname newfnames gnames subprf p = 
    let val (subgoals, p2) = 
            mk_subprf_into_meth mname newfnames gnames subprf p
    in (subgoals,subprf) end;
*)


fun lift_and_show_above rname asmtognames gname p = 
    let 
      val ((newtree, asmgoaltrees), p2) =
          lift_and_show_above_rtree rname asmtognames gname p
    in ((RTree.get_name newtree, 
         map RTree.get_name asmgoaltrees), p2)
    end;

(* forward resolution to remove an assumption 
   (aname is an assumption of rname): 

   aname, anames ==> rname     : C
   fname                       : C'
   ----------------------- fname / aname, C <= C'
   anames ==> rname            : C'

   [ if rname is asm, it must be in the context of fname. Works by
   lifting rname into F's context, changing aname to goal, and then
   proving aname by fname. ]
*)
fun apply_resol_fwd_i (aname,rname) fname p = 
    let val ((newname,(asgname::_)),p2) = (* note: _ = [] *)
            (* mk asm aname into a subgoal *)
            p |> lift_and_show_above rname [aname] fname
       (* when fname is in the same context as rname, no new asms *)
    in Seq.map (fn (sgs,p3) => ((sgs,newname),p3))
               (apply_resol_bck fname asgname p2)
    end; 

fun apply_resol_fwd (aname,rname) fname p = 
    Seq.map (fn ((sgs,n),p3) => 
             let val (sgs,p) = 
                     end_meth 
                       ("fwd resol: " ^ fname ^ " with: " ^ aname)
                       [n] [] p3 p
             in ((sgs,n),p) end)
            (apply_resol_fwd_i (aname,rname) fname (start_meth [] p));



(* apply resolution forward using theorem "th" on some result "fname"
to get the conclusion of "th", where the assumption of "th" is proved by
"fname" *)
fun apply_resol_fwd_thm th fname p = 
    let 
      val (thm_rtree,p2) = p |> start_meth []
                             |> insert_thm_i th;
      val asmname = case RTree.get_asms thm_rtree of 
                      [] => raise prf_exp "theorem has no assumptions!"
                    | (sg::sgs) => RTree.get_name sg;
    in 
      (apply_resol_fwd_i (asmname, RTree.get_name thm_rtree) fname p2)
        |> Seq.map (fn ((_,n),p3) => 
       (* no new subgoals from resol in the same cx, so "_" can be ignored *)
           let val (_,p) = 
                   end_meth 
                     ("fwd thmresol: " ^ fname ^ " with: " ^ (Thm.get_name_hint th))
                     [n] [] p3 p
           in (n,p) end)
    end;


val apply_frule_thm = apply_resol_fwd_thm;

fun apply_rule_thm th gname p0 = 
    let 
      val p = start_meth [gname] p0; 
      val (th_name, p) = insert_thm th p; 
    in
      (apply_resol_bck th_name gname p)
        |> Seq.map 
        (fn (_,p) => end_meth ("rule " ^ (Thm.get_name_hint th)) [] [gname] p p0)
    end;

fun apply_erule_thm th fname gname p0 = 
    let 
      val p = start_meth [gname] p0; 
      val (th_name, p) = p |> insert_thm th; 
    in
      (Seq.maps
        (fn ([],p) => 
            raise prf_exp "apply_erule_thm: theorem has no assumptions!"
          | (h::gs,p) => 
            Seq.map 
              (fn (_,p) => 
                  end_meth ("erule: " ^ (Thm.get_name_hint th) ^ " with: " ^ fname)
                           [] [gname] p p0)
              (apply_resol_bck fname h p))
        (apply_resol_bck th_name gname p))
    end;

(* apply subst *)
fun apply_subst eqname gname z p = 
    apply_subst_to_result eqname (get_result p gname) z p;

end;

structure Prf : PRF = DB_Prf;

(* install_pp (make_pp ["Prf", "T"] (Pretty.pprint o Prf.pretty)); *)
