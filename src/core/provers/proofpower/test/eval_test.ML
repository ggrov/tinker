  val path = "/Users/yuhuilin/Desktop/psgraph/" ;
  set_flag ("output_in_utf8", true);
  set_flag ("input_in_utf8", true);
  set_flag ("output_in_utf8", false);
  set_flag ("input_in_utf8", false);


  init_symbol_table [];

(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file (path^"demo_unicode.psgraph");
  use_utf8_string "tacâ¤–;" (*unicode*);
val tac = 1; (*pp char*);
tac;
ReaderWriter.ask_at_terminal "tacâ¤–";
  File_Io.read_string (path^"demo_unicode.psgraph"); 
  filter_empty_brk it;
  Json.of_string it;
  |> input_json

 fun filter_empty_brk0 (x::xs) = 
  if x = #"(" then 
   case xs 
     of (y :: ys) => if y = #")" then (filter_empty_brk0 ys) else  x :: (filter_empty_brk0 xs)
     | [] =>  x :: (filter_empty_brk0 xs)
  else x :: (filter_empty_brk0 xs)
  |filter_empty_brk0 [] = []

 fun filter_empty_brk str = 
  String.explode str
  |> filter_empty_brk0
  |> String.implode;


unicode_to_pp;
