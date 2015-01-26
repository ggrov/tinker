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
    val json_output = dispatch json
    (*val _ = Json.string_of output |> tracing;*)
  in 
    (case output of Json.String "REQUEST_CLOSE" => ((*tracing "server is closing" ;*) ())
        | _ =>
           (TextIO.output (outstream, Json.encode json_output);
           TextIO.flushOut outstream;
           protocol_loop src')
    )
  end
in protocol_loop (Json.json_source instream)
end
handle protocol_exn msg => 
  (TextIO.output (outstream, (* an error default msg *)));
   TextIO.flushOut outstream)

end

