functor PSGraphFun(Theory_IO : PSGRAPH_THEORY_IO) : PS_GRAPH =
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
  }

  datatype atomic_tacs = Atomic_Tacs of {
     name : string, (* map to the node name *)
     tactic: string, (* actual ml code of the tactic *)
     args : Theory.Data.arg_typ
  }

 (* prover tactic : what about evaluation? should this be in the tactic or as args here? *)
 datatype T = PSGraph of {
      graph : Theory.Graph.T,
      graph_tactics : subgraph StrName.NTab.T, (* only name of parent *)
      atomic_tactics : atomic_tacs StrName.NTab.T,
      tactics : Prover.tactic StrName.NTab.T, (* atomic_tactics name -> tactic *)
      goaltype_data : Theory.Data.GoalTyp.data,
      parents: (StrName.NTab.name) StrName.NTab.T (* worth to keep it ? *)
  }
  
 exception tactic_exp of string

 fun update_top_graph f (PSGraph rep) = 
   PSGraph { graph = f (#graph rep), graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, tactics = #tactics rep,
             goaltype_data = #goaltype_data rep, parents = #parents rep}
 fun update_graph_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = f (#graph_tactics rep), 
             atomic_tactics = #atomic_tactics rep, tactics = #tactics rep,
             goaltype_data = #goaltype_data rep, parents = #parents rep}
 fun update_atomic_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = f (#atomic_tactics rep), tactics = #tactics rep,
             goaltype_data = #goaltype_data rep, parents = #parents rep}
 fun update_tactics f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, tactics = f (#tactics rep),
             goaltype_data = #goaltype_data rep, parents = #parents rep}
 fun update_goaltype_data f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, tactics = #tactics rep,
             goaltype_data = f (#goaltype_data rep), parents = #parents rep}
 fun update_parents f (PSGraph rep) = 
   PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
             atomic_tactics = #atomic_tactics rep, tactics = #tactics rep,
             goaltype_data = #goaltype_data rep, parents = f(#parents rep)}


 fun get_top_graph (PSGraph rep) = #graph rep;
 fun get_graph_tactics (PSGraph rep) = #graph_tactics rep;
 fun get_atomic_tactics (PSGraph rep) = #atomic_tactics rep;
 fun get_tactics (PSGraph rep) = #tactics rep;
 fun get_goaltype_data (PSGraph rep) = #goaltype_data rep;
 fun get_parents (PSGraph rep) = #parents rep;
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
 val set_tactics = update_tactics o K;
 val set_goaltype_data = update_goaltype_data o K;
 val set_parents = update_parents o K;
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
             tactics = StrName.NTab.empty,
             goaltype_data = Theory.Data.GoalTyp.default_data,
             parents = StrName.NTab.empty};

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

 fun combine ps1 _ = ps1; (* fixme *)
 
 fun merge_disjoint ps1 ps2 =      
  let 
    val graph_tactics' = StrName.NTab.merge_disjoint (get_graph_tactics ps1) (get_graph_tactics ps2)
    val atomic_tactics' = StrName.NTab.merge_disjoint (get_atomic_tactics ps1) (get_atomic_tactics ps2)
    val tactics' = StrName.NTab.merge_disjoint (get_tactics ps1) (get_tactics ps2)
    val parents' = StrName.NTab.merge_disjoint (get_parents ps1) (get_parents ps2)
  in
      PSGraph { graph = Theory.Graph.empty,
             graph_tactics = graph_tactics',
             atomic_tactics = atomic_tactics',
             tactics = tactics',
             goaltype_data =  Theory.Data.GoalTyp.default_data, 
(* fixme: should be able to merger data, a function needs to be added in the goaltyp interface*)
             parents = parents'}
   end

 fun load_atomics tacs ps = 
   fold
   (fn (str, tac) => update_tactics (StrName.NTab.doadd (str, tac)))
   tacs ps;

 fun arg_typ_to_json args = Json.Array (map (fn y => (Json.Array (map (fn x => Json.String x) y))) args)
 fun arg_typ_from_json (Json.Array args) = map (fn (Json.Array x) => map (fn y => case y of (Json.String str) => str) x) args 

 fun output_atomic_json (name, Atomic_Tacs atom) =
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
(* expect to out put as an eval field *)
 fun input_json (Json.Object object) = 
  let
    val in_graph = Theory_IO.in_json (JsonInputUtils.get object "graph")
    (*FIXME: all the remain field are dummy, just for now *)
    (*
    val in_cur = JsonInputUtils.get_string object "current"
    val in_cur_idx = JsonInputUtils.get_int object "current_index"
    ...
    *)
    val graph_tactics = 
      JsonInputUtils.get_array object "graph_tactics"
      |> map input_subgraph_json
      |> StrName.NTab.of_list
    val atomic_tactics = 
      JsonInputUtils.get_array object "atomic_tactics"
      |> map input_atomic_json
      |> StrName.NTab.of_list
    fun eval_tactic str = 
      case exec_tac_exp str 
        of SOME t => t
        | NONE => raise tactic_exp ("ERR: fail to eval " ^ str ^ " as a tactic." )
    val tactics = 
      StrName.NTab.list_of atomic_tactics
      |> map (fn (name, Atomic_Tacs{tactic,...}) => (name, eval_tactic tactic))
      |> StrName.NTab.of_list
  in
    of_graph in_graph
    |> set_graph_tactics graph_tactics
    |> set_atomic_tactics atomic_tactics
    |> set_tactics tactics
  end

 fun write_json_file path ps =  File_Io.write_string path (output_json ps |> Json.encode);

(* a hack to fix the problem in gui *)
 fun filter_empty_brk0 (x::xs) = 
  if x = #"(" then 
   case xs 
     of (y :: ys) => if y = #")" then (filter_empty_brk0 ys) else  x :: (filter_empty_brk0 xs)
     | [] =>  x :: (filter_empty_brk0 xs)
  else x :: (filter_empty_brk0 xs)
  |filter_empty_brk0 [] = []

 fun filter_empty_brk str = 
  String.explode str
  |> filter_empty_brk0
  |> String.implode;

 fun read_json_file path = 
  File_Io.read_string path 
  |> filter_empty_brk
  |> Json.of_string 
  |> input_json

 structure Sharing = 
 struct
  type T = T
  type subgraph = subgraph
  type atomic_tacs = atomic_tacs
  structure Theory = Theory.Sharing
 end
end
