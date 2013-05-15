signature GPRF =
sig
  type pos
  type typ
  type term 
  type thm
  type context
  type tactic 

  exception gterm_exp
  
  val typ_of : term -> typ
  val match : context -> (term * term) -> bool

  val eq_pos : (pos * pos) -> bool

  val top_of_trm : term -> term
  val trm_of_pos : pos -> term -> term 
  val subtrm_of_pos : pos -> term -> term

  val trm_of_thm : thm -> term
 (* val consts_of_trm : term -> string list  return ops ?? duplicated ops allowed*)
 
  val trm_of_string : context -> string -> term
  val pretty_trm : context -> term -> Pretty.T

  
 (* val get_goal : context -> T ->  (context * term)*)
  
end;

