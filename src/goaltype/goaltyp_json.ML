(* json conversion for a goal typ  *)
structure GTJson = 
struct 

  datatype T = GoalTyp of 
   { name : G.name,
     link : Link.T,
     facts : Class.T list, (* fixme: turn this into a set *)
     goal : Class.T }


  fun class_to_json class = 
  
  fun class_from_json json =

  fun link_to_json link =
  
  fun link_from_json link = 

  (* json format 
       { name : string
         link : link_json_object
         facts : class_json array
         goal : class_json obj 
  *)

  fun to_json gt = 
  
  fun from_json json = 



end; (* struct *)


