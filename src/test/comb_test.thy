(* simple test of combinators *)
theory comb_test                                                
imports               
 "../build/Graph"                                                                  
begin

ML{*
;
 val impI = RTechn.id
           |> RTechn.set_name "impI"
           |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.impI"))
*}
ML{*
  val psfg1 = LIFT ([GoalTyp.top],[GoalTyp.top]) (impI)
  val psfg2 = LIFT ([GoalTyp.top],[GoalTyp.top]) (RTechn.id)
  val psfg3 = psfg1 THENG psfg2;
*}

ML{*
 RTechnJSON.rtechn_to_json RTechn.id
  |> Json.pretty
  |> Pretty.writeln;
*}

ML{*
  val ps = psfg3 PSGraph.empty;
  val g = PSGraph.get_graph ps;
*}

ML{*
 
 PS_GraphicalTheoryIO.OutputGraphJSON.output g
  |> Json.pretty
  |> Pretty.writeln;
*}





end



