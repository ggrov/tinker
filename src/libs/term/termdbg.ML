(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Title:      Pure/IsaPlanner/term_lib.ML
    ID:    $Id: termdbg.ML 2576 2010-06-26 13:47:23Z lucasd $
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Created:    17 Aug 2002
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  DESCRIPTION:

    Additional code to work with terms.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature TERM_DBG =
sig
    val debug_isaplanner : bool ref
    val asm_mk : theory -> Term.term -> Thm.thm
    val asm_read : theory -> string -> Thm.thm
end;


structure TermDbg 
 : TERM_DBG
= struct

(* for printing statistics and debug info during proving *)
val debug_isaplanner = Unsynchronized.ref false;

fun asm_mk thry t = Thm.assume (Thm.cterm_of thry t);
fun asm_read thry s = 
    s |> (Syntax.read_prop 
                (ProofContext.set_mode ProofContext.mode_schematic 
                                       (ProofContext.init_global thry)))
      |> asm_mk thry;


end;
