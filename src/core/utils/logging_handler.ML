structure LoggingHandler = 
struct
  exception tinker_fail of (bool) (* if critical *)
  exception logging_exp of string

  val if_debug =  true (* to enable local print, an overall control for all local print *)
  val if_check_perform = false (* print time for each steps *)

  val debug_tracing = fn msg =>  if if_debug then tracing (("TRACING: ") ^ msg) else ()
  val logging_tags = [ 
    "GOAL",
    "GOALTYPE",
    "TACTIC",
    "ENV_DATA",
    "ARG_DATA",
    "EVAL_ML",
    "SOCKET",
    "GRAPH",
    "HIERARCHY",
    (*"JSON_GUI",*)
    "JSON_CORE",
    "EVAL",
    "GUI_LAUNCHER",
    "WARNING",
    "FAILURE"
  ] |> StrName.NSet.of_list;

  val active_tags = Unsynchronized.ref StrName.NSet.empty;
  fun get_active_tags _ = !active_tags;
  val set_active_tags = fn x => active_tags := x;
  
  val logging_handler_print0 = 
   if if_debug then
   (fn tag => (fn msg =>  
         Pretty.block [Pretty.str "[ LOGGING - ", 
                       Pretty.str (tag ^ ": "),
                       Pretty.str msg,
                       Pretty.str " ]"]|> Pretty.string_of |> writeln)) 
   else (fn _ =>( fn _ => ()))
  fun debug_json tag str x = (if if_debug then logging_handler_print0 tag str else (); x);
 
  val logging_handler = 
    Unsynchronized.ref logging_handler_print0;


  fun get_logging_handler _ = !logging_handler;
  val set_logging_handler = fn x => logging_handler := x;

  fun logging_warning x = (get_logging_handler ()) "WARNING" x;

  fun print_tags tags tag_name = 
    StrName.NSet.list_of tags
    |> map (fn x => Pretty.str (x ^ " "))
    |> (fn xs => Pretty.str (tag_name ^ ": [") :: xs @ [Pretty.str "]"])
    |> Pretty.block |> Pretty.writeln;
  fun print_all_tags _ = print_tags logging_tags "All Logging Tags";
  fun print_active _ = print_tags (get_active_tags ()) "Active Logging Tags";

  fun clear_active_tags _ = set_active_tags StrName.NSet.empty;
  fun ins_active_tag tag = 
    if StrName.NSet.contains logging_tags tag
    then if (StrName.NSet.contains (get_active_tags ()) tag) then ()
      else set_active_tags (StrName.NSet.add tag (get_active_tags())) 
    else logging_warning ("Not a valid logging tag: " ^ tag);

  fun rmv_active_tag tag = 
    if StrName.NSet.contains logging_tags tag
    then if (StrName.NSet.contains (get_active_tags ()) tag) 
      then set_active_tags (StrName.NSet.delete tag (get_active_tags())) 
      else logging_warning ("Logging tag is not currenyly active: " ^ tag)
    else logging_warning ("Not a valid logging tag: " ^ tag);
  fun active_all_tags _ = map ins_active_tag  (StrName.NSet.list_of logging_tags)
  fun logging tag x = 
    if StrName.NSet.contains (get_active_tags ()) tag then (get_logging_handler ()) tag x
    else ()

  val defaul_buffer = 
   StrName.NSet.list_of logging_tags
   |> map (fn x => ((x,[])))
   |> StrName.NTab.of_list 
  

  val logging_buffer : string list  StrName.NTab.T  Unsynchronized.ref = 
    Unsynchronized.ref defaul_buffer;
  val get_logging_buffer = fn _ => !logging_buffer;
  val set_logging_buffer = fn x => logging_buffer := x;
  val clear_logging_buffer = fn _ => set_logging_buffer defaul_buffer

  fun insert_buffer_msg tag msg = 
   StrName.NTab.get (get_logging_buffer ()) tag
   |> (fn l => l @  [msg])
   |> (fn x => StrName.NTab.update (tag, x) (get_logging_buffer ()))
   |> set_logging_buffer

  val logging_handler_gui = insert_buffer_msg

  fun buffer_to_json _ = 
   StrName.NTab.list_of (get_logging_buffer ())
   |> List.filter (fn (_,list) => not (list = []))
   |> map (fn (name, list) => (name, Json.Array (map Json.String list)))
   |> Json.mk_object
   |> (fn x => (clear_logging_buffer (); x))
  
(*
  fun buffer_to_json _ = 
    let val  i = Timer.startRealTimer() in
    buffer_to_json0 () 
    |> (fn x => ( writeln ((Timer.checkRealTimer i)|> Time.toString) ;x))
  end
*)

(*fun buffer_to_json _ = Json.mk_object [];*)
fun log_undefined tag n ret =  (logging tag ("Warning: Undefined arguements: " ^ n ); ret)

fun check_perform f arg label = 
 if (not if_check_perform)
 then f arg
 else 
   (let val i = Timer.startRealTimer() in
    f arg
    |> (fn x => (writeln (label^": ");  
                 writeln ((Timer.checkRealTimer i)|> Time.toString);
                 x))
   end) 
 
end
 
val _ = LoggingHandler.set_logging_handler LoggingHandler.logging_handler_gui ;
val _ = LoggingHandler.active_all_tags ();
structure LH = LoggingHandler; 

