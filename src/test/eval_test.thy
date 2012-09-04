theory eval_test 
imports
  "../build/Eval"
begin

ML{*
 val rtechn = RTechn.id
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);

 val g = GraphComb.theng (GraphEnv.graph_of_rtechn rtechn) (GraphEnv.graph_of_rtechn rtechn);


*}


end;


