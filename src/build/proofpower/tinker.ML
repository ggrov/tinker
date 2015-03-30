  val cur_path = OS.FileSys.getDir();
  OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");
  
(* use "build_simple_GT.ML"; *)
  use "build_clause_GT.ML";