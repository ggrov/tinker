local 
val _ = Trm.drop_var_args_flag := false;
val thry = (theory "Main");
val gctxt = (Context.Theory thry);
val ctxt = (ProofContext.init thry);

val p = Prf.init ctxt;
val t = 
    Prf.read_top_term 
      p "(!! z. g z = f z) ==> (EX x. f x) ==> (EX y. g y)";
val (g,p) = p |> Prf.conj_term_at_top ("g",t);

(* backward proof method *)
val premeth_p = p;
val p = Prf.start_meth ["g"] p;
val (exi_name, p) = p |> Prf.insert_thm (PureThy.get_thm thry "exE");
val [(gs,p)] = Seq.list_of (Prf.apply_resol_bck exi_name "g" p);
val [(gs,p)] = Seq.list_of (Prf.apply_resol_bck "i" "exEd" p);
val (gs,p) = Prf.end_meth ("exE with:" ^ "i") [] ["g"] p premeth_p;

val ((gs,p) :: L) = Seq.list_of (p |> Prf.apply_rule_thm (PureThy.get_thm thry "exI") "exEe");
(*  or more verbose version...
val exI_dtac = IsaDTac.Rule.rule_th (thm "exI");
val ((gs,p) :: L) = Seq.list_of (p |> Prf.apply_dtac exI_dtac "exEe");
*)

val atomise_eq = PureThy.get_thm thry "HOL.atomize_eq";
val symmetric = PureThy.get_thm thry "Pure.symmetric";
val unatomise_eq = 
    Thm.put_name "unatomise"
                  (Drule.zero_var_indexes (atomise_eq RS symmetric));

val (unatomise, p) = p |> Prf.insert_thm unatomise_eq;

val _ = Prf.get_result p unatomise;

(* result and zipper *)
val (r as ((n,nd),(cxn,cx))) = Prf.get_result p "h";
val z = Zipper.mktop (Prf.nd_get_trm nd);
(* apply fwd subst at zipper *)
val (((newi,gs),p)::L) = 
    p |> Prf.apply_subst unatomise "h" z 
      |> Seq.list_of;

(* enter: Prf.apply_subst_fwd
val p = Prf.get_aprf p;
val eq_name = unatomise;
val f_name = "h";
val f_r = Prf.get_result p g_name;
open DB_APrf;

val [(ienv)] = Seq.list_of unifs;
val ((g_name,g_nd),g_ncx as (g_cxn,g_cx)) = f_r;
val r_name = eq_name;
*)

(* apply goal subst *)
val (r as ((n,nd),(cxn,cx))) = Prf.get_result p "exIb";
val z = Zipper.mktop (Prf.nd_get_trm nd);
val z2 = z |> Zipper.move_down_right; (* go under Trueprop *)

val (((newg,gs),p)::L) = 
    p |> Prf.apply_subst newi "exIb" z2
      |> Seq.list_of;

val [(gs,p)] = 
  Seq.list_of (Prf.apply_resol_bck "exEf" "exIc" p);

val _ = Prf.print p;

in 
val _ = writeln "Test Completed: test/subst.ML";
end;
