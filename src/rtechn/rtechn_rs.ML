structure TacticTab =
struct

 structure Data = Theory_Data(struct 
    type T = (Thm.thm list -> Proof.context -> tactic) StrName.NTab.T
    val empty =  StrName.NTab.empty;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 exception undefined_strat_exp of string;

 val get_all_tactics = Data.get;

 fun get_tactic th name =
    case StrName.NTab.lookup (Data.get th) name of 
      NONE => raise undefined_strat_exp name
    | SOME v => v;

 val add_tactic = Data.map o StrName.NTab.ins;
 val add_tactic_list =  Data.map o (fold StrName.NTab.ins);

end; (* structure *)



(* RULESETS *)

(* invariants
       dom(unfold) = ran(fold)
       ran(fold) = dom(unfold)
       dom(or_fold) = ran(or_unfold)
       ran(or_unfold) = dom(or_fold)
       x : dom(or_fold) implies card(lookup(x,or_fold)) > 1
       dom(try) = dom(else) 
       disjoint(unfold,fold,or_fold,or_unfold,try,else)
*)
structure Strategy_RS =
struct 

  val unfold_tag : TagName.name = TagName.mk "unfold"; (* hgraph *)
  val fold_tag : TagName.name = TagName.mk "fold"; (* hgraph - dual of fold *)
  val or_fold_tag : TagName.name = TagName.mk "or_fold"; (* or - similar to hgraph but could be many matches *)
  val or_unfold_tag : TagName.name = TagName.mk "or_unfold"; (* dual to or fold *)
  val try_tag : TagName.name = TagName.mk "try"; (* should only be one match! *)
  val else_tag : TagName.name = TagName.mk "else"; (* should only be one match! *)

  fun rs_get_unfold rs = Strategy_Theory.Ruleset.get_rules_in_tag rs unfold_tag;
  fun rs_get_fold rs = Strategy_Theory.Ruleset.get_rules_in_tag rs fold_tag; 

  fun rs_get_or_unfold rs = Strategy_Theory.Ruleset.get_rules_in_tag rs or_unfold_tag;
  fun rs_get_or_fold rs = Strategy_Theory.Ruleset.get_rules_in_tag rs or_fold_tag; 

  fun rs_get_try rs = Strategy_Theory.Ruleset.get_rules_in_tag rs try_tag;
  fun rs_get_else rs = Strategy_Theory.Ruleset.get_rules_in_tag rs else_tag; 

  fun rs_add_rule tag rule rs =
    rs |> Strategy_Theory.Ruleset.add_fresh_rule (R.mk (TagName.dest tag),rule) 
       |> (fn (rname,rs') => Strategy_Theory.Ruleset.tag_rule rname tag rs')
       |> Strategy_Theory.Ruleset.activate_tag tag;

  (* note a bug in Rule.symmetric - it is just identity *)
  fun symmetric_rule r = 
    Strategy_Theory.Rule.mk (Strategy_Theory.Rule.get_rhs r, Strategy_Theory.Rule.get_lhs r);

  (* assume rhs: nesting box, lhs: graph *)
  fun rs_add_nested rule = 
    rs_add_rule unfold_tag rule
    #> rs_add_rule fold_tag (symmetric_rule rule);

  (* assume rhs: or box, lhs: graph *)
  fun rs_add_single_or rule =
    rs_add_rule or_unfold_tag rule
    #> rs_add_rule or_fold_tag (Strategy_Theory.Rule.symmetric rule);

  (* generalises single or to or list *)
  val rs_add_or_list = fold rs_add_single_or;
  
  fun rs_add_or rule1 rule2 = (rs_add_single_or rule2) o (rs_add_single_or rule1);

  fun rs_add_try rtry relse = 
    rs_add_rule try_tag rtry
    #> rs_add_rule else_tag relse;
   
  val rs_delete_rule = Strategy_Theory.Ruleset.delete_rule;

  (* activation *)

  val rs_activate_fold = Strategy_Theory.Ruleset.activate_tag fold_tag;
  val rs_activate_unfold =  Strategy_Theory.Ruleset.activate_tag unfold_tag;
  val rs_activate_or_fold =  Strategy_Theory.Ruleset.activate_tag or_fold_tag;
  val rs_activate_or_unfold = Strategy_Theory.Ruleset.activate_tag or_unfold_tag;
  val rs_activate_try = Strategy_Theory.Ruleset.activate_tag try_tag
                   #> Strategy_Theory.Ruleset.activate_tag else_tag;

  val rs_deactivate_fold = Strategy_Theory.Ruleset.deactivate_tag fold_tag;
  val rs_deactivate_unfold =  Strategy_Theory.Ruleset.deactivate_tag unfold_tag;
  val rs_deactivate_or_fold =  Strategy_Theory.Ruleset.deactivate_tag or_fold_tag;
  val rs_deactivate_or_unfold = Strategy_Theory.Ruleset.deactivate_tag or_unfold_tag;
  val rs_deactivate_try = Strategy_Theory.Ruleset.deactivate_tag try_tag
                   #> Strategy_Theory.Ruleset.deactivate_tag else_tag;

  fun rs_activate_all rs =
   fold
     Strategy_Theory.Ruleset.activate_rule
    (Strategy_Theory.Ruleset.get_all_rule_names_list rs)
    rs;

  fun rs_deactivate_all rs = 
   fold
     Strategy_Theory.Ruleset.deactivate_rule
    (Strategy_Theory.Ruleset.get_all_rule_names_list rs)
    rs;

  (* in isabelle theory context *)
  structure Ctxt = Theory_Data(struct 
    type T = Strategy_Theory.Ruleset.T
    val empty = Strategy_Theory.Ruleset.empty;
    val extend = I;
    fun merge (rs1,rs2) = Strategy_Theory.Ruleset.merge rs1 rs2;
  end);

  structure Theory =
  struct
    val get_ruleset = Ctxt.get;
    val update = Ctxt.map;
    fun add_nested rule = update (rs_add_nested rule);
    fun add_or rule1 rule2 = update (rs_add_or rule1 rule2);
    fun add_or_list orls = update (rs_add_or_list orls); 
    fun add_try rtry relse = update (rs_add_try rtry relse);
    fun delete_rule rule = update (rs_delete_rule rule);

    val activate_fold = update rs_activate_fold;
    val activate_unfold = update rs_activate_unfold;
    val activate_or_fold = update rs_activate_or_fold;
    val activate_or_unfold = update rs_activate_or_unfold;
    val activate_try = update rs_activate_try;

    val deactivate_fold = update rs_deactivate_fold;
    val deactivate_unfold = update rs_deactivate_unfold;
    val deactivate_or_fold = update rs_deactivate_or_fold;
    val deactivate_or_unfold = update rs_deactivate_or_unfold;
    val deactivate_try = update rs_deactivate_try;

    val activate_all = update rs_activate_all;
    val deactivate_all = update rs_deactivate_all;

  end; (* struct *)

end;
