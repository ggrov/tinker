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

  (* pretty print rule *)
  val pretty_rule : rule -> Pretty.T

  (* adding/removing wave rules, note that the order of the args is for the purpose of using fold easily *)
  val add :  rule -> T ->  T
  val remove : rule -> T ->  T

  (* get a rule from thm and name, if not applicable for rule then NONE *)
  val rule_of_thm :  (StrName.name * thm) -> rule option
  (* get lhs and rhs from a thm, if it's not an equality, exception will be raised  *)
  val strip_lhs_rhs : thm -> (term * term)
  
  (* pretty *)
  val pretty : T -> Pretty.T
  val print : T -> unit

  val lhs_of_rule : rule -> Term.term
  val name_of_rule : rule -> StrName.name
  val thm_of_rule : rule -> Thm.thm

  val mk_sym_thm : Thm.thm -> Thm.thm

  (* lookup: changed due to it's more easier to apply it as tactics, but it might be less efficient *)
  val match : theory -> T -> term -> (int * rule) list
end;


(* substitutions rules *)
structure SubstsetDB  = 
struct

  exception rule_exp of string*Thm.thm;

  (* equational wave rules *)
  datatype rule = Rule of {
                           lhs : Term.term,
                           name : StrName.name, (* thm with attributes *)
                           thm : Thm.thm }; (* (same as dthm) meta equality rule *)
  
  fun lhs_of_rule (Rule rep) = #lhs rep;
  fun name_of_rule (Rule rep) = #name rep;
  fun thm_of_rule (Rule rep) = #thm rep;

  fun rule_eq (a,b) = Thm.eq_thm ((thm_of_rule a), (thm_of_rule b));

  fun mk_sym_thm thm = Thm.symmetric (safe_mk_meta_eq thm);

  val global_ctxt_of_rule = Proof_Context.init_global o (fn _ => @{theory});

  fun pretty_rule r = 
      Pretty.block [Pretty.str "Lhs: '", Syntax.pretty_term @{context} (lhs_of_rule r), (* FIXME: can I use @{context} here? *)
                    Pretty.str "Name: '",  Pretty.str (name_of_rule r),
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

  fun strip_lhs_rhs thm = Logic.dest_equals (Thm.concl_of (safe_mk_meta_eq thm))

  fun rule_of_thm (name, thm) = 
    let val (lhs, _) = strip_lhs_rhs thm in
    SOME (Rule {lhs = lhs, name = name, thm = thm})end
    handle _ => (tracing ("[eqrule: " ^ name ^ "not valid for wrules!]"); NONE);

  fun merge (n1,n2) = Net.merge rule_eq (n1,n2);

  val dest = map (fn r => (lhs_of_rule r,r)) o Net.entries;

  (* pretty printing *)
  val pretty = Pretty.chunks o map (pretty_rule o snd) o dest;
  val print = Pretty.writeln o pretty

  fun mk_searchinfo thy gtrm = 
    let val ctrm = (Thm.cterm_of thy gtrm);
    val maxid = (#maxidx (rep_cterm ctrm)) in
    (thy, maxid, Zipper.mktop gtrm) end;


  fun match_lhs thy gtrm lhs =
    EqSubst.searchf_lr_unify_valid (mk_searchinfo thy gtrm) lhs
    |> Seq.flat

  fun match thy db t = 
    let
      val rule_list = Net.entries db;
    in 
      map 
      (fn r => 
        match_lhs thy t (lhs_of_rule r)
        |> Seq.list_of
        |> length
        |> (fn x => (x, r))) (* return num of matched occurances paired with the rules *)
      rule_list
      |> (* filter out which have no matched occreances *)
        filter (fn(x, y) => if x > 0 then true else false)
    end

end;

structure WRule = Named_Thms
  (val name = @{binding "wrule"}
   val description = "Theorems for rippling");
val wrule_add = Thm.declaration_attribute WRule.add_thm
val wrule_del = Thm.declaration_attribute WRule.del_thm

structure Substset: SUBSTS_RULES = SubstsetDB;

