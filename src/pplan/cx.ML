(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gproof/prf/cx.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
                Initially written Oct 2005, Updated 10 Mar 2006        *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
 Contexts for proof nodes - holding assumptions and parameters
*)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* Goal and Context names *)
structure Goaln : NAME where type name = string = StrName;
structure Cxn : NAME where type name = string = StrName;

(*install_pp (make_pp ["Goaln", "NSet", "T"] 
                    (Pretty.pprint o Goaln.NSet.pretty));
install_pp (make_pp ["Cxn", "NSet", "T"] 
                    (Pretty.pprint o Cxn.NSet.pretty));*)

(* slightly faster tables which cannot *)
structure GoalTab = Table(type key = Goaln.name val ord = Goaln.name_ord);
structure CxTab = Table(type key = Cxn.name val ord = Cxn.name_ord);

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature PRF_CX
= sig
  type gname
  type cxname
  type ancestors 
  type ncol (* goal name collection *)
  type ptab (* param table (names, types/sorts) *)
  type ptab_renaming (* param table renaming *)
  type T    (* node context *)

  exception no_ancestors_exp of string;

  val empty : Proof.context -> T
  val empty_renaming : ptab_renaming
  val no_ancestors : ancestors
  val add_ancestor : cxname -> ancestors -> ancestors
  val ancestor_inc : (cxname * T) -> ancestors
  val ancestors_rep : ancestors -> int * cxname list
  val first_ancestor : ancestors -> cxname (* raises exception if none *)

  val mk : Proof.context
           -> ancestors 
           -> ptab (* new params *)
           -> ptab (* all params *)
           -> ncol (* new asms *)
           -> ncol (* all asms *)
           -> T
  val mk_top_with_fixed : Proof.context -> ptab -> T

  val default_cxname : cxname
  val cxname_eq : cxname * cxname -> bool

  val get_isar_ctxt : T -> Proof.context
  val get_lfixes : T -> ptab
  val get_fixes : T -> ptab
  val get_lasms : T -> ncol (* local assumptions *)
  val get_aasms : T -> ncol (* all assumptions *)
  val get_ancestors : T -> ancestors
  val get_parent : T -> cxname (* raises exception if cx is root *)

  val dest_ptab : ptab -> (Trm.TypParams.T * Trm.TrmParams.T);
  val mk_ptab : (Trm.TypParams.T * Trm.TrmParams.T) -> ptab;

  val inst_params : InstEnv.T -> T -> T;

  val get_trmps_of_ptab : ptab -> Trm.TrmParams.T;
  val get_typps_of_ptab : ptab -> Trm.TypParams.T;

  val get_fixed_trm_ps : T -> Trm.TrmParams.T
  val get_lfixed_trm_ps : T -> Trm.TrmParams.T
  val get_fixed_typ_ps : T -> Trm.TypParams.T
  val get_lfixed_typ_ps : T -> Trm.TypParams.T

  val add_lasms : ncol -> T -> T 
  val add_asms : ncol -> T -> T
  val add_asm : gname -> T -> T

  val empty_ptab : ptab
  val isempty_ptab : ptab -> bool 

  val params_beyond : T -> T -> ptab
  val asms_beyond : T -> T -> ncol

  val split_to_common_ancestors : 
      ancestors -> ancestors 
      -> (ancestors * ancestors) * (cxname * ancestors)
  val split_cx_to_common_ancestors :
      cxname * T -> cxname * T -> 
      (ancestors * ancestors) * (cxname * ancestors);
  val first_common_ancestor : cxname * T -> cxname * T -> cxname

  (* raises exception on non-disjointness *)
  val append_disjoint_ptab : ptab -> ptab -> ptab
  (* make cx avoid names in ptab extending given renamings *) 
  val rename_ptab_to_avoid 
      : ptab (* the ptab which we want to rename *)
        -> (ptab (* avoiding names in this ptab *)
            * ptab_renaming) (* old renamings *)
        -> (ptab (* renamed local ptab *)
            * (ptab (* extended avoid ptab *)
               * ptab_renaming)) (* extended renamings *)

  val rename_trm_params : ptab_renaming -> Trm.T -> Trm.T
  val rename_trm_avoiding : 
      ptab * ptab_renaming -> (ptab * Trm.T)
      -> (ptab * ptab_renaming) * (ptab * Trm.T)

  (* drops the first n params, where n is the number of pararams in
     the first ptab. *)
  val drop_inner_nptab : ptab -> ptab -> ptab
  val drop_inner_lfixes_in_cx : ptab -> T -> T
  val drop_outer_nptab : ptab -> ptab -> ptab
  val drop_outer_fixes_in_cx : ptab -> T -> T

  (* renames first pab, adds as bound/local params *)
  val rename_and_addtofront_ptab : ptab -> ptab -> ptab
  (* renames context ptab *)
  (* val put_cx_after_ptab : ptab -> T -> T *)
  (* renames lfixes *)
  (* val add_ptab_to_cx_lfixes : ptab -> T -> T *)

  (* strip Isabelles !! quantified vars, and add params to ptab *)
  val add_fixedt_to_ptab (* adds all alls (renamed to be fersh) 
                            and new frees (not seen before) to ptab *)
      : ptab -> Trm.T -> ((ptab * ptab) * Trm.T) (* (new, all, fixed term) *)
  val add_alledt_to_ptab (* ignores initial params corresponding to ptab *)
      : ptab -> Trm.T -> ((ptab * ptab) * Trm.T) (* (new, all, fixed term) *)
  val add_alls_to_ptab (* only add top level alls *)
      : ptab -> Trm.T -> (ptab * ptab) * Trm.T

  (* pretty printing *)
  val pretty_ancestors : ancestors -> Pretty.T
  val pretty_cx_ancestors : T -> Pretty.T
  val pretty_cxname : cxname -> Pretty.T
  val pretty_ptab : ptab -> Pretty.T
  val print_ptab : ptab -> unit
  val full_pretty_ptab : Proof.context -> ptab -> Pretty.T
  val full_print_ptab : Proof.context -> ptab -> unit
  val pretty : T -> Pretty.T
  val print : T -> unit

end;


(* local context - scoped. Somehow this is the same as a theory: it
defines constants and axioms? Myabe I should think about this more:
fixes = constants from ancestor theory, lfixes = constants in this
theory, and the lasms are axioms, and asms = lemmas/theorems. *)
structure DB_Cx
= struct
  type gname = string;
  type cxname = string;
  type ncol = Goaln.NSet.T;
  datatype ancestors = Ancest of int * cxname list
  datatype ptab = PTab of (Trm.TypParams.T * Trm.TrmParams.T);
  datatype ptab_renaming = 
           PTabRN of (TFree.name TFree.NTab.T 
                      * Free.name Free.NTab.T);

  exception no_ancestors_exp of string;

  val empty_renaming = PTabRN (TFree.NTab.empty,
                               Free.NTab.empty);
  val no_ancestors = Ancest (0,[]);
  fun dest_ptab (PTab x) = x;
  val mk_ptab = PTab;
  fun get_trmps_of_ptab (PTab (typs,trms)) = trms;
  fun get_typps_of_ptab (PTab (typs,trms)) = typs;

  datatype T
    = Cx of { isar_ctxt : Proof.context, (* isar context, for parsing *)
              anscestors : ancestors, (* contexts we are in *)
              fixes : ptab,   (* fixed params, including local *)
              lfixes : ptab, (* local params *)
              asms : ncol, (* all assumed things, including local ones *)
              lasms : ncol }; (* local assumptions *)

  fun empty isar_ctxt = 
      Cx { isar_ctxt = isar_ctxt,
           anscestors = no_ancestors,
           fixes = PTab (Trm.TypParams.empty,Trm.TrmParams.empty),
           lfixes = PTab (Trm.TypParams.empty,Trm.TrmParams.empty),
           lasms = Goaln.NSet.empty,
           asms = Goaln.NSet.empty };

  fun mk isar_ctxt anscestors lfixes fixes lasms asms = 
      Cx { isar_ctxt = isar_ctxt, 
           anscestors = anscestors,
           fixes = fixes, lfixes = lfixes,
           lasms = lasms, asms = asms };


  fun mk_top_with_fixed isar_ctxt fixes = 
      mk isar_ctxt no_ancestors fixes fixes Goaln.NSet.empty Goaln.NSet.empty;

  fun get_isar_ctxt (Cx rep) = #isar_ctxt rep;
  fun get_ancestors (Cx rep) = #anscestors rep;
  fun get_fixes (Cx rep) = #fixes rep;
  fun get_lfixes (Cx rep) = #lfixes rep;
  fun get_lasms (Cx rep) = #lasms rep;
  fun get_aasms (Cx rep) = #asms rep;

  val get_fixed_trm_ps = get_trmps_of_ptab o get_fixes;
  val get_lfixed_trm_ps = get_trmps_of_ptab o get_lfixes;
  val get_fixed_typ_ps = get_typps_of_ptab o get_fixes;
  val get_lfixed_typ_ps = get_typps_of_ptab o get_lfixes;
      
  fun ancestors_rep (Ancest x) = x;
  fun add_ancestor cx (Ancest (i,l)) = (Ancest (i + 1,cx::l));
  fun ancestor_inc (cxname,cx) = 
      add_ancestor cxname (get_ancestors cx);
  fun first_ancestor (Ancest (_,h::_)) = h
    | first_ancestor (Ancest (_,[])) = 
      raise no_ancestors_exp "first_ancestor";

  val get_parent = first_ancestor o get_ancestors; (* raises exception if cx is root *)

  (* ptabs *)
  fun append_disjoint_ptab (PTab (typt1,pt1)) (PTab (typt2,pt2)) = 
      PTab (Trm.TypParams.append_disjoint typt1 typt2, 
            Trm.TrmParams.append_disjoint pt1 pt2);

  val empty_ptab = PTab (Trm.TypParams.empty,Trm.TrmParams.empty);
  fun isempty_ptab (PTab (typt1,pt1)) = 
      Trm.TrmParams.is_empty pt1 andalso Trm.TypParams.is_empty typt1;

  fun update_isar_ctxt f (Cx rep) = 
      Cx { isar_ctxt = f (#isar_ctxt rep),
           anscestors = #anscestors rep,
           fixes = #fixes rep,
           lfixes = #lfixes rep,
           lasms = #lasms rep,
           asms = #asms rep };

  fun update_fixes f (Cx rep) = 
      Cx { isar_ctxt = #isar_ctxt rep,
           anscestors = #anscestors rep,
           fixes = f (#fixes rep),
           lfixes = #lfixes rep,
           lasms = #lasms rep,
           asms = #asms rep };

  fun update_lfixes f (Cx rep) = 
      Cx { isar_ctxt = #isar_ctxt rep,
           anscestors = #anscestors rep,
           fixes = (#fixes rep),
           lfixes = f (#lfixes rep),
           lasms = #lasms rep,
           asms = #asms rep };

  fun update_lasms f (Cx rep) = 
      Cx { isar_ctxt = #isar_ctxt rep,
           anscestors = #anscestors rep,
           fixes = #fixes rep,
           lfixes = #lfixes rep,
           lasms = f (#lasms rep),
           asms = #asms rep };

  val set_lasms = update_lasms o K;

  fun add_lasms lasms (Cx rep) = 
      Cx { isar_ctxt = #isar_ctxt rep,
           anscestors = #anscestors rep,
           fixes = #fixes rep,
           lfixes = #lfixes rep,
           lasms = Goaln.NSet.union_merge lasms (#lasms rep),
           asms = Goaln.NSet.union_merge lasms (#asms rep) };

  fun update_asms f (Cx rep) = 
      Cx { isar_ctxt = #isar_ctxt rep,
           anscestors = #anscestors rep,
           fixes = #fixes rep,
           lfixes = #lfixes rep,
           lasms = #lasms rep,
           asms = f (#asms rep) };
  val add_asm = update_asms o Goaln.NSet.add;
  val add_asms = update_asms o Goaln.NSet.union_merge;

  fun cxname_eq ab = ((String.compare ab) = EQUAL);
  val default_cxname = "C";

  fun inst_ptab ienv (PTab (typt,pt)) = 
      PTab (typt, 
            pt |> Trm.TrmParams.map_params 
               (fn (n,ty) => (n, InstEnv.inst_typ_tvars ienv ty)));

  fun inst_params ienv cx = 
      cx |> update_fixes (inst_ptab ienv)
         |> update_lfixes (inst_ptab ienv);

  (* params in cx not in p_cx *)
  fun params_beyond cx p_cx = 
         PTab (Trm.TypParams.params_beyond 
                 (get_fixed_typ_ps cx) (get_fixed_typ_ps p_cx),
               Trm.TrmParams.params_beyond 
                 (get_fixed_trm_ps cx) (get_fixed_trm_ps p_cx));

  (* asms in cx not in p_cx *) (* IMPROVE: can we record in a way
  like params, and thus take time prop to the difference in number of
  asms, rather than time proportional to the asms in all anscestor
  contexts? *)
  fun asms_beyond cx p_cx = 
      Goaln.NSet.subtract (get_aasms cx) (get_aasms p_cx);

  (* find the subcontexts of cx1 and cx2 that are different and the
  part that are the same. All contexts eventually become one!  returns
  the two subcontexts that are different (top down), the first commmon
  ancestor (looking up), and the rest (also looking up) *)
  fun split_to_common_ancestors (Ancest (np1, parents1))
                                (Ancest (np2, parents2)) = 
      let 
        val minn = Int.min(np1,np2);
        val drop1 = (np1 - minn);
        val drop2 = (np2 - minn);
        val (premin1,postmin1) = Library.chop drop1 parents1;
        val (premin2,postmin2) = Library.chop drop2 parents2;
        fun split_to_first_common (p1 as (n1,pl1)) (p2 as (n2,pl2)) 
                                  (cs as c1::t1) (c2::t2) = 
            if cxname_eq (c1,c2) then 
              ((Ancest p1,Ancest p2), (c1, Ancest (np1 - n1, cs)))
            else split_to_first_common 
                   (n1 + 1,c1::pl1) (n2 + 1,c1::pl2) t1 t2
          | split_to_first_common _ _ _ _ = 
            raise ERROR "Cx:split_to_common_ancestors:split_to_first_common: not given list"
      in 
        split_to_first_common 
          (drop1,premin1) (drop2,premin2) postmin1 postmin2          
      end;
  fun split_cx_to_common_ancestors ncx1 ncx2 = 
        split_to_common_ancestors 
          (ancestor_inc ncx1) (ancestor_inc ncx2)
  val first_common_ancestor = fst o snd oo split_cx_to_common_ancestors;
      

  (* make cx avoid the given fixes, extending the given renamings. *)
  fun rename_ptab_to_avoid (PTab (ltypfixes, ltrmfixes))
                           (PTab (avoid_typfixes,avoid_trmfixes),
                            PTabRN (typ_rns,trm_rns)) = 
      let 
        val ((ltrmfixes_list,trm_rns'),avoid_trmfixes') = 
            Trm.TrmParams.refresh_names ltrmfixes (([],trm_rns),avoid_trmfixes)
        val ltrmfixes' = Trm.TrmParams.of_plist ltrmfixes_list

        val ((ltypfixes_list,typ_rns'),avoid_typfixes') = 
            Trm.TypParams.refresh_names ltypfixes (([],typ_rns),avoid_typfixes)
        val ltypfixes' = Trm.TypParams.of_plist ltypfixes_list
      in 
        (PTab (ltypfixes',ltrmfixes'),
         (PTab (avoid_typfixes',avoid_trmfixes'),
          PTabRN (typ_rns', trm_rns')))
      end;

(* renaming ptabs *)
  fun rename1_free trm_rns ((n,ty), free) =
      (case Trm.TrmParams.NTab.lookup trm_rns n 
        of NONE => free
         | SOME n2 => Trm.mk_free (n2,ty));
      
  fun rename1_typfree typ_rns ((n,srt),typfree) =
      (case Trm.TypParams.NTab.lookup typ_rns n 
        of NONE => typfree
         | SOME n2 => Trm.mk_tfree (n2,srt));
    
  fun rename_trm_params (PTabRN (typ_rns, trm_rns)) t = 
      t |> (fn t => if Trm.TrmParams.NTab.is_element_empty trm_rns then t
                    else Trm.map_trm_frees (rename1_free trm_rns) t)
        |> (fn t => if Trm.TypParams.NTab.is_element_empty typ_rns then t
                    else Trm.map_trm_types 
                           (Trm.map_typ_tfrees (rename1_typfree typ_rns)) t);

(* rename params in a term, extending the fixes and renaming context *)
fun rename_trm_avoiding (fr as (fixes,renaming)) (lfixes,t) = 
    let val (lfixes',fr2 as(_,renaming')) = 
            rename_ptab_to_avoid lfixes fr;
        val t' = rename_trm_params renaming' t;
    in (fr2, (lfixes',t')) end


  (* drop the first n params *)
  fun dropn_outer_fixes (drop_typ_n, drop_trm_n) (PTab (typfixes,trmfixes)) = 
      PTab (Trm.TypParams.drop_outern drop_typ_n typfixes,
            Trm.TrmParams.drop_outern drop_trm_n trmfixes);
  (* interesting case for verification: how to stop incorrect dropping? *)
  fun drop_outer_nptab (PTab (droptyps,droptrms)) = 
      dropn_outer_fixes (Trm.TypParams.get_nparams droptyps, 
                         Trm.TrmParams.get_nparams droptrms);
  val drop_outer_fixes_in_cx = 
      update_fixes o drop_outer_nptab;

  (* drop the last n params *)
  fun dropn_inner_fixes (drop_typ_n, drop_trm_n) (PTab (typfixes,trmfixes)) = 
      PTab (Trm.TypParams.drop_innern drop_typ_n typfixes,
            Trm.TrmParams.drop_innern drop_trm_n trmfixes);
  fun drop_inner_nptab (PTab (droptyps,droptrms)) = 
      dropn_inner_fixes (Trm.TypParams.get_nparams droptyps, 
                         Trm.TrmParams.get_nparams droptrms);
  fun drop_inner_lfixes_in_cx droptab = 
      let val dropf = drop_inner_nptab droptab in 
      update_fixes dropf o update_lfixes dropf end;

  (* add extra context params, (dropping first n corresponding to
     ptab) from allified term,
     return new params then all params *)
  fun add_alledt_to_ptab (PTab (old_typtab, old_vptab)) alledt = 
      let 
        (* params directory correspond to frees with the same name *)
        val (t, (new_params, vptab0)) = 
            Trm.refix_all_params' old_vptab alledt;
        (* also check any new free vars - treat these as new params *)
        val (new_frees, vptab1) = Trm.addto_params alledt vptab0
        val all_new_params = new_params @ new_frees;
 
        (* also check new free type vars *)
        val (new_typs, typtab1) = Trm.addto_tparams t old_typtab
      in
        ((PTab (Trm.TypParams.of_plist new_typs, 
           Trm.TrmParams.of_plist all_new_params), 
          PTab (typtab1,vptab1)), t)
      end;

  (* add context params: only meta level all'ed things *)
  fun add_alls_to_ptab (PTab (old_typtab, old_vptab)) t0 = 
      let val (t, (new_ps, vptab)) = Trm.fix_all_params' old_vptab t0; 
      in ((PTab (Trm.TypParams.empty, Trm.TrmParams.of_plist new_ps), 
           PTab (old_typtab,vptab)), t) end;

  (* adds all initial meta-level quantified params, as well as any
     additional frees in term as new params to the ptab.
     returns (new params, all params) *)
  fun add_fixedt_to_ptab (PTab (old_typtab, old_vptab)) t0 = 
      let 
        (* params directory correspond to frees with the same name *)
        val (t, (new_params,vptab0)) = Trm.fix_all_params' old_vptab t0;
        (* also check any new free vars - treat these as new params *)
        val (new_frees,vptab1) = Trm.addto_params t0 vptab0;
        val all_new_params = new_frees @ new_params;
 
        (* also check new free type vars *)
        val (new_typs,typtab1) = Trm.addto_tparams t old_typtab;
      in
        ((PTab (Trm.TypParams.of_plist new_typs, 
                Trm.TrmParams.of_plist all_new_params), 
          PTab (typtab1,vptab1)), t)
      end;

  (* rename first param table to and add the params to the front of
  the big param table. -- IMPROVE: can't this be done more efficiently? *)
  fun rename_and_addtofront_ptab 
        (PTab (more_typtab, more_vptab)) 
        (PTab (old_typtab, old_vptab)) = 
      PTab (snd (Trm.TypParams.refresh_names 
                  more_typtab 
                  (([],Trm.TypParams.NTab.empty),old_typtab)),
            snd (Trm.TrmParams.refresh_names
                  more_vptab 
                  (([],Trm.TrmParams.NTab.empty),old_vptab)) );

(* 
  val put_cx_after_ptab ptab = 
      update_
                        
 ptab -> T -> T
  val put_ptab_infrontof_cx : ptab -> T -> T
*)

(* pretty printing *)
val pretty_cxname = Pretty.str;

fun pretty_ancestors (Ancest (_,l)) = 
    Pretty.list "[" "]" (map pretty_cxname l);

val pretty_cx_ancestors = pretty_ancestors o get_ancestors;

fun pretty_tfix ctxt (n,srt) = 
    (Pretty.block 
      [TFree.pretty_name n,
       Pretty.str " : ",
       Trm.pretty_sort ctxt srt]);
fun pretty_fix ctxt (n,typ) = 
    (Pretty.block 
      [Free.pretty_name n,
       Pretty.str " : ",
       Trm.pretty_typ ctxt typ]);
 
val pretty_gname = Pretty.str;

fun full_pretty_ptab ctxt ptab = 
    Pretty.chunks 
      [Pretty.block 
         [Pretty.str "  Typfixes: ",
          Pretty.list "[" "]" (map (pretty_tfix ctxt) 
                                   (Trm.TypParams.get_plist 
                                      (get_typps_of_ptab ptab)))],
       Pretty.block 
         [Pretty.str "  Fixes: ",
          Pretty.list "[" "]" (map (pretty_fix ctxt) 
                                   (Trm.TrmParams.get_plist 
                                      (get_trmps_of_ptab ptab)))]];

val full_print_ptab = 
    Pretty.writeln oo full_pretty_ptab;

fun pretty_ptab ptab = 
    Pretty.chunks 
      [Pretty.block 
         [Pretty.str "  Typfixes: ",
          Pretty.list "[" "]" (map (TFree.pretty_name o fst) 
                                   (Trm.TypParams.get_plist 
                                      (get_typps_of_ptab ptab)))],
       Pretty.block 
         [Pretty.str "  Fixes: ",
          Pretty.list "[" "]" (map (Free.pretty_name o fst) 
                                   (Trm.TrmParams.get_plist 
                                      (get_trmps_of_ptab ptab)))]];

val print_ptab = 
    Pretty.writeln o pretty_ptab;

fun pretty (cx as Cx rep) =  
    let val ctxt = get_isar_ctxt cx
    in
      Pretty.chunks 
        ([Pretty.block [Pretty.str "Ancestors: ", pretty_cx_ancestors cx]]
         @ [Pretty.str "All ",
            full_pretty_ptab ctxt (get_fixes cx)]
         @ [Pretty.str "Local ",
            full_pretty_ptab ctxt (get_lfixes cx)]
         @ [Pretty.block 
              [Pretty.str "Local Asms: ",
               Pretty.list "[" "]" 
                           (map pretty_gname (Goaln.NSet.list_of (#lasms rep)))]]
         @ [Pretty.block 
              [Pretty.str "All Asms: ",
               Pretty.list "[" "]" 
                           (map pretty_gname (Goaln.NSet.list_of (#asms rep)))]]
        )
    end;

val print = Pretty.writeln o pretty;

end; (* struct Cx *)


structure Cx : PRF_CX = DB_Cx;

(*install_pp (make_pp ["Cx", "ptab"] 
                    (Pretty.pprint o Cx.pretty_ptab));*)
          
