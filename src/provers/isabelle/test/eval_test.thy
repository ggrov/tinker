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
  val edata1 = EVal.evaluate_any edata0 ;
*}

(* socket *)
ML_file "../../../interface/text_socket.ML"
ML_file "../../../interface/ui_socket.ML"

(* json protocol, they are alreay in Quantolib *)

ML_file "../../../interface/json_protocol/controller_util.ML"
ML_file "../../../interface/json_protocol/controller_module.ML"
ML_file "../../../interface/json_protocol/modules/psgraph.ML"
ML_file "../../../interface/json_protocol/controller_registry.ML"
ML_file "../../../interface/json_protocol/protocol.ML"

(*
ML{*
UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams (SOME edata0) (K edata0)
*}
*)
end;


