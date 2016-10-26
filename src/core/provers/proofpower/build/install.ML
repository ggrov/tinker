val cur_path = OS.FileSys.getDir();
OS.FileSys.chDir (cur_path ^ "/psgraph/src/core/provers/proofpower/build");
OS.FileSys.chDir (cur_path ^ "/../GIT/tinker/src/core/provers/proofpower/build");

use "PRELOAD";
use (cur_path ^ "/psgraph/src/core/provers/proofpower/build/test_install");
