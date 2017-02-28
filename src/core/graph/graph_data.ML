functor PSGraphDataFun (GoalTyp : CLAUSE_GOALTYPE) : GRAPH_DATA
= struct                                                   
local open LoggingHandler in
  structure GoalTyp = GoalTyp;

  type arg_typ = string list list

  datatype vdata =  
       T_Atomic of  (string * arg_typ)
     | T_Graph of (string * arg_typ)
     | T_Identity 
     | G_Break (* breakpoint *)
     | G of GoalTyp.gnode 
     | T_Var of string (* variable of rtechn *)
     | G_Var of string (* variable of gnode *)
     | Boundary (* boundary of a graph *)

  
  fun get_vdata_name vdata = 
    case vdata of
     (T_Atomic atom) => fst atom
    | (T_Graph g) => fst g
    | _ => ""

  fun get_vdata_args (T_Atomic atom) = snd atom
  | get_vdata_args (T_Graph g) = snd g
  | get_vdata_args _ = [[]]

  val get_graph_tac_name = fst
  val get_graph_tac_args = snd

  (* example Atomic 
          rule,[[exI]]
          frule[[exI],[X,Y]]
          erule(exE,X,Y)
          simp[["add","a","b"]]
          auto[["simp add", "a"],["intro","d"]]
        Nested : use args as input output for variable binding *)


  datatype edata  = GT of GoalTyp.T
                  | GT_Var of string (* variable of goalnode *)

  exception node_exp of string * vdata;

  val identity = T_Identity;
  val break_point =  G_Break; (* breakpoint *)

  fun is_tactic_node (T_Atomic _) = true
   |  is_tactic_node (T_Graph _)  = true
   |  is_tactic_node T_Identity  = true
   |  is_tactic_node _ = false;

  fun is_atomic (T_Atomic _) = true
   |  is_atomic _ = false;

  fun is_nested (T_Graph _) = true
   |  is_nested _ = false;

  fun is_identity T_Identity = true
   |  is_identity _ = false;

  fun is_break_point G_Break = true
   |  is_break_point _ = false;

  fun is_boundary Boundary = true
  |   is_boundary _ = false

  (* node equality *)
  fun vdata_eq (T_Atomic a1,T_Atomic a2) = (get_vdata_name (T_Atomic a1) = get_vdata_name (T_Atomic a2))
   | vdata_eq (T_Graph n1,T_Graph n2) = (get_vdata_name (T_Graph n1) = get_vdata_name (T_Graph n2))
   | vdata_eq (T_Identity,T_Identity) = true 
   | vdata_eq (G_Break,G_Break) = true
   | vdata_eq (G g1,G g2) = GoalTyp.gnode_eq (g1,g2)
   | vdata_eq (T_Var v1,T_Var v2) = (v1 = v2)
   | vdata_eq (G_Var v1,G_Var v2) = (v1 = v2)
   | vdata_eq (Boundary, Boundary) = true
   | vdata_eq _ = false;

 fun edata_eq (GT gt1,GT gt2) = GoalTyp.eq (gt1,gt2)
  |  edata_eq (GT_Var v1,GT_Var v2) = (v1 = v2)
  |  edata_eq _ = false;

  (* default vertex and edge data *)
  val default_vdata = T_Identity;
  val default_edata = GT GoalTyp.default;


  (* pretty printing *)
  val pretty_theory_name = Pretty.str "PSGraph";

  fun pretty_vdata (T_Atomic name) = Pretty.str (get_vdata_name (T_Atomic name))
   |  pretty_vdata (T_Graph name) = Pretty.str (get_vdata_name (T_Graph name))
   |  pretty_vdata (T_Identity) = Pretty.str "id"
   |  pretty_vdata (G_Break) = Pretty.str "break_point"
   |  pretty_vdata (G gn) = GoalTyp.goal_pretty gn
   |  pretty_vdata (T_Var s) = Pretty.str ("?T_" ^ s)
   |  pretty_vdata (G_Var s) = Pretty.str ("?G_" ^ s)
   |  pretty_vdata (Boundary) = Pretty.str "boundary"

  val print_vdata = Pretty.writeln o pretty_vdata;

  fun pretty_edata (GT gt) = GoalTyp.pretty gt
   |  pretty_edata (GT_Var v) = Pretty.str ("?" ^ v)

  val print_edata = Pretty.writeln o pretty_edata;
  
 exception gdata_json_exp of string * Json.json

 fun arg_typ_to_json args = 
  Json.Array (map (fn y => (Json.Array (map (fn x => Json.String x) y))) args)
 fun arg_typ_from_json (Json.Array args) = 
  map 
  (fn (Json.Array x) => 
    (map 
    (fn y => 
      case y of (Json.String str) => str 
               | _ => raise Json.parse_exn "unexcepted json strcure in arg_typ_from_json") 
    x)
    |_ => raise Json.parse_exn "unexcepted json strcure in arg_typ_from_json")
  args 
 | arg_typ_from_json _ =  raise Json.parse_exn "unexcepted json strcure in arg_typ_from_json"


 fun vdata_to_json (T_Atomic atom) = 
      Json.mk_object ([("type", Json.String "T_Atomic"), 
          ("atm", Json.String (get_vdata_name (T_Atomic atom))), 
          ("args", arg_typ_to_json (get_vdata_args (T_Atomic atom)))])
   | vdata_to_json (T_Graph tg) = 
      Json.mk_object ([("type", Json.String "T_Graph"), 
          ("subgraph",  Json.String (get_graph_tac_name tg)),
           ("args", arg_typ_to_json (get_graph_tac_args tg))]) 
   | vdata_to_json T_Identity = 
      Json.mk_object [("type", Json.String "T_Identity")]
   | vdata_to_json G_Break = 
      Json.mk_object [("type", Json.String "G_Break")] 
   | vdata_to_json (G gn) = 
      Json.mk_object [("type", Json.String "G"), ("gn", GoalTyp.gnode_to_json gn)]
   | vdata_to_json (T_Var t_var) =
      Json.mk_object [("type", Json.String "T_Var"), ("t_var", Json.String t_var)]
   | vdata_to_json (G_Var g_var) =
      Json.mk_object [("type", Json.String "G_Var"), ("g_var", Json.String g_var)]
   
 fun vdata_from_json (Json.Object jobj) (* has to be jobj *) = 
       (case JsonInputUtils.get_string jobj "type" of
              "T_Atomic" =>
              (debug_json "JSON_CORE" ("Json parsing: Node (T_Atomic) - " ^ JsonInputUtils.get_string jobj "atm") ();
              T_Atomic 
               (JsonInputUtils.get_string jobj "atm", 
                JsonInputUtils.get jobj "args" |> arg_typ_from_json))
            | "T_Graph" =>  
            (debug_json "JSON_CORE" ("Json parsing: Node (T_Graph) - " ^ JsonInputUtils.get_string jobj "subgraph") ();
              T_Graph
               (JsonInputUtils.get_string jobj "subgraph", 
                JsonInputUtils.get jobj "args" |> arg_typ_from_json))
            | "T_Identity"=> T_Identity |> debug_json "JSON_CORE""Json parsing: Node (T_Identity)) Done"
            | "G_Break" => G_Break |> debug_json "JSON_CORE" "Json parsing: Node (G_Break)) Done"
            | "G" => G (GoalTyp.gnode_from_json (Json.get jobj "gn") ) 
            | "T_Var" => T_Var (JsonInputUtils.get_string jobj "t_var")
            | "G_Var" => T_Var (JsonInputUtils.get_string jobj "g_var")
            | _ => raise gdata_json_exp ("unexpected node type in JSON encoding", Json.Object jobj)
       )
    | vdata_from_json x = 
        raise gdata_json_exp 
              ("Fail to parse vdata from json, the expected formate of json has to be jobj",
              x);


  fun edata_to_json (GT gt) = 
      Json.mk_object [("type", Json.String "GT"), 
                        ("gtyp", GoalTyp.to_json gt)]
    | edata_to_json (GT_Var var) = 
        Json.mk_object [("type", Json.String "GT_Var"), 
                        ("gtyp_var", Json.String var)]
       
  fun edata_from_json (Json.Object jobj) (* has to be jobj *) = 
      (case JsonInputUtils.get_string jobj "type" of
              ("GT_Var") => GT_Var (JsonInputUtils.get_string jobj "gtyp_var")
            | ("GT") => 
             (debug_json "JSON_CORE" ("Json parsing: Edge (GT) - " ^ Json.encode (Json.Object jobj)) ();
              GT (GoalTyp.from_json (JsonInputUtils.get jobj "gtyp")))
            | _ => raise gdata_json_exp ("unexpected edge type in JSON encoding", Json.Object jobj))
    | edata_from_json x = 
        raise gdata_json_exp 
              ("Fail to parse edata from json, the expected format of json has to be jobj",
              x);

  structure Sharing = 
  struct
    type vdata = vdata
    type edata = edata
    structure GoalTyp = GoalTyp.BasicSharing
  end
 end
end;