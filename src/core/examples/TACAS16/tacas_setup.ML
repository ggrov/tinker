 open_theory "hol";
 use (tinkerhome ^ "/src/core/build/proofpower/tinker");
 val tinker_path = tinkerhome  ^ "/src/core/examples/TACAS16/";
 val pspath = tinker_path;
 open_theory "z_library";
 set_pc "z_library";
 use_file (tinkerhome ^ "/src/core/examples/TACAS16/imp058.sml");


(* the defnition of the pp version 
val simple_quantifier_tac_pp = (REPEAT(CHANGED ((REPEAT strip_±) THEN (TRY (all_¶_uncurry ORELSE redundant_simple_¶ ORELSE simple_¶_equation ORELSE simple_¶_±)) THEN (TRY (all_µ_uncurry ORELSE redundant_simple_µ ORELSE simple_µ_± ORELSE simple_µ_tac)))));
*)

(* definitions for gts in basic prove exists *)
 fun is_ex env pnode [] = 
  if is_%exists% (PPProver.get_pnode_concl pnode)
  then [env]
  else []
 |   is_ex _ _ _ = [];

 fun is_conj env pnode [] = 
  if is_%and% (PPProver.get_pnode_concl pnode)
  then [env]
  else []
 |   is_conj _ _ _ = [];

 fun is_not_conj env pnode [] = 
  if is_%and% (PPProver.get_pnode_concl pnode) |> not
  then [env]
  else []
 |   is_not_conj _ _ _ = [];

 fun is_forall env pnode [] = 
  if is_%forall% (PPProver.get_pnode_concl pnode)
  then [env]
  else []
 |   is_forall _ _ _ = [];

 fun is_not_forall env pnode [] = 
  if is_%forall% (PPProver.get_pnode_concl pnode) |> not
  then [env]
  else []
 |   is_not_forall _ _ _ = [];

 fun is_paired_ex env pnode [] = 
  let val trm = PPProver.get_pnode_concl pnode 
  val (tm1,tm2) = dest_app trm in
   if (fst(dest_const tm1) = "¶" andalso (not(is_simple_Ì tm2)))
   then [env]
   else [] end
 |   is_paired_ex _ _ _ = [];

 fun is_paired_forall env pnode [] = 
  let val trm = PPProver.get_pnode_concl pnode 
  val (tm1,tm2) = dest_app trm in
   if (fst(dest_const tm1) = "µ" andalso (not(is_simple_Ì tm2)))
   then [env]
   else [] end
 |   is_paired_forall _ _ _ = [];

 fun has_redundant_ex env pnode [] = 
  let val (exs,bdy) = strip_simple_¶ (PPProver.get_pnode_concl pnode);
  val bdy_frees = frees bdy;
  fun aux [] = false
    | aux (x :: rest) = (
       (present (op =$) x rest) orelse not(present (op =$) x bdy_frees)
	orelse aux rest) in
   if aux exs then [env] else [] end
   | has_redundant_ex _ _ _ = [];

 fun has_redundant_forall env pnode [] = 
  let val (exs,bdy) = strip_simple_µ (PPProver.get_pnode_concl pnode);
  val bdy_frees = frees bdy;
  fun aux [] = false
    | aux (x :: rest) = (
       (present (op =$) x rest) orelse not(present (op =$) x bdy_frees)
	orelse aux rest) in
   if aux exs then [env] else [] end
   | has_redundant_forall _ _ _ = [];

 fun is_ex_conj env pnode [] = 
  let val trm = PPProver.get_pnode_concl pnode in
  (simple_¶_±_conv trm ; [env])
   handle _ => [] end
 |   is_ex_conj _ _ _ =[];

 fun is_forall_conj env pnode [] = 
  let val trm = PPProver.get_pnode_concl pnode in
  (µ_±_conv trm ; [env])
   handle _ => [] end
 |   is_forall_conj _ _ _ =[];

 fun has_one_point_struct env pnode [] = 
  let val trm = PPProver.get_pnode_concl pnode in
  (simple_¶_equation_conv trm ; [env])
   handle _ => [] end
 |   has_one_point_struct _ _ _ =[];

 fun pred_cl res = case res of [] => false | _ => true;
 fun is_simp_ex env pnode [] = 
  if (is_ex env pnode [] |> pred_cl)
  then (
   if is_paired_ex env pnode [] |> pred_cl orelse
      has_redundant_ex env pnode [] |> pred_cl orelse
      has_one_point_struct env pnode [] |> pred_cl orelse
      is_ex_conj env pnode [] |> pred_cl 
   then [env]
   else [])
  else []
 |   is_simp_ex _ _ _ = [];
 
  fun forall_others env pnode [] = 
   if (is_forall env pnode []) |> pred_cl
   then(
    map (fn f => f env pnode [])
     [is_paired_forall , has_redundant_forall, is_forall_conj]
    |> List.filter (fn x => (pred_cl) x)
    |> (fn x => case x of [] => [env] | _ => []) 
   )
   else []
  |   forall_others _ _ _ = [];

  fun is_conj_or_simpl_ex_or_forall env pnode [] =
   if (is_conj env pnode [] |> pred_cl orelse 
       is_simp_ex env pnode [] |> pred_cl orelse
       pred_cl(is_forall env pnode [])) 
   then [env]
   else [] 
  |   is_conj_or_simpl_ex_or_forall _ _ _ = [];

  fun is_not_conj_or_simpl_ex_or_forall env pnode [] = 
   (case is_conj_or_simpl_ex_or_forall env pnode []
     of [] => [env] | _ => [])
  |   is_not_conj_or_simpl_ex_or_forall _ _ _ = [];

 val data = 
  default_gt_data
  |> ClauseGoalTyp.add_atomic "is_ex" is_ex
  |> ClauseGoalTyp.add_atomic "is_conj" is_conj
  |> ClauseGoalTyp.add_atomic "is_not_conj" is_not_conj
  |> ClauseGoalTyp.add_atomic "is_forall" is_forall
  |> ClauseGoalTyp.add_atomic "is_not_forall" is_not_forall
  |> ClauseGoalTyp.add_atomic "is_paired_ex" is_paired_ex
  |> ClauseGoalTyp.add_atomic "is_paired_forall" is_paired_forall
  |> ClauseGoalTyp.add_atomic "has_redundant_ex" has_redundant_ex
  |> ClauseGoalTyp.add_atomic "has_redundant_forall" has_redundant_forall
  |> ClauseGoalTyp.add_atomic "is_ex_conj" is_ex_conj
  |> ClauseGoalTyp.add_atomic "is_forall_conj" is_forall_conj
  |> ClauseGoalTyp.add_atomic "has_one_point_struct" has_one_point_struct
  |> ClauseGoalTyp.add_atomic "is_simp_ex" is_simp_ex
  |> ClauseGoalTyp.add_atomic "forall_others" forall_others
  |> ClauseGoalTyp.add_atomic "is_conj_or_simpl_ex_or_forall" is_conj_or_simpl_ex_or_forall
  |> ClauseGoalTyp.add_atomic "is_not_conj_or_simpl_ex_or_forall" is_not_conj_or_simpl_ex_or_forall;

open PPIntf;
