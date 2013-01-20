theory import_test
imports "../Build/Parse"   
begin

ML{*
 warning "hello";
*}

ML{* List.last;
    val gname = String.tokens (fn c => c = #".") "/test/test/hello.p.q" 
              |> hd
              |> String.tokens (fn c => c = #"/")
              |> List.last
              |> String.tokens (fn c => c = #"\\") (* in case of windows.. *)
              |> List.last;
*}          

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

 val imp_feature = Feature.Strings (StrName.NSet.single imp,"top-level-const");
 val all_feature = Feature.Strings (StrName.NSet.single all,"top-level-const"); 

 val imp_wire = mk_wire "Imp" true imp_feature;
 val all_wire = mk_wire "All" true all_feature;
*}

setup {* StringTransfer.add_wire ("Imp",imp_wire) 
     #>  StringTransfer.add_wire ("All",all_wire) 
     #>  StringTransfer.add_wire ("default_wire",Wire.default_wire) *} 

-- "the reasoning techniques"
ML{*
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
*}

setup {* StringTransfer.add_rtechn ("impI",impI) 
     #>  StringTransfer.add_rtechn ("allI",allI) *} 

ML{*
val strg = StringTransfer.parse "/Users/ggrov/intro.qgraph";
val stratg = StringTransfer.to_strategy_graph @{theory} strg;
*}

(* add graph *)
setup {* StringTransfer.register_graph "/Users/ggrov/intro.qgraph" *}
(* add graph tactic *)
setup {* StringTransfer.register_nested "/Users/ggrov/intro.qgraph" *}


declare [[strategy = "intro"]]

lemma "! x. P x --> P x"
  apply proof_strategy
  done

(* to write *)
ML{*
  fun write_string fname str =
     let 
       val outs = TextIO.openOut fname; 
       val _ = TextIO.output (outs,str)
     in 
       TextIO.closeOut outs
     end;

(* need to get hold of empty annotiations *)
(StringVE_IO.OutputGraphJSON.output #> Json.encode);
*}

end
