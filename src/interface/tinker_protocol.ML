structure TinkerProtocol =
struct
open JsonControllerUtil
exception protocol_exn of string
structure JobTable = NameTable(structure Dom = IntName)
(* alway try save_connect then test connection, if no response then safe_clse then safe_connect *)

val version_string = Json.String "1.0"
val dispatch = CModTinker.dispatch

fun run_in_textstreams (instream, outstream) =
let
  fun protocol_loop src =
  let
    val (json_list, src') = Source.get src
    val json = case json_list of [x] => x | _ =>
      raise protocol_exn "Expected: exactly one JSON object"
    val (Json.Object json_obj_output) = dispatch json (* this output is always a json object *)
  in 
    (case JsonInputUtils.get_string json_obj_output "cmd"
        of "Dummy_RSP" => ((); protocol_loop src')
        | "PRINT_ONLY_RSP" => 
          ((JsonInputUtils.get_string json_obj_output "msg"
          |> ( fn x => writeln ("PRINT_RSP" ^ x)));
           protocol_loop src')
        | _ =>
           (TextIO.output (outstream, Json.encode (Json.Object json_obj_output));
           TextIO.flushOut outstream;
           protocol_loop src')
    )
  end
in protocol_loop (Json.json_source instream)
end

end

