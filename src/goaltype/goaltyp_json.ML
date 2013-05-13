(* json conversion for a goal typ  *)
signature GOAL_TYPE_JSON =
sig 
  structure goaltyp : GOAL_TYP
  val to_json : goaltyp.T -> Json.json 
  val from_json : Json.json -> goaltyp.T 

  val link_to_json : goaltyp.link.T -> Json.json
  val link_from_json : Json.json -> goaltyp.link.T

  val class_to_json : goaltyp.link.class.T -> Json.json
  val class_from_json : Json.json -> goaltyp.link.class.T 

end

functor GTJson (gtp: GOAL_TYP) : GOAL_TYPE_JSON = 
struct 

  (* json format 
       { name : string
         link : link_json_object
         facts : class_json array
         goal : class_json obj 
  *)

  (* TODO: implement this properly *)
  structure goaltyp = gtp;
  fun class_to_json class = Json.of_string "class";
  
  fun class_from_json json = goaltyp.link.class.top;

  fun link_to_json link = Json.of_string "link";
  
  fun link_from_json json = goaltyp.link.top;

  fun to_json gt = Json.Null;
  
  fun from_json json = goaltyp.top;



end; (* struct *)


