theory ac_eq
imports IsaP
begin

ML {* 
 structure foo = struct open Term; end; 
 structure foo2 = struct open Trm; end;
 structure foo2 = struct open List; end;
*}


consts f :: "nat => nat => nat => nat"
consts g :: "nat=> bool => nat"

ML {* 


val context = 
    ProofContext.set_mode (ProofContext.mode_schematic) @{context};

val t2 =  Syntax.read_term context " Trueprop (f (?a :: nat) ?b ?c =  f ?a ?c ?b)";

(*val c1 = Commfun.sign_of_comm_thm t; (* should be raising and exception! *)*)
val c2 = Commfun.sign_of_comm_thm t2;

val t3 = Syntax.read_term context"Trueprop (f ?a ?b 0 = f ?a 0 ?b)";
(*val c3 = Commfun.sign_of_comm_thm t3; (* should be raising and exception! *) *)


val t4 = Syntax.read_term context"Trueprop ( (?a::nat) * (?b * 0) =  (?a * ?b) * 0)";
(*val a4 = Commfun.sign_of_ass_thm t4; *)


*}


ML {* 


val thm1 = Syntax.read_term context "Trueprop  ((?a :: nat) + ?b = ?b + ?a)"  ;

val thm2 = Syntax.read_term context "Trueprop  ((?a :: nat) * ?b = ?b * ?a)" ;

val thm3 = Syntax.read_term context "Trueprop (f ?a ?c ?b = f ?a ?b ?c)";

val thm4 = Syntax.read_term context "Trueprop (f ?b ?a ?c = f ?a ?b ?c)";

val thm5 = Syntax.read_term context "Trueprop ((?a :: nat) + (?b + ?c) =  (?a + ?b) + ?c)"; 
val thm6 = Syntax.read_term context "Trueprop ((?a :: nat) * (?b * ?c)  =  (?a * ?b) * ?c)"; 



val  sthm1= Commfun.sign_of_comm_thm thm1;
val  sthm2 = Commfun.sign_of_comm_thm thm2;
val  sthm3 = Commfun.sign_of_comm_thm thm3;
val  sthm4 = Commfun.sign_of_comm_thm thm4;

val  athm5 =  Commfun.sign_of_ass_thm thm5;
val  athm6 =  Commfun.sign_of_ass_thm thm6;


val try_thm =  Syntax.read_term context " Trueprop ((?a :: nat) + ?b = ?b + ?a)";
val try = Commfun.sign_of_comm_thm try_thm;
val try_thm2 = Syntax.read_term context "Trueprop ( (?a::nat) * (?b * 0) =  (?a * ?b) * 0)"; (*shouldn't work*)
(*val try = Commfun.sign_of_ass_thm try_thm2;*)
val try_thm3 = Syntax.read_term context "Trueprop ( (?a::nat) * (?b * ?c) =  (?a * ?b) * ?c)"; (*shouldwork*)
val try = Commfun.sign_of_ass_thm try_thm3;

val bb = Commfun.add_comm_sign sthm1  Commfun.emptyCTab;
val bb = Commfun.add_comm_sign sthm2  bb;
val bb = Commfun.add_comm_sign sthm3  bb;
val bb = Commfun.add_comm_sign sthm4  bb;

val cc= Commfun.add_ass_sign athm5 Commfun.emptyATab;
val cc= Commfun.add_ass_sign athm6 cc;

val t1 = Syntax.read_term context "(?a :: nat) + ?b + ?c ";
val t2 = Syntax.read_term context "(?a :: nat) + (?b + ?c) ";
val t3 = Syntax.read_term context "f ?a ?b (?c + (?d+ ?e))   ";
val t4 = Syntax.read_term context "f ((?a+?b)+ ?a) ?b ?e   ";
val t5 = Syntax.read_term context "g (f ((?a+?b)+ ?a) ?b ?e) ?m   ";
val t6 = Syntax.read_term context "g  (f ((?a+?b)+ ?a) ?b (g ?l ?m )) ?n    ";
val t7 = Syntax.read_term context "g  (f ((?a+?b)+ ?a) ?b (g ?l ?n )) ?n    ";

val t8 = Syntax.read_term context "(a :: nat) + ?b + ?c ";
val t9 = Syntax.read_term context "(a :: nat) + (?d * e) + ?c ";

val comm_term1 = Commfun.isa_term_to_commtrm bb t1;
val comm_term2 = Commfun.isa_term_to_commtrm bb t2;

val ass_term1 = Commfun.commterm_to_asstrm cc comm_term1;
val ass_term2 = Commfun.commterm_to_asstrm cc comm_term2;


val poo1 = Commfun.eq_isa_trms2 cc bb t4 t3; (*no *)
val poo2 = Commfun.eq_isa_trms2 cc bb t3 t4; 
val poo3 = Commfun.eq_isa_trms2 cc bb t5 t6; 
val poo4 = Commfun.eq_isa_trms2 cc bb t6 t5; (*no *)
val poo5 = Commfun.eq_isa_trms2 cc bb t6 t7; 
val poo6 = Commfun.eq_isa_trms2 cc bb t8 t9; 
val poo7 = Commfun.eq_isa_trms2 cc bb t9 t8;  (*no *)
val context = 
    ProofContext.set_mode (ProofContext.mode_schematic) @{context};

map  (Commfun.CMTTab.print (Commfun.pretty context)) poo6;


*}


ML {* 
(*val _ = TermDbg.writeterm t;

val (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
 (((Const("op =", Type("fun", [_, Type("fun", [_, Type("bool", [])])]))) $
 lhs) $ rhs) = t; *)


*}

ML {* 
val (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $ ((eq $ lhs) $ rhs) = t;


*}

ML {* 

*}


end;