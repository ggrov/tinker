(* Should work as evaluation interface to GUI *)
signature IEVAL =
sig

 structure EData : EVAL_DATA
 
 val step_into : V.name option -> EData.T -> EData.T
 val step_over : V.name option -> EData.T -> EData.T

 val backtrack : EData.T -> EData.T 

 (* debug / breakpoint / logging ??*)

 val complete : EData.T -> EData.T (* current hierarchy *)
 val cancel : EData.T -> EData.T (* remove all goal nodes *)

 val start : string (* term to generate goal from *)
             -> PSGraph.T
             -> EData.T

 (* edit of PSGraph during evaluation? *) 
 (* how to deal with other changes *)
 (* allow to re-evaluate until given point? *)
 val update_graph : EData.T -> EData.T (* other arguments *)
end

