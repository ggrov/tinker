(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      base/lcinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

 Holds the kinds of local cinfo for each goal. Allows you to check all
 the kinds of local cinfo that a goal has.

*) 


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature LCINFO =
sig

type T 

val empty : T;

(* adds a new kind of lcinfo to a goal *)
val add : (string * (Cx.gname -> PolymTable.T -> PolymTable.T))
          -> Cx.gname -> T -> T

(* give local cinfo from first goal to second goal. note: the cinfo
function at the end is assumed to just add local cinfo to the last
gname *)
val give : T -> Cx.gname -> Cx.gname -> PolymTable.T -> PolymTable.T

(* pretty printing / debugging *)
val pretty_gname : T -> Cx.gname -> Pretty.T
val pretty : T -> Pretty.T

val print_gname : T -> Cx.gname -> unit
val print : T -> unit


end


structure LCInfo : LCINFO = 
struct

datatype T = LCInfo of ((string (* kinds of cinfo in this goal *)
                        * (Cx.gname -> PolymTable.T -> PolymTable.T)) list) (* add cinfo to gname *)
                         GoalTab.table

val empty = LCInfo GoalTab.empty;

(* give cinfo from a goal to another goal. note: the cinfo
function at the end is assumed to just add local cinfo to the last
gname *)
fun give (LCInfo tab) fromgoal togoal cinfo =
    (case GoalTab.lookup tab fromgoal of 
       NONE => cinfo
     | SOME sflist => fold (fn (s,f) => f togoal) sflist cinfo);

(* add a new kind of local cinfo. *)
fun add sf g (LCInfo tab) =
    (case GoalTab.lookup tab g 
      of NONE => LCInfo (GoalTab.update (g,[sf]) tab)
       | SOME l => LCInfo (GoalTab.update (g,sf :: l) tab));

fun pretty_gname (LCInfo tab) g = 
    (case GoalTab.lookup tab g of 
       NONE => Pretty.str "NONE"
     | SOME l => Pretty.list "[" "]" (map (Pretty.str o fst) l));

fun pretty (lcinfo as (LCInfo tab)) = 
    Pretty.chunks
      (map 
         (fn (g,l) => 
             Pretty.block 
               [Pretty.str g,
                Pretty.str " => ",
                Pretty.list "[" "]" (map (Pretty.str o fst) l)])
         (GoalTab.dest tab));

val print_gname = Pretty.writeln oo pretty_gname;
val print  = Pretty.writeln o pretty;

end;
