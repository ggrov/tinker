(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      aprf.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Updated:    29 Nov 2006
    Date:       20 Dec 2005
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Abstract Proofs                                                    

    abstract concept of proof, dependencies, contexts, goals ==> graph 

   Note: implicit invarients: 
   1. ienv, denv and vars must be talking about the same set of vars
   2. connected, 
   3. open goals are the ones with MOpen method
   4. the contexts match the ones in the nodes 
   5. contexts match each other ancestors
   6. params are all in the right context 
   7. subproofs in compound methods really are subproofs 
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature APRF =
sig

  type gname
  type cxname

  structure Cx : PRF_CX 
      where type cxname = cxname
        and type ncol = Goaln.NSet.T  (* for asms and haves *)

  val default_gname : gname
  val gname_eq : gname * gname -> bool
  
  (* atomic method *)
  type mname = string
  type methkind
  type optmeth
  type meth
  (* node justification, nodes in proof, proof *)
  type nd
  type T

  exception term_is_not_valid_exp of (string * Trm.T);

  (* structure RTree : RTREE where type gname = gname and type meth = meth *)
  type rtree = RTree.T;
  type conj (* context + RTree.T *)

  type result = (gname * nd) * (cxname * Cx.T);

  
  exception subst_exp of string * (gname * result * Zipper.T * T);

  val methkind_tac : (Thm.thm * (Tactical.tactic * Pretty.T)) -> methkind
  val methkind_thm : Thm.thm -> methkind
  val methkind_res : gname -> methkind

  val optmeth_closed : methkind * gname list -> optmeth
  val optmeth_open : optmeth

  val meth_asm : meth;
  val meth_opt : optmeth (* open or closed of methkind *)
                 * Goaln.NSet.T (* avoids *)
                 -> meth;

  exception var_types_dont_match_exp of Var.name * Trm.typ * Trm.typ;
  exception tyvar_sorts_dont_match_exp of Var.name * Trm.sort * Trm.sort;
  exception assumption_out_of_scope_exp of gname * cxname * T;
  exception resolve_names_out_of_scope_exp of gname * gname;
  exception not_an_open_goal_exp of gname;
  exception not_a_closed_goal_exp of gname;
  exception not_an_open_nd_exp of nd;
  exception asm_node_exp of string;
  exception unimplemented_exp of string;

  val get_theory : T -> Context.theory
  val get_context : T -> Proof.context
  val get_goals : T -> nd Goaln.NTab.T
  val get_open_gnames : T -> Goaln.NSet.T
  val get_top_cxname : T -> cxname
  val get_top_ncx : T -> cxname * Cx.T
(*   val get_top_result_names : T -> Goaln.NSet.T   *)
  val get_open_vars : T -> (TVar.name * Trm.sort) list 
                           * (Var.name * Trm.typ) list
(*   val get_denv : T -> DepEnv.T *)
  val get_ienv : T -> InstEnv.T
  val set_ienv : InstEnv.T -> T -> T

  val update_goals : (nd Goaln.NTab.T -> nd Goaln.NTab.T) -> T -> T
  val update_goal : (nd -> nd) -> gname -> T -> T
(*   val update_denv : (DepEnv.T -> DepEnv.T) -> T -> T *)
  val update_ienv : (InstEnv.T -> InstEnv.T) -> T -> T

  val set_open_gnames : Goaln.NSet.T -> T -> T
  val add_open_gnames : Goaln.NSet.T -> T -> T

  val get_nd : T -> gname -> nd
  val get_cx : T -> cxname -> Cx.T
  val get_ncx : T -> cxname -> cxname * Cx.T
  val get_nd_cx : T -> nd -> Cx.T
  val get_nd_ncx : T -> nd -> cxname * Cx.T
  val get_ndname_cxname : T -> gname -> cxname
  val get_ndname_cx : T -> gname -> Cx.T
  val get_ndname_ncx : T -> gname -> cxname * Cx.T

  val get_ndname_ctrm : T -> gname -> Trm.T
  val get_ndname_lasmstab : T -> gname -> Goaln.NSet.T

  val get_ndname_aasmstab : T -> gname -> Goaln.NSet.T
  val get_result_aasm_rtrees : T -> result -> rtree list
  val get_result_lasm_rtrees : T -> result -> rtree list

  val nd_get_trm : nd -> Trm.T
  val nd_get_cxname : nd -> cxname
  val nd_get_avoid_of_opennd : nd -> Goaln.NSet.T option
  val nd_update_meth : (meth -> meth) -> nd -> nd

  val close_open_goal_with : 
     (methkind * gname list) -> gname -> T -> T

  (* init w.r.t. a theory. *)
  val init : Proof.context -> T
  val set_context : Proof.context -> T -> T
  val update_context : (Proof.context -> Proof.context) -> T -> T

  val read_top_term : T -> string -> Trm.T
  val read_prop : T -> string -> Trm.T

  val get_result : T -> gname -> result (* (gname * nd) * (cxname * Cx.T) *)

  (* Underlying notion of creating a new node: instantiate and choose fresh name *)
  val new_node : 
      cxname (* cx name *)
      -> meth (* meth *)
      -> gname (* suggested name *)
      -> Trm.T (* the term *)
      -> T 
      -> (gname * nd);

  (* Underlying notion of adding a node. new node must be made from given plan *)
  val add_node : (gname * nd) -> T -> T;

  (* result trees of things *)
  val rtree_of_result_wlasms : T -> result -> rtree; 
  val rtree_of_result_waasms : T -> result -> rtree; 
  val rtree_of_gname_wlasms : T -> gname -> rtree; 
  val rtree_of_gname_waasms : T -> gname -> rtree; 
  val rtree_of_gname : T -> gname -> rtree; (* just conclusion *)

  (* assumes that rtree was made for this conjext! *)
  val add_rtree : 
      meth 
      -> Proof.context
      -> Cx.ancestors
      -> Cx.ptab (* outer fixes *)
      -> Goaln.NSet.T (* outer asumptions *)
      -> rtree
      -> T 
      -> rtree * T
  val add_rtrees :
      meth 
      -> Proof.context
      -> Cx.ancestors
      -> Cx.ptab
      -> Goaln.NSet.T 
      -> rtree list
      -> T 
      -> rtree list * T
    
    val add_result_rtree_under_ncx :
       optmeth * Goaln.NSet.T ->
       cxname * Cx.T ->
       rtree -> T -> rtree * T
    val add_result_rtrees_under_ncx :
       optmeth * Goaln.NSet.T ->
       cxname * Cx.T ->
       rtree list -> T -> rtree list * T

(*   val add_result_rtrees_under_ncx *)

  (* make a new conjecture within cxname *)
  val conjecture_rtree : rtree -> cxname -> T -> rtree * T

  (* There is a symmetry between vars and params, and between
  asssumptions and subgoals: these function move between them. What is
  in each representations defines what you want to
  synthesise/prove. *) (* tricky to do: how to avoid param name
  conflict? Idea: global unique param names with local nicename. *)
(* val param_to_var : Var.pname -> T -> T
   val var_to_param : Var.name -> T -> T
   val asm_to_goal : gname -> T -> T
   val goal_to_asm : gname -> T -> T *)

  val assert_is_open : T -> gname -> unit (* raises exception if false *)

  (* internal *) 
  val inst_prf : InstEnv.T -> T -> T

  (* internal notion of resolution against goals (snd argument is goal)  *)
  (* 1step resolution *)
  val apply_resol_bck : 
      gname (* fact *)
      -> gname (* goal *)
      -> T
      -> (gname list * T) Seq.seq

  (* paramodulation *)
  val apply_subst_to_result :
      gname (* equation *)
      -> result (* result *)
      -> Zipper.T (* zipper spec loc in result term *)
      -> T
      -> ((gname * (* new fact, subst has been applied, subgoal for bck proof *)
           (gname list)) (* subgoal names, includes when subst in goal *)
          * T) Seq.seq



  (* pushing a fact whose context is on the same level as Cx.T *)
  val lift_and_show_result 
      : result (* lift this result *)
        -> Goaln.NSet.T (* have these assumptions of the result into subgoals *)
        -> cxname * Cx.T (* into this context *)
        -> T (* in this prf *)
        -> ((RTree.T * RTree.T list) (* new fact and assumptions to show *)
            * T)

  val lift_and_show_above_rtree 
      : gname (* lift this result R *)
        -> gname list (* these assums of R become subgoals *)
        -> gname (* into the context of this result *)
        -> T (* in this prf *)
        -> ((RTree.T * RTree.T list) (* new fact and assumptions to show *)
            * T) (* subgoals *)

  val mk_subprf_into_meth : 
      mname (* method name *)
      -> gname list (* facts that are derived in subprf and pulled out *)
      -> gname list (* goal list that are refined in subprf *)
      -> T (* subprf *)
      -> T (* prf *)
      -> (gname list * T) (* new subgoals and prf with compound method *)

(* HYPER resolution would be nice 
  val apply_hyp_resol : 
      gname (* result conclusion name *)
      -> gname option (* optionally resolve conclusion of result with this *)
      -> (gname * gname) list (* resolve away introduced subgoals against other results/local assumptions *)
      -> T
      -> (gname list * T) Seq.seq
*)

  val mk_thm : T -> gname 
               -> (Thm.thm (* theorem *)
                   * Thm.cterm list) (* open subgoal terms as hidden hyps *)

  val local_context_lifting : T
      -> Cx.cxname * Cx.T
      -> Cx.cxname * Cx.T -> Cx.ncol * Lifting.lifting * InstEnv.T


(*   val apply_meth : gname -> mname -> T
              -> (gname list * T) Seq.seq *)

  (* pretty printing *)
  val pretty_gname : gname -> Pretty.T;

  val pretty_node : T -> gname -> Pretty.T
  val print_node : T -> gname -> unit

  val pretty : T -> Pretty.T
  val pretty_goal_concls : T -> Pretty.T
  val pretty_wrt : T -> gname -> Pretty.T
  val pretty_open : T -> Pretty.T
  val pretty_script : T -> Pretty.T
  val pretty_full : T -> Pretty.T

  val print : T -> unit
  val print_goal_concls : T -> unit
  val print_wrt : T -> gname -> unit
  val print_script : T -> unit
  val print_open : T -> unit
  val print_full : T -> unit
                        
end;


structure DB_APrf 
= struct

exception unimplemented_exp of string;

exception var_types_dont_match_exp of Var.name * Trm.typ * Trm.typ;
exception tyvar_sorts_dont_match_exp of Var.name * Trm.sort * Trm.sort;

(* table of goal names *)
type gname = Goaln.NTab.name;
type cxname = Cxn.NTab.name;
type mname = string;

structure Cx = Cx;

(* IMRPOVE: make contexts self contained & use a var/context depenv *)

datatype methkind
  = MKindRes of gname 
  | MKindSubst of gname
  | MKindPrf of mname * T
  | MKindThm of Thm.thm
  | MKindTac of (Thm.thm * (Tactical.tactic * Pretty.T))
and optmeth
  = MOpen 
  | MClosed of methkind * gname list (* subgoals *) 
and meth 
  = Meth of optmeth * Goaln.NSet.T (* things this cannot use: avoids *)
  | AsmMeth (* assumed *)
and nd
  = Node of 
    { cx : cxname, (* goal name in which this context arrises *)
      trm : Trm.T,    (* the goal concl term *)
      meth : meth } (* proof method *)
and T 
  = Proof of 
    { top_cxname : cxname, (* top level context *)
      context : Proof.context,
      denv : DepEnv.T, (* to manage meta variables/goal deps *)
      ienv : InstEnv.T, (* to manage meta variable names, instantiations, ff-pairs *)
      goals : nd Goaln.NTab.T,
      ctxts : Cx.T Cxn.NTab.T,
      opengs : Goaln.NSet.T };

  (* result Trees *)
  type rtree = RTree.T;

  (*  conjectures: *)
  datatype conj = Conj of (cxname * Cx.T) * RTree.T;

  (* results with their context *)
  type result = (gname * nd) * (cxname * Cx.T);

  (* exceptions *)
  exception resolve_names_out_of_scope_exp of gname * gname;
  exception not_an_open_goal_exp of gname;
  exception not_an_open_nd_exp of nd;
  exception not_an_asssumption_exp of gname * T;
  exception assumption_out_of_scope_exp of gname * cxname * T;
  exception not_a_closed_goal_exp of gname;
  exception asm_node_exp of string;

(* method construction *)
val methkind_tac = MKindTac
val methkind_thm = MKindThm;
val methkind_res = MKindRes;

val optmeth_tac = MKindTac;
val optmeth_thm = MKindThm;
val optmeth_res = MKindRes ;
val optmeth_closed = MClosed ;
val optmeth_open = MOpen;

val meth_asm = AsmMeth;
val meth_opt = Meth;

(* node stuff *)
fun nd_get_trm (Node rep) = #trm rep;
fun nd_get_cxname (Node rep) = #cx rep;
fun nd_get_meth (Node rep) = #meth rep;
fun nd_is_asm nd = 
    (case nd_get_meth nd of AsmMeth => true | _ => false);
fun nd_is_open nd = 
    (case nd_get_meth nd of Meth(MOpen,_) => true | _ => false);

fun nd_get_avoid_of_opennd nd = 
    (case nd_get_meth nd of Meth(MOpen,avoid) => SOME avoid | _ => NONE);

(* fun nd_get_avoid (Node rep) = ;
    (case nd_get_meth nd 
      of MethAsm => NONE 
       | MethDep (mopt, avoid) => SOME avoid); *)

(* this node, or a parent, is used in the proof of x, 
   so x must be after this goal *)
fun nd_needed_after nd x = 
    (case nd_get_meth nd 
      of AsmMeth => false 
       | Meth (mopt, avoid) => 
         Goaln.NSet.contains avoid x);

fun nd_mk cx trm meth =  
    Node { cx = cx,
           trm = trm,
           meth = meth };

fun nd_inst i (Node rep) = 
     Node { cx = #cx rep,
            trm = InstEnv.inst_trm i (#trm rep),
            meth = #meth rep };

fun nd_update_meth f (Node rep) = 
    Node { cx = #cx rep,
           trm = #trm rep,    
           meth = f (#meth rep) };

val nd_set_meth = nd_update_meth o K;

fun nd_set_trm t (Node rep) = 
    Node { cx = #cx rep,
           trm = t,
           meth = #meth rep };

fun nd_set_cxname cxname (Node rep) =
    Node { cx = cxname,
           trm = #trm rep,
           meth = #meth rep };

(* basics *)
  val default_gname = "a"
  val gname_eq = op = : gname * gname -> bool;
  val cxname_eq = op = : cxname * cxname -> bool; 
  val pretty_gname = Pretty.str;

  (* helper function for folding *)
  fun addfst_to_list f (l, x) = 
      let val (a,x2) = (f x) in (a::l, x2) end;

fun get_context (Proof rep) = #context rep;
fun get_theory p = ProofContext.theory_of (get_context p);
fun get_top_cxname (Proof rep) = #top_cxname rep;
fun get_ienv (Proof rep) = #ienv rep;
fun get_denv (Proof rep) = #denv rep;
fun get_goals (Proof rep) = #goals rep;
fun get_ctxts (Proof rep) = #ctxts rep;
fun get_open_gnames (Proof rep) = #opengs rep;

fun is_open p g = Goaln.NSet.contains (get_open_gnames p) g;

fun update_goals f (Proof rep) = 
      Proof { top_cxname = #top_cxname rep,
              context = #context rep,
              denv = #denv rep,
              ienv = #ienv rep,
              goals = f (#goals rep),
              ctxts = #ctxts rep,
              opengs = #opengs rep };

fun update_goal f id = 
    update_goals (Goaln.NTab.map_entry f id);

fun update_open_gnames f (Proof rep) = 
      Proof { top_cxname = #top_cxname rep,
              context = #context rep,
              denv = #denv rep,
              ienv = #ienv rep,
              goals = #goals rep,
              ctxts = #ctxts rep,
              opengs = f (#opengs rep) };
val set_open_gnames = update_open_gnames o K;
val add_open_gnames = update_open_gnames o Goaln.NSet.union_merge;
val close_open_goal = update_open_gnames o Goaln.NSet.delete


fun update_context f (Proof rep) = 
      Proof { top_cxname = #top_cxname rep,
              context = f (#context rep),
              denv = #denv rep,
              ienv = #ienv rep,
              goals = #goals rep,
              ctxts = #ctxts rep,
              opengs = #opengs rep };

val set_context = update_context o K;


(* ***  

fun try_rename_gname n1 n2 (Proof rep) = 
      Proof { top_cxname = #top_cxname rep,
              context = #context rep,
              denv = DepEnv.rename_gname n1 n2 (#denv rep),
              ienv = #ienv rep,
              goals = #goals rep,
              ctxts = #ctxts rep,
              opengs = f (#opengs rep) };

*)


fun close_nd mkind_subgoals nd = 
    (case nd_get_meth nd
      of Meth(MOpen,avoids) => 
         nd_set_meth (Meth(MClosed mkind_subgoals,avoids)) nd
       | _ => raise not_an_open_nd_exp nd);

(* implicit prf *)
fun close_open_goal_with mkind_subgoals gid = 
    (close_open_goal gid) #> (update_goal (close_nd mkind_subgoals) gid);

(* update depenv *)
fun update_denv f (Proof rep) = 
    Proof { top_cxname = #top_cxname rep,
            context = #context rep,
            denv = f (#denv rep),
            ienv = #ienv rep,
            goals = #goals rep,
            ctxts = #ctxts rep,
            opengs = #opengs rep };
val set_denv = update_denv o K;

fun update_ienv f (Proof rep) = 
    Proof { top_cxname = #top_cxname rep,
            context = #context rep,
            denv = (#denv rep),
            ienv = f (#ienv rep),
            goals = #goals rep,
            ctxts = #ctxts rep,
            opengs = #opengs rep };

val set_ienv = update_ienv o K;

fun get_nd (p as (Proof rep)) nid = 
    Goaln.NTab.get (#goals rep) nid;
fun get_cx (p as (Proof rep)) cid = 
    Cxn.NTab.get (#ctxts rep) cid;
fun get_ncx p cid = (cid, get_cx p cid);

fun update_ctxts f (Proof rep) = 
    Proof { top_cxname = #top_cxname rep,
            context = #context rep,
            denv = #denv rep,
            ienv = #ienv rep,
            goals = #goals rep,
            ctxts = f (#ctxts rep),
            opengs = #opengs rep };
val set_ctxts = update_ctxts o K;

fun update_cx f cxname = 
    update_ctxts (Cxn.NTab.map_entry f cxname);
fun set_cx v cxname = update_cx (K v) cxname;

val get_ndname_cxname = nd_get_cxname oo get_nd;
fun get_nd_cx p nd = get_cx p (nd_get_cxname nd);
fun get_nd_ncx p nd = 
    let val cxn = nd_get_cxname nd
    in (cxn, get_cx p cxn) end;
fun get_ndname_cx p gid = get_cx p (get_ndname_cxname p gid);
fun get_ndname_ncx p gid = 
    let val cxn = nd_get_cxname (get_nd p gid)
    in (cxn, get_cx p cxn) end;
val get_ndname_ptabs = Cx.get_fixes oo get_ndname_cx;
val get_ndname_ctrm = nd_get_trm oo get_nd

(* Representation note: When a node "nid" is a member of the local
assumptions of its own context, we treat it having no further
conditions. If this is the case, then any assumptions of "nid" exclude
those within it's own context - further assumptions in it's context
are not conditions to it, but siblings. 

Invarient: top context is always empty.
*)

fun get_ndname_lasmstab p nid = 
    let val cx = get_ndname_cx p nid
      val lasms = Cx.get_lasms cx
    in if Goaln.NSet.contains lasms nid then Goaln.NSet.empty
       else lasms
    end;
fun get_ndname_aasmstab p nid = 
    let val cx = get_ndname_cx p nid
      val lasms = Cx.get_lasms cx
    in if Goaln.NSet.contains lasms nid then 
       (* safe becasue top context contain no assumptions *)
         Cx.get_aasms (get_cx p (Cx.get_parent cx))
       else Cx.get_aasms cx
    end;

fun get_top_ncx p = 
    let val top_cxname = (get_top_cxname p)
    in (top_cxname, get_cx p top_cxname) end;

fun get_top_cx p = 
    get_cx p (get_top_cxname p);

(* fun get_top_result_names p = 
    Cx.get_haves (get_cx p (get_top_cxname p)); *)
fun get_top_asm_names p = 
    Cx.get_aasms (get_top_cx p);
fun get_top_fixes_names p = 
    Cx.get_fixes (get_top_cx p);

(* NOTE: invarient of the realationship between denv and ienv is assumed:
   all uninst vars in ienv also occur in denv.  *)
fun get_open_var_names p = 
    let val denv = get_denv p
    in (DepEnv.get_tvars denv, DepEnv.get_vars denv) end;
fun get_open_vars p = 
    let val ienv = get_ienv p
    in (InstEnv.uninst_tvars_of ienv, InstEnv.uninst_vars_of ienv) end;

fun get_top_ncx p = 
    let val cxn = get_top_cxname p
    in (cxn, get_cx p cxn) end;

(* used by prf.ML *)
fun assert_is_open p g = 
    if is_open p g then ()
    else raise not_an_open_goal_exp g;

(* val goal_trm = nd_get_ndname_concl_trm o get_nd; *)
(* fun ext_goal_concl_trm p n = 
    let val nd = get_nd p n in
      nd_ext_goal_concl_trm (get_cx p (nd_get_cxname nd), nd)
    end; *)

(* fun ext_goal_trm p = nd_ext_goal_trm o (get_nd p); *)
(* fun goal_concl_thm p n = 
    let val nd = get_nd p n in
      nd_ext_goal_concl_thm (get_theory p) (get_cx p (nd_get_cxname nd), nd)
    end; *)

(* fun goal_thm p = nd_ext_goal_thm (get_theory p) o (get_nd p); *)

(* initial proof has an empty top context *)
fun init in_context = 
    let 
      (* the top-level context - terms can contain schematic vars *)
      val context = ProofContext.set_mode (ProofContext.mode_schematic) 
                                          in_context;
      val top_cx = Cx.empty context;
      val (top_cxname, ctxts) = 
          Cxn.NTab.add (Cx.default_cxname,top_cx) Cxn.NTab.empty
    in
      Proof { top_cxname = top_cxname,
              context = context,
              denv = DepEnv.empty,
              ienv = InstEnv.init context,
              goals = Goaln.NTab.empty,
              ctxts = ctxts,
              opengs = Goaln.NSet.empty }
    end;


fun read_top_term ap s = 
    Syntax.read_term (get_context ap) s;
    (* ProofContext.read_term (ProofContext.init (get_theory ap)) s; *)
    (* Sign.read_term (get_theory ap) s; *)

(* reads a prop, adds schematic vars to ctxt and does type inference *)
fun read_prop' s ctxt = 
    let val t = Syntax.read_prop ctxt s in t end;
      
(*       val t' = hd (Variable.polymorphic ctxt [t]) (* length invariant *)
      val t'' = Term.map_types TypeInfer.paramify_vars t'
      val ctxt' = ctxt |> Variable.declare_constraints t''
    in (t'',ctxt) end; *)

(* 
fun read_prop s p = 
    let val (t,ctxt2) = read_prop' s (get_context p)
    in (t,set_context ctxt2 p) end;
*)

fun read_prop p s = read_prop' s (get_context p);

(* add vars to dependency environment *)
fun add_uninsts_to_denv gname ienv denv = 
    DepEnv.add (TVar.NSet.of_list (InstEnv.uninst_tvar_names_of ienv),
                Var.NSet.of_list (InstEnv.uninst_var_names_of ienv))
               (Goaln.NSet.single gname)
               denv;

(* handy function to wrap lots of ifo about a node together *)
fun get_result ap result_name = 
    let
      val result_nd = get_nd ap result_name
      val result_cxname = nd_get_cxname result_nd
      val result_cx = get_cx ap result_cxname
    in ((result_name,result_nd),(result_cxname,result_cx)) end;
    
fun get_cx_asms ap cx = 
    map (fn n => (n,get_nd ap n)) (Goaln.NSet.list_of (Cx.get_aasms cx));

exception term_is_not_valid_exp of string * Trm.T;

(* Make a new node for adding to p -- should be signed by "p" that it
can be added. Creates a fresh name, and instantiates term using proff
ienv. *)
fun new_node cxname meth trygname in_t (p as Proof rep) =
    let 
      (* new name for this goalnode *)
      val gname = Goaln.NSet.new (Goaln.NTab.get_nameset 
                                    (get_goals p)) trygname;
      (* instantiate node *)
      val t = InstEnv.inst_trm (#ienv rep) in_t

      (* sanity check: cterm is ok *) 
      val _ = (Sign.cert_prop (get_theory p) t)
           handle Term.TYPE _ => 
                  (* cannot include p here: causes infinite because 
                     it is badly formed too. *)
                 raise term_is_not_valid_exp ("new_node: badly formed term (is it PROP type?) given to prf",t);

    in (gname, nd_mk cxname t meth) end;

(* add a node to the proof graph. Adds in variable names and dependencies. *)
fun add_node (nnd as (gname,nd)) (p as Proof rep) = 
    let 
      (* update variables tables: may re-add vars already in the
      table, they will keep old context and may not change type! *)
      (* IMPROVE: change of_trm to add_trm, avoid thry merge *)
      val new_ienv = InstEnv.of_trm (get_context p) (nd_get_trm nd)
      val depenv2 = add_uninsts_to_denv gname new_ienv (#denv rep)          

      (* update goal nodes table - we use update as we 
         already created the name: the only time it is ok to do this *)     
      val goals2 = Goaln.NTab.update nnd (#goals rep);

      (* add to open goals if we have no method attached *)
      val opengs2 = if nd_is_open nd then 
                      Goaln.NSet.ins_fresh gname (#opengs rep)
                    else #opengs rep;
     in
      Proof { top_cxname = #top_cxname rep,
              context = #context rep,
              denv = depenv2,
              ienv = InstEnv.merge_union new_ienv (#ienv rep),
              goals = goals2,
              ctxts = #ctxts rep,
              opengs = opengs2 }
    end;


(* add a new sub context with local params ps under cx 
   we assume that newps is distinct from cx.fixes and allps = 
   newps + cx.fixes *)
fun add_cx (suggested_cxname,cx) (p as Proof rep) = 
    let 
      val (cxname, ctxts2) = 
          Cxn.NTab.add (suggested_cxname,cx) (#ctxts rep)
    in (cxname, set_ctxts ctxts2 p) end;

(* make and add a new subcontext, with given stuff, under context cx *)
fun add_sub_cx newps allps newasms 
               suggested_name
               (cxname,cx) p = 
    let 
      val cx2 = Cx.mk 
                  (Cx.get_isar_ctxt cx)
                  (Cx.add_ancestor cxname (Cx.get_ancestors cx))
                      newps allps newasms
                      (Goaln.NSet.union_merge newasms (Cx.get_aasms cx))
      val (cx2_name, p2) = add_cx (suggested_name, cx2) p
    in ((cx2_name,cx2), p2) end;

(* add local asms to a named context -- asssumes that cx is up to date *)
fun add_lasms_to_cx asmnames (cxname,cx) (p : T) = 
    let val cx2 = Cx.add_lasms asmnames cx in 
      (cx2, set_cx cx2 cxname p) end;


(* gettting result trees. Important invarients: 1. assumption are never
more than one level bellow a result. 2. Assumptions assumed by a context
and also in that context assume nothing more and fix nothing. *)
fun rtree_of_result p r = 
    let 
      fun rtree_rec ((gname,nd),(cxname,cx)) = 
          (* if we are a local asm of this context, 
             then we fix nothing and assume nothing more *)
          if Goaln.NSet.contains (Cx.get_lasms cx) gname then 
            RTree.mk gname Cx.empty_ptab (nd_get_trm nd) []
          else 
            RTree.mk gname (Cx.get_lfixes cx) (nd_get_trm nd) [];
    in rtree_rec r end;


(* gettting result trees. Important invarients: 1. assumption are never
more than one level bellow a result. 2. Assumptions assumed by a context
and also in that context assume nothing more and fix nothing. *)
fun rtree_of_result_wlasms p r = 
    let 
      fun rtree_rec ((gname,nd),(cxname,cx)) = 
          (* if we are a local asm of this context, 
             then we fix nothing and assume nothing more *)
          if Goaln.NSet.contains (Cx.get_lasms cx) gname then 
            RTree.mk gname Cx.empty_ptab (nd_get_trm nd) []
          else 
            RTree.mk gname (Cx.get_lfixes cx) (nd_get_trm nd)
                     (map (rtree_rec o get_result p) 
                          (Goaln.NSet.list_of (Cx.get_lasms cx)));
    in rtree_rec r end;

fun rtree_of_result_waasms p r = 
    let 
      fun rtree_rec ((gname,nd),(cxname,cx)) = 
          (* if we are a local asm of this context, 
             then we fix nothing and assume nothing more *)
          if Goaln.NSet.contains (Cx.get_lasms cx) gname then 
            RTree.mk gname Cx.empty_ptab (nd_get_trm nd) []
          else 
            RTree.mk gname (Cx.get_lfixes cx) (nd_get_trm nd)
                     (map (rtree_rec o get_result p) 
                          (Goaln.NSet.list_of (Cx.get_aasms cx)));
    in rtree_rec r end;

(* all assumption trees of a result *)
fun get_result_aasm_rtrees p (r as ((nid,_),(_,cx))) = 
    map (rtree_of_result_wlasms p o get_result p)
        (Goaln.NSet.list_of 
           (if Goaln.NSet.contains (Cx.get_lasms cx) nid then 
              (* safe becasue top context contain no assumptions *)
                Cx.get_aasms (get_cx p (Cx.get_parent cx))
            else Cx.get_aasms cx));

(* local assumption trees of a result *)
fun get_result_lasm_rtrees p (r as ((nid,_),(_,cx))) = 
    let val lasms = Cx.get_lasms cx
    in 
      if Goaln.NSet.contains lasms nid then []
      else 
        map (rtree_of_result_wlasms p o get_result p)
            (Goaln.NSet.list_of lasms)
    end;

(* rtrees from names *)
fun rtree_of_gname_wlasms p gname = 
    rtree_of_result_wlasms p (get_result p gname);

fun rtree_of_gname_waasms p gname = 
    rtree_of_result_wlasms p (get_result p gname);

fun rtree_of_gname p gname = 
    rtree_of_result p (get_result p gname);

(* generic rtree addition: assume rtree params are correct (renamed
lfixes uniquely, and fixes = lfixes + ancestor params) for the given
ancestor contexts. *)
fun add_rtree meth isar_ctxt ancestors pfixes pasms rt p =
    if RTree.has_context rt then 
      let  (* make a new subcontext for this result, if needed *)
        val (cxname,ctxts) = 
            Goaln.NTab.new_name Cx.default_cxname (get_ctxts p)
        val (nnd as (nd_name, nd)) = 
            new_node cxname meth (RTree.get_name rt) (RTree.get_ctrm rt) p
        val p = p |> set_ctxts ctxts
                  |> add_node nnd;
        (* val _ = writeln ("added_compound: " ^ nd_name ^ " into cx: " ^ cxname); *)
        val lfixes = RTree.get_lfixes rt 
        val fixes = Cx.append_disjoint_ptab lfixes pfixes
        val (asms,p) = 
            add_rtrees AsmMeth isar_ctxt
                       (Cx.add_ancestor cxname ancestors) 
                       fixes Goaln.NSet.empty 
                       (RTree.get_asms rt)
                       p;
        val asm_names_list = map RTree.get_name asms;
        val asm_names_col = Goaln.NSet.of_list asm_names_list
        val cx = (Cx.mk 
                    isar_ctxt
                    ancestors lfixes fixes 
                    asm_names_col (Goaln.NSet.union_merge pasms asm_names_col))
                   |> Cx.inst_params (get_ienv p) (* could be moved for efficiency *)
        val p = update_ctxts (Cxn.NTab.update (cxname, cx)) p
      in (* update rtree to have correct names *) 
           (rt |> RTree.set_asms asms
               |> RTree.set_name nd_name,  p)
      end
    else (* no new subcontext is needed, just add under the old one *)
      let 
        val cxname = Cx.first_ancestor ancestors
        val (nnd as (nd_name, nd)) = 
            new_node cxname meth (RTree.get_name rt) (RTree.get_ctrm rt) p
        val p = add_node nnd p
        (* val _ = writeln ("added_base: " ^ nd_name ^ " into cx: " ^ cxname);*)
      in (rt |> RTree.set_name nd_name, p) end

and add_rtrees meth isar_ctxt ancestors fixes asms result_list p0 =
    apfst rev
    (List.foldl
       (fn (rt,(L,p1)) => 
           let val (rt2,p2) = 
                   add_rtree meth isar_ctxt ancestors fixes asms rt p1
           in (rt2 :: L,p2) end)
       ([],p0) result_list); 

(* adding assumption rtrees: implicit rtree p *)
fun add_assumed_rtree_under_ncx (ncx as (cxn,cx)) = 
    add_rtree AsmMeth (Cx.get_isar_ctxt cx)
              (Cx.ancestor_inc ncx) (Cx.get_fixes cx) 
              Goaln.NSet.empty;
fun add_assumed_rtrees_under_ncx (ncx as (cxn,cx)) = 
    add_rtrees AsmMeth (Cx.get_isar_ctxt cx) 
               (Cx.ancestor_inc ncx) (Cx.get_fixes cx) 
               Goaln.NSet.empty;

(* adding result rtrees: implicit rtree p *)
fun add_result_rtree_under_ncx meth (ncx as (cxn,cx)) = 
    add_rtree (Meth meth) (Cx.get_isar_ctxt cx)
              (Cx.ancestor_inc ncx) (Cx.get_fixes cx) 
              (Cx.get_aasms cx);
fun add_result_rtrees_under_ncx meth (ncx as (cxn,cx)) = 
    add_rtrees (Meth meth) 
               (Cx.get_isar_ctxt cx)
               (Cx.ancestor_inc ncx) (Cx.get_fixes cx) 
               (Cx.get_aasms cx);


(* update tree for being in the given context: rename params, update
     meth and uses *)
fun move_rtree_under_cx cx rt = 
    RTree.rename (Cx.get_fixes cx, Cx.empty_renaming) rt;

(* make a conjecture of a ctree *)
fun conjecture_rtree rtree cxname p = 
    add_result_rtree_under_ncx 
      (MOpen, Goaln.NSet.empty) (cxname, get_cx p cxname) rtree p;

(* adding various kinds of dependencies of vars *)
fun add_tt_deps (tv,subtvars) denv =
          let val deps = DepEnv.get_tvdeps denv tv
          in Basics.fold
              (fn x => DepEnv.add_tvdeps x deps)
              subtvars denv
          end;
fun add_vt_deps (v,subtvars) denv =
          let val deps = DepEnv.get_vdeps denv v
          in Basics.fold
              (fn x => DepEnv.add_vdeps x deps)
              subtvars denv
          end;
fun add_vv_deps (v,subvars) denv =
          let val deps = DepEnv.get_vdeps denv v
          in Basics.fold
              (fn x => DepEnv.add_vdeps x deps)
              subvars denv
          end;

(* FIXME: should use a context dependency table for quicker
instantiation of contexts... right now we will get slow with many type
var instantiations *)
fun inst_ctxts i ctxttab = 
    if InstEnv.no_inst_tvars i then ctxttab
    else Cxn.NTab.map_all (K (Cx.inst_params i)) ctxttab;

(* fun add_var_inst IMPROVE: think about nature of instantiation a proof plan !!! *)

(* Does not add any new vars to the varnames table *)
(* THINK: what about type-vars in fixed params? *)
fun inst_prf i (p as (Proof rep)) = 
    let 
      val tvs = InstEnv.inst_tvars_of i
      val vs = InstEnv.inst_vars_of i

      (* merge in the variable instantiations *)
      val ienv2 = InstEnv.merge_intersect_snd i (#ienv rep)

      val denv = #denv rep;

      val changedgoals = 
          List.foldr 
            (fn (v,gs) => 
                Goaln.NSet.union_merge
                  (DepEnv.get_vdeps denv v) gs)
            Goaln.NSet.empty
            vs;
      val changedgoals2 = 
          List.foldr 
            (fn (tv,gs) => 
                Goaln.NSet.union_merge
                  (DepEnv.get_tvdeps denv tv) gs)
            changedgoals
            tvs;
      val goals2 = 
          fold 
            (Goaln.NTab.map_entry (nd_inst i))
            (Goaln.NSet.list_of changedgoals2)
            (#goals rep);

      val ((ty_ty_deps, ty_v_deps), v_v_deps) = InstEnv.dep_updates i;
      
      (* consider: could we have an instenv for just the prfenv plan -
      and this way avoid trying to remove deps associated with new
      variables etc? *)
      val denv2 = 
          denv |> InstEnv.TVTab.fold add_tt_deps ty_ty_deps
               |> InstEnv.VTab.fold add_vt_deps ty_v_deps
               |> InstEnv.VTab.fold add_vv_deps v_v_deps
               |> fold DepEnv.del_tvar tvs
               |> fold DepEnv.del_var vs;

      val ctxts = inst_ctxts i (#ctxts rep);

    in Proof { top_cxname = #top_cxname rep,
               context = #context rep,
               denv = denv2,
               ienv = ienv2,
               goals = goals2,
               ctxts = ctxts,
               opengs = #opengs rep }
    end;

  (* lifts up cx to the point when it shares a common context with
  intocx, and then finds lifting into intocx. subgoals is the
  assumoptions of cx upto the shared context with cx. *)
  (* IMPROVE: add notion of type parameter lifting *)
  fun local_context_lifting p (intoncx as (_,intocx)) (ncx as (_,cx)) = 
      let (* find common parent context *)
        val p_cxname = Cx.first_common_ancestor intoncx ncx;
        val p_cx = get_cx p p_cxname;
        (* parameters to vars with arguments *)
        val local_params = Cx.get_trmps_of_ptab (Cx.params_beyond cx p_cx);
        val overparams = Cx.get_fixed_trm_ps intocx;
        val (lifting, ienv') = Lifting.mk overparams local_params (get_ienv p);
        (* carried assumptions *)
        val asm_names = Cx.asms_beyond cx p_cx;
      in (asm_names, lifting, ienv') end;

(* add subgoals, vars, and instantiations, from a unification
step. Note: we must instantiate the proof env first, then when we get
the rtree's they will be instantiated.  We inst prf to propegate inst
to update vars in different locations. set the ienv because we want
any new terms added to get instantiated by the new ienv. This assumes
we are given the newienv - which includes old insts.  IMRPOVE: fix and
use separating of vars to save instantiation work *)
fun add_unif_subgoals subgnames avoid lifting gncx ienv p = 
    let val p = (* inst prf, but only with vars that were in it before *)
            p |> inst_prf ienv
(* (InstEnv.select_fst (get_ienv p) ienv) *) (* for deps *)
              |> set_ienv ienv  (* adds new vars *)
        val subgoal_rtrees = 
            map ((rtree_of_gname_wlasms p)
                   #> (RTree.put_in_ncx gncx)
                        #> (RTree.map_trm 
                         ((* InstEnv.inst_trm ienv -- happens when added to aprf *)
                                Lifting.lift lifting)))
                (Goaln.NSet.list_of subgnames);
        val (subtrees,p) = add_result_rtrees_under_ncx 
                             (MOpen,avoid) gncx subgoal_rtrees p;
    in (subtrees,p) end;

(* true if a result is applicable to another one: r must be an
applicable assumption or a result which will not create a loop of
reasoning and is not the goal. *)
fun applicable ((rn,rnd),(rcxn,rcx)) ((gn,gnd),(gcxn,gcx)) = 
    (* aplpicable assumption *)
    (Goaln.NSet.contains (Cx.get_aasms gcx) rn)
    orelse 
    (not (Goaln.name_ord (rn,gn) = EQUAL)
     andalso (* result node *)
     ((not (nd_needed_after gnd rn) andalso not (nd_is_asm rnd))
      orelse (* in the same context as asm concl *)
      (nd_is_asm rnd andalso Cx.cxname_eq (rcxn, gcxn))));

  (* rebind things that were replaced with frees *)
  fun rebindctxt zctxt t = 
      let fun recf k (t as Free (n,ty)) = 
              (case Library.find_index (fn (a,ty2) => a = n) zctxt 
                of ~1 => t | i => Bound (i + k))
            | recf k (Abs(s,ty,t)) = Abs(s,ty,recf (k+1) t)
            | recf k (t1 $ t2) = 
              (recf k t1) $ (recf k t2)
            | recf _ t = t;
      in recf 0 t end;

  (* IMPROVE: generalise common aspects of resol and subst *)
  (* apply the result of forward an equational rewriting step *)
  fun apply_subst_fwd_result r_name r_rhs 
        asm_names avoid (z,zctxt) ((g_name,g_nd),g_ncx as (g_cxn,g_cx))
        lifting p ienv = 
      let
        val (subtrees, p) = 
            add_unif_subgoals asm_names avoid lifting g_ncx ienv p;
        val subgnames = (map RTree.get_name subtrees);
        val (snnd as (substgoalname,substgoalnd)) = 
            new_node 
              g_cxn (Meth(MClosed (MKindSubst r_name, 
                                   g_name::subgnames), avoid)) g_name
              (InstEnv.inst_trm 
                 ienv
                 (Zipper.top_trm (Zipper.set_trm (rebindctxt zctxt r_rhs) z)))
              p
      in ((substgoalname, subgnames), add_node snnd p) end;      

  (* apply the result of an equational rewriting step to a goal *)
  fun apply_subst_bck_result r_name r_rhs 
        asm_names avoid (z,zctxt) ((g_name,g_nd),g_ncx as (g_cxn,g_cx))
        lifting p ienv = 
      let
        val (subtrees, p) = 
            add_unif_subgoals asm_names avoid lifting g_ncx ienv p;
        val (snnd as (substgoalname,substgoalnd)) = 
            new_node 
              g_cxn (Meth(MOpen, avoid)) g_name
              (InstEnv.inst_trm 
                 ienv (Zipper.top_trm (Zipper.set_trm (rebindctxt zctxt r_rhs) z)))
              p
        val p = add_node snnd p
        val subgnames = (map RTree.get_name subtrees);
        val p = close_open_goal_with 
                  (MKindSubst r_name, substgoalname::subgnames) g_name p;
      in ((substgoalname, subgnames), p) end;


  (* make the new subgoals of a goal resolution step *)
  fun apply_resol_bck_result
        r_name asm_names avoid
        ((g_name,g_nd),gncx as (_,g_cx))
        lifting p 
        ienv = 
      let
        val (subtrees, p) = 
            add_unif_subgoals asm_names avoid lifting gncx ienv p;
        val subgnames = map RTree.get_name subtrees;
        val p = close_open_goal_with (MKindRes r_name, subgnames) g_name p;
      in (subgnames, p) end;

  (* get goal avoids if rr is applicable to gr, else raise exception *)
  fun goal_avoids (rr as ((rn,rnd),_)) (gr as ((gn : gname,gnd),_)) = 
      if applicable rr gr then
        case nd_get_meth gnd 
         of Meth(MOpen, gavoid) => 
            gavoid |> Goaln.NSet.add gn 
                   |> (case nd_get_meth rnd of 
                         AsmMeth => Goaln.NSet.add rn 
                       | Meth(_,ravoid) => 
                             Goaln.NSet.union_merge 
                               (Goaln.NSet.add rn ravoid))
          | _ => raise not_an_open_goal_exp gn
      else raise resolve_names_out_of_scope_exp (rn, gn);

  (* resolve one result with an open goal *)
   fun apply_resol_bck r_name g_name p = 
      let 
        val (g_r as ((_,g_nd),(gncx as (g_cxname,g_cx)))) = 
            get_result p g_name;
        val (r_r as ((_,r_nd),(rncx as (r_cxname,r_cx)))) = 
            get_result p r_name;
        val avoid = goal_avoids r_r g_r;

        val (asm_names,lifting,ienv2) = 
            local_context_lifting p gncx rncx;
        val fixes_to_allify = Cx.get_fixed_trm_ps g_cx;
        val r_concl = (nd_get_trm r_nd) 
                        |> Lifting.lift lifting
                        |> Trm.absify_params fixes_to_allify;
        val g_term = (nd_get_trm g_nd)
                       |> Trm.absify_params fixes_to_allify;
            (* must be after result and transitive closure of after *) 
        val unifs = MyUnify.unifiers (ienv2, [(r_concl, g_term)]);
      in
        Seq.map (apply_resol_bck_result 
                   r_name asm_names avoid g_r lifting p) unifs
      end;

   (* if we are subst under some extra local binders we need to create
      a new context *)
   fun mk_subst_cx z (old_gncx as (old_g_cxname,old_g_cx)) p = 
       let 
        (* also abstract over these *)
        val ((zctxt,renaming),allfixes) = 
            Trm.TrmParams.refresh_name_list 
              (Zipper.nty_ctxt z) 
              (([],Trm.TrmParams.NTab.empty), Cx.get_fixed_trm_ps old_g_cx)
        val new_ptab =
            Cx.mk_ptab (Trm.TypParams.empty, Trm.TrmParams.of_plist zctxt)
        val all_ptab =
            Cx.mk_ptab (Cx.get_fixed_typ_ps old_g_cx, allfixes)
       in  
         (zctxt, if null zctxt then (old_gncx,p)
                 else add_sub_cx new_ptab all_ptab Goaln.NSet.empty 
                                 old_g_cxname old_gncx p)
       end;

exception subst_exp of string * (gname * result * Zipper.T * T);

  (* use an equation to do a subtitution in a goal *)
  (* assumes z is a zipper on the goal term *)
  fun apply_subst_bck r_name g_r z p = 
      let 
        val ((g_name,g_nd),old_gncx) = g_r;
        val (r_r as ((_,r_nd),(rncx as (r_cxname,r_cx)))) = 
            get_result p r_name;

        val z = Zipper.zipto (Zipper.ctxt z) (Zipper.mktop (nd_get_trm g_nd))
            handle Zipper.move _ => 
                   raise subst_exp ("bad zipper.",(r_name, g_r, z, p));

        val (zctxt,(gncx as (g_cxname,g_cx),p)) = mk_subst_cx z old_gncx p
        val fixes_to_absify = Cx.get_fixed_trm_ps g_cx;

        val avoid = goal_avoids r_r g_r
            handle resolve_names_out_of_scope_exp _ => 
                   raise subst_exp ("rule is not applicable.",
                                    (r_name, g_r, z, p))
                 | not_an_open_goal_exp _ => 
                   raise subst_exp ("goal is not open.",
                                    (r_name, g_r, z, p));
        val (asm_names,lifting,ienv2) = 
            local_context_lifting p gncx rncx;

        val (r_lhs, r_rhs) = 
            (nd_get_trm r_nd) |> Lifting.lift lifting |> Logic.dest_equals;

        val lhs_matchtrm = 
            r_lhs |> Trm.absify_params fixes_to_absify;
        val g_subterm = (* CHECK: is the order correct? *)
            (Zipper.trm z) |> curry Term.subst_bounds (map Free zctxt)
                           |> Trm.absify_params fixes_to_absify 
        val unifs = 
            (* (Seq.of_list o Seq.list_of) *)
              (MyUnify.unifiers (ienv2, [(lhs_matchtrm, g_subterm)]));
      in
        Seq.map (apply_subst_bck_result 
                   r_name r_rhs asm_names avoid (z,zctxt) g_r lifting p) unifs
      end 
        handle subst_exp x => raise subst_exp x
             | _ => raise subst_exp ("mystery problem :(",(r_name, g_r, z, p));

  (* get goal avoids if rr is applicable to gr, else raise exception *)
  fun fwd_avoids (rr as ((rn,rnd),_)) (fwr as ((fwn,fwnd),_)) = 
      if applicable rr fwr then
        (case (nd_get_meth fwnd)
          of (Meth(MClosed _, avoid)) => 
             Goaln.NSet.add fwn avoid
           | AsmMeth => Goaln.NSet.empty
           | _ => raise not_a_closed_goal_exp fwn)
          |> (case nd_get_meth rnd of 
                AsmMeth => Goaln.NSet.add rn 
              | Meth(_,ravoid) => 
                Goaln.NSet.union_merge 
                  (Goaln.NSet.add rn ravoid))
      else raise resolve_names_out_of_scope_exp (rn, fwn);


  (* Use an equation to do a substitution on proved result *)
  (* assumes z is a zipper on the goal term *)
   fun apply_subst_fwd eq_name f_r z p = 
      let 
        val ((f_name,f_nd),old_fncx) = f_r
        val (r_r as ((_,r_nd),(rncx as (r_cxname,r_cx)))) = 
            get_result p eq_name;

        val z = Zipper.zipto (Zipper.ctxt z) (Zipper.mktop (nd_get_trm f_nd))
            handle Zipper.move _ => 
                   raise subst_exp ("bad zipper.",(eq_name, f_r, z, p));

        val (zctxt,(fncx as (f_cxname,f_cx),p)) = mk_subst_cx z old_fncx p
        val fixes_to_absify = Cx.get_fixed_trm_ps f_cx;

        val avoid = fwd_avoids r_r f_r
            handle resolve_names_out_of_scope_exp _ => 
                   raise subst_exp ("rule is not applicable.",
                                    (eq_name, f_r, z, p))
                 | not_a_closed_goal_exp _ => 
                   raise subst_exp ("fact is not proved.",
                                    (eq_name, f_r, z, p));
        (* lifting ... *)
        val (asm_names,lifting,ienv2) = 
            local_context_lifting p fncx rncx;
        val (r_lhs, r_rhs) = 
            (nd_get_trm r_nd) |> Lifting.lift lifting |> Logic.dest_equals;

        (* also abstract over these *)
        val lhs_matchtrm = 
            r_lhs |> Trm.absify_params fixes_to_absify;
        val f_subterm = 
            (Zipper.trm z) |> curry Term.subst_bounds (map Free zctxt)
                           |> Trm.absify_params fixes_to_absify;
        val unifs = 
            MyUnify.unifiers (ienv2, [(lhs_matchtrm, f_subterm)]);
      in
        Seq.map (apply_subst_fwd_result 
                   eq_name r_rhs asm_names avoid (z,zctxt) f_r lifting p) unifs
      end;

(* apply subst fwd or back, depending on if the result to apply the
   equation to is open or not *)
fun apply_subst_to_result eq_name (r as ((r_name,_),_)) z p = 
    if Goaln.NSet.contains (get_open_gnames p) r_name then 
      apply_subst_bck eq_name r z p
    else 
      apply_subst_fwd eq_name r z p;


(* consider a result in a new context: justified implicitly by resolution *)
fun consider_result_in_cx (r as ((r_name,r_nd),(rncx as (r_cxname,r_cx))))
                          (ncx as (cxname,cx)) p = 
    let 
      (* make avoid list for new result: only allow applicable
      assumptions and other results to be considered in subcx's *)
      val avoid = 
          case nd_get_meth r_nd of 
            AsmMeth => 
            if (Goaln.NSet.contains (Cx.get_aasms cx) r_name) then
                 Goaln.NSet.add r_name Goaln.NSet.empty
            else raise assumption_out_of_scope_exp 
                         (r_name, cxname, p)
          | Meth(_,ravoid) => 
            Goaln.NSet.add r_name ravoid;
      val rtree = (rtree_of_result_wlasms p r)
                   |> RTree.rename (Cx.get_fixes cx, Cx.empty_renaming)
      val (newtree,p) = 
          add_result_rtree_under_ncx (MClosed(MKindRes r_name, []),avoid)
                                     ncx rtree p;
    in (newtree, p) end;

(* consider some fact (rn) within the context of another one (gn) This
allows you to copy a result from one place to another. *)
fun consider_in_gname_cx rn gn p = 
    let 
      val cxn = nd_get_cxname (get_nd p gn)
      val cx = get_cx p cxn
    in consider_result_in_cx (get_result p rn) (cxn,cx) p end;

(* lift a result into context and change some assumptions into
subgoals so you can prove them. This is restricted so that this only
works on facts/asssumptions with one level of depth - otherwise we'd
need to include the lifted non-asm subgoals as new assumptions or
subgoals. IMPROVE: make more general: allow lifting from anywhere *)
fun lift_and_show_result (r as ((r_name,r_nd),(rncx as (r_cxname,r_cx))))
                         asmtogoals (ncx as (cxname,cx)) p = 
    let 
      val avoid = 
          case nd_get_meth r_nd of 
            AsmMeth => 
            if (Goaln.NSet.contains (Cx.get_aasms cx) r_name) then
                 Goaln.NSet.add r_name Goaln.NSet.empty
            else raise assumption_out_of_scope_exp (r_name, cxname, p)
          | Meth(_,ravoid) => 
            Goaln.NSet.add r_name ravoid;

      val thry = get_theory p;

      (* we don't need to include the assumptions of the as they 
         are just assumption in a new subcontext of cx  *)
      val (liftsubgoals,lifting,ienv2) = local_context_lifting p ncx rncx;

      val _ = if Goaln.NSet.is_empty 
                 (Goaln.NSet.subtract liftsubgoals (Cx.get_lasms r_cx))
              then true
              else raise unimplemented_exp "lift_and_show: has non-local assumptions";
      (* conditions for lifting *)
(*       val condsubgoal_rtrees = 
          map ((rtree_of_gname p)
                 #> (RTree.put_in_ncx ncx)
                      #> (RTree.map_trm 
                            (Trm.lift_ps_to_vars lifting)))
              (Goaln.NSet.list_of condsubgnames);
      val (condsubtrees,p) = add_result_rtrees_under_ncx 
                           (MOpen,avoid) ncx condsubgoal_rtrees p; *)

      (* IMPROVE: dropping fixes after adding them is inefficient: 
         improve rtree of result to allow skipping of some fixes *)
      val rtree = 
          (rtree_of_result_wlasms p r)
            |> RTree.drop_lfixes
            |> RTree.put_in_ncx ncx
            |> RTree.map_trm (Lifting.lift lifting)

      val (goal_trs,asm_trs) = RTree.select_asms asmtogoals rtree;
      val (subg_trees,p) = 
          add_result_rtrees_under_ncx (MOpen,avoid) ncx goal_trs p;

      val subgnames = map RTree.get_name subg_trees;
      val (newtree,p) = 
          add_result_rtree_under_ncx 
            (MClosed(MKindRes r_name, subgnames),avoid)
            ncx (RTree.set_asms asm_trs rtree) p;
    in ((newtree, subg_trees),set_ienv ienv2 p) end;

(* lift a result to a new context *)
fun lift_and_show_above_rtree rname asmtognames gname p = 
    let val (_,ncx) = get_result p gname in 
      lift_and_show_result 
        (get_result p rname) 
        (Goaln.NSet.of_list asmtognames)
        ncx p
    end;

(* remove gnames entries not in this prf *)
fun restrict_gn_col p gnameset = 
    let val gtab = get_goals p
    in
      Goaln.NSet.fold 
        (fn n => 
         fn gnset => 
            if Goaln.NTab.contains gtab n
            then gnset else Goaln.NSet.delete n gnset)
        gnameset
        gnameset
    end;

fun restrict_gn_list p gnames = 
    List.filter (not o Goaln.NTab.contains (get_goals p)) gnames;

(* limit the references to avoids and subgoals to only the goals
actually within this prf. Any sub-methods get abbreviated to MKindPrf
with method name and the subgoals that occur within the super-prf. *)
fun subprf_restrict_meth mname subprf p (Meth(optmeth,avoid)) = 
    Meth ((case optmeth of 
             MOpen => MOpen
           | MClosed(mkind,subgoals) =>  
             MClosed(MKindPrf(mname, subprf), restrict_gn_list p subgoals)),
          restrict_gn_col p avoid)
    (* assumption do not change *)
  | subprf_restrict_meth _ _ _ AsmMeth = AsmMeth;
fun subprf_restrict_gnames_in_nd mname subprf p rnd = 
    nd_update_meth (subprf_restrict_meth mname subprf p) rnd



(* given a method name, and a set of result names to pull out, make a
a compound method. 

Note: Unused names for vars and goals are not lifted to the super-prf,
although names are not shortened/freed either. IDEA: have ideal and real
names, this would allow shortening of names?  *)
(* *)
(* fun subprfify mname newfnames oldp newp = 
    let
      (* check that newfnames are really new new subprf *)
      val closed_goals = 
          Goaln.NSet.subtract 
            (get_open_gnames oldp) (get_open_gnames subprf);

      (* Add the cx from subprf and all its parent contexts not in
         p. Includes addition of assumption nodes.
         Assumes that subprf and p have the same root context - else the
         get_parent will raise an exception. Also assumes ncx is not in p
         else will replace old cx *)
       fun add_subprf_ncx (ncx as (cxn,cx)) p = 
           let val p2 = p |> update_ctxts (Cxn.NTab.update ncx)
                          |> (fold (add_subprf_result o get_result subprf) 
                                   (Goaln.NSet.list_of (Cx.get_lasms cx)))
             val pcxn = Cx.get_parent cx
           in
             if Cxn.NTab.contains (get_ctxts p2) pcxn then p2
             else p2 |> add_subprf_ncx (pcxn,get_cx subprf pcxn)
           end
       (* note: assumes that nd is not an assumption: assumptions are added
          by adding the context they are in *)
       and add_subprf_result (r as (nnd as (n,nd),ncx as (cxn,cx))) p = 
           if Cxn.NTab.contains (get_ctxts p) cxn then 
             p |> add_node (n, subprf_restrict_gnames_in_nd mname subprf p nd)
           else
             p |> add_subprf_ncx ncx
               |> add_node (n, subprf_restrict_gnames_in_nd mname subprf p nd);

      (* use collection sets to remove duplicates *)
      val new_subgoals = get_open_gnames subprf;
      val added_nodes = fold Goaln.NSet.add newfnames new_subgoals;
      val new_subgoal_list = Goaln.NSet.list_of new_subgoals;
      val added_nodes_list = Goaln.NSet.list_of added_nodes;

      val p = 
          p |> inst_prf (InstEnv.select_list (get_open_var_names p) 
                                             (get_ienv subprf))
            |> fold (add_subprf_result o get_result subprf) added_nodes_list
            |> fold (close_open_goal_with 
                       (MKindPrf(mname, subprf), new_subgoal_list)) gnames
    in (new_subgoal_list, p) end;
*)

(* given a method name, some goals and some new result names, make a
subprf's steps into a compound method within the super-proof. Note:
Unused names for vars and goals are not lifted to the super-prf, 
although names are not shortened either. IDEA: have ideal and real 
names, this would allow shortening of names?  *)
fun mk_subprf_into_meth mname newfnames gnames subprf p = 
    let
      (* Add the cx from subprf and all its parent contexts not in
         p. Includes addition of assumption nodes.
         Assumes that subprf and p have the same root context - else the
         get_parent will raise an exception. Also assumes ncx is not in p
         else will replace old cx *)
       fun add_subprf_ncx (ncx as (cxn,cx)) p = 
           let val p2 = p |> update_ctxts (Cxn.NTab.update ncx)
                          |> (fold (add_subprf_result o get_result subprf) 
                                   (Goaln.NSet.list_of (Cx.get_lasms cx)))
             val pcxn = Cx.get_parent cx
           in
             if Cxn.NTab.contains (get_ctxts p2) pcxn then p2
             else p2 |> add_subprf_ncx (pcxn,get_cx subprf pcxn)
           end
       (* note: assumes that nd is not an assumption: assumptions are added
          by adding the context they are in *)
       and add_subprf_result (r as (nnd as (n,nd),ncx as (cxn,cx))) p = 
           if Cxn.NTab.contains (get_ctxts p) cxn then 
             p |> add_node (n, subprf_restrict_gnames_in_nd mname subprf p nd)
           else
             p |> add_subprf_ncx ncx
               |> add_node (n, subprf_restrict_gnames_in_nd mname subprf p nd);

      (* use collection sets to remove duplicates *)
      val new_subgoals = get_open_gnames subprf;
      val added_nodes = fold Goaln.NSet.add newfnames new_subgoals;
      val new_subgoal_list = Goaln.NSet.list_of new_subgoals;
      val added_nodes_list = Goaln.NSet.list_of added_nodes;

      val p = 
          p |> inst_prf (InstEnv.select (get_open_var_names p) 
                                        (get_ienv subprf))
            |> fold (add_subprf_result o get_result subprf) added_nodes_list
            |> fold (close_open_goal_with 
                       (MKindPrf(mname, subprf), new_subgoal_list)) gnames
    in (new_subgoal_list, p) end;

(* Uncomment to skip hiding for subprfs *)
(* fun mk_subprf_into_meth mname newfnames gnames subprf p = 
    (Goaln.NSet.list_of 
       (Goaln.NSet.subtract (get_open_gnames subprf) (get_open_gnames p)), 
     subprf);
*)


(* context trees are used just for pretty printing: they provide a way
to use pattern matching style recursion of the context tree that is
otherwise stored as a graxph within the proof plan's representation *)

(* context table, for holding lots of contexts that are not in p *)
fun add_r_to_cxtab (r as (nd,(cxname,cx))) cxtab = 
    (case Cxn.NTab.lookup cxtab cxname 
      of NONE => Cxn.NTab.update (cxname, (cx,[nd])) cxtab
       | SOME (cx,l) => Cxn.NTab.update (cxname, (cx,nd::l)) cxtab);

(* context trees for organising contexts in a sparse manner: put the
top context at the top, and only add contexts needed in order for the
existence of subcontexts *)
(* THINK: isn't this the same as a table organised by an ordering on
the context anscestors? *)
datatype cxtree = CxTree  
         of ((cxname * Cx.T) (* this context *)
             * ((gname * nd) list)) (* results in this context *)
            * (cxtree list); (* child contexts *)
fun mk_lf_cxtree cr =  CxTree(cr,[])


(* assumes p is above all given contexts. IMPROVE: combine with
the ancestor finding to make it more efficient. See Lucas' note
on efficient nested contexts. 
children is children seen so far.
*)
fun add_cx_to_child_cxtreeL p parent (cxname,(cx,nds)) children =
    let 
      fun add_cx newc parent [] = [mk_lf_cxtree newc]
        | add_cx (newc as ((new_ncx as (new_cxn,_)),new_nds))
                 (parent as ((pcxn, pcx),nds))                 
                 ((h as CxTree (c2 as ((ncx2 as (cxn2,_)),nds2),subcxs2))
                  ::psubcxs) =
          if Cx.cxname_eq(cxn2,new_cxn) then 
            (CxTree ((ncx2,new_nds @ nds2),subcxs2))
            :: psubcxs
          else 
            let val an = Cx.first_common_ancestor new_ncx ncx2 in 
              if Cx.cxname_eq (an, cxn2) then 
                let val subcxs2' = add_cx newc c2 subcxs2
                in CxTree (c2,subcxs2') :: psubcxs end
              else if Cx.cxname_eq (an, new_cxn) then 
                CxTree (newc,[h]) :: psubcxs
              else if Cx.cxname_eq (an, pcxn) then 
                h :: (add_cx newc parent psubcxs)
              else 
                CxTree (((an,get_cx p an),[]),
                        [mk_lf_cxtree newc,h]) :: psubcxs
            end
    in add_cx ((cxname,cx),nds) parent children end;

fun add_cxnds_to_cxtree p
      (newc as (new_cxn,(new_cx,new_nds)))
      (CxTree (pcxnds as ((pcxn, pcx),nds),
               children)) =
    if Cx.cxname_eq(new_cxn,pcxn) then 
      (CxTree (((pcxn, pcx),new_nds @ nds),
               children))
    else 
      CxTree(pcxnds, add_cx_to_child_cxtreeL p pcxnds newc children);

fun cxtree_of_cxtab p cxtab = 
    let val top_ncx = get_top_ncx p
    in Cxn.NTab.fold (add_cxnds_to_cxtree p) 
                   cxtab
                   (CxTree ((top_ncx,[]),[]))
    end;

(* we filter out asm nodes as they are part of the context *)
fun make_cx_tree p = 
    let val cxtab = fold add_r_to_cxtab 
                         (filter (fn ((_,nd),_) => not (nd_is_asm nd))
                           (map (get_result p) (Goaln.NTab.keys (get_goals p))))
                         Cxn.NTab.empty;
    in cxtree_of_cxtab p cxtab end;

(* make a theorem from a result in a proof plan *)

(* IMPROVE: make more efficient by recording unification results for
fixed params in resol steps and location of substs steps *)
(* will fail in an assumption contains a mvar *)

(* make a result thm relative to the super_cx: only fixes and assumes
below super-cx are explicit in the theorem - the other assumptions are
expressed as hidden hyps and the other fixes as frees. *)
fun mk_result_thm p super_cx (r as ((gname,nd),rncx as (rcxn,rcx))) = 
    let 
      val thry = get_theory p;
      val t = nd_get_trm nd;
      val params = (Cx.params_beyond rcx super_cx) 
                     |> Cx.get_trmps_of_ptab;                     
      val asms = (Cx.asms_beyond rcx super_cx)
                   |> Goaln.NSet.list_of
                   |> map (RTree.trm_of o rtree_of_gname_waasms p);
    in
      case nd_get_meth nd of 
        AsmMeth => 
        let 
          val ct = (asms, t) 
                     |> Logic.list_implies
                     |> Trm.allify_params params
                     |> Thm.cterm_of thry 
        in (Thm.assume ct, []) end
      | Meth(MClosed(MKindRes gname2,subgoals),_) =>  
        let 
          val goal_thm = Thm.trivial (Thm.cterm_of thry t);
          val (r2 as ((_,nd2),rncx2)) = get_result p gname2;
          val super2_cxn = Cx.first_common_ancestor rncx2 rncx;
          val super2_cx = get_cx p super2_cxn;
          val (gname2_thm,gname2_opengs) = mk_result_thm p super2_cx r2;
          val gname2_thm2 = gname2_thm |> Thm.forall_elim_vars 0;

          val (subgoal_thms,open_gs) = 
              fold (fn n => fn (thL,opengsL) => 
                    let val (th,open_gs) = 
                            mk_result_thm p super_cx (get_result p n)
                    in (th :: thL, open_gs @ opengsL) end)
                   subgoals ([],gname2_opengs);

          val gname_th =
              (Tactic.rtac gname2_thm2 1 goal_thm)
                |> (fold (fn subgth => Seq.maps (Tactic.rtac subgth 1))
                         (rev subgoal_thms))
                |> Seq.hd
        in
          (gname_th
             |> fold (Thm.implies_intr o Thm.cterm_of thry) asms
             |> (fold (Thm.forall_intr o Thm.cterm_of thry o Free) 
                      (Trm.TrmParams.get_plist params))
           , open_gs)
        end
      | Meth(_ (* MOpen *) ,_) => 
        let 
          val ct = (asms, t) 
                     |> Logic.list_implies
                     |> Trm.allify_params params
                     |> Thm.cterm_of thry 
        in (Thm.assume ct, [ct]) end
    end;

fun mk_thm p gname = 
    mk_result_thm p (snd (get_top_ncx p)) (get_result p gname);

(* Pretty Printing *)
fun pretty_trm p t = Pretty.unbreakable (Trm.pretty (get_context p) t);

fun list_sep x [] = []
  | list_sep x [a] = [a]
  | list_sep x (h::(t as h2::t2)) = 
    h :: x :: (list_sep x t);
fun pretty_sep_block s l = 
    Pretty.block (list_sep (Pretty.str s) l);

fun pretty_sep_chunks s l = 
    Pretty.chunks (list_sep (Pretty.str s) l);

fun pretty_curly_chunks l = 
    Pretty.block [Pretty.str "{", Pretty.chunks l, Pretty.str "}"];

fun pretty_named_concl p n = 
    Pretty.unbreakable
      (Pretty.block
         [(pretty_gname n),
          Pretty.str ": \"", pretty_trm p (nd_get_trm (get_nd p n)),
          Pretty.str "\""]);

fun pretty_tfix_brief thry (n,srt) = 
    (Pretty.block [TFree.pretty_name n]);
fun pretty_fix_brief thry (n,typ) = 
    (Pretty.block [Free.pretty_name n]);
fun pretty_tfix thry (n,srt) = 
    (Pretty.block 
      [TFree.pretty_name n,
       Pretty.str " : ",
       Trm.pretty_sort thry srt]);
fun pretty_fix thry (n,typ) = 
    (Pretty.block 
      [Free.pretty_name n , Pretty.str " : ",
       Trm.pretty_typ thry typ ]);
val pretty_hline = 
    Pretty.str 
      "------------------------------------------------------------------";

fun prettyL_avoid avoid = 
    (if Goaln.NSet.is_empty avoid then []
     else [Pretty.str "(without: ",
           Pretty.list "" ")" (map pretty_gname (Goaln.NSet.list_of avoid))])
fun prettyL_subgoals sgl = 
    (if List.null sgl then []
     else [Pretty.str "(to: ",
           Pretty.list "" ")" (map pretty_gname sgl)])

fun pretty_methkind (MKindRes g) = Pretty.str (" " ^ g)
  | pretty_methkind (MKindSubst g) = Pretty.str ("_subst " ^ g)
  | pretty_methkind (MKindPrf (mname,prf)) = 
    Pretty.block [ Pretty.str "_meth (", Pretty.str mname, Pretty.str ")"]
  | pretty_methkind (MKindThm th) = 
    Pretty.block [ Pretty.str "_thm ", Pretty.str (Thm.get_name_hint th)]
  | pretty_methkind (MKindTac (th,(tac,p))) = 
    Pretty.block [ Pretty.str "_tac (", p, Pretty.str ")"];



(* 
fun pretty_meth (Meth(MOpen,avoid)) = 
    Pretty.block 
      ([Pretty.str " [gap]"] @ [Pretty.str ""]
        @ (prettyL_avoid avoid))
  | pretty_meth (Meth(MClosed(m,sgl),avoid)) = 
    Pretty.block 
      ([Pretty.str " ["]
       @ [Pretty.str "by: ",
          pretty_methkind m]
       @ [Pretty.str "]"]
       @ prettyL_subgoals sgl
       @ prettyL_avoid avoid)
  | pretty_meth (AsmMeth) = Pretty.str " [assumed]";
*)

fun pretty_node_trm_and_meth p (name, n) = 
    let 
      val nametrmP = 
          Pretty.block 
            [Pretty.str "(", pretty_gname name, 
             Pretty.str "): ", 
             pretty_trm p (nd_get_trm n)]
    in
      case nd_get_meth n of 
        AsmMeth => 
        Pretty.block [Pretty.str "a", nametrmP]
      | Meth(MClosed(methkind,subgoals),avoids) => 
        Pretty.block ([ Pretty.str "p", nametrmP ])
      | Meth(MOpen,avoids) => 
        Pretty.block 
          ([ Pretty.str "?", nametrmP])
    end;

fun pretty_node_trm_and_meth_long p (name, n) = 
    let 
      val nametrmP = 
          Pretty.block 
            [Pretty.str "(", pretty_gname name, 
             Pretty.str "): ", 
             Pretty.quote 
               (pretty_trm p (nd_get_trm n))]
    in
      case nd_get_meth n of 
        AsmMeth => 
        Pretty.chunks [Pretty.block [nametrmP],
                       (Pretty.indent 2 o Pretty.block) 
                         [Pretty.str "[assumed]"]]
      | Meth(MClosed(methkind,subgoals),avoids) => 
        Pretty.chunks 
          [Pretty.block [ nametrmP ],
           (Pretty.block
             ([Pretty.str "[", Pretty.str "by", pretty_methkind methkind]
              @ (if null subgoals then []
                 else [Pretty.list " to: " "" (map pretty_gname subgoals)])
              @ [Pretty.str "]"]))]
      | Meth(MOpen,avoids) => 
        Pretty.chunks 
          [Pretty.block [nametrmP],
           (Pretty.block
             [Pretty.str "[? ", Pretty.str "gap" 
              (* , Pretty.block (prettyL_avoid avoids),*)
              , Pretty.str "]"])]
    end;

(* with types/sorts *)
fun prettyL_fixes p ptab = 
    let
      val context = get_context p
      val tvsL = rev (Trm.TypParams.get_plist (Cx.get_typps_of_ptab ptab))
      val vsL = rev (Trm.TrmParams.get_plist (Cx.get_trmps_of_ptab ptab))
      val fix_typesPL = 
          if null tvsL then [] else 
          [Pretty.block
             [Pretty.str "ALLTYPES ", 
              pretty_sep_block ", " (map (pretty_tfix context) tvsL),
              Pretty.str "."]]
      val fixPL = 
          if null vsL then [] else 
          [Pretty.block 
             [Pretty.str "ALL ", 
              pretty_sep_block ", " (map (pretty_fix context) vsL),
              Pretty.str "."]]
    in if null fix_typesPL andalso null fixPL then []
       else [pretty_sep_block " " (fix_typesPL @ fixPL)]
    end;

fun prettyL_cx_lfixes p (cxname, cx) = 
    prettyL_fixes p (Cx.get_lfixes cx);


(* without types/sorts, used for assumptions *)
fun prettyL_fixes_brief p ptab = 
    let
      val thry = get_theory p
      val tvsL = rev (Trm.TypParams.get_plist (Cx.get_typps_of_ptab ptab))
      val vsL = rev (Trm.TrmParams.get_plist (Cx.get_trmps_of_ptab ptab))
      val fix_typesPL = 
          if null tvsL then [] else 
          [Pretty.block
             [Pretty.str "ALLTYPES ", 
              pretty_sep_block " " (map (pretty_tfix_brief thry) tvsL),
              Pretty.str ". "]]
      val fixPL = 
          if null vsL then [] else 
          [Pretty.block 
             [Pretty.str "ALL ", 
              pretty_sep_block " " (map (pretty_fix_brief thry) vsL),
              Pretty.str ". "]]
    in if null fix_typesPL andalso null fixPL then []
       else [pretty_sep_block " " (fix_typesPL @ fixPL)]
    end;

fun prettyL_cx_lfixes_brief p (cxname, cx) = 
    prettyL_fixes_brief p (Cx.get_lfixes cx);


(* named rtree, used for statements with only one conclusion and proof
   is ommited. *)
fun pretty_rtree p rtree = 
    let 
      val lasms = RTree.get_asms rtree 
      val lfixes = RTree.get_lfixes rtree
      val no_lasms = null lasms
      val no_params = Cx.isempty_ptab lfixes;
      val conclP = [Pretty.str "(",Pretty.str (RTree.get_name rtree),
                    Pretty.str "): ", 
                    Pretty.quote (pretty_trm p (RTree.get_ctrm rtree))];
    in
      Pretty.block 
        ([Pretty.str "{"]
         @ (if no_params then []
            else [Pretty.block (prettyL_fixes_brief p lfixes)])
         @ (if no_lasms then []
            else [Pretty.block (map (pretty_rtree p) lasms)])
         @ [Pretty.block 
              ((if no_lasms then [] 
                else [Pretty.block [Pretty.str " |- "]])
               @ [Pretty.block conclP, Pretty.str "}"])]
        )
    end;

(* pretty result, without local context params *)
fun pretty_lresult p result = 
    let val tr = (rtree_of_result_wlasms p) result
    in pretty_rtree p tr end;

fun pretty_cx_ancestors ncx = 
    Pretty.list "[" "]" 
                (map Pretty.str 
                     (snd (Cx.ancestors_rep (Cx.ancestor_inc ncx))));

(* 
fun pretty_supporting_cxtree 
      p (CxTree((ncx as (cxname,cx), nnds), children)) = 
    let 
      val lasms = map (get_result p) (Goaln.NSet.list_of (Cx.get_lasms cx))
      val lasmsPL = (map (pretty_lresult p) lasms)
      val no_lasms = null lasms
      val no_params = Cx.isempty_ptab (Cx.get_lfixes cx)
    in
      pretty_curly_chunks
        ((if no_params then []
          else [Pretty.block (prettyL_cx_lfixes_brief p ncx)])
         @ (if no_lasms then [] 
            else [Pretty.block 
                    [Pretty.chunks lasmsPL]])
         @ [Pretty.block 
              ((if no_lasms then []
                else [Pretty.block [Pretty.brk 2, Pretty.str "|- "]])
               @ [Pretty.block [Pretty.chunks 
                                  (map (fn x => pretty_node_trm_and_meth p x) 
                                       nnds)]]
               @ [Pretty.chunks (map (pretty_supporting_cxtree p) children)])]
        )
    end;
*)



fun pretty_cxtree p (CxTree((ncx as (cxn,cx), nnds), children)) = 
    let 
      val lfixesPL = (prettyL_cx_lfixes p ncx);
      val no_asms = Goaln.NSet.is_empty (Cx.get_lasms cx);
      val no_lfixes = null lfixesPL;
    in
      pretty_curly_chunks
        ((* [Pretty.block [Pretty.str "(Cx:", pretty_cx_ancestors ncx, 
                        Pretty.str ")"]]
         @ *)
           (if no_lfixes then [] else [Pretty.block (lfixesPL)])
         @ (if no_asms then [] 
            else 
              [Pretty.block 
                 [Pretty.chunks
                    (map (pretty_lresult p o get_result p) 
                         (Goaln.NSet.list_of (Cx.get_lasms cx)))]])
         @ (if no_asms then [] 
            else [Pretty.block [Pretty.str "|- "]])
         @ [(Pretty.chunks
                   (list_sep 
                      (Pretty.block [])
                      ((map (pretty_node_trm_and_meth_long p) nnds) @ 
                       (map (pretty_cxtree p) children))))]
        )
    end;

fun pretty_script p = 
    Pretty.block 
    [Pretty.chunks 
       [Pretty.str "", pretty_hline, 
        (Pretty.block [Pretty.indent 1 (pretty_cxtree p (make_cx_tree p))]),
        pretty_hline
    ]];

val pretty = pretty_script;

fun pretty_wrt p (g : gname) = pretty p;

fun pretty_node p n = 
    let val (nnd,ncx as (cxn,cx)) = (get_result p n)
    in pretty_cxtree p (CxTree((ncx, [nnd]), [])) end;

fun pretty_goal_concls p = 
    Pretty.chunks 
      (map (pretty_named_concl p) (Goaln.NSet.list_of (get_open_gnames p)));

fun pretty_open p = pretty p;
(*     Pretty.chunks 
      (map (pretty_wrt p) (Goaln.NSet.list_of (get_open_gnames p)));
*)

fun pretty_full p = 
    Pretty.chunks 
      [Pretty.str "", pretty_hline, 
       Pretty.str "Dep Env: ",
       Pretty.indent 2 (DepEnv.pretty (get_theory p) (get_denv p)),
       pretty_hline,
       Pretty.str "Inst Env: ",
       Pretty.indent 2 (InstEnv.pretty (get_ienv p)),
       pretty_hline,
       Pretty.str "Proof: ",
       (Pretty.block [Pretty.indent 1 (pretty_cxtree p (make_cx_tree p))]),
       pretty_hline
      ];

val print = Pretty.writeln o pretty;
val print_goal_concls = Pretty.writeln o pretty_goal_concls;
val print_node = Pretty.writeln oo pretty_node;
val print_wrt = Pretty.writeln oo pretty_wrt;
val print_open = Pretty.writeln o pretty_open;
val print_script = Pretty.writeln o pretty_script;
val print_full = Pretty.writeln o pretty_full;

end;

structure APrf : APRF = DB_APrf;

(* install_pp (make_pp ["APrf", "T"] (Pretty.pprint o APrf.pretty_script)); *)
