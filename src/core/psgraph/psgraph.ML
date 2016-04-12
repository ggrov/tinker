functor PSGraphFun(structure Theory_IO : PSGRAPH_THEORY_IO 
                   structure Env_Tac_Utils : ENV_TAC_UTILS
                   sharing Theory_IO.PS_Theory.Sharing = Env_Tac_Utils.Sharing.PS_Theory) : PS_GRAPH =
struct
 structure Theory = Theory_IO.PS_Theory;
 structure Prover = Theory.Data.GoalTyp.Prover;
 structure Theory_IO = Theory_IO;
 structure Env_Tac_Utils = Env_Tac_Utils;

 local open LoggingHandler in

  datatype graph_tacs = Graph_Tacs of {
    name : StrName.NTab.name,
    branchType : string,
    graphs: Theory.Graph.T list
    (*args : Theory.Data.arg_typ*)
  }

  fun update_graphs_graph_tacs f (Graph_Tacs rep) = 
   Graph_Tacs {
    name = #name rep ,
    branchType =  #branchType rep,
    graphs = f (#graphs rep)}
  val set_graphs_graph_tacs = update_graphs_graph_tacs o K

  datatype atomic_tacs = Atomic_Tacs of {
     name : string, 
     tactic: Prover.tactic,
     def: string
     (*args : Theory.Data.arg_typ*)
  }

  datatype env_tacs = Env_Tacs of {
     name : string, 
     tactic: Prover.env_tac (* actual ml code of the tactic *),
     def: string
     (*args : Theory.Data.arg_typ*)
  }

  datatype occurences = Occurs of {
        atomic_tactics : 
          ((StrName.NTab.name (* graph name *) * 
            int (* index *) * 
            string (* use vname as key for this table *)) list
          ) StrName.NTab.T,
        graph_tactics : 
          ((StrName.NTab.name (* graph name *) * 
           int (* index *) * 
           string (* use vname as key for this table *)) list
          ) StrName.NTab.T
  }
  val default_occurs : occurences = Occurs {atomic_tactics = StrName.NTab.empty, graph_tactics = StrName.NTab.empty};

 (* prover tactic : what about evaluation? should this be in the tactic or as args here? *)
 datatype T = PSGraph of {
      main : StrName.NTab.name,
      graph_tactics : graph_tacs StrName.NTab.T, (* only name of parent *)
      atomic_tactics : atomic_tacs StrName.NTab.T,
      env_tactics : env_tacs StrName.NTab.T,
(* as we allow using tactic with various arguments, the types of tactics various, we need to use string *)
      (*tactics : Prover.tactic StrName.NTab.T,*) (* atomic_tactics name -> tactic *) (* do we still need it ? *)
      goaltype_data : Theory.Data.GoalTyp.data,
      occurs : occurences 
  }

 fun get_atomic_tac_by_name (PSGraph rep) name = 
  StrName.NTab.get (#atomic_tactics rep) name |> (fn Atomic_Tacs {tactic,...} => tactic)
  
 fun get_atomic_env_tac_by_name (PSGraph rep) name = 
  StrName.NTab.get (#env_tactics rep) name |> (fn Env_Tacs {tactic,...} => tactic)
  
 exception tactic_exp of string
 fun update_graph_tactics f (PSGraph rep) = 
   PSGraph { graph_tactics = f (#graph_tactics rep), main = (#main rep),
             atomic_tactics = #atomic_tactics rep, env_tactics = #env_tactics rep,(* tactics = #tactics rep,*)
             occurs = #occurs rep, goaltype_data = #goaltype_data rep}
 fun update_atomic_tactics f (PSGraph rep) = 
   PSGraph { main = #main rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = f (#atomic_tactics rep), env_tactics = #env_tactics rep,(* tactics = #tactics rep,*)
             occurs = #occurs rep, goaltype_data = #goaltype_data rep}
 fun update_env_tactics f (PSGraph rep) = 
   PSGraph { main = #main rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, env_tactics = f (#env_tactics rep),(* tactics = #tactics rep,*)
             occurs = #occurs rep, goaltype_data = #goaltype_data rep}
 fun update_main f (PSGraph rep) = 
   PSGraph { main = f (#main rep), graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, env_tactics = #env_tactics rep,(* tactics = #tactics rep,*)
             occurs = #occurs rep, goaltype_data = #goaltype_data rep}
 fun update_occurs f (PSGraph rep) = 
   PSGraph { main = #main rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, env_tactics = #env_tactics rep,(* tactics = #tactics rep,*)
             occurs = f(#occurs rep), goaltype_data = #goaltype_data rep}
 fun update_goaltype_data f (PSGraph rep) = 
   PSGraph { main = #main rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, env_tactics = #env_tactics rep,(* tactics = #tactics rep,*)
             occurs = (#occurs rep), goaltype_data = f (#goaltype_data rep)}

 fun get_goaltype_data (PSGraph rep) = #goaltype_data rep
 fun get_main (PSGraph rep) = #main rep
 fun get_graph_tactics (PSGraph rep) = #graph_tactics rep;
 fun get_atomic_tactics (PSGraph rep) = #atomic_tactics rep;
 fun get_env_tactics (PSGraph rep) = #env_tactics rep;
 fun get_top_graph ps = 
  StrName.NTab.get (get_graph_tactics ps) (get_main ps) 
  |> (fn (Graph_Tacs rep) => (#graphs rep) |> hd);
(* 
 fun get_atomic_tac_code_and_args ps name pnode = 
  let 
    val (Atomic_Tacs atom_tacs) = StrName.NTab.get (get_atomic_tactics ps) name
    val tac_code = (#tactic atom_tacs)
    val (tac_args : string list list) = (#args atom_tacs)
    val env_data = Theory.GoalTyp.Prover.get_pnode_env pnode
    fun subst_env_var var = 
      case Theory.Graph_Utils.parse_env_var_name var of NONE => var
      | SOME var0  => 
        (case StrName.NTab.get env_data var0 of (Prover.E_ML var') => var'
          | _ =>  (logging "ENV_DATA" ("Only E_ML is supported, please check the type of " ^ var0  ^ " in " ^ tac_code); 
                   raise tinker_fail))
    handle StrName.Tab.UNDEF _ => 
          (logging "ENV_DATA" ("Undefined env_var " ^ var0  ^ " for " ^ tac_code); 
           raise tinker_fail)
    val tac_args_env_var : string list list = 
      map 
      (fn arg => (subst_env_var (hd arg)) :: (tl arg)
        handle Empty => 
           (logging "ARG_DATA" ("Illformed arg_data, [] encountered for " ^ tac_code); 
           raise tinker_fail))
      tac_args
     val _ = logging "TACTIC" (
               "tac_code [" ^ tac_code ^ "] " ^ 
               "tac_args_env_var [" ^ 
               ((String.concat (List.concat tac_args_env_var))) ^ 
               "]")
  in
    (tac_code, tac_args_env_var)
  end

 fun get_graph_tacs_args ps name = 
  let val (Graph_Tacs gtacs) = StrName.NTab.get (get_graph_tactics ps) name in
  (#args gtacs) end
 *)
 (* fun get_tactics (PSGraph rep) = #tactics rep;*)
 fun get_occurs (PSGraph rep) = #occurs rep;
 fun get_graphs ps name = 
   StrName.NTab.get (get_graph_tactics ps) name 
   |> (fn (Graph_Tacs {graphs,...})=> graphs)

 fun get_graph ps name idx = 
   StrName.NTab.get (get_graph_tactics ps) name 
   |> (fn (Graph_Tacs {graphs,...})=> (fn x =>List.nth (x, idx)) graphs)

 val set_goaltype_data = update_goaltype_data o K;
 val set_graph_tactics = update_graph_tactics o K;
 val set_atomic_tactics = update_atomic_tactics o K;
 val set_env_tactics = update_env_tactics o K;
 val set_occurs = update_occurs o K;
 val set_main = update_main o K;
 fun set_top_graph g ps = 
  let val main_graph_tacs = StrName.NTab.get (get_graph_tactics ps)  (get_main ps)
  val main_graph_tacs' = set_graphs_graph_tacs [g] main_graph_tacs in
  set_graph_tactics (StrName.NTab.update_new (get_main ps, main_graph_tacs') (get_graph_tactics ps)) ps end

 fun replace_nth l nth h = 
  List.take (l, nth + 1) |> rev |> tl |> rev(* but last *)
  |> (fn x => x @ [h] @(List.drop (l, nth + 1)))

 fun set_graph name idx g ps = 
  StrName.NTab.get (get_graph_tactics ps) name
  |> (fn (Graph_Tacs rep) => 
    (Graph_Tacs{name = #name rep, 
              branchType = #branchType rep,
              graphs = replace_nth (#graphs rep) idx g}))
  |> (fn x => StrName.NTab.update (name, x)  (get_graph_tactics ps))
  |> (fn x => set_graph_tactics x ps)

 fun mk_default_graph_tacs name g =  
  Graph_Tacs {
    name  = name,
    branchType = "OR",
    graphs = [g]
   };
 fun of_graph name graph = 
   PSGraph { graph_tactics = StrName.NTab.ins (name, mk_default_graph_tacs name graph) StrName.NTab.empty,
             atomic_tactics = StrName.NTab.empty,
             env_tactics = StrName.NTab.empty,
             main = "default", occurs = default_occurs, goaltype_data = Theory.Data.GoalTyp.default_data};
 val default_psgraph =    
   PSGraph { graph_tactics =  StrName.NTab.empty,
             atomic_tactics = StrName.NTab.empty,
             env_tactics = StrName.NTab.empty,
             main = "default", occurs = default_occurs,
             goaltype_data = Theory.Data.GoalTyp.default_data};

 val empty = of_graph "default" Theory.Graph.empty;

 fun all_names ps = 
   let
     val gtac_nms = StrName.NTab.get_nameset (get_graph_tactics ps)
     val tac_nms = StrName.NTab.get_nameset (get_atomic_tactics ps)
   in
     StrName.NSet.union_merge gtac_nms tac_nms
   end;

(* ?? looks strange *)
 fun fresh_name ps = StrName.NSet.new (all_names ps);
 
 fun merge_disjoint main ps1 ps2 =      
  let 
    val graph_tactics' = StrName.NTab.merge_disjoint (get_graph_tactics ps1) (get_graph_tactics ps2)
    val atomic_tactics' = StrName.NTab.merge_disjoint (get_atomic_tactics ps1) (get_atomic_tactics ps2)
    val env_tactics' = StrName.NTab.merge_disjoint (get_env_tactics ps1) (get_env_tactics ps2)
  (*  val tactics' = StrName.NTab.merge_disjoint (get_tactics ps1) (get_tactics ps2) *)
  in
      PSGraph { main = main,
             graph_tactics = graph_tactics',
             atomic_tactics = atomic_tactics',
             env_tactics = env_tactics',
             occurs = default_occurs,
             goaltype_data = Theory.Data.GoalTyp.default_data
            (* TODO: should be able to merger*)
              }
   end
(*
 fun load_atomics tacs ps = 
   fold
   (fn (str, tac) => update_tactics (StrName.NTab.doadd (str, tac)))
   tacs ps;
*)


 fun output_atomic_json (_, Atomic_Tacs atom) =
   Json.mk_object [
    ("name", Json.String (#name atom)), 
    ("tactic", Json.String (#def atom)) 
    (*"args", arg_typ_to_json (#args atom)*)]

 fun output_env_json (_, Env_Tacs env) =
   Json.mk_object [
    ("name", Json.String (#name env)), 
    ("tactic", Json.String (#def env)) 
    (*"args", arg_typ_to_json (#args atom)*)]

 fun is_atom_tac (Json.Object jobj) = not (Theory.Graph_Utils.is_env_tactic_name (JsonInputUtils.get_string jobj "name"))
 | is_atom_tac _ = raise Json.parse_exn "unexcepted json strcure in is_env in PSGraph"

 fun input_env_json b (Json.Object jobj) = 
  let
    fun eval_ml ml_str = 
      let
       val _ = logging "TACTIC" (
         "eval env_tac_code [" ^ ml_str ^ "] ") 
      in
        Prover.EnvTac_ML_Exec.eval_ml ml_str
      end
    val name = JsonInputUtils.get_string jobj "name"
    val tac_def = JsonInputUtils.get_string jobj "tactic"
    fun tactic b _ =
      if b then
      ( case tac_def 
        of "" =>  eval_ml name | x => eval_ml x)
      else eval_ml name
    val dummy_env  = K (K [])
   in
   if Env_Tac_Utils.is_abbrv_env_tac name then 
    (name, Env_Tacs {name = name, tactic = dummy_env, def = tac_def})
   else
    (name, Env_Tacs {name = name, tactic = tactic b (), def = tac_def(*, args = args*)})
   end
 | input_env_json _ _ = raise Json.parse_exn "unexcepted json strcure in input_env_json"

 fun input_atomic_json b (Json.Object jobj) = 
  let
    fun eval_ml ml_str = 
      let
       val _ = logging "TACTIC" (
         "eval tac_code [" ^ ml_str ^ "] ") 
      in
        Prover.Tac_ML_Exec.eval_ml ml_str
      end
    val name = JsonInputUtils.get_string jobj "name"
    val tac_def = JsonInputUtils.get_string jobj "tactic" 
    val tactic = 
      if b then
      (case tac_def
      of "" =>  eval_ml ("K " ^ name) 
      | x => eval_ml x)
     else eval_ml name
 
    (* val args = (arg_typ_from_json (Json.get jobj "args"))*)
  in
    (name, Atomic_Tacs { name = name, tactic = tactic, def = tac_def(*, args = args*)})
  end
 | input_atomic_json _ _ = raise Json.parse_exn "unexcepted json strcure in input_atomic_json"
                                                      
 fun output_subgraph_json (name, (Graph_Tacs subgraph)) = 
   Json.mk_object [
    ("name", Json.String name),
    ("branch_type", Json.String (#branchType subgraph)),
    ("graphs", map Theory_IO.out_json (#graphs subgraph) |> Json.Array)
    (*"args", arg_typ_to_json (#args subgraph)*)]

 fun input_subgraph_json (Json.Object jobj) =
  let 
    val name =  JsonInputUtils.get_string jobj "name"
    val branchType = JsonInputUtils.get_string jobj "branch_type"
    val graphs = JsonInputUtils.get_array jobj "graphs" |> map Theory_IO.in_json
   (* val args = (arg_typ_from_json (Json.get jobj "args"))*)
  in
    (name, Graph_Tacs {name = name, branchType = branchType, graphs = graphs(*, args = args*)})
  end
 | input_subgraph_json _ = raise Json.parse_exn "unexcepted json strcure in input_subgraph_json"
 
 val get_V_from_occurs_record = (fn Json.String s => s) o List.last;
 val get_idx_from_occurs_record = (fn Json.Int s => s) o hd o tl;
 val get_graph_from_occurs_record = (fn Json.String s => s) o hd;

 fun input_occurs_json (Json.Object jobj)  =
  let
    fun array_record_to_list array =
      map (fn (Json.Array x) => x) array
      |> map (fn x => [(get_graph_from_occurs_record x, get_idx_from_occurs_record x, get_V_from_occurs_record x)])
      |> List.concat
    fun parse_occurs name json = 
      JsonInputUtils.get_obj json name
      |> (fn obj => Json.properties obj |> map (fn v => (v, JsonInputUtils.get_array obj v |> array_record_to_list)))
      |> StrName.NTab.of_list
    val atomic_tactics = parse_occurs "atomic_tactics" jobj
    val graph_tactics = parse_occurs "graph_tactics" jobj
  in
    Occurs {atomic_tactics = atomic_tactics, graph_tactics = graph_tactics}
  end
 | input_occurs_json _ = raise Json.parse_exn "unexcepted json strcure in input_occurs_json"

 fun mk_occurs_subfield_json (g, idx, v) = Json.Array [Json.String g, Json.Int idx, Json.String v];
 fun mk_occurs_item_json (v, occ_l) = (v,  map mk_occurs_subfield_json occ_l |> Json.Array)
 fun output_occurs_json (Occurs occ)  = 
    [("atomic_tactics", 
      (#atomic_tactics occ) 
      |> StrName.NTab.list_of 
      |> map mk_occurs_item_json
      |> Json.mk_object),
    ("graph_tactics",
      (#graph_tactics occ) 
     |> StrName.NTab.list_of 
     |> map mk_occurs_item_json
     |> Json.mk_object)]
   |> Json.mk_object;

 fun to_prover_json (Json.String s) = Theory.Data.GoalTyp.Prover.encoding_to_prover s |> Json.String
 | to_prover_json (Json.Array arr) = map to_prover_json arr |> Json.Array
 | to_prover_json (Json.Object obj) = 
    Json.fold (fn (n,j) => Json.update (n, to_prover_json j)) obj Json.empty_obj
    |> Json.Object
 | to_prover_json x = x

 fun from_prover_json (Json.String s) = Theory.Data.GoalTyp.Prover.encoding_from_prover s |> Json.String
 | from_prover_json (Json.Array arr) = map from_prover_json arr |> Json.Array
 | from_prover_json (Json.Object obj) = 
    Json.fold (fn (n,j) => Json.update (n, from_prover_json j)) obj Json.empty_obj
    |> Json.Object
 | from_prover_json x = x


 fun output_json ps = 
  let 
    val graph_tactics = 
     Json.Array 
       (StrName.NTab.list_of (get_graph_tactics ps) 
       |> map output_subgraph_json)
    val atomic_tactics =  
      Json.Array 
      ((StrName.NTab.list_of (get_atomic_tactics ps) 
       |> map output_atomic_json) @
       (StrName.NTab.list_of (get_env_tactics ps) 
       |> map output_env_json))
    val goaltype_data = Json.String "" 
    val current = Json.Array[Json.String (get_main ps)]
    val current_index = Json.Int 0     
    val occ = output_occurs_json (get_occurs ps)
  in
    Json.mk_object [
      ("main", Json.String (get_main ps)),
      ("current", current),
      ("current_index", current_index),
      ("graphs", graph_tactics),
      ("atomic_tactics", atomic_tactics),
      ("goal_types", goaltype_data),
      ("occurrences", occ)
    ] |> from_prover_json
  end

 fun output_eval_json name_current index_current ps = 
  let
    val graph_tactics = 
       (StrName.NTab.list_of (get_graph_tactics ps) 
       |> map output_subgraph_json) 
    val atomic_tactics =  
      Json.Array 
      ((StrName.NTab.list_of (get_atomic_tactics ps) 
       |> map output_atomic_json) @
       (StrName.NTab.list_of (get_env_tactics ps) 
       |> map output_env_json))
    val goaltype_data = Json.String "" 
  in
  Json.mk_object 
  [
    ("main", Json.String (get_main ps)),
    ("current", map Json.String name_current |> Json.Array),
    ("current_index", Json.Int index_current),
    ("graphs", Json.Array graph_tactics),
    ("atomic_tactics", atomic_tactics),
    ("goal_types", goaltype_data),
    ("occurrences", output_occurs_json (get_occurs ps))
  ] |> from_prover_json
  end

(* expect to out put as an eval field *)
 fun input_json b (Json.Object object) = 
  let
    val gt_data = 
      Json.get object "goal_types"
      |> Theory.Data.GoalTyp.data_from_json
    val graph_tactics = 
      JsonInputUtils.get_array object "graphs"
      |> map input_subgraph_json
      |> StrName.NTab.of_list
    val atomic_tactics = 
      JsonInputUtils.get_array object "atomic_tactics"
      |> filter is_atom_tac(* filter out the ENV tac *)
      |> map (input_atomic_json b)
      |> StrName.NTab.of_list
    val env_tactics = 
      JsonInputUtils.get_array object "atomic_tactics"
      |> filter (not o is_atom_tac)(* filter out the ENV tac *)
      |> map (input_env_json b)
      |> StrName.NTab.of_list
    val occurs = Json.get object "occurrences" |> input_occurs_json

    val main = JsonInputUtils.get_string object "main" 
  in
    default_psgraph
    |> set_goaltype_data gt_data
    |> set_graph_tactics graph_tactics
    |> set_atomic_tactics atomic_tactics
    |> set_env_tactics env_tactics
    |> set_occurs occurs
    |> set_main main
    (* |> set_tactics tactics*)
  end
 | input_json _ _ = raise Json.parse_exn "unexcepted json structure in input_json"

 fun write_json_file path ps = 
  File_Io.write_string path (output_json ps |> Json.encode |> Theory.Data.GoalTyp.Prover.encoding_to_gui);

 fun read_json_file data path = 
  let 
   val ps = File_Io.read_string path 
   |> Theory.Data.GoalTyp.Prover.encoding_from_gui
   |> Json.of_string 
   |> to_prover_json
   |> input_json true
  in
   case data of NONE => ps
   | (SOME gt_data) => 
    get_goaltype_data ps 
    |> (fn x => Theory.Data.GoalTyp.merge_data x gt_data)
    |> (fn x => set_goaltype_data x ps )
  end



(*
  fun weak_validate ?
  fun strong_validate ?
*)
(* TO DO: implement the type checking / graph validating *)
 val validate_psgraph = (fn _ => false )

 end (* end of open logging handler *)

 structure Sharing = 
 struct
  type T = T
  type graph_tacs = graph_tacs
  type atomic_tacs = atomic_tacs
  type env_tacs = env_tacs
  type occurences = occurences 
  structure Theory = Theory.Sharing
 end
end
