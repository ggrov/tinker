theory json_test
imports "../build/basic/RTechn" "../build/GoalTyp"   
uses "../isa_prover.ML"
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
structure GoalTypData : GOALTYP_DATA = GoalTypDataFun (IsaProver);
structure Class : CLASS = ClassFun (GoalTypData);
structure Link : LINK = LinkFun(structure GoalTypData = GoalTypData structure Prover = IsaProver);
structure GoalTyp = GoalTypFun(structure Link = Link structure Class = Class);
structure GoalTypJson = GoalTypJsonFun  (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = IsaProver);

*}

ML{*
val d1 = GoalTypData.Int 0;
val d2 = GoalTypData.Position [1,2,3];


GoalTypJson.data_to_json d1 |> Json.pretty |> Pretty.writeln;
GoalTypJson.data_to_json  d2 |> Json.pretty |> Pretty.writeln;

GoalTypJson.data_to_json  d1 |> GoalTypJson.data_from_json  ;
GoalTypJson.data_to_json  d2 |> GoalTypJson.data_from_json  ;
*}

ML{*
  val d1 = GoalTypData.Int 0;
  val d2 = GoalTypData.Position [1,2,3];
  val d3 = GoalTypData.Int 2;
  
  val class = GoalTyp.Class.top |> GoalTyp.Class.rename (C.mk "class") 
                                     |> GoalTyp.Class.set_item (F.mk "cname_test")[[d1, d2],[d3]]
                                     |> GoalTyp.Class.set_item (F.mk "cname_test2")[[d1],[d3]];
  GoalTypJson.class_to_json class |> Json.pretty |>Pretty.writeln; 
  GoalTypJson.class_to_json class |> GoalTypJson.class_from_json;

  val link = GoalTyp.Link.top |> GoalTyp.Link.rename (C.mk "link") 
                                     |> GoalTyp.Link.set_item ((L.mk "ln"),(C.mk "cn1", C.mk "cn2"))[[d1, d2],[d3]]
                                     |> GoalTyp.Link.set_item ((L.mk "ln2"),(C.mk "cnx1", C.mk "cnx2"))[[d1],[d3]];
  GoalTypJson.link_to_json link |> Json.pretty |>Pretty.writeln; 
  GoalTypJson.link_to_json link |> GoalTypJson.link_from_json; 

  val gtp = GoalTyp.top |> GoalTyp.set_name (G.mk "goal type")
                        |> GoalTyp.set_link link
                        |> GoalTyp.set_facts [class, class]
                        |> GoalTyp.set_gclass class;
  GoalTypJson.to_json gtp;
  GoalTypJson.to_json gtp |> Json.pretty |>Pretty.writeln; 
  GoalTypJson.to_json gtp |> GoalTypJson.from_json; 

*}

end
