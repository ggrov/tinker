signature GPROVER =
sig
  type pos
  type typ
  type term 
  type thm
  type context
  type tactic 

  exception gterm_exp
  
  val globe_ctxt : context (* used in those place need context in general *)
  val typ_of : term -> typ
  val match : context -> (term * term) -> bool

  val eq_pos : (pos * pos) -> bool
  val intlist_of_pos : pos -> int list
  val pos_of_intlist : int list -> pos

  val top_of_trm : term -> term
  val trm_of_pos : pos -> term -> term 
  val subtrm_of_pos : pos -> term -> term

  val trm_of_thm : thm -> term
  (*val consts_of_trm : term -> term list  return ops ?? duplicated ops allowed*)
 
  val trm_of_string : context -> string -> term
  val string_of_trm : context -> term -> string
  val pretty_trm : context -> term -> Pretty.T

  val concl_of_thm : thm -> term

  
 (* val get_goal : context -> T ->  (context * term)*)
  
end;

