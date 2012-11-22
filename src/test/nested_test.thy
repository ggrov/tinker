theory nested_test 
imports
  "../build/Eval"             
begin

ML{*
 val path = "/u1/staff/gg112/";
 val wire = Wire.default_wire;
 val rt = RTechn.id_of wire;
 val (g,th) = NEST "2id" (LIFTRT rt THENG LIFTRT rt) @{theory};
 Strategy_RS.Theory.get_ruleset th |> Strategy_Theory.Ruleset.get_all_rule_names_list;
*}

ML{*
 Strategy_Dot.write_dot_to_file false (path ^ "nested1.dot") g
*}

ML{*
  Strategy_RS.Theory.get_ruleset th |> Strategy_Theory.Ruleset.get_all_rule_names_list;
*}
end;


