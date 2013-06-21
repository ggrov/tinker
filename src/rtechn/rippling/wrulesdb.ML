(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfo/rippling/wrulesdb.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Created:    15 Mar 2003
    Modified:   Dominic Mulligan
                dpm_edinburgh@yahoo.com
                12 Sept 2007
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Database of wave rules for rippling
*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature WRULESDB =
sig

exception ripple_wrulesdb_exp of string
type T


type wrule
type impwrule
type fwd_impwrule
type part_wrule


(* wave rules *)
structure WRData : PRF_MORPH_DATA where type T = wrule
structure WRNet : PRF_MORPH_NET where type MData.T = wrule
type impr_net = impwrule Net.net;
type partwrule_net = part_wrule Net.net;

(* structure PartialWRData : PRF_MORPH_DATA where type T = part_wrule
structure PartialWRNet : PRF_MORPH_NET where type MData.T = part_wrule *)

(* search function for zippers: defines ordering and way rules are
   looked up for equational rewriting *)
type searchf = Zipper.T -> Zipper.T Seq.seq

(* basic eq for wave rules *)
val wrule_eq : wrule * wrule -> bool
val fwd_impwrule_eq : fwd_impwrule * fwd_impwrule -> bool
val impwrule_eq : impwrule * impwrule -> bool

(* basic creation and merging *)
val init : searchf -> T
val merge : T * T -> T

(* adding/removing wave rules *)
val add_eq_wrule : Proof.context -> wrule * T -> T
val add_eq_wrules : Proof.context -> wrule list * T -> T
val add_inv_wrule : Proof.context -> wrule * T -> T
val add_inv_wrules : Proof.context -> wrule list * T -> T
val add_impwrule : Proof.context -> impwrule * T -> T
val add_impwrules : Proof.context -> impwrule list * T -> T
val add_fwd_impwrule : Proof.context -> fwd_impwrule * T -> T
val add_fwd_impwrules : Proof.context -> fwd_impwrule list * T -> T
val add_partwrule : Proof.context -> part_wrule * T -> T
val add_partwrules : Proof.context -> part_wrule list * T -> T

val clear_wrules : T -> T

val conclterm_of_impwrule : impwrule -> Term.term

val add_dthms_as_wrules : Proof.context -> (DThm.T list * T) -> T
val addall_dthms_as_wrules : Proof.context -> (DThm.T list * T) -> T
val add_dthms_as_impwrules : Proof.context -> (DThm.T list * T) -> T
val add_dthms_as_fwd_impwrules : Proof.context -> (DThm.T list * T) -> T

val del_dthms_from_wrules : DThm.T list * T -> T
(* val del_dthms_from_eq_wrules : DThm.T list * T -> T *)
val del_dthms_from_impwrules : DThm.T list * T -> T
val del_dthms_from_fwd_impwrules : DThm.T list * T -> T

(* lookup *)
val lookup
    : T (* wave rule database *)
      -> Prf.T (* prf *)
      -> Prf.gname (* result to look at in prf *)
      -> (DTac.T Seq.seq (* eq rules *)
          * DTac.T Seq.seq (* imp rules *)
          * (fwd_impwrule * (Prf.gname list * Prf.T)) Seq.seq) (* forward imps *)

val eqrule_zipper_lookup :
    T -> Prf.T -> Prf.gname 
    -> Zipper.T (* zipper in result to look under *)
    -> DTac.T Seq.seq

val imprule_concl_lookup : 
    T -> Prf.T
    -> Prf.gname -> Trm.T
    -> DTac.T Seq.seq 

val fwd_imprule_prems_lookup :
    T -> Prf.T
    -> Prf.gname -> Trm.T
    -> (fwd_impwrule
          * (Prf.gname list * Prf.T)) Seq.seq

(* getting wave rule collections *)
val impwrules_of : T -> impwrule list
val fwd_impwrules_of : T -> fwd_impwrule list
val wrules_of : T -> WRData.T list
val get_imprule_net : T -> impr_net;
val get_eqrule_net : T -> WRNet.T;
val get_partrule_net : T -> partwrule_net;
val partrules_of : T -> part_wrule list
 
(* working with wave rules *)
val dthm_of_wrule : wrule -> DThm.T
val lhsterm_of_wrule : wrule -> Term.term
val rule_of_wrule : wrule -> Thm.thm
val dthm_of_impwrule : impwrule -> DThm.T
val dthm_of_fwd_impwrule : fwd_impwrule -> DThm.T

val thm_of_impwrule : impwrule -> Thm.thm;

(*Info about partial wave-rules: *)
val wrule_of : part_wrule -> wrule 
val zipper_of :  part_wrule -> Zipper.T;
val term_of :   part_wrule -> Term.term

(* search fuctions for rippling *)
val get_searchf : T -> searchf
val set_searchf : searchf * T -> T

(* pretty printing *)
val pretty_impwrule_sml : Proof.context -> impwrule -> Pretty.T
val pretty_fwd_impwrule_sml : Proof.context -> fwd_impwrule -> Pretty.T
val pretty_partwrule : Proof.context -> part_wrule -> Pretty.T
val pretty_of_wruledb : Proof.context -> T -> Pretty.T
val pretty_wrule : Proof.context -> wrule -> Pretty.T
val pretty_wrule_sml : Proof.context -> wrule -> Pretty.T
val print : Proof.context -> T -> unit
val pretty : Proof.context -> T -> Pretty.T

end;



structure DB_WRules
= struct

exception ripple_wrulesdb_exp of string

(* equational wave rules *)
datatype wrule = WRule of {lhs : Term.term,
                           dthm : DThm.T, 
                           ienv : InstEnv.T,
                           rule : Thm.thm }; (* meta equality rule *)

fun lhsterm_of_wrule (WRule rep) = #lhs rep;
fun dthm_of_wrule (WRule rep) = #dthm rep;
fun rule_of_wrule (WRule rep) = #rule rep;
fun ienv_of_wrule (WRule rep) = #ienv rep;
fun wrule_eq (a,b) = DThm.eq (dthm_of_wrule a) (dthm_of_wrule b);
val theory_of_wrule = DThm.theory_of o dthm_of_wrule; (* for pretty *)
val global_ctxt_of_wrule = Proof_Context.init_global o theory_of_wrule;
fun pretty_wrule ctxt wr = 
    Pretty.block [Pretty.str "Rule: '", DThm.pretty (dthm_of_wrule wr),
                  Pretty.str "': ", 
                  Display.pretty_thm ctxt (rule_of_wrule wr)];
fun pretty_wrule_sml ctxt wr = 
    Display.pretty_thm ctxt (rule_of_wrule wr);


(* partial wave-rules *)
datatype part_wrule = PartWRule of {wrule : wrule,
                                     subterm : Term.term,
                                     zipper : Zipper.T}; 
fun wrule_of (PartWRule rep) = #wrule rep;
fun zipper_of (PartWRule rep) = #zipper rep;
fun term_of (PartWRule rep) = #subterm rep;
val ienv_of_partwrule = ienv_of_wrule o wrule_of;
(*Obviously not true, need to figure this out. When wave-rule equal, subterms equal and focus-term?*)
fun partwrule_eq (pwrule1 ,pwrule2) = false

fun pretty_partwrule ctxt pwrule =
    Pretty.block [Trm.pretty ctxt (term_of pwrule),
                  Pretty.str " of wrule ",
                  pretty_wrule_sml ctxt (wrule_of pwrule)];


(* implication wave rules *)
datatype impwrule = ImpWRule of { concl : Term.term,
                                  dthm : DThm.T };

datatype fwd_impwrule = FwdImpWRule of { prem : (Term.term * int),
                                         (* note: need the int to represent premise number, so don't get INSERT exception *)
                                         dthm : DThm.T };

fun conclterm_of_impwrule (ImpWRule rep) = #concl rep;
fun dthm_of_impwrule (ImpWRule rep) = #dthm rep;
fun thm_of_impwrule (ImpWRule rep) = DThm.finalthm_of (#dthm rep);
fun impwrule_eq (a,b) = DThm.eq (dthm_of_impwrule a) (dthm_of_impwrule b);
fun dthimpwrule_eq (dth,impr) = DThm.eq (dth) (dthm_of_impwrule impr);
fun pretty_impwrule_sml ctxt impr = 
    let val dth = (dthm_of_impwrule impr)
      val th = DThm.finalthm_of dth 
    in Pretty.block [DThm.pretty dth, Pretty.str ": ",
                     Pretty.quote (Display.pretty_thm ctxt th)] end;

fun premterms_of_fwd_impwrule (FwdImpWRule rep) = #prem rep
fun dthm_of_fwd_impwrule (FwdImpWRule rep) = #dthm rep
fun thm_of_fwd_impwrule (FwdImpWRule rep) = DThm.finalthm_of (#dthm rep)
fun fwd_impwrule_eq ((FwdImpWRule left), (FwdImpWRule right)) =
    let
      val (_, i) = (#prem left)
      val a = (#dthm left)
      val (_, j) = (#prem right)
      val b = (#dthm right)
    in
        ((DThm.eq a b) andalso (i=j))
    end
fun dthfwd_impwrule_eq (dth, fwd_impr) = DThm.eq dth (dthm_of_fwd_impwrule fwd_impr)

fun pretty_fwd_impwrule_sml ctxt fwd_impr =
  let
    val dth = (dthm_of_fwd_impwrule fwd_impr)
    val th = DThm.finalthm_of dth
  in
    Pretty.block [
      DThm.pretty dth, Pretty.str " : ",
      Pretty.quote (Display.pretty_thm ctxt th)]
  end

(* apply wave rule, fwd to results, backwards to goals *)
fun apply_wrule wrule prf gname z = 
    Seq.map 
      (if Prf.is_open_goal prf gname then (fn ((g,gs),p) => (([],gs),p))
       else (fn ((g,gs),p) => (([g],gs),p)))
      (Subst.apply_thm_at 
         (rule_of_wrule wrule)
         false (* do not do symmetry - this can be done in dthm *)
         gname z prf);

(* equational wave rule prf morphisms *)
structure WRData : PRF_MORPH_DATA = 
struct 
  type T = wrule;
  val pat_of = lhsterm_of_wrule;
  val ienv_of = ienv_of_wrule;
  val prff = apply_wrule;
  val eq = wrule_eq;
  val pretty = pretty_wrule;
end;
structure WRNet = PrfMorphNetFUN(WRData);

(* partial wave rule net *)
type partwrule_net = part_wrule Net.net;

(* 
structure PartialWRData = 
struct 
  type T = pwrule;
  val pat_of = term_of;
  val ienv_of = ienv_of_partwrule;
  (* FIXME: dummy value for prff as moa does search separately *)
  fun prff wrule prf gname z = Seq.empty;  
  val eq = partwrule_eq;
  val pretty = pretty_partwrule;
end;
structure PartialWRNet = PrfMorphNetFUN(PartialWRData);
*)

(*search function for parial wave-rules.
type searchf =
     Prf.T -> (Zipper.T * Prf.gname) -> PartialWRNet.T 
     -> (pwrule * Prf.T) Seq.seq; *)


(* search function for zippers: defines ordering and way rules are
   looked up for equational rewriting *)
type searchf = Zipper.T -> Zipper.T Seq.seq

(* the wave rule net for implications that can be used *)
type impr_net = impwrule Net.net;

type fwd_impr_net = fwd_impwrule Net.net;

(* The wave rule database *)
type T = {eqrule_net : WRNet.T,
          inv_eqrule_net : WRNet.T,
          searchf : searchf, (* search ordering for equational rules *)
          imprule_net : impr_net,
          fwd_imprule_net : fwd_impr_net,
          partrule_net : partwrule_net};

fun init s = {eqrule_net = WRNet.empty,
              inv_eqrule_net = WRNet.empty,
              searchf = s,  
              imprule_net = Net.empty,
              fwd_imprule_net = Net.empty, 
              partrule_net = Net.empty} : T;
    
fun clear_wrules (db : T) = init (#searchf db);

fun get_imprule_net (db : T) = #imprule_net db;
fun get_inv_eqrule_net (db : T) = #inv_eqrule_net db;
fun get_eqrule_net (db : T) = #eqrule_net db;
fun get_fwd_imprule_net (db : T) = #fwd_imprule_net db;
fun get_partrule_net (db :T) = #partrule_net db;
fun get_searchf (db : T) = #searchf db;

fun set_searchf (s, (db : T)) = 
    {eqrule_net = get_eqrule_net db, 
     inv_eqrule_net =  #inv_eqrule_net db,
     searchf = s,
     imprule_net = get_imprule_net db, 
     partrule_net = get_partrule_net db,
     fwd_imprule_net = get_fwd_imprule_net db};


fun add_eq_wrule ctxt (wr,db : T) = 
    let val _ = tracing ("Adding wave rule: " ^ 
                         (Pretty.string_of (pretty_wrule_sml ctxt wr))) in
      {eqrule_net = WRNet.insert (wr, get_eqrule_net db),
       inv_eqrule_net =  #inv_eqrule_net db,
       searchf = #searchf db,
       imprule_net = (#imprule_net db),
       fwd_imprule_net = (#fwd_imprule_net db),
       partrule_net = (#partrule_net db)} : T
    end;

fun add_eq_wrules ctxt (wrs, db) = 
    List.foldr (fn (x,db) => add_eq_wrule ctxt (x,db)) db wrs;

(* Add 'invalid' wrules to separate net *)
fun add_inv_wrule ctxt (wr,db : T) = 
    let val _ = tracing ("Adding wave rule (invalid): " ^ 
                         (Pretty.string_of (pretty_wrule_sml ctxt wr))) in
      {eqrule_net = (#eqrule_net db),
       searchf = #searchf db,
       imprule_net = (#imprule_net db),
       partrule_net = (#partrule_net db),
       fwd_imprule_net = (#fwd_imprule_net db),
       inv_eqrule_net = WRNet.insert (wr, get_inv_eqrule_net db)} : T 
    end; 

(* Add 'invalid' wrules to separate net *)
fun add_inv_wrules ctxt (wrs, db) = 
    List.foldr (fn (x,db) => (add_inv_wrule ctxt) (x,db)) db wrs;

fun add_impwrule ctxt (impr,db : T) = 
    let val _ = tracing ("Adding implication wave rule: " ^
                           (Pretty.string_of (pretty_impwrule_sml ctxt impr))) in
      {eqrule_net = #eqrule_net db,
       inv_eqrule_net =  #inv_eqrule_net db,
       searchf = #searchf db,
       imprule_net = Net.insert_term impwrule_eq (conclterm_of_impwrule impr,impr) (#imprule_net db),
       fwd_imprule_net = #fwd_imprule_net db,
       partrule_net = #partrule_net db} : T 
    end;

fun add_impwrules ctxt (rs, db : T) = 
    List.foldr (fn (x,db) => add_impwrule ctxt (x,db)) db rs;

fun add_prems net rule =
  let
      val (trm, index) = premterms_of_fwd_impwrule rule
  in
      Net.insert_term fwd_impwrule_eq (trm, rule) net
  end

fun add_fwd_impwrule ctxt (fwd_impr,db : T) =
  let val _ = tracing ("Adding forward implication wave rule: " ^
                        (Pretty.string_of (pretty_fwd_impwrule_sml ctxt fwd_impr)))
  in
       {eqrule_net = #eqrule_net db,
       inv_eqrule_net =  #inv_eqrule_net db,
       searchf = #searchf db,
       imprule_net = #imprule_net db,
       fwd_imprule_net = (add_prems (#fwd_imprule_net db) fwd_impr),
       partrule_net = #partrule_net db} : T
  end

fun add_fwd_impwrules ctxt (rs, db : T) =
  List.foldr (fn (x, db) => add_fwd_impwrule ctxt (x, db)) db rs;

fun add_partwrule ctxt (pwr,db : T) =
  let
    val _ = tracing ("Adding partial wave rule: " ^ (Pretty.string_of (pretty_partwrule ctxt pwr)))
  in
    {  eqrule_net = #eqrule_net db,
       inv_eqrule_net =  #inv_eqrule_net db,
       searchf = #searchf db,
       imprule_net = #imprule_net db,
       partrule_net = Net.insert_term partwrule_eq (term_of pwr,pwr) (#partrule_net db),
       fwd_imprule_net = #fwd_imprule_net db } : T
  end;

fun add_partwrules ctxt (pwrs,db) =
    List.foldr (fn (x,db) => add_partwrule ctxt (x,db)) db pwrs;

(*local *)

  fun ienv_of_thm th = 
      InstEnv.of_trm (Proof_Context.init_global (Thm.theory_of_thm th))
        (Logic.list_implies (* hack to get one term from a term 
                               and it's flexies *)
           (map Logic.mk_equals (Thm.tpairs_of th),
            Thm.prop_of th));
      
(* THINK: maybe use dattrthm's instead of doing it in subst? *)
  fun mk_wrule lhs dthm rule =
      WRule {lhs = lhs,
             dthm = dthm,
             ienv = ienv_of_thm rule,
             rule = Thm.put_name_hint (DThm.long_name_of dthm) rule};

  fun mk_pwrule waverule zipper = 
            PartWRule{wrule = waverule, 
                       subterm = Zipper.trm zipper,
                       zipper = zipper};

  (* quick removal of "rs" elements from "ls" when (eqf (r,l)) is true 
     Ignores ordering. *)
  fun lrem eqf rs ls = 
      let fun list_remove rs ([],[]) = []
            | list_remove [] (xs,_) = xs
            | list_remove (r::rs) ([],leftovers) = 
              list_remove rs (leftovers,[])
            | list_remove (r1::rs) ((x::xs),leftovers) = 
              if eqf (r1, x) then list_remove (r1::rs) (xs,leftovers)
              else list_remove (r1::rs) (xs, x::leftovers)
      in
        list_remove rs (ls,[])
      end;

  (* FIXME: make more efficient, only require a single new var! *)
  (* check if the new term has any meta variables not in the old term *)
  fun has_new_vars (old, new) =
      (case lrem (op =) (Trm.vars_of old) (Trm.vars_of new) of
         [] => false
       | (_::_) => true);
  (* check if the new term has any type variables not in the old term *)
  fun has_new_typ_vars (old, new) =
      (case lrem (op =) (Trm.tvars_of old) (Trm.tvars_of new) of
         [] => false
       | (_::_) => true);

    (* checks to see if the lhs -> rhs is a invalid rewrite rule *)
(* FIXME: we should really check that there is a subterm on the lhs
which embeds into the rhs, this would be much closer to the normal
notion of valid wave rule - ie there exists at least one case where it
is a valid wave rule... *)
  fun is_not_valid_rwrule thy (lhs, rhs) =
      Term.is_Var (Term.head_of lhs) (* if lhs is essentially just a var *)
      orelse has_new_vars (lhs,rhs)
      orelse has_new_typ_vars (lhs,rhs)
      orelse Pattern.matches_subterm thy (lhs, rhs)
      orelse (case lhs of
               Const("HOL.True",_) => true
             | Const("HOL.False",_) => true
             | _ => false)
  (* rules are meta-equalities derived by EqRuleData from th *)
  (* Creates a list of wave rules for an equality theorem, skipping
  those which are not valid wave rules. *)
  fun wrules_of_eq_dthm tsig dth rules = 
      let 
        fun chk_addrule r =
            let val (lhs,rhs) = Logic.dest_equals (Thm.concl_of r) 
            in if is_not_valid_rwrule tsig (lhs,rhs) then NONE
               else SOME (mk_wrule lhs dth r) end
      in Library.map_filter chk_addrule rules end;

(* Alternative to above function, return pair of lists of legal wrules
and invalid wrules *)

 fun wrules_of_eq_dthm2 tsig dth rules = 
     let 
       fun chk_addrule [] (valid, inv) =  (valid, inv)
         | chk_addrule (r::rs) (valid, inv) = 
           let val (lhs,rhs) = Logic.dest_equals (Thm.concl_of r)
           in if is_not_valid_rwrule tsig (lhs,rhs) 
              then chk_addrule rs (valid, (mk_wrule lhs dth r)::inv) 
              else chk_addrule rs ((mk_wrule lhs dth r)::valid, inv)
           end 
     in chk_addrule rules ([],[]) end;


  (* Creates a list of wave rules for an equality theorem, *without* 
     skipping any! *)
  fun all_wrules_of_eq_dthm tsig dth rules = 
      let 
        fun addrule r = 
            let val (lhs,rhs) = Logic.dest_equals (Thm.concl_of r) 
            in (mk_wrule lhs dth r) end
      in map addrule rules end;

  fun impwrule_of_dthm dth = 
        ImpWRule { concl = Thm.concl_of (DThm.finalthm_of dth), 
                   dthm = dth };
  fun fwd_impwrule_of_dthm dth =
    let
      val prems = Thm.prems_of (DThm.finalthm_of dth)
      fun aux [] _ = []
        | aux (h :: t) index =
          (h, index) :: (aux t (index+1))
    in
      map (fn (t, i) => FwdImpWRule { prem = (t,i), dthm = dth }) (aux prems 0)
    end

(* Creates list of partial waverules given one (equality) wave-rule *)
  fun pwrules_of_wrule waverule =
      let 
                        
        val subterms_of_wrule =
              ZipperSearch.leaves_lr (Zipper.mktop (lhsterm_of_wrule waverule))

        fun is_left_leaf [] = false
          | is_left_leaf ((Zipper.C.D.AppR _)::t) = true
          | is_left_leaf _ = false;      
      in 
        map (mk_pwrule waverule)
            (Seq.list_of (Seq.filter 
                            (fn z => (is_left_leaf(Zipper.ctxt z)) andalso 
                                     (Term.is_Const(Zipper.trm z)))
                                     subterms_of_wrule))
      end;


  fun add_wrules_of_dthm ctxt (dth, db) = 
      let val th = DThm.finalthm_of dth 
          val thry = DThm.theory_of dth 
      in 
        (* Using a dummy context, is this ok? *)
        case EqSubst.prep_meta_eq (Proof_Context.init_global thry) th of 
          [] => add_impwrule ctxt (impwrule_of_dthm dth, db)
        | rs => 
           let
           (* val wrules = wrules_of_eq_dthm2 thry dth rs *)
             val (wrules, rest_wrules) = wrules_of_eq_dthm2 thry dth rs
             val db' = add_partwrules ctxt (Library.flat (map pwrules_of_wrule wrules),db)
           (* This was intended for rippling in reverse, but we never do that
              as we don't have a ind scheme revision critic *)
           (* val db2 = add_inv_wrules (rest_wrules, db') *)
           in add_eq_wrules ctxt (wrules,db') end
      end;

  fun addall_wrules_of_dthm ctxt (dth, db) = 
      let val th = DThm.finalthm_of dth 
          val thry = DThm.theory_of dth
      in 
        case EqSubst.prep_meta_eq (Proof_Context.init_global thry) th of 
          [] => add_impwrule ctxt (impwrule_of_dthm dth,db)
        | rs => 
          let
            val wrules = all_wrules_of_eq_dthm thry dth rs
            val db' = add_partwrules ctxt (Library.flat (map pwrules_of_wrule wrules), db)
          in add_eq_wrules ctxt (wrules,db') end
      end;

  fun del_wrules_of_dthm (dth, db : T) = 
      let val th = DThm.finalthm_of dth 
      val thry = DThm.theory_of dth 
      val rules = all_wrules_of_eq_dthm 
                                  thry dth 
                                  (EqSubst.prep_meta_eq (Proof_Context.init_global thry) th)
      in
           {eqrule_net = List.foldr WRNet.delete 
                               (#eqrule_net db)
                               rules,
            inv_eqrule_net = List.foldr WRNet.delete 
                               (#inv_eqrule_net db)
                               rules,
            searchf = #searchf db,
            imprule_net = #imprule_net db,
           partrule_net = #partrule_net db,
            fwd_imprule_net = #fwd_imprule_net db} (*Should fix this!*)
      end;

  fun del_impwrules_of_dthm (dth, db : T) = 
      let val th = DThm.finalthm_of dth in 
         {searchf = #searchf db,
          eqrule_net = #eqrule_net db,
          inv_eqrule_net = #inv_eqrule_net db,
          imprule_net = Net.delete_term dthimpwrule_eq (Thm.concl_of th, dth) (#imprule_net db),
    partrule_net = #partrule_net db,
          fwd_imprule_net = #fwd_imprule_net db }
      end;

  fun delete_prems net rules rule =
    let
      fun aux net [] rule = net
        | aux net (h::t) rule =
            aux (Net.delete_term dthfwd_impwrule_eq (h, rule) net) t rule
    in
      aux net rules rule
    end

  fun del_fwd_impwrules_of_dthm (dth, db : T) = 
      let val th = DThm.finalthm_of dth in 
         {searchf = #searchf db,
          eqrule_net = #eqrule_net db,
          inv_eqrule_net = #inv_eqrule_net db,
          imprule_net = #imprule_net db,
    partrule_net = #partrule_net db,
          fwd_imprule_net = (delete_prems (#fwd_imprule_net db) (Thm.prems_of th) dth) }
      end;

(*in*)
  fun add_dthms_as_wrules ctxt (dthms, db) =
      List.foldr (add_wrules_of_dthm ctxt) db dthms;
  fun addall_dthms_as_wrules ctxt (dthms, db) =
      List.foldr (addall_wrules_of_dthm ctxt) db dthms;
  fun add_dthms_as_impwrules ctxt (dthms, db) =
      List.foldr (fn (dth,db) => add_impwrule ctxt (impwrule_of_dthm dth, db)) db dthms;
  fun add_dthms_as_fwd_impwrules ctxt (dthms, db) =
    let
      val impwrules = maps (fn x => fwd_impwrule_of_dthm x) dthms
    in
      List.foldr (fn (dth,db) => add_fwd_impwrule ctxt (dth, db)) db impwrules
    end;
  fun del_dthms_from_wrules (dthms, db) = 
      List.foldr del_wrules_of_dthm db dthms;
  fun del_dthms_from_impwrules (dthms, db) = 
      List.foldr del_impwrules_of_dthm db dthms;
  fun del_dthms_from_fwd_impwrules (dthms, db : T) =
      List.foldr del_fwd_impwrules_of_dthm db dthms;
(*end;*)


(* Note: mergeing takes 2nd search function over first *)
fun merge (db1 : T,db2 : T)= 
    {eqrule_net = WRNet.merge (#eqrule_net db1, #eqrule_net db2),
     inv_eqrule_net = WRNet.merge (#inv_eqrule_net db1, #inv_eqrule_net db2),
     searchf = get_searchf db2,
     imprule_net = Net.merge impwrule_eq 
                             (#imprule_net db1, #imprule_net db2),
     fwd_imprule_net = Net.merge fwd_impwrule_eq (#fwd_imprule_net db1, #fwd_imprule_net db2),
     partrule_net = Net.merge partwrule_eq 
                              (#partrule_net db1, #partrule_net db2)} : T;

(* *)
fun dtacs_of_eqrule prf gname (z, eqruleseq) =
    Seq.map
      (fn eqrule => 
          DTac.mk 
            ((fn ctxt => pretty_wrule_sml ctxt eqrule), 
             (fn (_,prf) => WRNet.MData.prff eqrule prf gname z)))
      eqruleseq;

fun eqrule_zipper_lookup (db : T) prf gname z = 
    Seq.maps (dtacs_of_eqrule prf gname)
            (Seq.map (fn z => (z, WRNet.matchings (get_eqrule_net db) prf gname z))
                     ((get_searchf db) z));

(* *)
fun dtac_of_impwrule prf gname impwr = 
    DTac.mk 
      ((fn ctxt => pretty_impwrule_sml ctxt impwr), 
       GTacs.of_bckf (fn _ => Prf.apply_rule_thm (thm_of_impwrule impwr) gname));

fun imprule_concl_lookup db prf gname t = 
    Seq.map 
      (dtac_of_impwrule prf gname)
      (Seq.filter 
         (fn m => 
             case Seq.pull (Prf.apply_rule_thm (thm_of_impwrule m) gname prf)
              of NONE => false
               | SOME _ => true)
         (Seq.of_list (Net.match_term (get_imprule_net db) t)));

fun fwd_imprule_prems_lookup db prf gname t =
    (Seq.map (fn (x, (y, z)) => (x, ([y], z)))
      (Seq.maps
        (fn m => Seq.map (pair m) (Prf.apply_frule_thm (thm_of_fwd_impwrule m) gname prf))
          (Seq.of_list (Net.match_term (get_fwd_imprule_net db) t))))

fun lookup (db : T) prf n = 
    let val t = Prf.get_ndname_ctrm prf n in
      (eqrule_zipper_lookup db prf n (Zipper.mktop t), 
       imprule_concl_lookup db prf n t,
       fwd_imprule_prems_lookup db prf n t) end;


val wrules_of = WRNet.dest o get_eqrule_net;
val impwrules_of = Net.entries o get_imprule_net;
val fwd_impwrules_of = Net.entries o get_fwd_imprule_net;
val partrules_of = Net.entries o get_partrule_net;

fun pretty_of_wruledb ctxt (db : T) = 
    Pretty.chunks 
      [Pretty.str "Equality Wave Rules: ",
       WRNet.pretty ctxt (#eqrule_net db),
       Pretty.str "Implication Wave Rules: ",
       Pretty.chunks (map (pretty_impwrule_sml ctxt) (impwrules_of db)),
       Pretty.str "Partial Wave Rules: ",
       Pretty.chunks (map (pretty_partwrule ctxt) (partrules_of db))
      ];

fun print ctxt db = Pretty.writeln (pretty_of_wruledb ctxt db);
fun pretty ctxt db = pretty_of_wruledb ctxt db;
    
end;


structure WRules : WRULESDB = DB_WRules;
