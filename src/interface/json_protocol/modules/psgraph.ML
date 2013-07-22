
structure CModPsgraph : CONTROLLER_MODULE =
struct

open JsonControllerUtil
  
val ftab = Symtab.empty

val ftab = ftab |> register
{
  name   = "mode_choice", (* should be the fisrt command received after init *)
  doc    = "get mode",
  input  = S json_t,
  output = S json_t
} (fn _ => (
  UISocket.ui_mode_choice ()
))

val ftab = ftab |> register
{
  name   = "passive_init", (* should be the fisrt command received after init *)
  doc    = "init edata with the provided psgraph",
  input  = S json_t,
  output = S json_t
} (fn x => (
  UISocket.ui_passive_init x
))

val ftab = ftab |> register
{
  name   = "active_init", (* should be the fisrt command received after init *)
  doc    = "get the current/first eval status",
  input  = S json_t,
  output = S json_t
} (fn x => (
  UISocket.ui_active_init x
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
} (fn _ => (
  ((*tracing " send close command" ; *)Json.String "REQUEST_CLOSE")
))

end
