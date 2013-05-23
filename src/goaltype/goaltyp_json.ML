(* json conversion for a goal typ  *)
signature GOAL_TYPE_JSON =
sig 
  structure GoalTyp : GOAL_TYP

  val to_json : GoalTyp.T -> Json.json 
  val from_json : Json.json -> GoalTyp.T 

  val data_to_json : GoalTyp.Link.Class.GTData.data -> Json.json
  val data_from_json : Json.json -> GoalTyp.Link.Class.GTData.data

  val link_to_json : GoalTyp.Link.T -> Json.json
  val link_from_json : Json.json -> GoalTyp.Link.T

  val class_to_json : GoalTyp.Link.Class.T -> Json.json
  val class_from_json : Json.json -> GoalTyp.Link.Class.T 

end

functor GTJsonFun (GTyp: GOAL_TYP) : GOAL_TYPE_JSON = 
struct 
    exception EXP_PARSING_JSON of string

  (* json format
 
     GoalTyp := { 
         gtyp_name : string
         gtyp_link : link_json_object
         facts : class_json array
         goal_class : class_json obj 
     }

     Link := {
        lname : string
        lmap : [[[idx,idx,idx], ll_data_obj], [[...], ...]]
     }

     Class := {
        cname : string
        cmap : [[idx, ll_data_obj], [..., ...]]
     }

     list of list of data_obj

     data := {
      feature_data_typ : Int | String | Term | Bool | DVar
      feature_data: ...
     }

  *)

  structure GoalTyp = GTyp;
  local 
    open GoalTyp.Link.Class.GTData 
  in

  fun get_el_from_list str strl = 
    List.filter (fn (x,_) => case (String.compare (str, x)) of EQUAL => true | _ => false) strl |> hd
  handle _ => raise EXP_PARSING_JSON ("Unknown type constructor \""^str^"\"")

  (* FIXME: term doesn't work*)
  fun data_to_json (Int i) = Json.mk_object [("Feature_Int", Json.Int i)]
    | data_to_json (String s) = Json.mk_object [("Feature_Str", Json.String s)]
    | data_to_json (Term t) = 
        GoalTyp.Link.Class.GTData.Prover.string_of_trm GoalTyp.Link.Class.GTData.Prover.globe_ctxt t 
        |> (fn x => Json.mk_object [("Feature_Trm", Json.String x)])
    | data_to_json (Position p) = Json.mk_object [("Feature_Pos", map Json.Int (Prover.intlist_of_pos p) |> Json.Array)]
    | data_to_json (Bool b) = Json.mk_object [("Feature_Bool", Json.Bool b)]
    | data_to_json (DVar d) = Json.mk_object [("Feature_DVar", Json.String (F.string_of_name d))]

  fun data_from_json (Json.Object jobj) = 
    let 
      val typStr = Json.properties jobj |> hd;
      val typList = [("Feature_Int", (1 : int)), ("Feature_Str", (2 : int)), 
                     ("Feature_Trm", (3 : int)), ("Feature_Pos", (4 : int)), 
                     ("Feature_Bool", (5 : int)), ("Feature_DVar", (6 : int))]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => let val (Json.Int i) = Json.get jobj typStr in Int i end
                           | 2 => let val (Json.String s) =  Json.get jobj typStr in String s end
                           | 3 => raise EXP_PARSING_JSON "Not support terom from json"(*let val (Json.String t) = Json.get jobj typStr in Term t end*)
                           | 4 => let val (Json.Array ary) = Json.get jobj typStr in 
                                    Prover.pos_of_intlist (map (fn (Json.Int i) => i) ary) |> Position end
                           | 5 => let val (Json.Bool b) = Json.get jobj typStr in Bool b end
                           | 6 => let val (Json.String s) =  Json.get jobj typStr in F.mk s |> DVar end
          )
    end
    | data_from_json  _ = raise EXP_PARSING_JSON "Not a Json object type."


  fun data_ll_to_json dll =
  let 
    fun list_to_json dl = map (fn x => data_to_json x) dl |> Json.Array
  in
    map list_to_json dll |> Json.Array
  end
    
  fun data_ll_from_json  (Json.Array j) = map (fn (Json.Array x) => map (data_from_json) x) j
  | data_ll_from_json _ = raise EXP_PARSING_JSON "Not a Json array type."

  fun class_to_json class = 
    let 
      val item_list = map (fn x => GoalTyp.Link.Class.get_item x class 
                                    |> (fn (SOME y) => (x, y))) (GoalTyp.Link.Class.get_keys class)
      val data_obj = Json.Array ((map 
                                    (fn(x, y) => Json.Array [Json.String(F.string_of_name x),  data_ll_to_json y]) 
                                    item_list))
   in
      Json.mk_object[("cname", GoalTyp.Link.Class.get_name class |> C.string_of_name |> Json.String), ("cmap", data_obj)]
   end                                   
  
  fun class_from_json (Json.Object jobj) = 
  let
    val pair = Json.get jobj "cmap" |> (fn (Json.Array ll) => map (fn (Json.Array l) => 
                                           (hd l |> (fn (Json.String str) => F.mk str), data_ll_from_json (hd (tl l)))) ll)
  in
    GoalTyp.Link.Class.top 
    |> GoalTyp.Link.Class.rename (Json.get jobj "cname" |> (fn (Json.String str) => C.mk str))
    |> (fn class => (fold (fn (x,y) => (fn t => GoalTyp.Link.Class.set_item x y t)) pair class))
  end
  | class_from_json _ = raise EXP_PARSING_JSON "Not a Json object type.";

  fun link_to_json link = 
    let 
      val item_list = map (fn x => GoalTyp.Link.get_item x link |> (fn (SOME y) => (x, y))) (GoalTyp.Link.get_keys link)
      val data_obj = 
            Json.Array ((map 
                          (fn((k1,(k2,k3)), y) => Json.Array [Json.Array([Json.String(L.string_of_name k1), 
                                                              Json.String(C.string_of_name k2), 
                                                              Json.String(C.string_of_name k3)]), 
                                                              data_ll_to_json y]) 
                          item_list))
   in
      Json.mk_object[("lname", GoalTyp.Link.get_name link |> L.string_of_name |> Json.String), ("lmap", data_obj)]
   end                                   
  
  fun link_from_json (Json.Object jobj) = 
  let
    fun strip_JsonStr (Json.String str) = str;
    val pair = Json.get jobj "lmap" 
               |> (fn (Json.Array ll) => map 
                                          (fn (Json.Array l) => 
                                            (hd l |> (fn (Json.Array kl) =>
                                                        (strip_JsonStr (hd kl) 
                                                         |> L.mk, (strip_JsonStr (hd (tl kl)) 
                                                         |> C.mk,strip_JsonStr (hd (tl (tl kl)))|> C.mk))), 
                                             data_ll_from_json (hd (tl l))))
                                          ll)
  in
    GoalTyp.Link.top 
    |> GoalTyp.Link.rename (Json.get jobj "lname" |> (fn (Json.String str) => L.mk str))
    |> (fn link => (fold (fn (x,y) => (fn t => GoalTyp.Link.set_item x y t)) pair link))
  end
  | link_from_json _ = raise EXP_PARSING_JSON "Not a Json object type.";

  fun to_json gt = Json.mk_object [
                                   ("gtyp_name", GoalTyp.get_name gt |> G.string_of_name |> Json.String), (*name*)
                                   ("gtyp_link", GoalTyp.get_link gt |> link_to_json), (*link*)
                                   ("facts", GoalTyp.get_facts gt |> map class_to_json |> Json.Array), (*class list*)
                                   ("goal_class", GoalTyp.get_gclass gt |> class_to_json ) (*class for goal*)
                                  ];

  fun from_json (Json.Object jobj) = GoalTyp.top 
                                     |> GoalTyp.set_name (Json.get jobj "gtyp_name" |> (fn (Json.String str) => G.mk str))
                                     |> GoalTyp.set_link (Json.get jobj "gtyp_link" |> link_from_json)
                                     |> GoalTyp.set_facts (Json.get jobj "facts" 
                                        |> (fn (Json.Array l) => (map class_from_json l)))
                                     |> GoalTyp.set_gclass (Json.get jobj "goal_class" |> class_from_json)
  | from_json _ = raise EXP_PARSING_JSON "Not a Json object type.";

  end (* local *)


end; (* struct *)


