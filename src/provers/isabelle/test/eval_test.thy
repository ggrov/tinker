theory eval_test 
imports
  "../build/IsaP"         
begin

ML{*
  val gt = FullGoalTyp.default;

  val auto = RTechn.id
            |> RTechn.set_name (RT.mk "auto")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "auto"));
  val auto_tac = fn x => ( fn _ => Clasimp.auto_tac x);

  val psauto = PSComb.LIFT ([gt],[]) (auto);
  val psgraph = psauto PSGraph.empty;

  val psgraph = 
    psauto PSGraph.empty 
    |> PSGraph.update_atomics (StrName.NTab.doadd ("auto", auto_tac))

*}
ML{*
  val (pn,pp) = BIsaAtomic.init @{context} @{prop "A --> A"};
  val pnode_tab = 
       StrName.NTab.ins
         (BIsaAtomic.get_pnode_name pn,pn)
         StrName.NTab.empty;
  val edata_0 = EData.init psgraph pp pnode_tab [];

  FullGoalTyp.init_lift gt pn;
*}
ML{*
  val edata0 = EVal.init psgraph @{context} @{prop "A --> A"} |> hd;
  val edata1 = EVal.evaluate_any edata0 |> Seq.list_of |> hd;
*}
end;


