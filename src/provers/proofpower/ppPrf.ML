structure PpPrf : GPRF =
struct
  type term = Basic_Term.term
  type pos = int list (* fixme *)
  type typ = Basic_Term.typ
  type thm = THM
  type context = string list * string (* context string list * theory string *)
  (* get_current_pc () open_theory, set_pc *)
  
  val typ_of = Basic_Term.type_of
  fun match ctxt = true (* FIXME*)
  
(* FIXME: complete this *)
  fun pos_of_trm pos trm = trm
  fun subtrm_of_pos pos trm = trm
  
(* TODO: how to print those fancy symbols in proofpower ?*)
  fun string_of_trm _ = fn trm => PrettyPrinter.format_term true trm 
  val pretty_trm = ??? (* FIXME *)
end
