signature PS_THEORY = 
sig
  (* todo: sharing *)
  structure Data : PSGRAPH_DATA
  include GRAPHICAL_THEORY

  sharing type Graph.nvdata = Data.nvdata
  sharing type Graph.edata = Data.edata

end (* signature *)

functor PSGraph_TheoryFun (GoalTyp : BASIC_GOALTYPE) =
struct
  structure GoalTyp = GoalTyp;

  (* may need some sharing stuff here *)
  structure Data = PSGraphDataFun(GoalTyp);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);

  structure Theory = GraphicalTheory(
    structure Data = Data
    structure DataIO = PSDataIO
  );

  open Theory;

end


