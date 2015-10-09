 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
 val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
 val pspath = tinker_path ^ "src/dev/psgraph/";

 open_theory "hol";
 set_pc "hol";

(* definitions for gts in basic prove exists *)
 fun is_pair_in_exists env pnode _ = 
  let val _ = PPProver.get_pnode_concl pnode in [env]
 handle Fail _ => [] end;


 val data = 
  default_gt_data
  |> ClauseGoalTyp.add_atomic "is_pair_in_exists" is_pair_in_exists
;
(*  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c(Z) :- top_symbol(concl,Z).") @ x) *)


 val ps = PSGraph.read_json_file (pspath ^"basic_prove_exists_tac.psgraph") |>   PSGraph.set_goaltype_data data; 

 PPIntf.set_psg_goal (SOME g) (SOME ps);

if snd(dest_¤(concl s1)) =$ mk_t
	then accept_tac (¤_t_elim s1) 

mk_t;

dest_¤;
accept_tac;
¤_t_elim;

val g : GOAL= ([],¬¶ (x,y) · (x:î) = (1:î)®);
val g : GOAL= ([],¬¶ x · (x:î) = (1:î)®);
set_goal g;
(dest_app o snd o top_goal)();
a (conv_tac basic_prove_¶_conv);

undo 1;(
all_¶_uncurry_conv;

all_¶_uncurry_conv : CONV = (fn tm =>
let fun aux tm' = (
	let val (tm1,tm2) = dest_app tm';
	in
	(if fst(dest_const tm1) = "¶"
	then (if is_simple_Ì tm2
		then SIMPLE_BINDER_C aux
		else (BINDER_C aux AND_OR_C ¶_uncurry_conv)
	) else fail_conv) tm'
	end);
in
	aux tm
end