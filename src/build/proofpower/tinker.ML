  val cur_path = OS.FileSys.getDir();
  OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");
  
  use "build_psgraph.ML";
  
