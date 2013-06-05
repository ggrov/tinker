(* simple test of combinators *)
theory comb_test                                              
imports               
 "../build/BIsaP"                                                                  
begin

ML{*
 val impI = RTechn.id
           |> RTechn.set_name (RT.mk "impI")
           |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.impI"))
*}
ML{*
  val psfg1 = PSComb.LIFT ([SimpleGoalTyp.default],[SimpleGoalTyp.default]) (impI)
  val psfg2 = PSComb.LIFT ([SimpleGoalTyp.default],[SimpleGoalTyp.default]) (RTechn.id)
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
 Theory.PS_TheoryIO.OutputGraphJSON.output g
  |> Json.pretty
  |> Pretty.writeln;
*}




end



