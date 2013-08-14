structure PPProver : PROVER =
struct

  type pos = PPTermLib.pos
  type typ = TYPE
  type term = TERM
  type thm = THM
  type tactic = TACTIC
  type context = string list * string (* context string list * theory string *)
  (* get_current_pc () open_theory, set_pc *)

  exception gterm_exp
  
  val current_ctxt = get_current_pc (); (* used in those place need context in general *)
  val typ_of = type_of
  fun match ctxt = (op ~=$) 

  val eq_pos = PPTermLib.eq_pos
    
  fun intlist_of_pos pos = pos
  fun pos_of_intlist il = il
  
  val root_of_trm = PPTermLib.root_of_trm
  val subtrm_of_pos = PPTermLib.subtrm_of_pos
  val trm_of_pos = PPTermLib.trm_of_pos
  
  val concl_of_thm = concl
  val asms_of_thm =  asms
  (* get asm of thm - asms*)
  fun trm_of_string _ = mk_string 
  
(* TODO: how to print those fancy symbols in proofpower ?*)
  fun string_of_trm _ = fn trm => PrettyPrinter.format_term true trm |> String.concat
  fun pretty_trm dummy t = Pretty.str "pretty term - not supported in pp"

  structure Sharing = 
  struct
    type pos = pos
    type typ = typ
    type term = term
    type thm = thm
    type context = context
    type tactic = tactic
  end
end
