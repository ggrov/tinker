header {* IsaPlanner Rippling Notation *}

theory RippleNotation
imports Pure
begin

section {* Rippling Notation *}

consts wfO :: "'a \<Rightarrow> 'a"
consts wfI :: "'a \<Rightarrow> 'a"
consts Sink :: "'a \<Rightarrow> 'a"
consts wfR :: "'a \<Rightarrow> 'a \<Rightarrow> 'a"

term "f (wfO Suc b) b == f (wfO Suc a) b"
term "(r (wfR a b) c)";

(* possible infix notation... tends to clash with other theories 
("[< _ >]")
("[> _ <]")
("'\ _ '/")
("[R _ _ ]")
*)

end;
