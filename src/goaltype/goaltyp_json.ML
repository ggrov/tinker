(* json conversion for a goal typ  *)
signature GOAL_TYPE_JSON =
sig 
  val to_json : GoalTyp.T -> Json.json 
  val from_json : Json.json -> GoalTyp.T 

  val link_to_json : Link.T -> Json.json
  val link_from_json : Json.json -> Link.T

  val class_to_json : Class.T -> Json.json
  val class_from_json : Json.json -> Class.T 

end

structure GTJson : GOAL_TYPE_JSON = 
struct 

  (* json format 
       { name : string
         link : link_json_object
         facts : class_json array
         goal : class_json obj 
  *)

  (* TODO: implement this properly *)

  fun class_to_json class = Json.of_string "class";
  
  fun class_from_json json = Class.top;

  fun link_to_json link = Json.of_string "link";
  
  fun link_from_json json = Link.top;

  fun to_json gt = Json.Null;
  
  fun from_json json = GoalTyp.top;



end; (* struct *)


