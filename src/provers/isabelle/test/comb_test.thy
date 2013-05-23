(* simple test of combinators *)
theory comb_test                                                
imports               
 "../build/Prf"                                                                  
begin

ML{*
;
 val impI = RTechn.id
           |> RTechn.set_name (RT.mk "impI")
           |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.impI"))
*}
ML{*
  val psfg1 = PSComb.LIFT ([GoalTyp.top],[GoalTyp.top]) (impI)
  val psfg2 = PSComb.LIFT ([GoalTyp.top],[GoalTyp.top]) (RTechn.id)
  val psfg3 = PSComb.THENG (psfg1,psfg2);
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



