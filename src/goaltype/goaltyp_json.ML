(* json conversion for a goal typ  *)
signature GOAL_TYPE_JSON =
sig 
  structure GoalTyp : GOAL_TYP
  val to_json : GoalTyp.T -> Json.json 
  val from_json : Json.json -> GoalTyp.T 

  val link_to_json : GoalTyp.Link.T -> Json.json
  val link_from_json : Json.json -> GoalTyp.Link.T

  val class_to_json : GoalTyp.Link.Class.T -> Json.json
  val class_from_json : Json.json -> GoalTyp.Link.Class.T 

end

functor GTJsonFun (GTyp: GOAL_TYP) : GOAL_TYPE_JSON = 
struct 

  (* json format 
       { name : string
         link : link_json_object
         facts : class_json array
         goal : class_json obj 
  *)

  (* TODO: implement this properly *)
  structure GoalTyp = GTyp;
  fun class_to_json class = Json.of_string "class";
  
  fun class_from_json json = GoalTyp.Link.Class.top;

  fun link_to_json link = Json.of_string "link";
  
  fun link_from_json json = GoalTyp.Link.top;

  fun to_json gt = Json.Null;
  
  fun from_json json = GoalTyp.top;



end; (* struct *)


