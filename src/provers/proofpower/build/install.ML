val cur_path = OS.FileSys.getDir();
OS.FileSys.chDir (cur_path ^ "/psgraph/src/provers/proofpower/build");

use "PRELOAD";
use "test_install";
save_and_exit 0;