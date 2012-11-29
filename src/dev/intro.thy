theory intro  
imports
  "../build/Eval"             
begin

ML{*
  val path = "/u1/staff/gg112/";
*}

section "Implements an introduction method using graphs"

ML{*
 val imp = "HOL.implies";
 val conj = "HOL.conj";
 val all = "HOL.All";

 fun mk_wire name is_pos feature =
   Wire.default_wire
   |> Wire.set_name (SStrName.mk name)
   |> Wire.set_goal 
      (BWire.default_wire |> (if is_pos then BWire.set_pos (F.NSet.single feature) 
                                         else BWire.set_neg (F.NSet.single feature)));

 val comb_feature = Feature.Strings (StrName.NSet.of_list [imp,conj,all],"top-level-const");
 val imp_feature = Feature.Strings (StrName.NSet.single imp,"top-level-const");
 val conj_feature = Feature.Strings (StrName.NSet.single conj,"top-level-const");
 val all_feature = Feature.Strings (StrName.NSet.single all,"top-level-const"); 

 val comb_wire = mk_wire "neg_comb" false comb_feature;
 val imp_wire = mk_wire "imp" true imp_feature;
 val conj_wire = mk_wire "conj" true conj_feature;
 val all_wire = mk_wire "all" true all_feature;
*}

-- "the reasoning techniques"
ML{*
val split1 = 
 RTechn.id
 |> RTechn.set_name "split1"
 |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_outputs (W.NSet.of_list [comb_wire,imp_wire,conj_wire,all_wire]);

val allI = 
 RTechn.id
 |> RTechn.set_name "allI"
 |> RTechn.set_inputs (W.NSet.single all_wire)
 |> RTechn.set_outputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.allI"));

val impI = 
 RTechn.id
 |> RTechn.set_name "impI"
 |> RTechn.set_inputs (W.NSet.single imp_wire)
 |> RTechn.set_outputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.impI"));

val conjI = 
 RTechn.id
 |> RTechn.set_name "conjI"
 |> RTechn.set_inputs (W.NSet.single conj_wire)
 |> RTechn.set_outputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.conjI"));

*}

-- "graphs"
ML{*
val gf = LIFT (GraphEnv.lift_merge 4 Wire.default_wire)
           THENG
        LIFTRT split1 
           THENG
        (LIFTRT conjI TENSOR LIFTRT impI TENSOR LIFTRT allI);


val (g,th) = gf @{theory};
val g = GraphComb.self_loops g;
val (g',th') = NEST "intros" (LIFT g) th;
*}



ML{*
 Strategy_Dot.write_dot_to_file false (path ^ "imptest0.dot") g; 
*}

ML{*
 val edata0 = RTechnEval.init_g th' [@{prop "A \<and> A"}] g;
 Strategy_Dot.write_dot_to_file false (path ^ "imptest.dot") (RTechnEval.EData.get_graph edata0);
*}

ML{*

val [gnode] = GraphEnv.get_goalnodes_of_graph (RTechnEval.EData.get_graph edata0) 
              |> V.NSet.list_of
              |> map (GraphEnv.v_to_gnode (RTechnEval.EData.get_graph edata0));
val (SOME pnode) = PPlan.lookup_node (RTechnEval.EData.get_pplan edata0) "g";
val check = EvalOutput.upd_by_wire (RTechnEval.EData.get_fmatch edata0) gnode pnode;

val v_rt = GraphEnv.get_rtechns_of_graph (RTechnEval.EData.get_graph edata0) |> V.NSet.list_of |> hd;
val rt = GraphEnv.v_to_rtechn (RTechnEval.EData.get_graph edata0) v_rt;
check comb_wire;
check imp_wire;
check conj_wire;
check all_wire;
*}
ML{*
 val rule =  EvalGraph.output_gnode (comb_wire,rt) (comb_wire,gnode);
 val lhs = Strategy_Theory.Rule.get_rhs rule;
 Strategy_Dot.write_dot_to_file false (path ^ "imptest.dot") (lhs);
*}


ML{*
  val edata = hd (RTechnEval.eval_any edata0 |> Seq.list_of);
 Strategy_Dot.write_dot_to_file false (path ^ "imptest.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}



ML{*
  val edata = (RTechnEval.eval_any edata |> Seq.list_of);
 Strategy_Dot.write_dot_to_file false (path ^ "imptest.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}


end;


