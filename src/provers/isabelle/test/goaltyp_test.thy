theory goaltyp_test             
imports                    
  "../build/GoalTyp" 

  uses "../../prover.ML"  "../isa_prover.ML"  (* "../isa_setup.ML"*)
begin
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
(*
  fun feature_to_json f = x;
  fun feature_from_json json = 1;
  fun data_to_json 
  fun data_from_json json = 1;

  fun class_to_json class = Json.of_string "class";
  
  fun class_from_json json = Class.top;

  fun link_to_json link = Json.of_string "link";
  
  fun link_from_json json = Link.top;

  fun to_json gt = Json.Null;
  
  fun from_json json = GoalTyp.top;
*)
*}

text{* Test for Class*}
ML{*
(*test for type set*)
structure int_set_type : TYPE_SET = 
struct 
type T = int
val compare = fn (x,y) =>  SOME(Int.compare(x,y))
end;

structure int_set = NaiveSetFun (int_set_type);

val s1 = int_set.id |> int_set.insert 1 |> int_set.insert 2;
val s2 = int_set.id |> int_set.insert 3 |> int_set.insert 4;
int_set.remove 1 s1;
int_set.size s1;
int_set.union(s1,s2);
int_set.inter(s1,s2);

val s3 = int_set.id |> int_set.insert 1 |> int_set.insert 2;
val s4 = int_set.id |> int_set.insert 2 |> int_set.insert 4;
int_set.union(s3,s4);
int_set.inter(s3,s4);
*}
ML{*

val f0 = Class.set_data (GT_Name.mk "sequence int") [[(GTData.Int 3),(GTData.Int 5),(GTData.Int 1)], [(GTData.Int 1),(GTData.Int 2),(GTData.Int 3)]] Class.top ;

val f1 = Class.set_data (GT_Name.mk "sequence int") [[(GTData.Int 3),(GTData.Int 5),(GTData.Int 1)],[(GTData.Int 4),(GTData.Int 2),(GTData.Int 3)]] Class.top ;

DB_Class.union (f0,f1);
DB_Class.inter (f0,f1);

val f0 = Class.set_data (GT_Name.mk "sequence int") [[(GTData.Int 3),(GTData.Int 5),(GTData.Int 1)], [(GTData.Int 1),(GTData.Int 2),(GTData.Int 3)]] Class.top ;

val f1 = Class.set_data (GT_Name.mk "sequence int") [[(GTData.Int 3),(GTData.Int 6),(GTData.Int 1)],[(GTData.Int 4),(GTData.Int 2),(GTData.Int 3)]] Class.top;
val f2 =  Class.set_data (GT_Name.mk "dummy  int") [[GTData.Int 8]] f1; 
DB_Class.union (f0,f1);
DB_Class.inter (f0,f1);
DB_Class.inter (f0,f2);
*}

ML{*
GTData.from_single_list [(GTData.Int 3),(GTData.Int 5),(GTData.Int 1)];
val data = GTData.from_list [[(GTData.Int 3),(GTData.Int 5),(GTData.Int 1)], [(GTData.Int 1),(GTData.Int 2),(GTData.Int 3)]];
val list_data = GTData.to_list data
*}


text{* Test for link*}
end
