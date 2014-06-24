
functor PSGraph_TheoryFun (GoalTyp : BASIC_GOALTYPE) =
struct
  structure GoalTyp = GoalTyp;

  (* may need some sharing stuff here *)
  structure PSData = PSGraphDataFun(GoalTyp);
  structure PSDataIO = PSGraphIOFun(structure Data = PSData);

  structure PSGraph_Theory = GraphicalTheory(
    structure Data = PSData
    structure DataIO = PSDataIO
  );
  open PSGraph_Theory;

end


