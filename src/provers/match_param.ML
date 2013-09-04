signature MATCH_PARAM_SHARING =
sig
  structure GoalTypData : GOALTYP_DATA_SHARING
  structure Atomic : ATOMIC_SHARING
end

signature MATCH_PARAM =
sig
  structure GoalTypData : GOALTYP_DATA
  structure Atomic : ATOMIC

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name

  val class_data_match : F.name -> Atomic.context 
                         -> Atomic.Object 
                         -> GoalTypData.data list -> bool
  val link_data_match :  F.name ->  Atomic.context 
                         -> Atomic.Object * Atomic.Object 
                         -> GoalTypData.data list -> bool
  
  structure Sharing : MATCH_PARAM_SHARING
    sharing Sharing.GoalTypData = GoalTypData
    sharing Sharing.Atomic = Atomic
end;

(*
functor ProverMatchFun(structure Prover : PROVER
                       structure Atomic : ATOMIC) : MATCH_PARAM =
struct

  structure GData = ??

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name

  fun 


end 
*)
