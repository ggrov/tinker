(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    The Reasoning state
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)


(* FIXME: remove rtechn completely from rstate and remove continuation!! *)
signature RSTATE = 
sig 

  exception goalnode_exp of string * GoalNode.T option

  type T (* type of a reasoning state *)

  (* consrtuctors - see pplan... *)
  val init : Proof.context -> T
  val init_from_thy : Context.theory -> T
  val init_from_pp : PPlan.T -> T

(*  val sol_setf : T -> T  *)

  val set_cinfo : CInfo.T -> T -> T
  val set_lcinfo : LCInfo.T -> T -> T
  val set_prev :  T option -> T -> T
  val set_pplan : PPlan.T -> T -> T
  val set_inputs : GoalNode.T option -> T -> T
  val set_outputs : GoalNode.G.NSet.T -> T -> T 
  val set_ctxt : Proof.context -> T -> T

  val get_cinfo : T -> CInfo.T
  val get_lcinfo : T -> LCInfo.T
  val get_prev : T -> T option
  val get_pplan : T -> PPlan.T
  val get_inputs : T -> GoalNode.T option
  val get_outputs :  T -> GoalNode.G.NSet.T
  val get_ctxt : T -> Proof.context

  (* set a search stack operation *)
  val set_searchops : T MSearch.searchopT list -> T -> T
  val add_searchop : T MSearch.searchopT -> T -> T
  val get_searchops : T -> T MSearch.searchopT list
  val pop_searchop : T -> (T * T MSearch.searchopT) option

  (* updating parts of the reasoning state *)
  val update_pplan : (PPlan.T -> PPlan.T) -> T -> T
  val update_inputs : (GoalNode.T option -> GoalNode.T option) -> T -> T
  val update_outputs : (GoalNode.G.NSet.T -> GoalNode.G.NSet.T) -> T -> T
  val update_lcinfo : (LCInfo.T -> LCInfo.T) -> T -> T
  val update_ctxt : (Proof.context -> Proof.context) -> T -> T
  val update_cinfo : (CInfo.T -> CInfo.T) -> T -> T


 (* working with input and output *)
  val has_inputs : T -> bool
  val has_outputs : T -> bool
  val reset_inputs : T -> T
  val reset_outputs : T -> T
  val reset_io : T -> T
  val try_update_inputs : (GoalNode.T -> GoalNode.T) -> T -> T (* raises goalnode_exp *)
  val set_inputs_value : GoalNode.T -> T -> T
  val move_inputs_to_outputs: T -> T 
  val try_move_inputs_to_outputs : T -> T (* only when output is empty - raises goalnode_exp *)
  val try_apply_output_of_input : (GoalNode.T -> GoalNode.T) -> T -> T (* raises goalnode_exp *)
  val apply_output_of_input : (GoalNode.T option -> GoalNode.G.NSet.T) -> T -> T

  (* Pass on local cinfo, by deafuat (push) to goalnames. *)
  (* val push_lcinfo : PPlan.gname -> T -> T *)
  val give_lcinfo : PPlan.gname -> PPlan.gname list -> T -> T

  (* Set dealyoptions for search *)
  val get_delayop : T -> (T, Term.term) MSearch.delayopT option
  val delay_rst :  Term.term -> T -> T
  val reset_delayopt : T -> T
  val resume_others : Term.term -> T -> T 
  val eval_delayopts : T -> (T * (T, Term.term) MSearch.delayopT) option
                        
  (* Unique ID's for Reasoning states - for internal use/debugging *)
  val get_id : T -> int (* unique id for each state, assuming use of unfold *)
  val new_id : T -> T (* force a new id *)

  val pretty : T -> Pretty.T
  val print : T -> unit

end; (* signature *)

structure RState_DB 
= struct

  structure Wire = BWire;

  datatype T = 
    RState of { linfo      : LCInfo.T,
                pplan      : PPlan.T,
                inputs     : GoalNode.T option,
                outputs    : GoalNode.G.NSet.T,
                prev       : T option,
                id         : int,
                searchop   : T MSearch.searchopT list,
                delayop    : ((T, Term.term) MSearch.delayopT) option};

 exception goalnode_exp of string * GoalNode.T option

  val global_id = Synchronized.var "IsaPlanner.global_id" 0;
  fun inc_g_id () = 
      Synchronized.change_result global_id (fn global_id => (global_id,global_id + 1)); 

  fun update_prev f (RState rep) = 
      RState{  prev = f (#prev rep), linfo = #linfo rep, 
              pplan = #pplan rep, inputs = #inputs rep, outputs = #outputs rep, id= #id rep, searchop = #searchop rep, delayop= #delayop rep};
  fun update_pplan f (RState rep) = 
      RState{ prev = #prev rep, linfo = #linfo rep, 
              pplan = f (#pplan rep), inputs = #inputs rep, outputs = #outputs rep, id= #id rep, 
              searchop = #searchop rep, delayop= #delayop rep};

  fun update_inputs f (RState rep) = 
      RState{ prev = #prev rep, linfo = #linfo rep, 
              pplan = #pplan rep, inputs = f (#inputs rep), outputs = #outputs rep, id= #id rep, 
              searchop = #searchop rep, delayop= #delayop rep};

  fun update_outputs f (RState rep) = 
      RState{ prev = #prev rep, linfo = #linfo rep, 
              pplan = #pplan rep, inputs = #inputs rep, outputs = f (#outputs rep),
              id= #id rep, searchop = #searchop rep, delayop= #delayop rep};

  val update_ctxt = update_pplan o PPlan.update_context;
  val update_cinfo = update_ctxt o CInfo.Ctxt.map;

  fun update_lcinfo f (RState rep) = 
      RState{ prev = #prev rep, linfo = f (#linfo rep), 
              pplan = #pplan rep, inputs = #inputs rep, outputs = #outputs rep, id= #id rep, searchop = #searchop rep, 
              delayop= #delayop rep};
  fun update_searchop f (RState rep) = 
      RState{ prev = #prev rep, linfo = #linfo rep, 
              pplan = #pplan rep, inputs = #inputs rep, outputs = #outputs rep, id= #id rep, 
              searchop = f (#searchop rep), delayop= #delayop rep};
  fun new_id (RState rep) = 
      RState{ prev = #prev rep, linfo = #linfo rep, 
              pplan = #pplan rep,inputs = #inputs rep, outputs = #outputs rep, id=inc_g_id(), 
              searchop = #searchop rep, delayop= #delayop rep};
  fun update_delayop f (RState rep) = 
      RState{ prev = #prev rep, linfo = #linfo rep, 
              pplan = #pplan rep,inputs = #inputs rep, outputs = #outputs rep, id= #id rep, 
              searchop = #searchop rep, delayop= f (#delayop rep)};

  val set_lcinfo = update_lcinfo o K;
  val set_prev = update_prev o K;
  val set_pplan = update_pplan o K;
  val set_inputs = update_inputs o K;
  val set_outputs = update_outputs o K;
  val set_searchops = update_searchop o K;
  val set_delayop = update_delayop o K;

  val set_ctxt = update_ctxt o K;
  val set_cinfo = update_cinfo o K;

  fun get_lcinfo (RState rep) = #linfo rep;
  fun get_prev (RState rep) = #prev rep;
  fun get_pplan (RState rep) = #pplan rep;
  fun get_inputs (RState rep) = #inputs rep;
  fun get_outputs (RState rep) = #outputs rep;
  fun get_id (RState rep) = #id rep;
  fun get_searchops (RState rep) = #searchop rep;
  fun get_delayop (RState rep) = #delayop rep;

  val get_ctxt = PPlan.get_context o get_pplan;
  val get_cinfo = CInfo.Ctxt.get o get_ctxt;

 (* working with input and output *)

  fun has_inputs rst = 
    case get_inputs rst of
       NONE => false
     |  _   => true;

  val has_outputs = 
    GoalNode.G.NSet.is_empty o get_outputs;

  val reset_inputs = set_inputs NONE ;
  val reset_outputs = set_outputs (GoalNode.G.NSet.empty);
  val reset_io = reset_inputs #> reset_outputs;

  fun try_update_inputs f rst =
    case get_inputs rst of 
        NONE     => raise goalnode_exp ("inputs empty",NONE)
     | (SOME gn) => set_inputs (SOME (f gn)) rst;

  val set_inputs_value = set_inputs o SOME;

  fun move_inputs_to_outputs rst = 
    case get_inputs rst of 
        NONE     => set_outputs GoalNode.G.NSet.empty rst
     | (SOME gn) => set_outputs (GoalNode.G.NSet.single gn) rst;

  fun try_move_inputs_to_outputs rst =
    if has_outputs rst 
      then raise goalnode_exp ("move inputs to outputs: already has output: ",NONE)
      else move_inputs_to_outputs rst;

  fun try_apply_output_of_input f rst =
    case get_inputs rst of 
        NONE     => raise goalnode_exp ("try_apply_output_of_input: inputs empty",NONE)
     | (SOME gn) => set_outputs (GoalNode.G.NSet.single (f gn)) rst;

  fun apply_output_of_input f rst = set_outputs (f (get_inputs rst)) rst;

  (* for search ops *)
  val add_searchop = update_searchop o (fn h => fn t => h::t);
  val drop_searchop = update_searchop tl;
  fun pop_searchop rst = 
      case get_searchops rst of [] => NONE 
        | (h::t) => SOME (set_searchops t rst, h);

 (* For delay options *)
 exception DelayException of string;

 fun delay_rst t rst = update_delayop (fn _ => SOME (MSearch.delay t)) rst;
 val reset_delayopt  = update_delayop (fn _ => NONE);

 fun to_resume t rsts = 
     let
       fun to_resume_aux t (ts,fs) []  = (ts,fs)
         | to_resume_aux t (ts,fs) (rst::rsts)  = 
           (case (get_delayop rst) of
             SOME(MSearch.delay t') => if (t = t') then 
                                         to_resume_aux t ((reset_delayopt rst)::ts,fs) rsts
                                       else to_resume_aux t (ts,(rst::fs)) rsts
           | _ => raise DelayException "Trying to resume a state that isn't delayed." )
              (*This shouldn't happen, should only be called on lists of delayed states *)
     in
       to_resume_aux t ([],[]) rsts
     end;

 fun resume_others t rst=  
                  let val defrost_fun = to_resume t in
                    update_delayop (fn _ => SOME (MSearch.resume(defrost_fun))) rst
                  end;

  (* Evaluate and update a state's delay-options in delayed search. *)    
   fun eval_delayopts rst = 
       case (get_delayop rst) of 
         NONE => NONE
       | SOME (MSearch.delay t) => SOME(rst, MSearch.delay t)
       | SOME (MSearch.resume defrost_fun) => SOME(reset_delayopt rst, MSearch.resume defrost_fun)


 (* pass on local cinfo *)
 fun give_lcinfo fromgoal togoals rst = 
     fold 
       (fn togoal => update_cinfo (LCInfo.give (get_lcinfo rst) fromgoal togoal))
       togoals rst;

  (* initialisation of a new rstate *)
  fun init ctxt = 
      RState {linfo = LCInfo.empty, 
              prev = NONE, 
              pplan = PPlan.init ctxt,
              inputs = NONE,
              outputs = GoalNode.G.NSet.empty,
              id = inc_g_id (),
              searchop = [],
              delayop = NONE};

  fun init_from_thy thry = init (ProofContext.init_global thry);

  fun init_from_pp pp = 
      (init (PPlan.get_context pp))
        |> set_pplan pp;
 
  val pretty = PPlan.pretty o get_pplan;
  val print = PPlan.print o get_pplan;

end; (* functor *)

structure RState : RSTATE = RState_DB;

(* install pretty printer: print out the proof plan *)
(*install_pp (make_pp ["RState", "T"] (Pretty.pprint o RState.pretty));*)
