
functor IsaMatchParamFun (structure GoalTypData : GOALTYP_DATA
                          structure Atomic : ATOMIC
                          ): MATCH_PARAM =
struct
  structure GoalTypData : GOALTYP_DATA = GoalTypData
  structure Atomic : ATOMIC = Atomic

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name


 (* Class Feature in Isabelle context *)


  (* FIXME: why is the Object required as this level?
      - all stuff should have been instantiated by now! *)
  (* F.name -> Atomic.context -> Atomic.Object -> GoalTypData.data list -> bool *)
  fun class_data_match fname ctxt obj data = false
(*
    case get_feature ctxt fname of
       NONE => false
     | SOME f => f ctxt obj data;
*)

  fun link_data_match  _ _ _ _ = false
  
  structure Sharing : MATCH_PARAM_SHARING = 
    struct
      structure GoalTypData = GoalTypData.Sharing
      structure Atomic = Atomic.Sharing
    end
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
