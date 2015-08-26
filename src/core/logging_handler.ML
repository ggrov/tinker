structure LoggingHandler = 
struct
  exception tinker_fail of (bool) (* if critical *)
  exception logging_exp of string

  val logging_tags = [ 
    "BASIC_INFO",
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

  val if_debug = true
  val logging_handler_print = 
   if if_debug then
   (fn tag => (fn msg =>  
      Pretty.writeln (
         Pretty.block [Pretty.str "[ LOGGING - ", 
                       Pretty.str (tag ^ ": "),
                       Pretty.str msg,
                       Pretty.str " ]"])))
   else (fn _ =>( fn _ => ()))

  val logging_handler = 
    Unsynchronized.ref logging_handler_print;


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

(*fun buffer_to_json _ = Json.mk_object [];*)
  
end

val _ = LoggingHandler.set_logging_handler 
  (fn tag => fn msg => ((*LoggingHandler.logging_handler_print tag msg;*) LoggingHandler.logging_handler_gui tag msg));

