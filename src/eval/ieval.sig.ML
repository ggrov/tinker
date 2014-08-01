(* Should work as interface to GUI for evaluation *)
signature IEVAL =
sig

 structure EData : EVAL_DATA
 
 val step_into : V.name option -> EData.T -> EData.T
 val step_over : V.name option -> EData.T -> EData.T

 (* debug? *)
 val complete : EData.T -> EData.T
 
end

