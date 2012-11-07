theory tac_test 
imports
  "../build/Eval"        
begin


find_theorems "\<Sum> _"

value "\<Sum> {1::nat,2::nat}"

lemma "Sigma ({(x::nat). x < 10}) < (100::nat)"

ML{*
 Option.isSome o Seq.pull;
 fun mk_goal ctxt thm =
  let 
    val goal = PNode.mk_goal ("g") ctxt ctxt thm;
    val prf = PPlan.init_prf |> PPlan.add_root goal 
  in
    PPlan.apply_prf prf goal thm
  end;

 (* should strategy be a function on theory? *)
 fun apply_strat strat ctxt thm =
   mk_goal ctxt thm
  |> snd
  |> (fn t => PPExpThm.export_name t "g")
  |> PPExpThm.prj_thm 
  |> Seq.single;

fun dummy_tac thm = 
  mk_goal @{context} thm
  |> snd
  |> (fn t => PPExpThm.export_name t "g")
  |> PPExpThm.prj_thm 
  |> Seq.single
*}

lemma "A ==> A"
 apply (tactic "dummy_tac")
 oops

end;


