signature G_TERM =
sig
  type term
  type position
  val compare_term  : (term * term) -> order
  val compare_position : (position* position) -> order
end;

structure General_Term = 
struct
  type position = int list;
  type term = Term.term;(* fixme: could be term dependent, this should be defined in G_TERM *)
  
(*FIXME: complete the compare function based on term and position definition*)
  fun compare_term (_,_) = EQUAL 
  fun compare_position (_,_) = EQUAL 
end (*struct*)
