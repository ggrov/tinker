(*  DESCRIPTION:

    Working with the proof plan of a reasoning state

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature RST_PP =
sig
  val init : Context.theory -> RState.T
  val read_top_term : RState.T -> string -> Term.term
  val get_ctxt : RState.T -> Proof.context
  val get_theory : RState.T -> Context.theory
  val get_ienv : RState.T -> InstEnv.T
  val get_cx : RState.T -> PPlan.gname -> Cx.T
                                          
  (* lookup by given goalname *)
  val goal_concl : RState.T -> PPlan.gname -> Term.term
  (* get the goal as a theorem so you can use Isabelle tactics to solve it *)
  val goal_thm : RState.T -> PPlan.gname -> Thm.thm
  val goal_thm_winst : RState.T -> PPlan.gname -> Thm.thm
                                                  
  (* the goal term with local assumptions *)
  val goalterm_with_lasms : RState.T -> PPlan.gname -> Trm.T
  val lasms_of_goal : RState.T -> PPlan.gname -> PPlan.gname list
                                                 
  (* probably don't want these: *)
  val goalterm_with_asms : RState.T -> PPlan.gname -> Trm.T
  val asms_of_goal : RState.T -> PPlan.gname -> PPlan.gname list
                                                
  (* named terms with local assumption and with forall-vars as meta vars *)
  val lookup_varified_lntrms : RState.T -> PPlan.gname list 
                               -> (PPlan.gname * Term.term) list
                                  

  (* theorem of a proved result - proof plan must have no open subgoals *)
  val result_thm : RState.T -> PPlan.gname -> Thm.thm

  (* no open goals in proof plan *)
  val solved_all_chk : RState.T -> bool (* proof plan level *)

  (* new top level conj *)
  val new_conj_at_top : PPlan.gname * Term.term 
                        -> RState.T -> PPlan.gname * RState.T
  val new_conj_of_str_at_top : PPlan.gname * string
                               -> RState.T -> PPlan.gname * RState.T
                                          
  (* new conj at same context as another goalname *)
  val new_conj_at : PPlan.gname * Term.term -> PPlan.gname
                    -> RState.T -> PPlan.gname * RState.T
  val new_conj_of_str_at : PPlan.gname * string -> PPlan.gname
                           -> RState.T -> PPlan.gname * RState.T
                                          
  (* sets curgoals to new goalname *)  
(*
  val add_new_conj_at_top : PPlan.gname * Term.term -> RState.T -> RState.T
  val add_new_conj_at : PPlan.gname * Term.term -> PPlan.gname -> RState.T -> RState.T
*)                                    
  (* val inst_1var : (Trm.Var.name * Trm.T) -> RState.T -> RState.T *)
  val inst : InstEnv.T -> RState.T -> RState.T
                                      
  (* for a given wire:  current goals of the state *)
(*
  val forall : (RState.T -> PPlan.gname -> bool) -> BWire.name -> RState.T -> bool
  val forsome : (RState.T -> PPlan.gname -> bool) -> BWire.name -> RState.T -> bool
*)
                                            
end;


structure RstPP : RST_PP
= struct

val init = RState.init_from_thy;
val read_top_term = Prf.read_top_term o RState.get_pplan;

val get_theory  = PPlan.get_theory o RState.get_pplan;
val get_ctxt = PPlan.get_context o RState.get_pplan;
val get_ienv = PPlan.get_ienv o RState.get_pplan;
val get_cx = Prf.get_ndname_cx o RState.get_pplan;

(* get terms of goals*)
(* implicit rst and goalname *)
val goal_concl = Prf.get_ndname_ctrm o RState.get_pplan;
(*fun goals_concl rst = map (goal_concl rst) (RState.get_goalnames rst);
fun goals_namedconcl rst = map (fn g => (g, goal_concl rst g)) 
                               (RState.get_goalnames rst);
*)

(*get theorems of goals*)
(* implicit rst and goalname *)
val goal_thm = Prf.get_fixed_concl_goal_thm o RState.get_pplan;
val goal_thm_winst = Prf.get_fixed_concl_goal_thm_winst o RState.get_pplan;
(*
fun goals_thms rst = 
    map (goal_thm rst) (RState.get_goalnames rst);
*)

(* isabelle thm, if result is proved (currently also requires no open
subgoals in proof) *) 
val result_thm = Prf.get_isa_thm o RState.get_pplan;


(* Get named terms where allified vars are varified *)
fun lookup_varified_lntrms rst names =
    map (fn n => (n, PPlan.get_varified_ltrm 
                       (RState.get_pplan rst) n))
        names; 
  
(*get the assumptions associated with this goal*) 
fun asms_of_goal rst goal =
     Prf.get_ndname_aasms (RState.get_pplan rst) goal;
fun lasms_of_goal rst goal =
     Prf.get_ndname_lasms (RState.get_pplan rst) goal;
    
(* get goal concl with assumptions term *)
fun goalterm_with_asms rst gname = 
    Prf.get_ndname_ftrm (RState.get_pplan rst) gname;
fun goalterm_with_lasms rst gname = 
    Prf.get_ndname_ltrm (RState.get_pplan rst) gname;

(* checking state *)
val solved_all_chk = PPlan.solved_all_goals_chk o RState.get_pplan;

(*
fun forall f wire rst = 
   Goaln.NSet.forall (f rst) (RState.get_names_of_wire rst wire);

fun forsome f wire rst = 
   Goaln.NSet.exists (f rst) (RState.get_names_of_wire rst wire);
*)

(* new conj, may change goalname, gives back new goalname *)
fun new_conj_at_top (n,t) rst = 
    let val (newg, ppl) = (PPlan.conj_term_at_top (n,t) (RState.get_pplan rst))
    in (newg, rst |> RState.set_pplan ppl) end;
fun new_conj_of_str_at_top (n,s) rst = 
    let val (newg, ppl) = (PPlan.conj_string_at_top (n,s) (RState.get_pplan rst))
    in (newg, rst |> RState.set_pplan ppl) end;

fun new_conj_at (n,t) at_gname rst = 
    let val (newg, ppl) = (PPlan.conj_term_in_cx_of (n,t) at_gname (RState.get_pplan rst))
    in (newg, rst |> RState.set_pplan ppl) end;
fun new_conj_of_str_at (n,s) at_gname rst = 
    let val (newg, ppl) = (PPlan.conj_string_in_cx_of (n,s) at_gname (RState.get_pplan rst))
    in (newg, rst |> RState.set_pplan ppl) end;

(* adds a goalname, may change goalname, doesnt tell you, adds for rtechns *)
(*
fun add_new_conj_at_top nt rst = 
    let val (n2,rst2) = new_conj_at_top nt rst
    in rst2 |> RState.add_goalnames [n2] end;
fun add_new_conj_at nt at_gname rst = 
    let val (n2,rst2) = new_conj_at nt at_gname rst
    in rst2 |> RState.add_goalnames [n2] end;
*)
(* implicit: ienv rst *)
val inst = RState.update_pplan o PPlan.inst;

(* FIXME: change pplan representation so that instenv holds all var
names and types. *)
(* 
exception var_already_has_inst of (Trm.Var.name * Trm.T);

fun inst_1var_t (v,t) rst = 
    let 
      val pp = RState.get_pplan rst
      val ienv = PPlan.get_ienv pp

      val t_vars = Trm.vtab_of t
      val pp_vars = PPlan.get_vars pp
      val new_vars = Trm.difference_vtab t_vars pp_vars
      val all_vars = Trm.merge_joint_vtabs new_vars pp_vars

      val v_trm = 
          (case InstEnv.lookup_var v ienv of 
            NONE => (Var(v,Trm.Var.NTab.lookup 
                             (Trm.trm_var_tab_of (PPlan.get_vars pp)) v))
          | SOME (typ,inst_opt) => 
            case inst_opt of NONE => Var(v,typ)
                           | SOME i => i);
    in
      (InstEnv.unify (PPlan.get_theory pp) (new_vars,all_vars) 
                     (PPlan.get_flexes pp)  )

    inst (InstEnv.empty |> InstEnv.add_var_inst (Term.type_of t))

fun inst_1var_s (v,s) rst = 
    inst_1var_t (v, PPlan.read_term (RState.get_pplan rst) s) rst;
*)

end;

(* structure RstPP = RstPPFun(RState); *)

