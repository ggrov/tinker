theory tac_test 
imports
  "../build/Eval"        
begin

ML{*
 fun mk_goal ctxt thm =
  let 
    val goal = PNode.mk_goal ("g") ctxt ctxt thm;
    val prf = PPlan.init_prf |> PPlan.add_root goal 
  in
    PPlan.apply_prf prf goal thm
  end;

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


