signature GRAPH_UTILS_SHARING =
sig
  structure Graph : GRAPH_SHARING
end

signature GRAPH_UTILS =
sig 
  structure Graph : GRAPH

  val mk_gnode : Graph.Data.GoalTyp.gnode -> Graph.Data.vdata 
  val all_gnodes : Graph.T -> V.name list
  val lookup_gnode : Graph.T -> V.name -> Graph.Data.GoalTyp.gnode option 

  val get_vertex_list : Graph.T -> V.NSet.name list
  val get_vertex_input_edge_list : Graph.T -> V.name -> E.NSet.name list
  val get_vertex_output_edge_list : Graph.T -> V.name -> E.NSet.name list
  
  val all_tactics : Graph.T -> V.name list 
  val gnode_of : Graph.T -> V.name -> Graph.Data.GoalTyp.gnode
  val goaltype_of : Graph.T -> E.name -> Graph.Data.GoalTyp.T

  val is_gnode : Graph.T -> V.name -> bool 
  val is_gtyp : Graph.T -> E.name -> bool
  val is_tactic : Graph.T -> V.name -> bool
  
  
  val parse_arg_data : Graph.Data.GoalTyp.Prover.context -> Graph.Data.GoalTyp.Prover.pnode 
      -> Graph.Data.arg_typ -> Graph.Data.GoalTyp.Prover.arg_data list

  val is_env_tactic_name : string -> bool
  val is_env_tactic : Graph.T -> V.name -> bool
  val parse_env_var_name : string -> string option

  structure Sharing : GRAPH_UTILS_SHARING
end

functor GraphUtilFunc (Graph: GRAPH) : GRAPH_UTILS =
struct 

 local open LoggingHandler in
  structure Graph = Graph;
  structure GoalTyp = Graph.Data.GoalTyp
  
   fun get_vertex_output_edge_list graph v = 
      Graph.get_out_edges graph v 
      |> E.NSet.list_of;

   fun get_vertex_input_edge_list graph v = 
      Graph.get_in_edges graph v 
      |> E.NSet.list_of;

   fun get_vertex_list graph =  
     Graph.get_vertices graph
     |> V.NSet.list_of

   fun is_gtyp graph e = 
     case Graph.lookup_edge_data graph e of (SOME (Graph.Data.GT _)) => true | _ => false;

   fun is_tactic graph v = 
   case Graph.lookup_vertex_data graph v of 
       SOME (Graph.Data.T_Atomic _) => true
     | SOME (Graph.Data.T_Graph _) => true
     | SOME Graph.Data.T_Identity => true
     | _ => false; 

   fun is_gnode graph v = 
     case Graph.lookup_vertex_data graph v of 
         SOME (Graph.Data.G _) => true
       | _ => false; 

   fun lookup_gnode graph v = 
     case Graph.lookup_vertex_data graph v of 
        (SOME (Graph.Data.G gn)) => SOME gn
       | _ => NONE; 

   fun goaltype_of graph e = 
     case Graph.get_edge_data graph e of (Graph.Data.GT g) => g   
     |  _ => (logging "FAILURE" ("Unknown goaltype type in edge" ^ (E.string_of_name e)); raise tinker_fail true)

   fun gnode_of graph v = 
     case Graph.get_vertex_data graph v of (Graph.Data.G gn) => gn
     | _ => (logging "FAILURE" ("This is not a goal node" ^ (V.string_of_name v)); raise tinker_fail true) 

   fun mk_gnode gnode = Graph.Data.G gnode;


   fun all_tactics graph = 
     get_vertex_list graph
     |> filter (is_tactic graph);

   fun all_gnodes graph = 
     get_vertex_list graph
     |> filter (is_gnode graph);

(* environment tactics and variables *)
  fun is_env_tactic_name name = 
  let
    fun is_prefix_ENV name = 
    let val _ =  Symbol.explode name |> Scan.this_string "ENV_" in
    true end;
    fun is_prefix_qmark name = 
    let val _ =  Symbol.explode name |> $$ "?" in
    true end;
  in
    (Scan.catch (is_prefix_ENV) name handle _ => false) orelse
    (Scan.catch (is_prefix_qmark) name handle _ => false)
  end

 (* is a tactic node and also follows the name convension that has a prefix of ENV *)
  fun is_env_tactic g v = 
    let
      fun get_tactic_node_name graph vgraph = 
        case Graph.lookup_vertex_data graph vgraph of 
           SOME (Graph.Data.T_Atomic n ) => fst n
           | _ => raise tinker_fail true (*"This is not a tatic node"*) (* no need to logging this, as it won't happen *)
    in
      is_tactic g v andalso is_env_tactic_name (get_tactic_node_name g v)
    end

(* check the format is "?_" *)
  fun parse_env_var_name str = 
  let
    fun get_env_arg_name0 str = 
      str |> Symbol.explode 
      |> $$ "?"
      |> snd
      |> implode
      |> SOME;
  in
    Scan.catch (get_env_arg_name0) str
    handle RunCallFail _ => NONE
  end
  
(**********************************************************
* Argument parsing
***********************************************************)
  fun parse_arg_data ctxt pnode args = 
   let 
    fun de_hd_last l = tl l |>  rev |> tl |> rev (* remove both hd and last ele *)
    val env = GoalTyp.Prover.get_pnode_env pnode 
    fun split_args str = String.tokens ((op member) (op =) [#"[", #"]", #" ", #"," ]) str
    fun parse_singleton typ def = 
     case typ 
      of "term" => GoalTyp.Prover.trm_of_string ctxt def|> GoalTyp.Prover.A_Trm
       | "thm" => GoalTyp.Prover.get_thm_by_name ctxt def|> GoalTyp.Prover.A_Thm
       | "string" => GoalTyp.Prover.A_Str def
       | "var" => Option.valOf (parse_env_var_name def)|> GoalTyp.Prover.A_Var
       | x => GoalTyp.Prover.parse_ML_arg def typ        
   in
    map 
    (fn arg (* [def, type] / [?env_var]*) 
      => if List.length arg = 1  (* env var or predefine antiqunto, e.g. Hyps, Concl *)
         then case (hd arg) 
           of "Concl" => GoalTyp.Prover.get_pnode_concl pnode |> GoalTyp.Prover.A_Trm
           | "concl" => GoalTyp.Prover.get_pnode_concl pnode |> GoalTyp.Prover.A_Trm
           | "Hyps" => GoalTyp.Prover.get_pnode_hyps pnode |> GoalTyp.Prover.A_L_Trm
           | "hyps" => GoalTyp.Prover.get_pnode_hyps pnode |> GoalTyp.Prover.A_L_Trm
           |  x => 
           (* first to check if it is a string i.e. in the format of "..." *)
            if ((String.explode x |> hd) = #"\"" andalso (String.explode x |> List.last) = #"\"" ) (* see if it is a string *)
            then
             String.substring (x, 1, size x - 2) 
             (*|> (fn x => (writeln x; x)) *)
             |> GoalTyp.Prover.A_Str
            else (* otherwise, it is a variable , then to get its value in the env *)
             ((StrName.NTab.get env (Option.valOf (parse_env_var_name (hd arg)))
             handle _ => (logging "FAILURE" ("fail to get arg: " ^ (hd arg) ^ " from env"); raise tinker_fail true))
             |> GoalTyp.Prover.env_to_arg)
         else if (List.last arg = "list") then
           map (parse_singleton (de_hd_last arg |> List.foldr (op ^) "")) 
            (split_args (hd arg)) 
           |>  GoalTyp.Prover.A_L
         else
          parse_singleton (List.foldr (op ^) "" (List.tl arg)) (hd arg)
    )
    args end
      
 structure Sharing =
  struct
   structure Graph = Graph.Sharing
  end

 end (* end of local open *)
end