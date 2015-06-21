structure LoggingHandler = 
struct
  exception tinker_fail
  exception logging_exp of string

  val logging_tags = [ 
    "BASIC_INFO", (* will be printed if debug level is not set to NO_INFO*)
    "GOALTYPE",
    "TACTIC",
    "ENV_DATA",
    "ARG_DATA",
    "SOCKET",
    "JSON_GUI",
    "JSON_CORE",
    "EVAL"
  ] |> StrName.NSet.of_list;

  val active_tags = Unsynchronized.ref StrName.NSet.empty;
  fun get_active_tags _ = !active_tags;
  val set_active_tags = fn x => active_tags := x;

  val logging_handler = 
    Unsynchronized.ref 
     (fn tag => (fn msg =>  
      Pretty.writeln (
         Pretty.block [Pretty.str "[ LOGGING - ", 
                       Pretty.str (tag ^ ": "),
                       Pretty.str msg,
                       Pretty.str " ]"]))); (* the func to handle the loogin info *)

  fun get_logging_handler _ = !logging_handler;
  val set_logging_handler = fn x => logging_handler := x;

  fun logging_warning x = (get_logging_handler ()) "WARNING" x;

  fun print_tags tags tag_name = 
    StrName.NSet.list_of tags
    |> map (fn x => Pretty.str (x ^ " "))
    |> (fn xs => Pretty.str (tag_name ^ ": [") :: xs @ [Pretty.str "]"]);
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

  fun logging tag x = 
    if StrName.NSet.contains (get_active_tags ()) tag then (get_logging_handler ()) tag x
    else ()

  
end
