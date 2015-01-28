functor TinkerProtocol (IEVal : IEVAL)=
struct
  open JsonControllerUtil

  exception protocol_exn of string
  exception user_exn of string

  structure IEVal = IEVal
  structure EData = IEVal.EData
  
  type T = ((Json.json -> Json.json) * string) Symtab.table

  fun pp_goal edata =  (fn x => ((EData.pretty_goals edata |> Pretty.writeln) ; x))

  fun get_cmd_name (Json.Object obj) =  
    JsonInputUtils.get_obj obj "cmd" 
    |> (fn x =>JsonInputUtils.get_string x "name")
  | get_cmd_name _ = raise user_exn "wrong json type in get_cmd_name"

  fun get_print_only_msg (Json.Object obj) =
    JsonInputUtils.get_obj obj "cmd" 
    |> (fn x =>JsonInputUtils.get_array x "args")
    |> hd
    |> (fn (Json.String str) => str)
  | get_print_only_msg _ = raise user_exn "wrong json type in get_print_only_msg"

  fun get_str_cmd_args_list (Json.Object obj) =
    JsonInputUtils.get_obj obj "cmd" 
    |> (fn x =>JsonInputUtils.get_array x "args")
    |> map (fn (Json.String str) => str)
  | get_str_cmd_args_list _ = raise user_exn "wrong json type in get_str_cmd_args_list"

  fun register (cmd : string) f = Symtab.update_new (cmd, f)

  val ftab = Symtab.empty

  structure JobTable = NameTable(structure Dom = IntName)
  (* alway try save_connect then test connection, if no response then safe_clse then safe_connect *)
  
(****************************************************
  internal data 
****************************************************)
  val edata : EData.T option Unsynchronized.ref = Unsynchronized.ref NONE 
  fun reset_data _ = edata := NONE
  fun get_data _ = !edata
  fun set_data d = edata := SOME (d)
(****************************************************
  protocol commands 
****************************************************)
  fun RSP_INIT_PSGRAPH _ = 
   Json.mk_object[
   ("cmd", 
         Json.mk_object[
         ("name", Json.String  "PRINT_ONLY_RSP"),
         ("args", Json.Array[Json.String "init graph in tinker"])])]
  val ftab = ftab |> register "RSP_INIT_PSGRAPH" RSP_INIT_PSGRAPH

  fun RSP_UPDATE_PSGRAPH _ = 
   Json.mk_object[
   ("cmd", 
         Json.mk_object[
         ("name", Json.String  "PRINT_ONLY_RSP"),
         ("args", Json.Array[Json.String "update graph in tinker"])])]
  val ftab = ftab |> register "RSP_UPDATE_PSGRAPH" RSP_UPDATE_PSGRAPH

  fun RSP_EVAL_PSGRAPH json = 
    let
      val opts = get_str_cmd_args_list json (* args option from users *)
      val opt = hd opts
      val (SOME edata0) = get_data();
      fun get_eval_gnode _ =  hd (tl opts)
    in
      case opt 
        of "OPT_EVAL_NEXT" =>
          (case IEVal.eval_goal (get_eval_gnode()) edata0
            of (IEVal.Cont edata1) => 
                 (set_data edata1;
                  IEVal.output_json "CMD_UPDATE_PSGRAPH" 
                   (IEVal.mk_cmd_str_arg_json ["OPT_EVAL_STOP", "OPT_EVAL_NEXT"]) 
                   edata1) |> pp_goal edata1
            | (IEVal.Good edata1) => 
                (set_data edata1;
                 IEVal.output_json "CMD_UPDATE_PSGRAPH" 
                  (IEVal.mk_cmd_str_arg_json ["OPT_EVAL_STOP"]) 
                  edata1) |> pp_goal edata1
            |(IEVal.Bad) => 
                IEVal.output_json "CMD_UPDATE_PSGRAPH" 
                  (IEVal.mk_cmd_str_arg_json ["OPT_EVAL_STOP"]) 
                  edata0)
        | "OPT_EVAL_STOP" =>
           (reset_data();
           Json.mk_object[("cmd", Json.mk_object[("name", Json.String  "CMD_CLOSE_CONNECT")])])
    end
  val ftab = ftab |> register "RSP_EVAL_PSGRAPH" RSP_EVAL_PSGRAPH


  fun dispatch json_input =
  let
    val func = case Symtab.lookup ftab (get_cmd_name json_input) of SOME x => x
               | NONE => raise user_exn ("Function not found: "  ^ "." ^ (get_cmd_name json_input))
  in func json_input
  end

(****************************************************
  protocol executer 
****************************************************)

  val version_string = Json.String "1.0"  

  fun run_in_textstreams (instream, outstream) init_msg =
  let
    fun protocol_loop src =
    let
      val _ = (* send the init msg if there is any *)
        case init_msg 
        of (SOME j) => (TextIO.output (outstream, j);TextIO.flushOut outstream)
        |  NONE => ()
      val (json_list, src') = Source.get src
      val json = case json_list of [x] => x | _ =>
        raise protocol_exn "Expected: exactly one JSON object"
      val json_output = dispatch json (* this output is always a json object *)
    in 
      (case get_cmd_name json_output
          of "CMD_CLOSE_CONNECT" => () (* do nothing and exit *)
          | "Dummy_RSP" => ((); protocol_loop src')
          | "PRINT_ONLY_RSP" => 
            ((get_print_only_msg  json_output
            |> ( fn x => writeln ("PRINT_RSP: " ^ x)));
             protocol_loop src')
          | _ =>
             (TextIO.output (outstream, Json.encode json_output);
             TextIO.flushOut outstream;
             protocol_loop src')
      )
    end
  in protocol_loop (Json.json_source instream)
  end

(****************************************************
    top level interface 
****************************************************)
  fun start_ieval ctxt ps assms g = 
    let
     val edata0 = IEVal.EVal.init ps ctxt assms g |> hd (* FIXME: only get the first one *)
     val _ = pp_goal edata0 ();
(*  in future, it should always maintain a socket connection*)
     val s = TextSocket.safe_local_client 1790;
     val (SOME (ins, outs)) = TextSocket.get_current_stream (); (* should always be something *)
     val init_msg = IEVal.output_string 
          "CMD_INIT_PSGRAPH" 
           (IEVal.mk_cmd_str_arg_json [
              "OPT_EVAL_STOP", "OPT_EVAL_NEXT"]) (SOME edata0);
      val _ = (reset_data (); set_data edata0)
    in
      run_in_textstreams (ins, outs) (SOME init_msg);
      reset_data ()
    end
end

