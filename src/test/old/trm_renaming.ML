
val thry = theory "Main";
val ctxt = (ProofContext.set_mode ProofContext.mode_schematic 
                                    (ProofContext.init thry));
val read = Syntax.read_prop ctxt;
val t1 = read "f (?a :: ?'a) (?b :: ?'a) ?c";
val t2 = read "f (?a :: ?'a => ?'b) (?b :: ?'a) ?c";

val ienv1 = InstEnv.of_trm thry t1;
InstEnv.print ienv1;
val renaming0 = InstEnv.init_renaming ienv1;
val (renaming2,t3) = InstEnv.rename_trm_vars renaming0 t2;

val inst2 = InstEnv.inst_of_renaming renaming2;
InstEnv.print inst2;
val avoid2 = InstEnv.avoid_of_renaming renaming2;
InstEnv.print avoid2;

Trm.print ctxt (InstEnv.inst_trm inst2 t2);
Trm.print ctxt (t3);
Trm.print ctxt (t2);

if (InstEnv.inst_trm inst2 t2) <> t3 then 
  raise ERROR "test/trm_rename.ML: renaming and instantiation of renaming ienv do not commute!"
else true;

(* 

val (_ $ (F $ V)) = t2;
val Free (_, F_ty) = F;

raise ERROR "stop";

InstEnv.rename_typ_tvars renaming0 F_ty;

DB_InstEnv.tvar_is_ignored_by_renaming



*)
