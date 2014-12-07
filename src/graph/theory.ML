signature PS_THEORY_SHARING = 
sig
  structure Data : PSGRAPH_DATA_SHARING
end

signature PS_THEORY = 
sig
  structure Data : PSGRAPH_DATA
  structure Theory : GRAPHICAL_THEORY
  structure PSDataIO : GRAPH_COMPONENT_DATA_IO
  include GRAPHICAL_THEORY

  sharing type Graph.nvdata = Data.nvdata
  sharing type Graph.edata = Data.edata
  sharing type PSDataIO.nvdata = Data.nvdata
  sharing type PSDataIO.edata = Data.edata

  structure Sharing : PS_THEORY_SHARING
    sharing Sharing.Data = Data.Sharing


end (* signature *)

functor PSGraph_TheoryFun (structure GoalTyp : BASIC_GOALTYPE
                           structure  Data : PSGRAPH_DATA) =
struct
  structure GoalTyp = GoalTyp;

  (* may need some sharing stuff here *)
  structure Data = Data (*PSGraphDataFun(GoalTyp);*);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);


  structure Theory = GraphicalTheory(
    structure Data = Data
    structure DataIO = PSDataIO
  );

  open Theory;
  structure Sharing = 
  struct
    structure Data = Data.Sharing
  end

end


