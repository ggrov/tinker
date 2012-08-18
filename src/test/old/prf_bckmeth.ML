local 

val _ = Trm.drop_var_args_flag := false;
val thry = (theory "Main");
val gctxt = (Context.Theory thry);
val ctxt = (ProofContext.init thry);
val p = Prf.init ctxt;

val t = 
    Prf.read_top_term 
      p "(!! z. g z = f z) ==> (EX x. f x) ==> (ALL y. f y)==> (EX y. g y)";
val (g,p) = p |> Prf.conj_term_at_top ("g", t);

val [(gs,p)] = 
  Seq.list_of (Prf.apply_erule_thm (PureThy.get_thm thry "exE") "i" "g" p);
val _ = Prf.print p;

in
val _ = writeln "Test Completed: test/prf_bckmeth.ML";
end;

(* 

val p = Prf.init (the_context());
val t = 
    Prf.read_top_term 
      p "((!! z. g z = f z) ==> (EX x. f x)) ==> (ALL y. f y) ==> (EX y. g y)";
val (g,p) = p |> Prf.conj_top_term "g" t;

Prf.get_ndname_ctrm p "h";
Prf.get_ndname_ltrm p "h";
Prf.get_ndname_ftrm p "h";
Trm.print (Prf.get_theory p) (Prf.get_ndname_ltrm p "i");
Trm.print (Prf.get_theory p) (Prf.get_ndname_ltrm p "h");
Trm.print (Prf.get_theory p) (Prf.get_ndname_ltrm p "j");

Prf.get_ndname_lasm_ntrms p "h";

*)
(* backward proof method *)
(* above is abbreviations for: 
val premeth_p = p;
val p = Prf.prep_bck_subprf "g" p;
val (exi_name, p) = p |> Prf.insert_thm (PureThy.get_thm thry  "exE");

val [(gs,p)] = 
  Seq.list_of (Prf.apply_resol_bck exi_name "g" p);

val [(gs,p)] = 
  Seq.list_of (Prf.apply_resol_bck "h" "exEd" p);
val p2 = p;
val (gs,p) = Prf.apply_bck_meth "g" ("exE",(K p)) premeth_p;

Prf.print_open p;
p2;
premeth_p;
p;

*)
