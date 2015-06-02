val cur_path = OS.FileSys.getDir();
OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");

use "PRELOAD";
use (cur_path ^ "/psgraph/src/provers/proofpower/build/test_install");
