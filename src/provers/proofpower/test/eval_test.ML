
  val gt = FullGoalTyp.default;

  val strip = RTechn.id
            |> RTechn.set_name (RT.mk "z_strip_tac")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "z_strip_tac"));

  val psauto = PSComb.LIFT ([gt],[]) (strip);
  val psgraph = psauto PSGraph.empty;

  val psgraph = 
    psauto PSGraph.empty 
    |> PSGraph.update_atomics (StrName.NTab.doadd ("z_strip_tac", z_strip_tac));
    
  val ctxt = get_current_pc();
  val edata0 = EVal.init_with_assm psgraph ctxt [] %<% A %and% B  %implies% A %and% B %>% |> hd;
  val edata1 = EVal.evaluate_any edata0 |> Seq.list_of |> hd;
