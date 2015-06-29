signature CMOD =
sig
  type T
  val ftab : T
  val dispatch Json.json -> Json.json
end


functor CModTinker (IEVal : IEVAL) : CMOD =
struct
exception user_exn of string
structure EData = IEVal.EData

type T = ((Json.json -> Json.json) * string) Symtab.table

fun get_cmd_name (Json.Object obj) =  
  JsonInputUtils.get_obj obj "cmd" 
  |> (fn x =>JsonInputUtils.get_string x "name")
| get_cmd_name _ = raise user_exn "wrong json type in get_cmd_name"

fun register (cmd : string) f = Symtab.update_new (cmd, f)
val ftab = Symtab.empty
(* 
  Dummy_RSP: cmd: string
  PRINT_ONLY_RSP: cmd: string, msg: string
*)

(*
RSP_INIT_PSGRAPH
RSP_ERROR_INIT_PSGRAPH
*)

(*
RSP_EVAL_PSGRAPH
RSP_ERROR_EVAL_PSGRAPH

*)

(*
RSP_DISPLAY_PSGRAPH
RSP_ERROR_DISPLAY_PSGRAPH
*)

(*
*)


val ftab = ftab |> register
  "RSP_INIT_PSGRAPH" RSP_INIT_PSGRAPH

fun RSP_EVAL_PSGRAPH json = 

(*
val ftab = ftab |> register
  "mode_choice" (* should be the fisrt command received after init *)
  (fn _ => (
  UISocket.ui_mode_choice ()))

val ftab = ftab |> register
 "passive_init" (* should be the fisrt command received after init *)
 (fn x => (
  UISocket.ui_passive_init x))

val ftab = ftab |> register
 "active_init" (* should be the fisrt command received after init *)
  (fn x => (
  UISocket.ui_active_init x))

val ftab = ftab |> register
  name   = "next_status"
  (fn x => (
  UISocket.ui_eval_next x))

val ftab = ftab |> register
  name   = "previous_status"
  (fn x => (
  UISocket.ui_eval_prev x))

val ftab = ftab |> register
  name   = "backtrack"
 (fn x => (
  UISocket.ui_eval_backtrack x))

val ftab = ftab |> register
  name   = "close"
  (fn _ => (
  ((*tracing " send close command" ; *)Json.String "REQUEST_CLOSE")))
*)

fun dispatch json_input =
let
  val func = case Symtab.lookup ftab (get_cmd_name json_input) of SOME x => x
             | NONE => raise user_exn ("Function not found: "  ^ "." ^ (get_cmd_name json_input))
in (fst func) json_input
end

end
