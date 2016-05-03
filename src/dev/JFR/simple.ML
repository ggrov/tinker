open_theory "hol";
use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";

val pspath = tinker_path ^ "src/dev/JFR/psgraph/";

val simple = PSGraph.read_json_file (SOME default_gt_data) (pspath^"simple.psgraph");

set_goal([], ¨x ç {x;y} ± 2 +3 < 2*3Æ);
PPIntf.apply_ps simple;
drop_main_goal();

 TextSocket.safe_close();

;
;