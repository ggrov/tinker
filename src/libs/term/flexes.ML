signature FLEXES
= sig

type T = (Trm.T * Trm.T) list;

(* all these function make the final goal protected *)
val mk_triv_ff_protected_thm :
    Context.theory -> T -> Trm.T -> Thm.thm 

val mk_ff_explicit_in_thm : Thm.thm -> Thm.thm

val inst_flexes : InstEnv.T -> T -> T

val of_thm : Thm.thm -> T

end;


structure DB_Flexes
= struct

type T = (Trm.T * Trm.T) list;

(* within the context of the vars, add the flexes fs to the theorem thm 
Given 
flexes: [(?a =?= ?y), ...] 
t: P
results in theorem 
P ==> P [(?a =?= ?y), ...] 

the vtab is needed to avoid variable name capture efficiently - rather
than building the variable table from the term and flexes.
*)
fun mk_triv_ff_protected_thm thry ffs t = 
    let 
      val ctermify = Thm.cterm_of thry;
      val th = Drule.protectI RS (Thm.trivial (ctermify (Logic.protect t)))
    in
      fold ((fn th => Drule.reflexive_thm RS th) 
            oo Thm.implies_intr o ctermify o Logic.mk_equals) 
           ffs th
    end;

(* take a theorem with flexes and add the flex-flex pairs as 
   equational goals *)
fun add_ffs_to_thm ffs th = 
    let 
      val ffs = Thm.tpairs_of th
      val t = Thm.concl_of th
      val flexyth = 
          mk_triv_ff_protected_thm (Thm.theory_of_thm th) ffs t 
    in
      Thm.implies_elim th flexyth (* contains tpairs of both theorems *)
    end;


(* take a theorem with flexes and add the flex-flex pairs as 
   equational goals *)
fun mk_ff_explicit_in_thm th = 
    let 
      val ffs = Thm.tpairs_of th
      val t = Thm.concl_of th
      val flexyth = 
          mk_triv_ff_protected_thm (Thm.theory_of_thm th) ffs t 
    in
      Thm.implies_elim th flexyth (* contains tpairs of both theorems *)
    end;

fun inst_flexes ienv ffs = 
    let val instf = InstEnv.inst_trm ienv
    in map (fn (x,y) => (instf x, instf y)) ffs end;

val of_thm = Thm.tpairs_of;

end;

structure Flexes : FLEXES = DB_Flexes;
