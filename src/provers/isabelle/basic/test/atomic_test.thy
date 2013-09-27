(* simple test of proof representation *)
theory atomic_test                                           
imports       
  "../build/BIsaP"   
begin

 ML_file "../isa_atomic.ML" 

ML{*
open BIsaAtomic_DB;
*}

ML{*
val (g,p) = init  @{context} @{prop "\<forall> A B. A \<longrightarrow> (B \<and> A) \<longrightarrow> B \<and> A"};
*}

ML{*
val ([g0],p0) = apply_rule "test" @{thm "allI"} (g,p) |> Seq.list_of |> hd;
*}

ML{*
val ([g01],p01) = apply_rule "test" @{thm "allI"} (g0,p0) |> Seq.list_of |> hd;
*}

ML{*
val ([g1],p1) = apply_rule "test" @{thm "impI"} (g01,p01) |> Seq.list_of |> hd;
*}
ML{*
val ([g2],p2) = apply_rule "test" @{thm "impI"} (g1,p1) |> Seq.list_of |> hd;
*}
ML{*
val ([g3,g4],p3) = apply_rule "test" @{thm "conjI"} (g2,p2) |> Seq.list_of |> hd;
*}
ML{*
val ([],p4) = apply_tactic () () (K atac) (g4,p3) |> Seq.list_of |> hd;
*}

ML{*
val ([g5],p5)  = apply_frule ("n",@{thm "conjunct1"}) ("n",@{thm "conjunct1"}) (g3,p4)
 |> Seq.list_of |> hd; 
*}

ML{*
val ([],p6) = apply_tactic () () (K atac) (g5,p5) |> Seq.list_of |> hd; 
*}

(* goal type test *)
ML{*
val gt1 = "has_symbol (HOL.All,HOL.conj,all)";
SimpleGoalTyp.init_lift gt1 g0;
val (SOME gn) = SimpleGoalTyp.init_lift SimpleGoalTyp.default g2
*}


(* partition test *)
ML{*
val (x:SimpleGoalTyp.gnode list) = [];
EVal.EAtom.partition [g1,g4] "g" [SimpleGoalTyp.default,"","has_symbol(HOL.conj)"];
*}

       
end



