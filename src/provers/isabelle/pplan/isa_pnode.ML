structure PNode =
struct

  exception gnode_exp of string;

  type gname = StrName.name;
  type factname = StrName.name;

  (* add 
      - information about tactic
      - support for hierarchies ?
  *)

  (* e.g.
     by tactic using fact: thms:
     by rules     using 
     by frule     of     
  *)
  datatype desc_typ =
    DTac of string * ((string * string list) list) (* tac name + configs: (type,args) pair *) 
  | DRule of string (* rule used *)
  | DErule of string (* rule used *)
  | DFrule of string * string (* assumption name + rule used *)
  | DSubst of string (* rule used *)
  | DSubstAsm of string * string (* assumption name + rule name used *)

  datatype step = BCK | FWD | OPEN

  datatype desc = Desc of {
    desc_typ : desc_typ,
    desc_thms : string list,
    desc_facts : string list };

  datatype T = Goal of 
    { name : gname,
      ctxt : Proof.context,
      assms : Thm.thm StrName.NTab.T, (* split into local and global *)
      lassms : StrName.NSet.T, (* invariant: lassm subseteq domain(assms) *)
      fixes : string list,
      goal : Thm.thm,
      (* needs to be a list to keep it in order *)
      result : (gname list) option, (* NONE indicates open, SOME [] indicates complete *)
      prev : pnode, (* name should be sufficient - look up rest in Prf *)
      desc : desc option}
  and 
   (* G should really just be name and context? *)
   pnode = G of T | R of Proof.context;

  (* update record for tactic information *)

  fun get_desc_typ (Desc desc) = #desc_typ desc;
  fun get_desc_thms (Desc desc) = #desc_thms desc;
  fun get_desc_facts (Desc desc) = #desc_facts desc;

  fun update_desc_typ f (Desc desc) = 
    Desc {desc_typ =  f (#desc_typ desc), desc_thms = #desc_thms desc, desc_facts = #desc_facts desc}
  fun update_desc_thms f (Desc desc) = 
    Desc {desc_typ =  #desc_typ desc, desc_thms = f (#desc_thms desc), desc_facts = #desc_facts desc}
  fun update_desc_facts f (Desc desc) = 
    Desc {desc_typ =  #desc_typ desc, desc_thms = #desc_thms desc, desc_facts = f (#desc_facts desc)}

  val set_desc_typ = update_desc_typ o K;
  val set_desc_thms = update_desc_thms o K;
  val set_desc_facts = update_desc_facts o K;

  (* information for proof node *)

  fun get_name (Goal rep) = #name rep;
  fun get_ctxt (Goal rep) = #ctxt rep;
  fun get_assms (Goal rep) = #assms rep;
  fun get_lassms (Goal rep) = #lassms rep;
  fun get_fixes (Goal rep) = #fixes rep;
  fun get_goal (Goal rep) = #goal rep;
  fun get_result (Goal rep) = #result rep;
  fun get_prev (Goal rep) = #prev rep;
  fun get_desc (Goal rep) = #desc rep;


  val get_all_assms = StrName.NTab.values o get_assms;
  val get_hyp = StrName.NTab.get o get_assms;

  fun update_name f (Goal rep) = Goal
   {name = f (#name rep), ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep, desc = #desc rep};

  fun update_ctxt f (Goal rep) = Goal
   {name = #name rep, ctxt = f (#ctxt rep), assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep, desc = #desc rep};

  fun update_assms f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = f (#assms rep), lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep, desc = #desc rep};

  fun update_lassms f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = f (#lassms rep),
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep, desc = #desc rep};

  fun update_fixes f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
   fixes = f (#fixes rep),  goal = #goal rep, result = #result rep, prev = #prev rep, desc = #desc rep};

  fun update_goal f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
   fixes = #fixes rep,  goal = f (#goal rep), result = #result rep, prev = #prev rep, desc = #desc rep};

  fun update_result f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = f (#result rep), prev = #prev rep, desc = #desc rep};

  fun update_prev f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = f (#prev rep), desc = #desc rep};

  fun update_desc f (Goal rep) = Goal
   {name = #name rep, ctxt = #ctxt rep, assms = #assms rep, lassms = #lassms rep,
    fixes = #fixes rep, goal = #goal rep, result = #result rep, prev = #prev rep, desc = f (#desc rep)};


  fun mk_goal name ctxt0 ctxt1 goal =
   Goal {name = name, ctxt = ctxt1, assms = StrName.NTab.empty,  
         lassms = StrName.NSet.empty, fixes = [], goal = goal, result = NONE, 
         prev = R ctxt0, desc = NONE}; 

  val set_name = update_name o K;
  val set_ctxt = update_ctxt o K;
  val set_assms = update_assms o K;
  val set_lassms = update_lassms o K;
  val set_fixes = update_fixes o K;
  val set_goal = update_goal o K;
  val set_result = update_result o K;
  val set_prev = update_prev o K;
  val set_desc = update_desc o K;

  val set_goal_prev = set_prev o G;

  val set_some_desc = update_desc o K o SOME;
  fun set_desc_only_typ typ = 
     set_some_desc (Desc {desc_typ = typ, desc_thms = [], desc_facts = []});

  fun ctxt (R ctxt) = ctxt
   |  ctxt (G (Goal rep)) = #ctxt rep;

  fun parent_ctxt (Goal rep) = ctxt (#prev rep);

  fun assms_of (R _) = StrName.NTab.empty
   |  assms_of (G (Goal rep)) = (#assms rep);

  (* 
     checks if context has been extended
     -> what about forward proof?
   *)
  fun empty_list [] = true
   |  empty_list _ = false

  fun check_ctxt_extended node =
    StrName.NSet.is_empty (get_lassms node) andalso
    empty_list (get_fixes node)

  (* working with tactic type *)
 
  fun get_step pnode = 
     case get_desc pnode of 
       NONE => OPEN
     | (SOME d) => 
         (case get_desc_typ d of
              (DFrule _) => FWD
            | (DSubstAsm _) => FWD
            | _ => BCK);

  (* no brackets around! *)
 
  fun pretty_fixes node =
    if empty_list (get_fixes node)
     then []
     else [Pretty.block ((Pretty.str "fixes: "):: Pretty.commas (map Pretty.str (get_fixes node)))];

  fun pretty_goal (ctxt:Proof.context) gname thm = 
   Pretty.block 
    [Pretty.str gname,
     Pretty.str ":", 
     Syntax.pretty_term ctxt (Thm.concl_of thm)];

  fun pretty_hyp node gname =
   Pretty.block 
    [Pretty.str gname,
     Pretty.str ":", 
     Display.pretty_thm (get_ctxt node) (StrName.NTab.get (get_assms node) gname)];

  fun pretty_hyps node =   
    if StrName.NSet.is_empty (get_lassms node) then []
    else
      [ StrName.NSet.list_of (get_lassms node)
        |> map (pretty_hyp node)
        |> (fn l => l @ [Pretty.str "|---------"])
        |> Pretty.chunks
      ];
   
  fun pretty_sequent node =
    (pretty_hyps node)
    @
    [pretty_goal (get_ctxt node) (get_name node) (get_goal node)]

  fun pretty_result node = 
    case get_result node of 
      NONE => Pretty.str "[ ?gap ]"
    | (SOME []) => Pretty.str "[ by ??? ]"
    | (SOME res) => 
        Pretty.enclose "[" "]" 
           ([Pretty.str " to : "] @ (Pretty.commas (map Pretty.str res)) @ [Pretty.str " by ??? "]);

  fun pretty node = 
    ((pretty_fixes node) @ (pretty_sequent node) @ [pretty_result node])
    |> Pretty.chunks;  

end

