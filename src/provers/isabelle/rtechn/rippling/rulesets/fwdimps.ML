(* holds sets of equations, matching gives subset that maybe can be used to perform substitution *)
signature FWD_IMP_RULES  =
sig
  type T (* collections of rules *)
  type rule (* a rule *)

  val empty : T
  val merge : T * T -> T

  (* basic eq for wave rules *)
  val rule_eq : rule * rule -> bool

  val rules_of_dthm : DThm.T -> rule list
  val rule_of_idx_dthm : DThm.T -> int -> rule

  val pretty_rule : rule -> Pretty.T

  (* adding/removing wave rules *)
  val add : rule -> T -> T
  val remove : rule -> T -> T
  (* add and remove in a directed way *)

  (* lookup *)
  val match : T (* ruleset *)
        -> Term.term  (* should we require that the assm number is given? *)
        -> rule list (* matching rules, meaning has to be applied for each goal*)

  (* pretty *)
  val pretty : T -> Pretty.T
  val print : T -> unit

  (* internal representation *) (* fixme *)
  val dest : T -> (Term.term * rule) list

  val prem_of_rule : rule -> Term.term * int
  val prem_term_of_rule : rule -> Term.term
  val prem_idx_of_rule : rule -> int
  val dthm_of_rule : rule -> DThm.T
  val thm_of_rule : rule -> Thm.thm

end;


(* substitutions rules *)
structure Fwdimpset : FWD_IMP_RULES = 
struct

  datatype rule = Rule of { prem : (Term.term * int),
 (* note: need the int to represent premise number, so don't get INSERT exception *)
                                     dthm : DThm.T };

  fun prem_of_rule (Rule rep) = #prem rep;
  val prem_term_of_rule = fst o prem_of_rule;
  val prem_idx_of_rule = snd o prem_of_rule;

  fun dthm_of_rule (Rule rep) = #dthm rep
  fun thm_of_rule (Rule rep) = DThm.finalthm_of (#dthm rep)

  fun rule_eq (left, right) =
      let
        val i = prem_idx_of_rule left
        val a = dthm_of_rule left
        val j = prem_idx_of_rule right
        val b = dthm_of_rule right
      in  ((DThm.eq a b) andalso (i=j)) end;

  fun dthrule_eq (dth, r) = DThm.eq dth (dthm_of_rule r)

  val theory_of_rule = DThm.theory_of o dthm_of_rule; (* for pretty *)
  val global_ctxt_of_rule = ProofContext.init_global o theory_of_rule;

  fun pretty_rule r =
    let
      val dth = (dthm_of_rule r)
      val th = DThm.finalthm_of dth
    in
      Pretty.block [
        DThm.pretty dth, Pretty.str " : ",
        Pretty.quote (Display.pretty_thm (global_ctxt_of_rule r) th)]
    end

  type T = rule Net.net;

  val empty = Net.empty : T;

  (* basic operations *)
  fun add rule net = 
    let val t = prem_term_of_rule rule in 
      Net.insert_term rule_eq (t, rule) net
      handle Net.INSERT => 
             (* when the same thing is inserted twice, do nothing but warn user *)   
             (tracing "WARNING: you tried to insert the same thing twice!"; net)
    end;

  fun remove rule net = 
      let val t = prem_term_of_rule rule in Net.delete_term rule_eq (t, rule) net end;

  fun merge (n1, n2) = Net.merge rule_eq (n1,n2);

  (* dest: implicit Net.net, gives back MData.T list *)
  val dest = map (fn r => (prem_term_of_rule r,r)) o Net.entries;

  (* pretty printing *)
  val pretty = Pretty.chunks o map (pretty_rule o snd) o dest;
  val print = Pretty.writeln o pretty;

  (* may raise exception *)
  fun rule_of_idx_dthm dth i = 
     let val t = List.nth (Thm.prems_of (DThm.finalthm_of dth),i) in 
       Rule { prem = (t,i), dthm = dth }
     end;

  fun rules_of_dthm dth =
    let
      val prems = Thm.prems_of (DThm.finalthm_of dth)
      fun aux [] _ = []
        | aux (h :: t) index =
          (h, index) :: (aux t (index+1))
    in
      map (fn (t, i) => Rule { prem = (t,i), dthm = dth }) (aux prems 0)
    end

  val match = Net.match_term; 


end;

