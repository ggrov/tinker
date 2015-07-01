(* Setup tinker for proofpower *)
 use ( OS.FileSys.getDir() ^ "/psgraph/src/core/demo/AdvisoryBoardMeeting2015/setup_proofpower");

(* Load the proof strategy *)
  val ps = PSGraph.read_json_file (path ^"demo.psgraph");
(* Proofs *)
  PPIntf.set_psg_goal ([¬B : BOOL®], ¬A ´ (A ± B ± (C ´ C))®) ps;

  TextSocket.safe_close();