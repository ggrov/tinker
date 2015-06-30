  val root_path = OS.FileSys.getDir();
  val build_path = root_path ^ "/psgraph/src/core/provers/proofpower/build";
  val supergraph_path = root_path ^ "/experiment/supergraph/";
  OS.FileSys.chDir build_path;

  use "load_psgraph";
 (* use "build_clause_GT.ML"; *)
  use "build_simple_GT.ML"; 

  use_file (supergraph_path ^ "open_struct/open_struct.ML");
  use_file (supergraph_path ^ "supergraph.ML"); 
  use_file (supergraph_path ^ "simpleGT_supergraph.ML"); 

(* enable the subgoal package printing 
  set_flags [
  ("subgoal_package_quiet", false), (* enable xpp output *)
  ("output_in_utf8", false), 
  ("input_in_utf8", false)];(* disable uftp-8 encoding for GUI *)
*)
  open_theory "CLTSpec_Common";
  new_theory "supergraph";

