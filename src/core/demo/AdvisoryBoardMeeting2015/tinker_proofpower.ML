(* Setup tinker for proofpower *)
 use ( OS.FileSys.getDir() ^ "/psgraph/src/core/demo/AdvisoryBoardMeeting2015/setup_proofpower");

(* Load the proof strategy *)
  val ps = PSGraph.read_json_file (path ^"demo_pp.psgraph");


 fun to_prover_json (Json.String s) = Theory.Data.GoalTyp.Prover.encoding_to_prover s |> Json.String
 | to_prover_json (Json.Array arr) = map to_prover_json arr |> Json.Array
 | to_prover_json (Json.Object obj) = 
    Json.fold (fn (n,j) => Json.update (n, to_prover_json j)) obj Json.empty_obj
    |> Json.Object
 | to_prover_json x = x
;
val (Json.Object object) = File_Io.read_string  (path ^"demo_pp.psgraph")
  |> Theory.Data.GoalTyp.Prover.encoding_from_gui
  |> Json.of_string 
  |> to_prover_json;

open PSGraph;

fun input_json (Json.Object object) = 
  let
(* having problem here *)
    val graph_tactics = 
      JsonInputUtils.get_array object "graphs"
      |> map input_subgraph_json;
      |> StrName.NTab.of_list;

    val atomic_tactics = 
      JsonInputUtils.get_array object "atomic_tactics"
      |> filter is_atom_tac(* filter out the ENV tac *)
      |> map input_atomic_json
      |> StrName.NTab.of_list
;
    val env_tactics = 
      JsonInputUtils.get_array object "atomic_tactics"
      |> filter (not o is_atom_tac)(* filter out the ENV tac *)
      |> map input_env_json
      |> StrName.NTab.of_list
    val occurs = Json.get object "occurrences" |> input_occurs_json

    val main = JsonInputUtils.get_string object "main" 
  in
    default_psgraph
    |> set_graph_tactics graph_tactics
    |> set_atomic_tactics atomic_tactics
    |> set_env_tactics env_tactics
    |> set_occurs occurs
    |> set_main main
    (* |> set_tactics tactics*)
  end

(* Proofs *)
  PPIntf.set_psg_goal (SOME ([¬B : BOOL®], ¬A ´ (A ± B ± (C ´ C))®)) (SOME ps);
  PPIntf.set_psg_goal (SOME ([¬B : BOOL®], ¬A ´ (A ± B ± (C ´ C))®)) NONE;
  TextSocket.safe_close();
