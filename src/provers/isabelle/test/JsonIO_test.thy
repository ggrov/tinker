theory JsonIO_test
imports "../build/RTechn"   
uses "../../../rtechn/rtechn_json.ML"     
begin
ML{*
open RTechnJSON;

val r = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,(RT.mk "atac")));

   val test_src =  ["abc", "bbc"] |> map RT.mk |> RT.NSet.of_list
   val test_dest = RTNSet_to_json test_src |> RTNSet_from_json;

   val test_src =  ["abc", "bbc"] |> map RT.mk |> RT.NSet.of_list |> RTechn.TClass;
   val test_dest = tac_assms_to_json test_src |> tac_assms_from_json;


   val test_src = test_src |> (fn x => RTechn.Tactic (x, RT.mk "test"));
   val test_dest = atomic_to_json test_src |> atomic_from_json;


   val test_src = test_src |> RTechn.Appf;
   val test_dest = appfn_to_json test_src |> appfn_from_json;
   val r = RTechn.id
           |> RTechn.set_name (RT.mk "myname") 
           |> RTechn.set_appf test_src;
*}

ML{*
 rtechn_to_json r
 |> Json.string_of
*}


end
