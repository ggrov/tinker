(* simple test of proof representation *)
theory demo1                                           
imports demodefs   
begin


  lemma "rev (l1 @ l2) = rev l2 @ rev l1"
    apply (ipsgraph induct_ripple) 
    (* apply (ipsgraph induct_ripple)  *)
  oops




end



