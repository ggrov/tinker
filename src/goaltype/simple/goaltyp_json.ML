signature GOALTYP_JSON =
sig 

  val gnode_to_json : GNode.T -> Json.json 
  val gnode_from_json : Json.json -> GNode.T 

  val to_json : G.name -> Json.json 
  val from_json : Json.json -> G.name

end

structure GoalTypJson : GOALTYP_JSON = 
struct 
    exception EXP_PARSING_JSON of string

  (* json format
     GNode := {
         facts_map [[string(cname), [string ... string (fact names)]]]
         gname: string
         parent: string
     }

     GoalTyp := gtyp_name : string
  *)

  fun to_json gt = gt |> G.string_of_name |> Json.String

  fun from_json (Json.String jstr) = G.mk jstr
   | from_json _ = raise EXP_PARSING_JSON "Not a Json String type.";


  fun gnode_to_json gn =  
      Json.mk_object [("gtyp_name", GNode.get_goaltyp gn |> to_json),
                      ("gname", GNode.get_goal gn |> Json.String), 
                      ("parent_node", GNode.get_parent gn |> (fn x=> 
                                                                case x of (SOME y) => gnode_to_json y
                                                                        | _ => Json.Null))]

  fun gnode_from_json (Json.Object jobj) =
    let
      fun strip_string (Json.String x) = x;
      fun strip_array (Json.Array x) = x
      val gname = Json.get jobj "gname" |> strip_string; 
      val parent = Json.get jobj "parent_node" |> (fn x => case x of Json.Null => NONE
                                                                    | _ => SOME(gnode_from_json x)) 
      val gtyp = Json.get jobj "gtyp_name"
                  |> from_json
    in
      GNode.mk_goal gtyp gname |> GNode.set_parent' parent 
    end
 | gnode_from_json _ = raise EXP_PARSING_JSON "Not a Json object type.";

end; (* struct *)


