structure GFact = StrName;

structure PNode =
struct

  exception gnode_exp of string;

  type gname = StrName.name;
  type factname = GFact.name;

  (* add 
      - information about tactic
      - support for hierarchies ?
  *)
  datatype gnode = Goal of 
    { name : gname,
      ctxt : Proof.context,
      assms : Thm.thm StrName.NTab.T, (* split into local and global *)
      lassms : StrName.NSet.T, (* invariant: lassm subseteq domain(assms) *)
      fixes : string list,
      goal : Thm.thm,
      (* needs to be a list to keep it in order *)
      result : (gname list) option, (* NONE indicates open, SOME [] indicates complete *)
      prev : pnode} (* name should be sufficient - look up rest in Prf *)
  and 
   (* G should really just be name and context? *)
   pnode = G of gnode | R of Proof.context;

  type gtab = gnode StrName.NTab.T;

  fun get_name (Goal rep) = #name rep;
  fun get_ctxt (Goal rep) = #ctxt rep;
  fun get_assms (Goal rep) = #assms rep;
  fun get_lassms (Goal rep) = #lassms rep;
  fun get_fixes (Goal rep) = #fixes rep;
  fun get_goal (Goal rep) = #goal rep;
  fun get_result (Goal rep) = #result rep;
  fun get_prev (Goal rep) = #prev rep;

  val get_all_assms = StrName.NTab.values o get_assms;

  fun update_name f (Goal rep) = Goal
   {name = f (#name rep), ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep};

  fun update_ctxt f (Goal rep) = Goal
   {name = #name rep, ctxt = f (#ctxt rep), assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep};

  fun update_assms f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = f (#assms rep), lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep};

  fun update_lassms f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = f (#lassms rep),
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep};

  fun update_fixes f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
   fixes = f (#fixes rep),  goal = #goal rep, result = #result rep, prev = #prev rep};

  fun update_goal f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
   fixes = #fixes rep,  goal = f (#goal rep), result = #result rep, prev = #prev rep};

  fun update_result f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = f (#result rep), prev = #prev rep};

  fun update_prev f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = f (#prev rep)};

  fun mk_goal name ctxt0 ctxt1 goal =
   Goal {name = name, ctxt = ctxt1, assms = StrName.NTab.empty,  
         lassms = StrName.NSet.empty, fixes = [], goal = goal, result = NONE, 
         prev = R ctxt0}; 

  val set_name = update_name o K;
  val set_ctxt = update_ctxt o K;
  val set_assms = update_assms o K;
  val set_lassms = update_lassms o K;
  val set_fixes = update_fixes o K;
  val set_goal = update_goal o K;
  val set_result = update_result o K;
  val set_prev = update_prev o K;

  val set_goal_prev = set_prev o G;

  fun ctxt (R ctxt) = ctxt
   |  ctxt (G (Goal rep)) = #ctxt rep;

  fun parent_ctxt (Goal rep) = ctxt (#prev rep);

  fun assms_of (R _) = StrName.NTab.empty
   |  assms_of (G (Goal rep)) = (#assms rep);

end



