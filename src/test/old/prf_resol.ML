local 

val _ = Trm.drop_var_args_flag := false;
val thry = (theory "Main");
val gctxt = (Context.Theory thry);
val ctxt = (ProofContext.init thry);

val p = Prf.init ctxt;
(* val t = Prf.read_top_term 
          p "!! x. ((!! x. R x x) ==> (!! x y. R x y ==> Q x y y) ==> (!!y. Q x (?z x) y ==> P x y (?z x)) ==> P x (?z x) (?w x))";
*)

val t = Prf.read_top_term 
          p "!! x. ((!! x. R x x) ==> (!! x y. R x y ==> Q x y y) ==> (!!y. Q x (?z x) y ==> P x y (?z x)) ==> P x (?z x) (?w x))";
val _ = Trm.print ctxt t;

val p = Prf.init ctxt;
val t =  
    Prf.read_top_term 
      p "!! x. ((!! y. R y y) ==> (!! z y. R z y ==> Q z y y) ==> (!!y. Q x (?v x) y ==> P x y (?v x)) ==> P x (?v x) (?v2 x))";
val _ = Trm.print ctxt t;

val (g,p) = p |> Prf.conj_term_at_top ("g",t);
val (nnd,(cxn,cx)) = Prf.get_result p "j";
val _ = Cx.print cx;
val _ = Prf.print_script p;
val [([g2],p2)] = Seq.list_of (Prf.apply_resol_bck "k" "g" p);
(* PolyML.exception_trace (fn () =>  Seq.list_of (Prf.apply_resol_bck "k" "g" p)  ); *)
val _ = Prf.print_script p2;
val [([g2],p2)] = Seq.list_of (Prf.apply_resol_bck "i" "m" p2);
val _ = Prf.print_script p2;
val [([],p2)] = Seq.list_of (Prf.apply_resol_bck "h" "n" p2);
val _ = Prf.print_script p2;
in 
val _ = writeln "Test Completed: test/prf_resol.ML";
end;
(* 
open DB_APrf;

val r_name = "k";
val goal_name = "l";

Prf.print_full_node p "g";
Prf.print_full_node p "h";
Prf.print_full_node p "i";
Prf.print_full_node p "j";
*)
