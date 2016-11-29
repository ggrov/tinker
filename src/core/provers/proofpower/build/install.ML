val cur_path = OS.FileSys.getDir();
val tinkerhome = cur_path ^ "/psgraph"; (* cur_path ^ /../GIT/tinker/ *)
OS.FileSys.chDir (tinkerhome ^ "src/core/provers/proofpower/build");
OS.FileSys.chDir (tinkerhome ^ "/src/core/provers/proofpower/build");

use "PRELOAD";
use (tinkerhome ^ "/src/core/provers/proofpower/build/test_install");
