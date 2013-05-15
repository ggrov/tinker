(* json conversion for a goal typ  *)
signature GOAL_TYPE_JSON =
sig 
  structure GoalTyp : GOAL_TYP

  val to_json : GoalTyp.Link.Class.GTData.GPrf.context -> GoalTyp.T -> Json.json 
  val from_json : GoalTyp.Link.Class.GTData.GPrf.context ->Json.json -> GoalTyp.T 

  val data_to_json :GoalTyp.Link.Class.GTData.GPrf.context ->  GoalTyp.Link.Class.GTData.data -> Json.json
  val data_from_json : GoalTyp.Link.Class.GTData.GPrf.context -> Json.json -> GoalTyp.Link.Class.GTData.data

  val link_to_json : GoalTyp.Link.Class.GTData.GPrf.context -> GoalTyp.Link.T -> Json.json
  val link_from_json : GoalTyp.Link.Class.GTData.GPrf.context -> Json.json -> GoalTyp.Link.T

  val class_to_json : GoalTyp.Link.Class.GTData.GPrf.context -> GoalTyp.Link.Class.T -> Json.json
  val class_from_json : GoalTyp.Link.Class.GTData.GPrf.context -> Json.json -> GoalTyp.Link.Class.T 

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

  fun get_el_from_list str strl =  List.filter (fn (x,_) => case (String.compare (str, x)) of EQUAL => true | _ => false) strl |> hd
                                   handle _ => raise EXP_PARSING_JSON ("Unknown type constructor \""^str^"\"")
  (* FIXME: term doesn't work*)
  fun data_to_json ctxt (Int i) = Json.mk_object [("Feature_Int", Json.Int i)]
    | data_to_json ctxt (String s) = Json.mk_object [("Feature_Str", Json.String s)]
    | data_to_json ctxt (Term t) = Json.mk_object [("Feature_Trm", Json.String (GPrf.string_of_trm ctxt t))]
    | data_to_json ctxt (Position p) = Json.mk_object [("Feature_Pos", map Json.Int (GPrf.intlist_of_pos p) |> Json.Array)]
    | data_to_json ctxt (Bool b) = Json.mk_object [("Feature_Bool", Json.Bool b)]
    | data_to_json ctxt (DVar d) = Json.mk_object [("Feature_DVar", Json.String (F.string_of_name d))]

  fun data_from_json ctxt (Json.Object jobj) = 
    let 
      val typStr = Json.properties jobj |> hd;
      val typList = [("Feature_Int", (1 : int)), ("Feature_Str", (2 : int)), ("Feature_Trm", (3 : int)), ("Feature_Pos", (4 : int)), 
          ("Feature_Bool", (5 : int)), ("Feature_DVar", (6 : int))]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => let val (Json.Int i) = Json.get jobj typStr in Int i end
                           | 2 => let val (Json.String s) =  Json.get jobj typStr in String s end
                           | 3 => let val (Json.String t) = Json.get jobj typStr in Term (GPrf.trm_of_string ctxt t) end
                           | 4 => let val (Json.Array ary) = Json.get jobj typStr in GPrf.pos_of_intlist (map (fn (Json.Int i) => i) ary) |> Position end
                           | 5 => let val (Json.Bool b) = Json.get jobj typStr in Bool b end
                           | 6 => let val (Json.String s) =  Json.get jobj typStr in F.mk s |> DVar end
          )
    end
    | data_from_json _ _ = raise EXP_PARSING_JSON "Not a Json object type."


  fun data_ll_to_json ctxt dll =
  let 
    fun list_to_json dl = map (fn x => data_to_json ctxt x) dl |> Json.Array
  in
    map list_to_json dll |> Json.Array
  end
    
  fun data_ll_from_json ctxt  (Json.Array j) = map (fn (Json.Array x) => map (data_from_json ctxt) x) j
  | data_ll_from_json _ _ = raise EXP_PARSING_JSON "Not a Json array type."

  fun class_to_json _ class = Json.of_string "class";
  
  fun class_from_json _ json = GoalTyp.Link.Class.top;

  fun link_to_json _ link = Json.of_string "link";
  
  fun link_from_json _ json = GoalTyp.Link.top;

  fun to_json _ gt = Json.Null;
  
  fun from_json _ json = GoalTyp.top;

  end (* local *)


end; (* struct *)


