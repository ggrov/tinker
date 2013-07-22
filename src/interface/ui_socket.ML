signature UI_SOCKET = 
sig
  
end (* end of sig *)

(* TODO: need to be functorised *)
structure UISocket = 
struct
  structure FocusList = 
    struct   
      type data = EVal.EData.T 
      (* list structure with focus, functionalities are similar to zipper *)
      type T = data list * data * data list

      fun of_single e = ([], e, [])

      fun insert_tl e (h, f ,t) = (h, f, t @[e]) 
      
      fun move_next (_, _, []) = NONE 
      |   move_next (h, f, (x::xs)) = SOME (h@[f], x, xs)      
      
      fun move_prev ([], _, _) = NONE
      |   move_prev (xs, f, t) = case tl xs of [] => SOME ([], hd xs, f :: t)
                                  | _ => SOME (take (length xs - 1) xs , List.last xs, f :: t)

      fun focus (_, f, _) =  f
      fun last  (h, f, t) = (List.last (h @ [f] @ t))
    end (* end of FocusList *)
  
  (* internal data to store temp status *)
  val edata : FocusList.T option Unsynchronized.ref = Unsynchronized.ref NONE 
  val fn_init_edata : 
    (PSGraph.PSTheory.PS_Theory.Graph.T 
      -> FocusList.data) option Unsynchronized.ref
    = Unsynchronized.ref NONE

  fun init_data () = edata := NONE
  fun init_fn () = fn_init_edata := NONE
  fun get_data () = !edata
  fun get_fn () = !fn_init_edata
  fun update_data d = edata := SOME (d)
  fun update_fn d = fn_init_edata := SOME (d)

  exception ui_socket_exp

  fun strip_some (SOME x) = x

  fun update_new_eval_result (EVal.Cont e) = 
    let 
      val e' = EVal.normalise_gnode e 
      val (SOME el) = get_data()
    in
      (((FocusList.insert_tl e' el) 
         |> FocusList.move_next
         |> strip_some
         |> update_data);
       Pretty.writeln (EData.pretty_goals e') ; 
       PSGraph.PSTheory.out_json (EData.get_graph e')) end
  | update_new_eval_result (EVal.Good _) = (writeln "No Goal left" ; Json.String "SUCCESS")
  | update_new_eval_result (EVal.Bad) = (tracing "Err - Returned a Bad eval status" ; Json.Null)

  fun ui_mode_choice _ = 
    case get_data () of NONE => Json.Bool false 
    | _ => Json.Bool true

  fun ui_eval_current _ = 
    let val el = get_data () in
    (case el of SOME el' => FocusList.focus el'
                            |> (fn e => (Pretty.writeln (EData.pretty_goals e) ; e))
                            |> EData.get_graph
                            |> PSGraph.PSTheory.out_json
    | NONE => (tracing "Err - No edata is set-up: edata is empty, err in lifting"; Json.Null)) end
  handle _ => (tracing "Err - No edata is set-up: err in lift a graph"; Json.Null);
  
  fun ui_eval_prev _ = 
    let 
      val (SOME el) = get_data ()
    in
      case FocusList.move_prev el of NONE => Json.String "TOP"
      | SOME el' => 
        (update_data el';
         Pretty.writeln (EData.pretty_goals (FocusList.focus el'));
         PSGraph.PSTheory.out_json (EData.get_graph (FocusList.focus el')))
    end
  handle _ => (tracing "Err: No edata is set-up in backtracking"; Json.Null);

  fun ui_eval_next _ =
    let 
      val (SOME el) = get_data ()
    in
      case FocusList.move_next el of NONE (* need to eval now *)
        =>  FocusList.focus el 
            |> EVal.evaluate_any 
            |> update_new_eval_result       
       | SOME el' => 
          (update_data el';
           (fn x => (Pretty.writeln (EData.pretty_goals x) ; x));
           PSGraph.PSTheory.out_json (EData.get_graph (FocusList.focus el')))
    end
  handle _ => (tracing "Err - No edata is set-up: err in eval next prrof step "; Json.Null);
  
  fun ui_passive_init json = 
    let val f = get_fn () in
      case f of SOME f'=> 
        ((f' (PSGraph.PSTheory.in_json json)  (* init edata *)
          |> (fn x => update_data(FocusList.of_single x)));(* store edata *)
         ui_eval_current ())
        | NONE  => (tracing "Err: No init_fn is setup in passive mode !"; Json.Null) end;
 
  fun ui_eval_close _ = init_data();

  val ui_active_init = ui_eval_current
  
  fun ui_eval server edata fn_init = 
    let 
      val _ = 
        case edata 
          of SOME e => update_data(FocusList.of_single e) (* active mode *)
          | NONE => (init_data(); (update_fn fn_init)); (* passive mode *)
      val sock = TextSocket.local_connect (4234)
      val (input, output) = TextSocket.get_io_stream sock
    in
      (server (input, output);
      TextSocket.close sock;
      (get_data () 
        |> (fn x => case x of NONE => raise ui_socket_exp
                        | SOME e => FocusList.last e)
        |> (fn x => (init_data();init_fn(); x))))
    end

end (* end of struct *)
