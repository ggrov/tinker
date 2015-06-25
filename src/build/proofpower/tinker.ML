  val root_path = OS.FileSys.getDir();
  val build_path = root_path ^ "/psgraph/src/provers/proofpower/build";
  OS.FileSys.chDir build_path;

  use "load_psgraph";
  use "build_simple_GT.ML"; 
 (* use "build_clause_GT.ML"; *)
  
(* enable the subgoal package printing 
  set_flags [
  ("subgoal_package_quiet", false), (* enable xpp output *)
  ("output_in_utf8", false), 
  ("input_in_utf8", false)];(* disable uftp-8 encoding for GUI *)
*)
  new_pc "supergraph";
  set_pc "supergraph";
