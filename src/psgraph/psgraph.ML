functor PSGraphFun(structure Theory_IO : PSGRAPH_THEORY_IO) : PS_GRAPH  =
struct

 structure Theory = Theory_IO.PS_Theory;
 structure Prover = Theory.Data.GoalTyp.Prover;
 structure Theory_IO = Theory_IO

 local open LoggingHandler in
(*
  fun weak_validate ?
  fun strong_validate ?
*)

  datatype subgraph = Subgraph of {
    name : StrName.NTab.name,
    branchType : string,
    graphs: Theory.Graph.T list,
    args : Theory.Data.arg_typ
  }

  datatype atomic_tacs = Atomic_Tacs of {
     name : string, (* map to the node name *)
     tactic: string, (* actual ml code of the tactic *)
     args : Theory.Data.arg_typ
  }

  datatype occurences = Occurs of {
        atomic_tactics : 
          ((StrName.NTab.name (* graph name *) * 
           int (* index *)) StrName.NTab.T (* use vname as key for this table *)
          ) StrName.NTab.T,
        graph_tactics : 
          ((StrName.NTab.name (* graph name *) * 
           int (* index *)) StrName.NTab.T (* use vname as key for this table *)
          ) StrName.NTab.T
      }
  val default_occurs : occurences = Occurs {atomic_tactics = StrName.NTab.empty,graph_tactics = StrName.NTab.empty};

 (* prover tactic : what about evaluation? should this be in the tactic or as args here? *)
 datatype T = PSGraph of {
      graph : Theory.Graph.T, (* this is the main / top graph *)
      graph_tactics : subgraph StrName.NTab.T, (* only name of parent *)
      atomic_tactics : atomic_tacs StrName.NTab.T,
(* as we allow using tactic with various arguments, the types of tactics various, we need to use string *)
     (*  tactics : Prover.tactic StrName.NTab.T, *) (* atomic_tactics name -> tactic *) (* do we still need it ? *)
      goaltype_data : Theory.Data.GoalTyp.data ,
      occurs : occurences 
  }
  
 exception tactic_exp of string

 fun update_top_graph f (PSGraph rep) = 
   PSGraph { graph = f (#graph rep), graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep,(* tactics = #tactics rep,*)
             goaltype_data = #goaltype_data rep,  occurs = #occurs rep}
 fun update_graph_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = f (#graph_tactics rep), 
             atomic_tactics = #atomic_tactics rep, (* tactics = #tactics rep,*)
             goaltype_data = #goaltype_data rep, occurs = #occurs rep}
 fun update_atomic_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = f (#atomic_tactics rep), (* tactics = #tactics rep,*)
             goaltype_data = #goaltype_data rep, occurs = #occurs rep}
 (* 
 fun update_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, tactics = f (#tactics rep),
             goaltype_data = #goaltype_data rep, parents = #parents rep}
*)

 fun update_goaltype_data f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, (* tactics = #tactics rep,*)
             goaltype_data = f (#goaltype_data rep), occurs = #occurs rep}
 fun update_occurs f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, (* tactics = #tactics rep,*)
             goaltype_data = #goaltype_data rep, occurs = f(#occurs rep)}

 fun get_top_graph (PSGraph rep) = #graph rep;
 fun get_graph_tactics (PSGraph rep) = #graph_tactics rep;
 fun get_atomic_tactics (PSGraph rep) = #atomic_tactics rep;

 fun get_atomic_tac_code_and_args ps name pnode = 
  let 
    val (Atomic_Tacs atom_tacs) = StrName.NTab.get (get_atomic_tactics ps) name
    val tac_code = (#tactic atom_tacs)
    val (tac_args : string list list) =  (#args atom_tacs)
    val env_data = Theory.GoalTyp.Prover.get_pnode_env pnode
    fun subst_env_var var = 
      case Theory.Graph_Utils.parse_env_var_name var of NONE => var
      | SOME var0  => 
        (case StrName.NTab.get env_data var0 of (Prover.E_ML var') => var'
          | _ =>  (logging "ENV_DATA" ("Only E_ML is supported, please check the type of " ^ var0  ^ " in " ^ tac_code); 
                   raise tinker_fail)
        handle StrName.Tab.UNDEF _ => 
          (logging "ENV_DATA" ("Undefined env_var " ^ var0  ^ " for " ^ tac_code); 
           raise tinker_fail))
    val tac_args_env_var : string list list = 
      map 
      (fn arg => (subst_env_var (hd arg)) :: (tl arg)
        handle Empty => 
           (logging "ARG_DATA" ("Illformed arg_data, [] encountered for " ^ tac_code); 
           raise tinker_fail))
      tac_args
  in
    (tac_code, tac_args_env_var)
  end

 fun get_hgraph_args ps name = 
  let val (Subgraph hgraphs) = StrName.NTab.get (get_graph_tactics ps) name in
  (#args hgraphs) end

 (* fun get_tactics (PSGraph rep) = #tactics rep;*)
 fun get_goaltype_data (PSGraph rep) = #goaltype_data rep;
 fun get_occurs (PSGraph rep) = #occurs rep;
 fun get_graphs ps name = 
  case name 
    of "main" => [get_top_graph ps]
    | _ => 
      StrName.NTab.get (get_graph_tactics ps) name 
      |> (fn (Subgraph {graphs,...})=> graphs)
 fun get_graph ps name idx = 
  case name 
    of "main" => get_top_graph ps
    | _ => 
      StrName.NTab.get (get_graph_tactics ps) name 
      |> (fn (Subgraph {graphs,...})=> (fn x =>List.nth (x, idx)) graphs)

 val set_top_graph = update_top_graph o K;
 val set_graph_tactics = update_graph_tactics o K;
 val set_atomic_tactics = update_atomic_tactics o K;
 val set_goaltype_data = update_goaltype_data o K;
 val set_occurs = update_occurs o K;

 fun replace_nth l nth h = 
  List.take (l, nth + 1) |> rev |> tl |> rev(* but last *)
  |> (fn x => x @ [h] @(List.drop (l, nth + 1)))

 fun set_graph name idx g ps = 
  case name
    of "main" => set_top_graph g ps
    | _ =>
      StrName.NTab.get (get_graph_tactics ps) name
      |> (fn (Subgraph rep) => 
        (Subgraph{args = #args rep, name = #name rep, 
                  branchType = #branchType rep,
                  graphs = replace_nth (#graphs rep) idx g}))
      |> (fn x => StrName.NTab.update (name, x)  (get_graph_tactics ps))
      |> (fn x => set_graph_tactics x ps)

 fun of_graph graph = 
   PSGraph { graph = graph,
             graph_tactics = StrName.NTab.empty,
             atomic_tactics = StrName.NTab.empty,
             (* tactics = StrName.NTab.empty,*)
             goaltype_data = Theory.Data.GoalTyp.default_data, occurs = default_occurs};

 val empty = of_graph Theory.Graph.empty;

 fun all_names ps = 
   let
     val gtac_nms = StrName.NTab.get_nameset (get_graph_tactics ps)
     val tac_nms = StrName.NTab.get_nameset (get_atomic_tactics ps)
   in
     StrName.NSet.union_merge gtac_nms tac_nms
   end;

(* ?? looks strange *)
 fun fresh_name ps = StrName.NSet.new (all_names ps);
 
 fun merge_disjoint ps1 ps2 =      
  let 
    val graph_tactics' = StrName.NTab.merge_disjoint (get_graph_tactics ps1) (get_graph_tactics ps2)
    val atomic_tactics' = StrName.NTab.merge_disjoint (get_atomic_tactics ps1) (get_atomic_tactics ps2)
  (*  val tactics' = StrName.NTab.merge_disjoint (get_tactics ps1) (get_tactics ps2) *)
  in
      PSGraph { graph = Theory.Graph.empty,
             graph_tactics = graph_tactics',
             atomic_tactics = atomic_tactics',
            (* tactics = tactics',*)
             goaltype_data =  Theory.Data.GoalTyp.default_data,
             occurs = default_occurs
            (* TODO: should be able to merger*)
              }
   end
(*
 fun load_atomics tacs ps = 
   fold
   (fn (str, tac) => update_tactics (StrName.NTab.doadd (str, tac)))
   tacs ps;
*)

 fun arg_typ_to_json args = 
  Json.Array (map (fn y => (Json.Array (map (fn x => Json.String x) y))) args)
 fun arg_typ_from_json (Json.Array args) = 
  map 
  (fn (Json.Array x) => 
    map 
    (fn y => case y of (Json.String str) => str) 
    x)
  args 
 | arg_typ_from_json _ =  raise Json.parse_exn "unexcepted json strcure in arg_typ_from_json"

 fun output_atomic_json (_, Atomic_Tacs atom) =
   Json.mk_object [
    ("name", Json.String (#name atom)), 
    ("tactic", Json.String (#tactic atom)), 
    ("args", arg_typ_to_json (#args atom))]

 fun input_atomic_json (Json.Object jobj) = 
  let
    val name =  JsonInputUtils.get_string jobj "name"
    val tactic = JsonInputUtils.get_string jobj "tactic"
    val args = (arg_typ_from_json (Json.get jobj "args"))
  in
    (name, Atomic_Tacs { name = name, tactic = tactic, args = args})
  end
 | input_atomic_json _ = raise Json.parse_exn "unexcepted json strcure in input_atomic_json"
                                                      
 fun output_subgraph_json (name, (Subgraph subgraph)) = 
   Json.mk_object [
    ("name", Json.String name),
    ("branchType", Json.String (#branchType subgraph)),
    ("graphs", map Theory_IO.out_json (#graphs subgraph) |> Json.Array),
    ("args", arg_typ_to_json (#args subgraph))]

 fun input_subgraph_json (Json.Object jobj) =
  let 
    val name =  JsonInputUtils.get_string jobj "name"
    val branchType = JsonInputUtils.get_string jobj "branchType"
    val graphs = JsonInputUtils.get_array jobj "graphs" |> map Theory_IO.in_json
     val args = (arg_typ_from_json (Json.get jobj "args"))
  in
    (name, Subgraph {name = name, branchType = branchType, graphs = graphs, args = args})
  end
 | input_subgraph_json _ = raise Json.parse_exn "unexcepted json strcure in input_subgraph_json"
 
 val get_V_from_occurs_record = (fn Json.String s => s) o  List.last;
 val get_others_from_occurs_record = 
  (fn x => (hd x |> (fn Json.String x => x), 
            hd (tl x) |>  (fn Json.Int x => x)))  o rev o tl o rev;
 fun input_occurs_json (Json.Object jobj)  =
  let
    fun array_record_to_tab array =
      map (fn (Json.Array x) => x) array
      |> map (fn x => (get_V_from_occurs_record x, get_others_from_occurs_record x))
      |> StrName.NTab.of_list
    fun parse_occurs name json = 
      JsonInputUtils.get_obj json name
      |> (fn obj => Json.properties obj |> map (fn v => (v, JsonInputUtils.get_array obj v |> array_record_to_tab)))
      |> StrName.NTab.of_list
    val atomic_tactics = parse_occurs "atomic_tactics" jobj
    val graph_tactics = parse_occurs "graph_tactics" jobj
  in
    Occurs {atomic_tactics = atomic_tactics, graph_tactics = graph_tactics}
  end
 | input_occurs_json _ = raise Json.parse_exn "unexcepted json strcure in input_occurs_json"

 fun mk_occurs_subfield_json (v, (n, idx)) = Json.Array [Json.String n, Json.Int idx, Json.String v];
 fun mk_occurs_graph_json (v, graph_tab) = (v,  map mk_occurs_subfield_json (StrName.NTab.list_of graph_tab) |> Json.Array)
 fun output_occurs_json (Occurs occ)  = 
    [("atomic_tactics", 
      (#atomic_tactics occ) 
      |> StrName.NTab.list_of 
      |> map mk_occurs_graph_json
      |> Json.mk_object),
    ("graph_tactics",
      (#graph_tactics occ) 
     |> StrName.NTab.list_of 
     |> map mk_occurs_graph_json
     |> Json.mk_object)]
   |> Json.mk_object;


 fun output_json ps = 
  let 
    val graph = Theory_IO.out_json (get_top_graph ps)
    val graph_tactics = 
     Json.Array 
       (StrName.NTab.list_of (get_graph_tactics ps) 
       |> map output_subgraph_json)
    val atomic_tactics =  
      Json.Array 
       (StrName.NTab.list_of (get_atomic_tactics ps) 
       |> map output_atomic_json)
    val goaltype_data = Json.String "" (* FIXME *)
    val current = Json.String "main"
    val current_index = Json.Int 0     
    val occ = output_occurs_json (get_occurs ps)
  in
    Json.mk_object [
      ("current", current),
      ("current_index", current_index),
      ("graph_tactics", graph_tactics),
      ("atomic_tactics", atomic_tactics),
      ("goal_types", goaltype_data),
      ("graph", graph),
      ("occurrences", occ)
    ]
  end

 fun output_json_as_eval_field name_current index_current ps = 
  let
    val graph_tactics = 
       (StrName.NTab.list_of (get_graph_tactics ps) 
       |> map output_subgraph_json) 
  in
  Json.mk_object 
  [
    ("name_current", map Json.String name_current |> Json.Array),
    ("index_current", Json.Int index_current),
    ("graphs", 
     Json.Array
     ([
       Json.mk_object[
        ("name", Json.String "main"),
        ("branchType", Json.String "OR"),
        ("args", Json.Array[]),
        ("graphs", Json.Array [Theory_IO.out_json (get_top_graph ps)])]
     ] @ graph_tactics)),
    ("occurrences", output_occurs_json (get_occurs ps))
  ]
  end

(* expect to out put as an eval field *)
 fun input_json (Json.Object object) = 
  let
    val in_graph = Theory_IO.in_json (JsonInputUtils.get object "graph")
    val graph_tactics = 
      JsonInputUtils.get_array object "graph_tactics"
      |> map input_subgraph_json
      |> StrName.NTab.of_list
    val atomic_tactics = 
      JsonInputUtils.get_array object "atomic_tactics"
      |> map input_atomic_json
      |> StrName.NTab.of_list
    val occurs = Json.get object "occurrences" |> input_occurs_json
  in
    of_graph in_graph
    |> set_graph_tactics graph_tactics
    |> set_atomic_tactics atomic_tactics
    |> set_occurs occurs
    (* |> set_tactics tactics*)
  end
 | input_json _ = raise Json.parse_exn "unexcepted json strcure in input_json"

 fun write_json_file path ps =  File_Io.write_string path (output_json ps |> Json.encode);

 fun read_json_file path = 
  File_Io.read_string path 
  |> Json.of_string 
  |> input_json

(* TO DO: implement the type checking / graph validating *)
 val validate_psgraph = (fn _ => false )

 end (* end of open logging handler *)

 structure Sharing = 
 struct
  type T = T
  type subgraph = subgraph
  type atomic_tacs = atomic_tacs
  type occurences = occurences 
  structure Theory = Theory.Sharing
 end
end
