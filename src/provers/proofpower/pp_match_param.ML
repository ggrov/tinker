functor PpMatchParamFun (structure GoalTypData : GOALTYP_DATA
                          structure Prover : PROVER
                          sharing GoalTypData.Sharing.Prover = Prover.Sharing): MATCH_PARAM =
struct
  structure GoalTypData : GOALTYP_DATA = GoalTypData
  structure Prover : PROVER = Prover

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name

  fun class_data_match _ _ _ _ = false
  fun link_data_match  _ _ _ _ = false
  
  structure Sharing : MATCH_PARAM_SHARING = 
    struct
      structure GoalTypData = GoalTypData.Sharing
      structure Prover = Prover.Sharing
    end
end;
