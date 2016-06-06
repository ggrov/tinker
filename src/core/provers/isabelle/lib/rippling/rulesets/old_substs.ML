(* holds sets of equations, matching gives subset that maybe can be used to perform substitution *)
signature SUBSTS_RULES  =
sig

  exception rule_exp of string*Thm.thm;

  type T (* collections of rules *)
  type rule (* a rule *)

  (* add not_rule exception ?? for creating rules that is... *)

  val empty : T
  val merge : T * T -> T

  (* basic eq for wave rules *)
  val rule_eq : rule * rule -> bool

  (* make meta info for a rule *)
  val rule_of_thm : Proof.context -> Thm.thm -> rule (* raises rule_exp *)
(*  val rule_of_dthm : Proof.context -> DThm.T -> rule (* raises rule_exp *) *)
 
  (* pretty print rule *)
  val pretty_rule : rule -> Pretty.T

  (* adding/removing wave rules *)
  val add : rule -> T -> T
  val remove : rule -> T -> T

  (* lookup *)
  val match : T (* ruleset *)
        -> Term.term
        -> (Zipper.T * rule) list (* matching rules at the given zipper *)
  
  val match_at :
      T -> Zipper.T (* zipper in result to look under *)
      -> rule list

  (* pretty *)
  val pretty : T -> Pretty.T
  val print : T -> unit

  (* internal representation *)
  val dest : T -> (Term.term * rule) list

  val lhs_of_rule : rule -> Term.term
  val dthm_of_rule : rule -> DThm.T
  val thm_of_rule : rule -> Thm.thm
  val ienv_of_rule : rule -> InstEnv.T

end;


(* substitutions rules *)
structure Substset : SUBSTS_RULES = 
struct

  exception rule_exp of string*Thm.thm;

  (* equational wave rules *)
  datatype rule = Rule of {lhs : Term.term,
                           ienv : InstEnv.T,
                           dthm : DThm.T, (* thm with attributes *)
                           thm : Thm.thm }; (* (same as dthm) meta equality rule *)
  
  fun lhs_of_rule (Rule rep) = #lhs rep;
  fun dthm_of_rule (Rule rep) = #dthm rep;
  fun thm_of_rule (Rule rep) = #thm rep;
  fun ienv_of_rule (Rule rep) = #ienv rep;

  fun rule_eq (a,b) = DThm.eq (dthm_of_rule a) (dthm_of_rule b);

  val theory_of_rule = DThm.theory_of o dthm_of_rule; (* for pretty *)
  val global_ctxt_of_rule = ProofContext.init_global o theory_of_rule;

  fun pretty_rule r = 
      Pretty.block [Pretty.str "Lhs: '", Syntax.pretty_term @{context} (lhs_of_rule r), (* FIXME: can I use @{context} here? *)
                    Pretty.str "DThm: '", DThm.pretty (dthm_of_rule r),
                    Pretty.str "' => Thm: ", 
                    Display.pretty_thm (global_ctxt_of_rule r) (thm_of_rule r)];
  fun pretty_rule_sml r = 
      Display.pretty_thm (global_ctxt_of_rule r) (thm_of_rule r);

  type T = rule Net.net;

  val empty = Net.empty : T;

  (* basic operations *)
  fun add rule net = 
    let val t = lhs_of_rule rule in 
      Net.insert_term rule_eq (t, rule) net
      handle Net.INSERT => 
             (* when the same thing is inserted twice, do nothing but warn user *)   
             (tracing "WARNING: you tried to insert the same thing twice!"; net)
    end;

  fun remove rule net = 
      let val t = lhs_of_rule rule in Net.delete_term rule_eq (t, rule) net end;

  fun merge (n1,n2) = Net.merge rule_eq (n1,n2);

  val dest = map (fn r => (lhs_of_rule r,r)) o Net.entries;

  (* pretty printing *)
  val pretty = Pretty.chunks o map (pretty_rule o snd) o dest;
  val print = Pretty.writeln o pretty;

 (* creating rules *)
  fun ienv_of_thm th = 
      InstEnv.of_trm (ProofContext.init_global (Thm.theory_of_thm th))
        (Logic.list_implies (* hack to get one term from a term 
                               and it's flexies *)
           (map Logic.mk_equals (Thm.tpairs_of th),
            Thm.prop_of th));
      
 (* THINK: maybe use dattrthm's instead of doing it in subst? *)
  fun mk_rule lhs dthm thm =
      Rule { lhs = lhs,
             ienv = ienv_of_thm thm,
             dthm = dthm,
             thm = Thm.put_name_hint (DThm.long_name_of dthm) thm};


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
  (* check if the new term has any meta variables not in the old term *)
  fun has_new_typ_vars (old, new) =
      (case lrem (op =) (Trm.tvars_of old) (Trm.tvars_of new) of
         [] => false
       | (_::_) => true);

  fun is_not_valid_rwrule thy (lhs, rhs) =
      Term.is_Var (Term.head_of lhs) 
      orelse has_new_vars (lhs,rhs)
      orelse has_new_typ_vars (lhs,rhs)
      orelse Pattern.matches_subterm thy (lhs, rhs)
      orelse (case lhs of
               Const("HOL.True",_) => true
             | Const("HOL.False",_) => true
             | _ => false);

  fun rule_of_thm ctx thm = 
     case EqSubst.prep_meta_eq ctx thm of 
          [] => raise rule_exp ("no equality type",thm)
        | [th] => 
             let val (lhs,rhs) = Logic.dest_equals (Thm.concl_of th)
                 val dthm = DThm.mk th
             in (* fixme: seems to always fail -- should we just skip it? *)
                (* if is_not_valid_rwrule (ProofContext.theory_of ctx) (lhs, rhs) 
                 then raise rule_exp ("not valid rewrite rule",thm)
                 else *) mk_rule lhs dthm th
             end
        | _ => raise rule_exp ("many potential rules",thm); (* or should accept this and return a list? *)

  fun match_at net z = Net.match_term net (Zipper.trm z) ;
  
  fun match net t = 
    let fun ch_match z = map (fn r => (z,r)) (Net.match_term net (Zipper.trm z)) in
       maps ch_match (Seq.list_of (ZipperSearch.all_td_lr (Zipper.mktop t)))
    end;

end;

