theory GoalType_test           
imports      
  Main   
  "../build/RTechn"
uses "../goaltype/type_set.ML" "../goaltype/general_term.ML" "../goaltype/class.ML" 
begin
ML{*
(*test for type set*)
structure int_set_type : TYPE_SET = 
struct 
type T = int
val compare = fn (x,y) =>  SOME(Int.compare(x,y))
end;

structure int_set = NaiveSet_FUN (int_set_type);

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

val f0 = Class.set_data "sequence int" [[(Class.Int 3),(Class.Int 5),(Class.Int 1)], [(Class.Int 1),(Class.Int 2),(Class.Int 3)]] Class.id ;

val f1 = Class.set_data "sequence int" [[(Class.Int 3),(Class.Int 5),(Class.Int 1)],[(Class.Int 4),(Class.Int 2),(Class.Int 3)]] Class.id ;

Class.union (f0,f1);
Class.inter (f0,f1);

val f0 = Class.set_data "sequence int" [[(Class.Int 3),(Class.Int 5),(Class.Int 1)], [(Class.Int 1),(Class.Int 2),(Class.Int 3)]] Class.id ;

val f1 = Class.set_data "sequence int" [[(Class.Int 3),(Class.Int 6),(Class.Int 1)],[(Class.Int 4),(Class.Int 2),(Class.Int 3)]] Class.id ;
val f1 =  Class.set_data "dummy  int" [[Class.Int 8]] f1; 
Class.union (f0,f1);
Class.inter (f0,f1)
*}
end
