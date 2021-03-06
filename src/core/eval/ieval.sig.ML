signature IEVAL_SHARING =
sig
  type result
  structure EData : EVAL_DATA_SHARING
end

(* Should work as evaluation interface to GUI *)
signature IEVAL =
sig
 structure EVal : EVAL
 structure EData : EVAL_DATA

 sharing EVal.EData.Sharing = EData.Sharing
 datatype result = Good of EData.T | Bad | Cont of EData.T

 (* debug / breakpoint / logging ??*)
(* val complete : EData.T -> EData.T  current hierarchy *)
(* val cancel : EData.T -> EData.T  remove all goal nodes *)
(* term to generate goal from *)
(* val start : string 
             -> EData.PSGraph.T
             -> EData.T
*)
 (* edit of PSGraph during evaluation? *) 
 (* how to deal with other changes *)
 (* allow to re-evaluate until given point? *)
 val update_psgraph : EData.T -> EData.T (* other arguments *)

 val output_string : string -> Json.json -> EData.T option  -> string
 val output_json : string -> Json.json -> EData.T  -> Json.json
 val output_cmd_only_json : string -> Json.json 
 val mk_cmd_str_arg_json : string list -> Json.json
 
 val eval_any : EData.T -> result
 val eval_goal: string -> EData.T -> result (* goal to be eval -> current eval status *)
 val eval_backtrack : EData.T -> result 
(* val eval_step_into : V.name option -> EData.T -> result*)
 val eval_step_over : string -> EData.T -> result
 val eval_complete : EData.T -> result (* finish whole ps *)
 val eval_finish : EData.T -> result (* finish current graph *)
 val eval_until_break :  EData.T -> result

 structure Sharing : IEVAL_SHARING
  sharing type result = Sharing.result
  sharing Sharing.EData = EData.Sharing

end

