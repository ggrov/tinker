theory group_strategy_fullgt
imports
  "../GroupAx"
  "../../../provers/isabelle/full/build/IsaP"
begin

-- "path to write graphs to"
ML{*
val path = "/home/colin/Documents/phdwork/groupstrat/"
*}


ML{*
  val goalclass = Class.add_item (SStrName.mk "has_symbol") [[GoalTypData.String "zero"]] Class.top
                |> Class.rename (C.mk "goal_base");
  val gt_base = FullGoalTyp.set_gclass goalclass FullGoalTyp.default
              |> FullGoalTyp.set_name (G.mk "base");
*}

end
