use (OS.FileSys.getDir() ^ "/psgraph/src/dev/JFR/fef_setup.ML");

(*=====  quick test *)
(* test if the fef theory is loaded *)
map get_spec [¨ElemsÆ, ¨OK_VCâdÆ];

(*===== tac1 *)
val ps_tac1 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac1.psgraph");

(* a qucik test of psgraph version of tac1 *)
PPIntf.set_psg_goal (SOME ([], ¨(A %implies% C)Æ)) (SOME ps_tac1);
(* a qucik test of applying a psgraph to the top goal *)
set_goal([], ¨((A %implies% B) %and% (B %implies% B))Æ);
a step_strip_tac;
top_goals();
PPIntf.apply_psg ps_tac1;
top_goals();

drop_main_goal();

(* For Rob: to run the real example: *)
(** step 1: setup goal, e.g. set_goal([], ¨(A %implies% C)Æ); *)

(** step 2: apply proof steps until tac1 is needed, then get the goal *)
val g = top_goal();
(** step 3: apply psgraph_tac1 to the goal *)
PPIntf.set_psg_goal (SOME g) (SOME ps_tac1);

(*===== tac2 *)
val ps_tac2 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac2.psgraph");

(* a qucik test of psgraph version of tac1 *)
PPIntf.set_psg_goal (SOME ([], ¨(A %implies% C)Æ)) (SOME ps_tac2);


(*===== tac3 *)
val ps_tac3 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac3.psgraph");

(* a qucik test of psgraph version of tac1 *)
PPIntf.set_psg_goal (SOME ([], ¨(≥ Snd (te tlâ0 rlâ0 râ0) = Snd (Fst x tlâ0 rlâ0 râ0) %implies% te ç OK_VCâd c %implies% C)Æ)) (SOME ps_tac3);


(*===== tac4 *)
val ps_tac4 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac4.psgraph");

(* a qucik test of psgraph version of tac1 *)
PPIntf.set_psg_goal (SOME ([], ¨(CaseVal c te cel ee ç OK_VCâd c %implies% C)Æ)) (SOME ps_tac4);



(*=== command to end the session *)
  TextSocket.safe_close();


top_goals();
List.foldr;
member;