functor TinkerProtocol (structure IEVal : IEVAL 
                        structure TextSocket : TEXT_SOCKET
                        val gui_socket_port : int 
                        val prover_socket_port: int)=
struct
  open  LoggingHandler

  exception protocol_exn of string
  exception user_exn of string

  structure IEVal = IEVal
  structure EData = IEVal.EData
  structure Prover = EData.PSGraph.Graph.Data.GoalTyp.Prover
  structure TextSocket = TextSocket
  
  val if_gui_dbg_mode = true
  fun dbg s1 s2 = if if_gui_dbg_mode then LH.debug_json s1 s2 () else ();

  val buffer_to_json' = EData.PSGraph.from_prover_json o buffer_to_json

(* if 0 then invalid *)
  val gui_sicket_port = gui_socket_port
  val prover_socket_port = prover_socket_port
  
  type T = ((Json.json -> Json.json) * string) Symtab.table

  fun pp_goal edata =  (fn x => ((EData.pretty_goals edata 
    |> ((logging "GOAL") o Pretty.string_of)) ; x))

  fun get_cmd_name (Json.Object obj) =  
    JsonInputUtils.get_string obj "cmd" 
  | get_cmd_name _ = raise user_exn "wrong json type in get_cmd_name"

  fun get_print_only_msg (Json.Object obj) =
    JsonInputUtils.get_string obj "print_only" 
  | get_print_only_msg _ = raise user_exn "wrong json type in get_print_only_msg"
(*
  fun get_str_cmd_args_list (Json.Object obj) =
    JsonInputUtils.get_array obj "eval_options" 
    |> map (fn (Json.String str) => str)
  | get_str_cmd_args_list _ = raise user_exn "wrong json type in get_str_cmd_args_list"
 *)
  fun register (cmd : string) f = Symtab.update_new (cmd, f)

  val ftab = Symtab.empty

  structure JobTable = NameTable(structure Dom = IntName)
  (* always try save_connect then test connection, if no response then safe_close then safe_connect *)
  
(****************************************************
  internal data 
****************************************************)
  val edata : EData.T option Unsynchronized.ref = Unsynchronized.ref NONE 
  fun reset_data _ = edata := NONE
  fun get_data _ = !edata
  fun set_data d = edata := SOME (d)

  val init_data : 
    (EData.PSGraph.Graph.Data.GoalTyp.Prover.context option * 
     EData.PSGraph.Graph.Data.GoalTyp.Prover.term option * 
     EData.PSGraph.Graph.Data.GoalTyp.Prover.term list option *
     EData.PSGraph.T option)  Unsynchronized.ref = Unsynchronized.ref (NONE, NONE, NONE, NONE)
 
  fun reset_init_data _ = init_data := (NONE, NONE, NONE, NONE)
  fun get_init_data _ = !init_data
  fun set_init_data d = init_data := d

(****************************************************
  protocol commands 
****************************************************)
  fun RSP_INIT_PSGRAPH (Json.Object obj) = 
   let 
    val init_data = get_init_data (); 
    val ctxt = Option.valOf (#1 init_data)
    val g = case (#2 init_data) of 
      (SOME g0) => g0
     | NONE => JsonInputUtils.get_array obj "goal" |> hd 
      |> (fn (Json.String str) => EData.PSGraph.Graph.Data.GoalTyp.Prover.prop_of_string ctxt str)
    val _ = logging "EVAL" ("To prove goal:" ^ (EData.PSGraph.Graph.Data.GoalTyp.Prover.string_of_trm ctxt g))
    val assms = case (#3 init_data) of 
      (SOME assms) => assms
    | NONE => JsonInputUtils.get_array obj "goal" |> tl |> hd 
       |> (fn (Json.Array arr) => 
            map (fn (Json.String str) => EData.PSGraph.Graph.Data.GoalTyp.Prover.prop_of_string ctxt str)
            arr) 
    val _ = logging "EVAL" ("With assms: " ^ (str_blocks " " (map (EData.PSGraph.Graph.Data.GoalTyp.Prover.string_of_trm ctxt) assms)))
    val ps = case (#4 init_data) of 
      (SOME ps) => ps
    | NONE => JsonInputUtils.get_array obj "psgraph" |> hd
    |> EData.PSGraph.input_json true
    val edata0 = IEVal.EVal.init ps ctxt (Prover.G_TERM(assms, g)) |> hd (* FIXME: only get the first one *)
    handle _ => (logging "FAILURE" "Fail to init the goal with the top-level graph";raise tinker_fail true);
    val _ = set_data edata0;
    val _ = pp_goal edata0 ()
   in
    IEVal.output_json "CMD_UPDATE_PSGRAPH" 
     (IEVal.mk_cmd_str_arg_json ["OPT_EVAL_STOP", "OPT_EVAL_NEXT"]) 
     edata0
   end
   | RSP_INIT_PSGRAPH _ = raise user_exn "wrong json type in RSP_UPDATE_PSGRAPH"
  val ftab = ftab |> register "RSP_INIT_PSGRAPH" RSP_INIT_PSGRAPH

  fun RSP_UPDATE_PSGRAPH (json as (Json.Object obj))= 
    let
      (*val opts = get_str_cmd_args_list json (* args option from users *)*)
      val opt = JsonInputUtils.get_string obj "option"
      val (SOME edata0) = get_data();
      val gnode = JsonInputUtils.get_string obj "node"
      val eval_fn = case gnode of "" => K IEVal.eval_any | _ => IEVal.eval_goal
      fun make_ret_reuslt edata_result = 
       case edata_result 
        of (IEVal.Cont edata1) => 
             (set_data edata1;pp_goal edata1 ();
              let val opt =  case  List.length (EData.get_branches edata1) of
                0 => ["OPT_EVAL_STOP", "OPT_EVAL_NEXT"] 
                | _ =>  ["OPT_EVAL_STOP", "OPT_EVAL_NEXT", "OPT_EVAL_BACKTRACK"] in 
              IEVal.output_json "CMD_UPDATE_PSGRAPH"
               (IEVal.mk_cmd_str_arg_json opt) 
               edata1 end) 
        | (IEVal.Good edata1) => 
            (set_data edata1;pp_goal edata1 ();
             IEVal.output_json "CMD_UPDATE_PSGRAPH" 
              (IEVal.mk_cmd_str_arg_json ["OPT_EVAL_STOP"]) 
              edata1)
        |(IEVal.Bad) => 
            (logging "FAILURE" "No subsequent eval status: Bad";
              raise tinker_fail true            
              (* IEVal.output_json "CMD_UPDATE_PSGRAPH" 
              (IEVal.mk_cmd_str_arg_json ["OPT_EVAL_STOP"]) 
              edata0*)) 
    in
      case opt 
        of "OPT_EVAL_NEXT" => 
          (eval_fn gnode edata0 |> make_ret_reuslt
          handle tinker_fail _ => raise tinker_fail true)
        | "OPT_EVAL_BACKTRACK" => 
          (IEVal.eval_backtrack edata0 |> make_ret_reuslt
          handle tinker_fail _ => raise tinker_fail true)
        | "OPT_EVAL_STEP_INTO" => 
          (eval_fn gnode edata0 |> make_ret_reuslt
           handle tinker_fail _ => raise tinker_fail true)
        | "OPT_EVAL_STEP_OVER" =>  
          (IEVal.eval_step_over gnode edata0 |> make_ret_reuslt          
            handle tinker_fail _ => raise tinker_fail true)
        | "OPT_EVAL_FINISH" => 
          (IEVal.eval_finish edata0 |> make_ret_reuslt
          handle tinker_fail b => raise tinker_fail true)
        | "OPT_EVAL_COMPLETE" => 
          (IEVal.eval_complete edata0 |> make_ret_reuslt
          handle tinker_fail b => raise tinker_fail b)
        | "OPT_EVAL_UNTIL_BREAK" => 
          (IEVal.eval_until_break edata0 |> make_ret_reuslt
          handle tinker_fail b => raise tinker_fail true)
        | "OPT_EVAL_STOP" =>
           (Json.mk_object[("cmd", Json.String  "CMD_END_EVAL_SESSION"), ("log_info", buffer_to_json' ())])
        | x => raise protocol_exn ("ERR: protocol unkown option: " ^ x)
    end
    | RSP_UPDATE_PSGRAPH _ = raise user_exn "wrong json type in RSP_UPDATE_PSGRAPH"

  val ftab = ftab |> register "RSP_UPDATE_PSGRAPH" RSP_UPDATE_PSGRAPH

(* assume that the graph structure of psgraph has not been changed *)
  fun CMD_CHANGE_PSGRAH (Json.Object obj)  = 
   let 
    val new_eval_json = JsonInputUtils.get obj "eval_psgraph" 
    val (SOME edata) = get_data() 
    (* keep current tactic field *)
    val cur_ps = IEVal.EVal.EData.get_psgraph edata
    val gdata = IEVal.EVal.EData.PSGraph.get_goaltype_data cur_ps (* keep the current goal data *)
   (* val atom_tacs = IEVal.EVal.EData.PSGraph.get_atomic_tactics cur_ps
    val env_tacs = IEVal.EVal.EData.PSGraph.get_env_tactics cur_ps*)
    val new_psgraph = 
      IEVal.EVal.EData.PSGraph.input_json true new_eval_json
      |> IEVal.EVal.EData.PSGraph.set_goaltype_data gdata
   (*   |> IEVal.EVal.EData.PSGraph.set_atomic_tactics atom_tacs
      |> IEVal.EVal.EData.PSGraph.set_env_tactics env_tacs *)
    val edata1 = IEVal.EVal.EData.set_psgraph new_psgraph edata
   in
    (set_data edata1;
     IEVal.output_json "CMD_UPDATE_PSGRAPH" 
     (IEVal.mk_cmd_str_arg_json ["OPT_EVAL_STOP", "OPT_EVAL_NEXT"]) edata1) 
    |> pp_goal edata1
   end
   | CMD_CHANGE_PSGRAH _  = raise protocol_exn "dummy, this won't happen in CMD_CHANGE_PSGRAH"
  
  val ftab = ftab |> register "CMD_CHANGE_PSGRAPH" CMD_CHANGE_PSGRAH
  
  fun RSP_MESSAGE_ERROR (Json.Object obj) = 
   let 
    val err = JsonInputUtils.get_string obj "error"
   in
    (dbg "FAILURE" err;
    Json.mk_object[("cmd", Json.String "RSP_MESSAGE_ERROR")])
   end
   | RSP_MESSAGE_ERROR _ = raise protocol_exn "dummy, this won't happen in RSP_MESSAGE_ERROR"
  
  val ftab = ftab |> register "RSP_MESSAGE_ERROR" RSP_MESSAGE_ERROR
  
  fun dispatch json_input =
  let
    val func = case Symtab.lookup ftab (get_cmd_name json_input) of SOME x => x
               | NONE => raise user_exn ("Function not found: "  ^ "." ^ (get_cmd_name json_input))
  in 
    func json_input
    handle tinker_fail b => 
      Json.mk_object[
      ("cmd", Json.String "RSP_EXCEPTION"),
      ("log_info", buffer_to_json' ()),
      ("if_interrupt", Json.Bool b)]
    | _ => Json.mk_object[
      ("cmd", Json.String "RSP_EXCEPTION"),
      ("log_info", buffer_to_json' ()),
      ("if_interrupt", Json.Bool true)]

  end

(****************************************************
  protocol executer 
****************************************************) 

  fun run_in_textstreams s init_json =
  let
    fun send_msg str =
    let
    val debug_io = false
    val path =  OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/tmp.txt";
    val _ = if debug_io then  File_Io.write_string path str else ()
    val _ = String.size str |> Int.toString |> (fn n =>  dbg ("size of msg: " ^ n)) in
     (TextSocket.write s ( str  ^ " \n"); TextSocket.flushOut s) end
    val _ = Json.encode init_json |> send_msg 
    fun protocol_loop src =
    let
     fun read0 str ins = 
      let val _ = dbg"!in read0 ---" 
       fun peak_json src  = 
        let val _ = Json.of_string src in true end
        handle _ => false 
        in 
         if peak_json str then (dbg "end"; str)
         else
           let val msg = TextSocket.read ins
           val _ = dbg ("received: " ^ msg)
           in 
           read0 (str ^ msg) ins end 
      end
      val str = read0 "" s
      val json = Json.of_string str
      val _ = (dbg "JSON_GUI" ("JSON IN: " ^ (Json.encode json)))
      val json_output = LH.check_perform dispatch json "run_in_textstreams" (* this output is always a json object *)
      val _ =  dbg "JSON_GUI" ("JSON OUT: " ^ ( Json.encode json_output))
    in 
      (case get_cmd_name json_output
         of "CMD_CLOSE_CONNECT" => () (* do nothing and exit: need to be consider what to do *)
          | "CMD_END_EVAL_SESSION" =>  send_msg (Json.encode json_output) (* send to stop cmd and quit *)
        (*  | "RSP_EXCEPTION" => send_msg (Json.encode json_output) *)(* end session and flash out the exception string*)
          | "RSP_MESSAGE_ERROR" => 
            raise RunCallFail "\n Error: Received RSP_MESSAGE_ERROR from GUI. \n Please set if_debug to true in LoggingHandler to see more debugging info for this failure" 
          | "Dummy_RSP" => ((); protocol_loop s)
          | "PRINT_ONLY_RSP" => 
            ((get_print_only_msg  json_output
            (*|> (fn x => logging "JSON_GUI" ("PRINT_RSP: " ^ x))*));
             protocol_loop src)
          | _ =>
             (LH.check_perform send_msg (LH.check_perform Json.encode json_output "Json encoding") "send_msg";
             protocol_loop s)
      )
    end
  in protocol_loop s
  end

(****************************************************
    top level interface 
****************************************************)
  fun start_ieval ctxt ps_opt assms_opt g_opt = 
    let
     val s = TextSocket.safe_local_client gui_socket_port;
     (* val (SOME (ins, outs)) = TextSocket.get_current_stream ();  should always be something *)
     val _  = (reset_data ();set_init_data (SOME ctxt, g_opt, assms_opt, ps_opt))
     val init_json = Json.mk_object[
      ("cmd", Json.String "CMD_INIT_PSGRAPH"),
      ("psgraph", Json.Bool (Option.isSome ps_opt)),
      ("goal", Json.Bool (Option.isSome g_opt)),
      ("log_info", buffer_to_json' ())]
      val _ = dbg "JSON_GUI" ("JSON OUT: " ^ (Json.encode init_json))
      val _ = reset_data ()
    in
      run_in_textstreams s init_json;
      get_data () |> (fn x => (reset_data () ; reset_init_data (); Option.valOf x))
    end

fun start_eval ctxt ps st = 
 let
  val edata0 = IEVal.EVal.init ps ctxt st |> hd (* FIXME: only get the first one *)
 in
   case IEVal.eval_complete edata0 
    of IEVal.Good e => e
    |  IEVal.Cont e => e
    |  IEVal.Bad => edata0
 end

end

