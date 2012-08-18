local
 
val _ = Trm.drop_var_args_flag := false;
val thry = (theory "Main");
val gctxt = (Context.Theory thry);
val ctxt = (ProofContext.init thry);
val p = Prf.init ctxt;

val t = 
    Prf.read_top_term 
      p "(!! z. g z = f z) ==> (EX x. f x) ==> (EX y. g y)";
val (g,p) = p |> Prf.conj_term_at_top ("g", t);

(* backward proof method *)
val premeth_p = p;
val p = Prf.start_meth ["g"] p;
val (exi_name, p) = p |> Prf.insert_thm (PureThy.get_thm thry "exE");
val [(gs,p)] = Seq.list_of (Prf.apply_resol_bck exi_name "g" p);
val [(gs,p)] = Seq.list_of (Prf.apply_resol_bck "i" "exEd" p);
val (gs,p) = Prf.end_meth "exE" [] ["g"] p premeth_p;

val ((gs,p) :: L) = Seq.list_of (p |> Prf.apply_rule_thm (PureThy.get_thm thry "exI") "exEe");

(* change '=' assumption to '==' *)
val premeth_p = p;
val p = Prf.start_meth [] p;
val (eqr_nm, p) = p |> Prf.insert_thm (PureThy.get_thm thry "eq_reflection");
val asmstogoals = Goaln.NSet.list_of (Cx.get_lasms (Prf.get_ndname_cx p eqr_nm));
val fwdfromnm = "h";
val ((concnm,subgnms),p) = 
    p |> Prf.lift_and_show_above eqr_nm asmstogoals fwdfromnm;
val subgnm = hd subgnms;
val ((gs,p)::L) = Seq.list_of (Prf.apply_resol_bck fwdfromnm subgnm p);
val (sgs,p) = Prf.end_meth "fwd eq_reflection" [concnm] [] p premeth_p;

(* apply goal subst *)
val (r as ((n,nd),(cxn,cx))) = Prf.get_result p "exIb";
val z = Zipper.mktop (Prf.nd_get_trm nd);
val z2 = z |> Zipper.move_down_right; (* go under Trueprop *)

val (((newg,gs),p)::L) = 
    p |> Prf.apply_subst concnm "exIb" z2
      |> Seq.list_of;

val [(gs,p)] = 
  Seq.list_of (Prf.apply_resol_bck "exEf" "exIc" p);
val _ = Prf.print p;
in
val _ = writeln "Test Completed: test/prf_fwdmeth.ML";
end;
