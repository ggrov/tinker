theory JsonIO_test
imports "../build/RTechn"
uses "../rtechn/rtechn_json.ML"   
begin
ML{*
local open RTechn Json in

val r = RTechn.id
            |> RTechn.set_name "assumption"
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"));


   val test_src = StrName.NSet.of_list ["abc", "bbc"]
   val test_dest = StrNameNSet_to_json test_src |> StrNameNSet_from_json;

   val test_src = StrName.NSet.of_list ["abc", "bbc"] |> TClass;
   val test_dest = tac_assms_to_json test_src |> tac_assms_from_json;


   val test_src = StrName.NSet.of_list ["abc", "bbc"] |> TClass |> (fn x => Tactic (x,"test"));
   val test_dest = atomic_to_json test_src |> atomic_from_json;


   val test_src = StrName.NSet.of_list ["abc", "bbc"] |> TClass |> (fn x => Tactic (x,"test")) |> Appf;
   val test_dest = appfn_to_json test_src |> appfn_from_json;
   val r = RTechn {name = "test", appf = test_src};

end
*}


end
