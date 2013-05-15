theory JsonIO_test
imports "../build/RTechn" "../build/GoalTyp"   
uses "../../../rtechn/rtechn_json.ML"   "../isaPrf.ML"
begin

(* reasoning technique *)
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


(* goal type *)
ML{*
structure GTData : GT_DATA = GTDataFun (IsaPrf);
structure Class : CLASS = ClassFun (GTData);
structure Link : LINK = LinkFun(Class);
structure GoalTyp = GoalTypFun(Link);
structure GTJson = GTJsonFun (GoalTyp);
*}

ML{*
val d1 = GTData.Int 0;
val d2 = GTData.Position [1,2,3];
val d3 = GTData.Term @{term " a + b"};

Syntax.string_of_term @{context} @{term" a + b"} |> Syntax.parse_term @{context};

GTJson.data_to_json @{context} d1 |> Json.pretty |> Pretty.writeln;
GTJson.data_to_json @{context} d2 |> Json.pretty |> Pretty.writeln;
GTJson.data_to_json @{context} d3 |> Json.pretty |> Pretty.writeln;

GTJson.data_to_json @{context} d1 |> GTJson.data_from_json @{context} ;
GTJson.data_to_json @{context} d2 |> GTJson.data_from_json @{context} ;
GTJson.data_to_json @{context} d3 |> GTJson.data_from_json @{context} ;
*}

ML{*
  fun data_ll_to_json ctxt dll =
  let 
    fun list_to_json dl = map (fn x => GTJson.data_to_json ctxt x) dl |> Json.Array
  in
    map list_to_json dll |> Json.Array
  end
    
  fun data_ll_from_json ctxt  (Json.Array j) = map (fn (Json.Array x) => map (GTJson.data_from_json ctxt) x) j
  | data_ll_from_json _ _ = raise EXP_PARSING_JSON "Not a Json array type."

  val d1 = GTData.Int 0;
  val d2 = GTData.Position [1,2,3];
  val d3 = GTData.Int 2;
  
  data_ll_to_json @{context} [[d1, d2],[d3]] |> Json.pretty |> Pretty.writeln;
  data_ll_to_json @{context} [[d1, d2],[d3]] |> data_ll_from_json @{context} 
*}

end
