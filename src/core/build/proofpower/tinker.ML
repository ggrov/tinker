(* define your own root path here ! *)
  val cur_path = OS.FileSys.getDir();
  val tinkerhome = cur_path ^ "/psgraph"; 
  val root_path = OS.FileSys.getDir();
  val build_path = tinkerhome ^ "/src/core/build/proofpower";
  OS.FileSys.chDir build_path;
(* load lib *)
  use "lib/load_lib.ML";
  use "lib/load_psgraph.ML";
