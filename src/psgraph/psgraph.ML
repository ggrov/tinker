functor PSGraphFun(Theory_IO : PSGRAPH_THEORY_IO) : PS_GRAPH  =
struct

 structure Theory = Theory_IO.PS_Theory;
 structure Prover = Theory.Data.GoalTyp.Prover;
 structure Theory_IO = Theory_IO

(*
  fun weak_validate ?
  fun strong_validate ?
*)

  datatype subgraph = Subgraph of {
    name : StrName.NTab.name,
    isOr : bool,
    graphs: Theory.Graph.T list,
    args : Theory.Data.arg_typ
    (* node_id : V.name list  the actual graph name plus node id as a key to uniquely identify a node *)
  }

  datatype atomic_tacs = Atomic_Tacs of {
     name : string, (* map to the node name *)
     tactic: string, (* actual ml code of the tactic *)
     args : Theory.Data.arg_typ
     (* node_id : V.name list  the actual graph name plus node id as a key to uniquely identify a node *)
  }

 (* prover tactic : what about evaluation? should this be in the tactic or as args here? *)
 datatype T = PSGraph of {
      graph : Theory.Graph.T,
      graph_tactics : subgraph StrName.NTab.T, (* only name of parent *)
      atomic_tactics : atomic_tacs StrName.NTab.T,
(* as we allow using tactic with various arguements, the types of tactics various, we need to use string *)
     (*  tactics : Prover.tactic StrName.NTab.T, *) (* atomic_tactics name -> tactic *) (* do we still need it ? *)
      goaltype_data : Theory.Data.GoalTyp.data
  }
  
 exception tactic_exp of string

 fun update_top_graph f (PSGraph rep) = 
   PSGraph { graph = f (#graph rep), graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep,(* tactics = #tactics rep,*)
             goaltype_data = #goaltype_data rep}
 fun update_graph_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = f (#graph_tactics rep), 
             atomic_tactics = #atomic_tactics rep, (* tactics = #tactics rep,*)
             goaltype_data = #goaltype_data rep}
 fun update_atomic_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = f (#atomic_tactics rep), (* tactics = #tactics rep,*)
             goaltype_data = #goaltype_data rep}
 (* 
 fun update_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, tactics = f (#tactics rep),
             goaltype_data = #goaltype_data rep, parents = #parents rep}
*)
 fun update_goaltype_data f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, (* tactics = #tactics rep,*)
             goaltype_data = f (#goaltype_data rep)}

 fun get_top_graph (PSGraph rep) = #graph rep;
 fun get_graph_tactics (PSGraph rep) = #graph_tactics rep;
 fun get_atomic_tactics (PSGraph rep) = #atomic_tactics rep;
(* tactic string  + args string *)

(* for the use of the string args *)
 fun build_tac_code_with_arg tac_code tac_args = 
  let
    fun concat a b = b ^ a;
    val args = 
      case tac_args of [] => ""
      | _ => map (fn x => "(" ^ (fold concat x "") ^ ")" ) tac_args
            |> (fn y => fold concat y "")
  in
     tac_code ^ args
  end

(*
 fun build_env_arg_str parent_arg_str arg_str = 
  String.translate (fn x => if x = #"@" then ("(" ^ parent_arg_str ^ ")") else str x ) arg_str
  |> (fn x =>(writeln ("ML tac code: " ^ x ^ " using parent arg: " ^ parent_arg_str ^ " and arg str: " ^ arg_str) ; x))
*)  
  
(* FIXME: need to handle the env variable, need to subst them *)
 fun get_atomic_tac_code ps name = 
  let 
    val (Atomic_Tacs atom_tacs) = StrName.NTab.get (get_atomic_tactics ps) name
    val tac_code = (#tactic atom_tacs)
    val tac_args =  (#args atom_tacs)
  in
     build_tac_code_with_arg tac_code tac_args
    (*|> (fn x => (writeln "after enter get_atomic_tactic_code0" ; x))*)
  end

 fun get_hgraph_args ps name = 
  let val (Subgraph hgraphs) = StrName.NTab.get (get_graph_tactics ps) name in
  (#args hgraphs) end

 (* fun get_tactics (PSGraph rep) = #tactics rep;*)
 fun get_goaltype_data (PSGraph rep) = #goaltype_data rep;
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
 
(* val set_tactics = update_tactics o K; *)
 val set_goaltype_data = update_goaltype_data o K;

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
                  isOr = #isOr rep,
                  graphs = replace_nth (#graphs rep) idx g}))
      |> (fn x => StrName.NTab.update (name, x)  (get_graph_tactics ps))
      |> (fn x => set_graph_tactics x ps)

 fun of_graph graph = 
   PSGraph { graph = graph,
             graph_tactics = StrName.NTab.empty,
             atomic_tactics = StrName.NTab.empty,
             (* tactics = StrName.NTab.empty,*)
             goaltype_data = Theory.Data.GoalTyp.default_data};

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
             goaltype_data =  Theory.Data.GoalTyp.default_data
(* fixme: should be able to merger data, a function needs to be added in the goaltyp interface*)
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
    ("isOr", Json.Bool (#isOr subgraph)),
    ("graphs", map Theory_IO.out_json (#graphs subgraph) |> Json.Array),
    ("args", arg_typ_to_json (#args subgraph))]

 fun input_subgraph_json (Json.Object jobj) =
  let 
    val name =  JsonInputUtils.get_string jobj "name"
    val isOr = JsonInputUtils.get_bool jobj "isOr"
    val graphs = JsonInputUtils.get_array jobj "graphs" |> map Theory_IO.in_json
     val args = (arg_typ_from_json (Json.get jobj "args"))
  in
    (name, Subgraph {name = name, isOr = isOr, graphs = graphs, args = args})
  end
 | input_subgraph_json _ = raise Json.parse_exn "unexcepted json strcure in input_subgraph_json"

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
  in
    Json.mk_object [
      ("current", current),
      ("current_index", current_index),
      ("graph_tactics", graph_tactics),
      ("atomic_tactics", atomic_tactics),
      ("goal_types", goaltype_data),
      ("graph", graph)
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
    ("name_current", Json.String name_current),
    ("index_current", Json.Int index_current),
    ("graphs", 
     Json.Array
     ([
       Json.mk_object[
        ("name", Json.String "main"),
        ("isOr", Json.Bool false),
        ("args", Json.Array[]),
        ("graphs", Json.Array [Theory_IO.out_json (get_top_graph ps)])]
     ] @ graph_tactics))
  ]
  end

 val exec_buffer :Prover.tactic option Unsynchronized.ref = Unsynchronized.ref NONE ;
 fun exec_tac_exp (s : string) : Prover.tactic option = (
	let	val cmd = 
	    "PSGraph.exec_buffer := ((" ^ s ^ ") |> SOME handle _ => NONE)"; (* hacky! PSGraph has to be the same as the strucutre instaintiated from this functor *)
		val _ =  Prover.exec_str cmd;
	in	!exec_buffer
	end
 );
 
 fun eval_tactic str = 
  case exec_tac_exp str 
    of SOME t => t
    | NONE => raise tactic_exp ("ERR: fail to eval " ^ str ^ " as a tactic." )

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
(* TODO: need to test the tactic with the default args before starting evaluation *)
 (*   val tactics = 
      StrName.NTab.list_of atomic_tactics
      |> map (fn (name, Atomic_Tacs{tactic,...}) => (name, eval_tactic tactic))
      |> StrName.NTab.of_list *)
  in
    of_graph in_graph
    |> set_graph_tactics graph_tactics
    |> set_atomic_tactics atomic_tactics
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

 structure Sharing = 
 struct
  type T = T
  type subgraph = subgraph
  type atomic_tacs = atomic_tacs
  structure Theory = Theory.Sharing
 end
end
