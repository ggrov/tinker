theory json_test
imports "../build/RTechn" "../build/GoalTyp"   
uses "../../../rtechn/rtechn_json.ML"  "../../../goaltype/goaltyp_json.ML"  "../isa_prover.ML"
begin

(* reasoning technique *)
ML{*
open RTechnJSON;

val r = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,( "atac")));

   val test_src =  ["abc", "bbc"] |> map C.mk |> C.NSet.of_list |> RTechn.TClass;
   val test_dest = tac_assms_to_json test_src |> tac_assms_from_json;

   val test_src = test_src |> (fn x => RTechn.Tactic (x,  "test"));
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
val d3 = GTData.Term " a + b";


GTJson.data_to_json d1 |> Json.pretty |> Pretty.writeln;
GTJson.data_to_json  d2 |> Json.pretty |> Pretty.writeln;
GTJson.data_to_json  d3 |> Json.pretty |> Pretty.writeln;

GTJson.data_to_json  d1 |> GTJson.data_from_json  ;
GTJson.data_to_json  d2 |> GTJson.data_from_json  ;
GTJson.data_to_json  d3 |> GTJson.data_from_json  ;
*}

ML{*
  val d1 = GTData.Int 0;
  val d2 = GTData.Position [1,2,3];
  val d3 = GTData.Int 2;
  
  val class = GoalTyp.Link.Class.top |> GoalTyp.Link.Class.rename (C.mk "class") 
                                     |> GoalTyp.Link.Class.set_item (F.mk "cname_test")[[d1, d2],[d3]]
                                     |> GoalTyp.Link.Class.set_item (F.mk "cname_test2")[[d1],[d3]];
  GTJson.class_to_json class |> Json.pretty |>Pretty.writeln; 
  GTJson.class_to_json class |> GTJson.class_from_json;

  val link = GoalTyp.Link.top |> GoalTyp.Link.rename (C.mk "link") 
                                     |> GoalTyp.Link.set_item ((L.mk "ln"),(C.mk "cn1", C.mk "cn2"))[[d1, d2],[d3]]
                                     |> GoalTyp.Link.set_item ((L.mk "ln2"),(C.mk "cnx1", C.mk "cnx2"))[[d1],[d3]];
  GTJson.link_to_json link |> Json.pretty |>Pretty.writeln; 
  GTJson.link_to_json link |> GTJson.link_from_json; 

  val gtp = GoalTyp.top |> GoalTyp.set_name (G.mk "goal type")
                        |> GoalTyp.set_link link
                        |> GoalTyp.set_facts [class, class]
                        |> GoalTyp.set_gclass class;
  GTJson.to_json gtp;
  GTJson.to_json gtp |> Json.pretty |>Pretty.writeln; 
  GTJson.to_json gtp |> GTJson.from_json; 

*}

end
