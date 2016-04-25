 open_theory "hol";
 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
 val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
 val pspath = tinker_path ^ "src/dev/psgraph/";

 open_theory "z_library";
 set_pc "z_library";

(* definitions for gts in basic prove exists *)
 fun is_ex env pnode [] = 
  if is_%exists% (PPProver.get_pnode_concl pnode)
  then [env]
  else []
 |   is_ex _ _ _ = [];

 fun is_paired_ex env pnode [] = 
  let val trm = PPProver.get_pnode_concl pnode 
  val (tm1,tm2) = dest_app trm in
   if (fst(dest_const tm1) = "¶" andalso (not(is_simple_Ì tm2)))
   then [env]
   else [] end
 |   is_paired_ex _ _ _ = [];

 fun has_redundant_ex env pnode [] = 
  let val (exs,bdy) = strip_simple_¶ (PPProver.get_pnode_concl pnode);
  val bdy_frees = frees bdy;
  fun aux [] = false
    | aux (x :: rest) = (
       (present (op =$) x rest) orelse not(present (op =$) x bdy_frees)
	orelse aux rest) in
   if aux exs then [env] else [] end
   | has_redundant_ex _ _ _ = [];

 fun is_ex_or env pnode [] = 
  let val trm = PPProver.get_pnode_concl pnode in
  (simple_%exists%_%or%_conv trm ; [env])
   handle _ => [] end
 |   is_ex_or _ _ _ =[];

 val data = 
  default_gt_data
  |> ClauseGoalTyp.add_atomic "is_ex" is_ex
  |> ClauseGoalTyp.add_atomic "is_paired_ex" is_paired_ex
  |> ClauseGoalTyp.add_atomic "has_redundant_ex" has_redundant_ex
  |> ClauseGoalTyp.add_atomic "is_ex_or" is_ex_or
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "top_concl(Z) :- top_symbol(concl,Z).") @ x)
;

(*  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c(Z) :- top_symbol(concl,Z).") @ x) *)

val g : GOAL= ([],¬¶ (x,y) · (x:î) = (1:î)®);
val g1 : GOAL= ([],¬¶ x y · (x:î) = (1:î)®);

 val ps = PSGraph.read_json_file NONE (pspath ^"basic_prove_exists_tac.psgraph") |>   PSGraph.set_goaltype_data data; 

 PPIntf.set_psg_goal (SOME g) (SOME ps);
 TextSocket.safe_close();

some experiments
===============================
data;
ClauseGoalTyp.type_check data pnode ("is_paired_ex",[]);
val (pnode,pplan) = 
let val tgt = g1 ; val (h, c) = ((fst tgt), (snd tgt)) in
PPProver.init PPProver.default_ctxt h c end;

val all_¶_uncurry_conv : CONV = (fn tm =>
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



===============
(* a pp implementation *)
REPEAT;
TRY;
THEN;
val strip_± = ±_tac;
val all_µ_uncurry = conv_tac all_µ_uncurry_conv;
val redundant_simple_µ = conv_tac redundant_simple_µ_conv;
simple_µ_±_conv;
simple_µ_tac;
val all_¶_uncurry = conv_tac all_¶_uncurry_conv;
val redundant_simple_¶ = conv_tac redundant_simple_¶_conv;
simple_µ_±_conv;
simple_µ_tac;

val demo_tac = REPEAT (CHANGED ((REPEAT ±_tac) THEN (TRY ´_tac)));
set_goal ([], ¬(B´(A±D±(FF´E))) ± B ± C ®);
a demo_tac;

´_tac;
all_µ_uncurry_conv;
drop_main_goal();


OR_T;

(REPEAT (CHANGED
(REPEAT strip_±) THEN 
(TRY (all_¶_uncurry ORELSE redundant_simple_¶ ORELSE
      simple_¶_equation ORELSE simple_¶_±)) THEN 
(TRY (all_µ_uncurry ORELSE redundant_simple_µ ORELSE
      simple_µ_± ORELSE simple_µ_tac))))
