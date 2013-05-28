structure SimpleGoalTyp : BASIC_GOALTYPE = 
struct

  type T = string
  type gnode = string (* or with term? *)
   
  val default = "any";
  val default_gnode = "?";

  val ord = String.compare;
  fun eq (t1,t2) = case ord(t1,t2) of EQUAL => true | _ => false;

  val gnode_ord = String.compare;
  fun gnode_eq (g1,g2) = case gnode_ord(g1,g2) of EQUAL => true | _ => false;

  val goal_name = I;

  val gnode_to_json = Json.String;
  fun gnode_from_json (Json.String str) = str

  val to_json = Json.String; 
  fun from_json (Json.String str) = str;

  val pretty_gnode = Pretty.str;
  val pretty = Pretty.str;

  (* delete *)
  fun lookup_fact_names _ _ = NONE;
  fun get_fact_names _ _ = StrName.NSet.empty;


end;
