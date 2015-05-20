  val cur_path = OS.FileSys.getDir();
  OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");
  
(* use "build_simple_GT.ML"; *)
  use "build_clause_GT.ML";
  
(* enable the subgoal package printing *)
  set_flags [
  ("subgoal_package_quiet", false), (* enable xpp output *)
  ("output_in_utf8", false), 
  ("input_in_utf8", false)];(* disable uftp-8 encoding for GUI *)

  new_pc "zed_psgraph";
  set_pc "zed_psgraph";
