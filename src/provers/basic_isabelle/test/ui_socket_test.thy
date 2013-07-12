theory ui_socket_test
imports "../build/BIsaP"  
begin  
 
(* socket *)
ML_file "../../../interface/text_socket.ML"
ML_file "../../../interface/ui_socket.ML"

(* json protocol, they are alreay in Quantolib *)
ML_file "../../../interface/json_protocol/controller_util.ML"
ML_file "../../../interface/json_protocol/controller_module.ML"
ML_file "../../../interface/json_protocol/modules/psgraph.ML"
ML_file "../../../interface/json_protocol/controller_registry.ML"
ML_file "../../../interface/json_protocol/protocol.ML"

ML{*
  val path = "/Users/yuhuilin/Desktop/" (*"/u1/staff/gg112/"*);
*}

(* simple example *)
ML{*
  val asm = RTechn.id
          |> RTechn.set_name (RT.mk "assumption")
          |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "atac"));
  
  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));
   
  val gt = SimpleGoalTyp.default;
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";
  
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
 
  val psconjI0 =  PSComb.LIFT ([gt_conj],[gt_conj, gt_imp]) (conjI);
  val psconjI = PSComb.LIFT ([gt_conj],[gt]) (conjI);
  val psimpI = PSComb.LIFT ([gt_imp],[gt]) (impI);
  val psasm1 = PSComb.LIFT ([gt],[]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psfg3 = psconjI0 THENG  psconjI THENG psimpI THENG psasm2;
  val psgraph = psfg3 PSGraph.empty |> PSGraph.load_atomics [("atac",K atac)];

  val edata0 = EVal.init psgraph @{context} @{prop "A \<Longrightarrow>(A \<and> A)  \<and> (A \<longrightarrow> A)"} |> hd;

 
*}


end
