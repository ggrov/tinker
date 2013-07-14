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
  fun init_data () = edata := NONE
  fun get_data () = !edata
  fun update_data d = edata := SOME (d)

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
  | update_new_eval_result (EVal.Bad) = (tracing "Returned a Bad evel status" ; Json.Null)

  fun ui_eval_close _ = init_data();

  fun ui_eval_current _ = 
    let val el = get_data () in
    (case el of SOME el' => FocusList.focus el'
                            |> (fn e => (Pretty.writeln (EData.pretty_goals e) ; e))
                            |> EData.get_graph
                            |> PSGraph.PSTheory.out_json
    | NONE => (tracing "No edata is set-up"; Json.Null)) end
  handle _ => (tracing "No edata is set-up"; Json.Null);
  
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
  handle _ => (tracing "No edata is set-up"; Json.Null);

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
  handle _ => (tracing "No edata is set-up"; Json.Null);
  
  
  fun ui_eval server edata = 
    let 
      val edata_fl = FocusList.of_single edata
      val _ = update_data (edata_fl)
      val sock = TextSocket.local_connect (4234)
      val (input, output) = TextSocket.get_io_stream sock
    in
      (server (input, output);
      TextSocket.close sock;
      (get_data () 
        |> (fn x => case x of NONE => raise ui_socket_exp
                        | SOME e => FocusList.last e)
        |> (fn x => (init_data(); x))))
    end

end (* end of struct *)
