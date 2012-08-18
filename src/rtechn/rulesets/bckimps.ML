(* holds sets of equations, matching gives subset that maybe can be used to perform backwards resolution *)
signature BCK_IMP_RULES  =
sig
  type T (* collections of rules *)
  type rule (* a rule *)

  val empty : T
  val merge : T * T -> T

  (* basic eq for wave rules *)
  val rule_eq : rule * rule -> bool

  (* make meta info for a rule *)
  val rule_of_thm : Thm.thm -> rule 
  val rule_of_dthm : DThm.T -> rule
  val pretty_rule : rule -> Pretty.T

  (* adding/removing wave rules *)
  val add : rule -> T -> T
  val remove : rule -> T -> T

  (* lookup *)
  val match : T (* ruleset *)
        -> Term.term (* shouldn't this be a thm?? *)
        -> rule list (* matching rules *)

  (* pretty *)
  val pretty : T -> Pretty.T
  val print : T -> unit

  (* internal representation *)
  val dest : T -> (Term.term * rule) list

  val conclterm_of_rule : rule -> Term.term
  val dthm_of_rule : rule -> DThm.T
  val thm_of_rule : rule -> Thm.thm

end;


(* substitutions rules *)
structure Bckimpset : BCK_IMP_RULES = 
struct

  (* implication wave rules *)
  datatype rule = Rule of { concl : Term.term,
                             dthm : DThm.T };
  
  fun conclterm_of_rule (Rule rep) = #concl rep;
  fun dthm_of_rule (Rule rep) = #dthm rep;
  val thm_of_rule = DThm.finalthm_of o dthm_of_rule;

  fun rule_eq (a,b) = DThm.eq (dthm_of_rule a) (dthm_of_rule b);
  fun dthm_rule_eq (dth,impr) = DThm.eq (dth) (dthm_of_rule impr);

  val theory_of_rule = DThm.theory_of o dthm_of_rule; (* for pretty *)
  val global_ctxt_of_rule = ProofContext.init_global o theory_of_rule;

  fun pretty_rule r = 
      Pretty.block [Pretty.str "DThm: '", DThm.pretty (dthm_of_rule r),
                    Pretty.str "' => Thm: ", 
                    Display.pretty_thm (global_ctxt_of_rule r) (thm_of_rule r)];

  fun pretty_rule impr = 
     let val dth = (dthm_of_rule impr)
          val th = DThm.finalthm_of dth 
          val ctxt = global_ctxt_of_rule impr
     in Pretty.block [DThm.pretty dth, Pretty.str ": ",
                      Pretty.quote (Display.pretty_thm ctxt th)] 
     end;
 
  type T = rule Net.net;

  val empty = Net.empty : T;

  (* basic operations *)
  fun add rule net = 
    let val t = conclterm_of_rule rule in 
      Net.insert_term rule_eq (t, rule) net
      handle Net.INSERT => 
             (* when the same thing is inserted twice, do nothing but warn user *)   
             (tracing "WARNING: you tried to insert the same thing twice!"; net)
    end;

  fun remove rule net = 
      let val t = conclterm_of_rule rule in  
         Net.delete_term rule_eq (t, rule) net 
      end;

  fun merge (n1, n2) = Net.merge rule_eq (n1,n2);

  val dest = map (fn r => (conclterm_of_rule r,r)) o Net.entries;

  (* make rules *)
  fun mk_rule dth = 
        Rule { concl = Thm.concl_of (DThm.finalthm_of dth), 
                dthm = dth };

  val rule_of_thm = mk_rule o DThm.mk;
  val rule_of_dthm = mk_rule;

  (* pretty printing *)
  val pretty = Pretty.chunks o map (pretty_rule o snd) o dest;
  val print = Pretty.writeln o pretty;

  val match = Net.match_term;

end;

