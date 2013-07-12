
structure CModPsgraph : CONTROLLER_MODULE =
struct

open JsonControllerUtil
  
val ftab = Symtab.empty

val ftab = ftab |> register
{
  name   = "current_status", (* should be the fisrt command received after init *)
  doc    = "get the cueernt eval status",
  input  = S json_t,
  output = S json_t
} (fn x => (
  UISocket.ui_eval_current x
))

val ftab = ftab |> register
{
  name   = "next_status",
  doc    = "get the next eval status",
  input  = S json_t,
  output = S json_t
} (fn x => (
  UISocket.ui_eval_next x
))

val ftab = ftab |> register
{
  name   = "previous_status",
  doc    = "get the prev eval status",
  input  = S json_t,
  output = S json_t
} (fn x => (
  UISocket.ui_eval_prev x
))

val ftab = ftab |> register
{
  name   = "close",
  doc    = "shut down current server",
  input  = S json_t,
  output = S json_t
} (fn x => (
  ((*tracing " send close command" ; *)Json.String "REQUEST_CLOSE")
))

end
