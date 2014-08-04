theory test
imports
  "../../build/isabelle/BasicGoalTyp"
  (* "../../build/isabelle/Eval"
  "../../provers/isabelle/basic/build/BIsaMeth"
  *)
begin

ML{*
 datatype Args = Name of string 
                | Var of string
                | Concl
                | Hyps
                | Term of string (* fix me: should we make this term? *)
                | Clause of string * (Args list)
*}

ML{*
   type pnode = { pname : string, pctxt : Proof.context, ptrm : Term.term } 
    (* could also hold the thm? *)
  type pplan = { goal : Thm.thm, opengs : pnode list, usedgs : StrName.NSet.T }
  datatype gnode = GNode of 
     { name : string,
       env : Term.term StrName.NTab.T
     }

  type args = string list
*}

ML{*
  type atomic = args -> pnode * pplan ->  gnode -> gnode list 
*}



(*
  top_symbol(Concl,X) := case lookup(X) of  get_top(Concl)
  top_symbol(X) :- top_symbol(Concl,X).
*)

  

end
