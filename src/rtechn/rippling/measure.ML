(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ripple_measure.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Modified:   5 Aug 2008
    Created:    24 Feb 2004
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    Measures for rippling 
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature BASIC_RIPPLE_MEASURE = 
sig 
  type T
  structure Col : COLLECTION 
  sharing type Col.obj = T

  val name : string; (* unique ID for measure kind *)
  val ord : T * T -> order
  val init_measures : Embed.T list (* new embedding *)
                     -> Col.T (* new measures *)
  val better_next_measures : Col.T (* old measures *)
                -> Embed.T list (* new embedding *)
                -> Col.T (* new better measures *)

  (* all possible new measures; not the same as initial measures
     because new measures may build upon old ones; when measurement is
     not depndent on old measurements, then this is the same as
     init_measure. *)
  val all_next_measures : Col.T -> Embed.T list -> Col.T

  val success_chk : T -> bool

  val pretty : T -> Pretty.T
  val print : T -> unit
end;


(* IsaPlanner Ripple measure using only a single int *)
functor IntRippleMeasureFUN(val embed_measure : Embed.T -> int)
        : BASIC_RIPPLE_MEASURE 
= struct

type T = int;
structure Col = CollectionFUN(type key = int val ord = Int.compare);

val name = "IntRippleMeasure";
fun success_chk i = (i = 0);
fun init_measures es = Col.of_list (map embed_measure es);
fun ord (i,i2) = Library.int_ord (i,i2);
fun better_next_measures oldms es = 
    let val m2s = (map embed_measure es)
    in 
      Col.of_list 
        (filter 
           (fn m2 => 
               List.exists (fn oldm => (case ord(oldm,m2) of GREATER => true | _ => false))
                           (Col.list_of oldms))
           m2s)
    end;
fun all_next_measures oldm e = init_measures e;
fun pretty i = (Pretty.str o string_of_int) i;
val print = Pretty.writeln o pretty;

end;
