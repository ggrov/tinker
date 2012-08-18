theory ac_eq_test
imports "src/libs/term/ac_eq"
begin

typedecl "ciao"
typedecl "zorba"

ML {* 
val plus = @{term "op + :: nat => nat => nat"}
val times = @{term "op *  :: nat => nat => nat"}
val a = @{term "a :: nat"}
*}

ML {*
val plus = Const("HOL.plus_class.plus", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]));
val times = Const("HOL.times_class.times", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])]));
val eq = (Const("op =", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("bool", [])])])));
val a = Free("a", Type("N.N",[]));
val b = Free("b", Type("N.N",[]));
val c =  Free("c", Type("N.N",[]));
val d =  Free("d", Type("N.N",[]));
val e =  Free("e", Type("N.N",[]));
val f =  Free("f", Type("N.N",[]));


val x = Free("x", Type("ciao",[]));
val y = Free("y", Type("ciao",[]));
val z = Free("z", Type("ciao",[]));
val ciaof = Const("ciaof", Type("fun", [Type("N.N", []), Type("fun", [Type("ciaof", []), Type("fun", [Type("N.N", []), Type("N.N", [])])])]));

val zorba = Const("zorba", Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("fun", [Type("N.N", []), Type("N.N", [])])])]));



val t = @{term "(a :: nat) + b * c"}

val t = @{term "((a :: nat) + b) + c = (a :: nat) + (b + c)"}

val ass1 = plus $a $(plus $b $(plus  $c  $ (times $ (plus $ a $ (plus $b $ c)))) $ d ); 
val ass2 = plus $a $(plus $b $(plus  $c  $ (times $ d $(plus $ (plus $ a  $b) $ c))));
val ass5 = plus $a $(plus $b $(plus  $c  $ (times $(plus $ (plus $ a  $b) $ c) $ d  )));

val ass3 =  (plus $ a $ (plus $b $ c)); 
val ass4 = (plus $ (plus $ a  $b) $ c);

val gaia1 = times $a $ (ciaof $ (zorba $ (plus $a $b)  $b $c) $x $d);
val gaia2 = times  $ (ciaof $d  $x $ (zorba $b $c $(plus $a $b)) ) $a;

val lhs1 = times $ a $ (plus $b $ c); 
val lhs2 = times $(plus $ d $ e) $ f;
val lhs3 = times $ d $ (plus $e $ f);
val lhs4 = times $ a $ (plus $c $ b);
val lhs5 = times $ (plus $b $ c)  $ a ;
val lhs6 = times $ (plus $c $ b)  $ a; 

val check1 = plus $  (plus $a $(times $b $c)) $ d ;
val check2 = plus   $a  $(plus $(times $c $b) $ d) ;

val rhs1 = plus $(times $ a $ b) $(times $ a $ c);
val rhs2 =   plus $(times $ e $ f) $(times $ d $ f);


val llhs1 = plus $a $ (plus $b $(plus  $c  $(times $ a $ (plus $b $ c)))); 
val llhs2 = plus $a $ (plus $b $(plus  $c  $(times $(plus $ d $ e) $ f)));
val llhs3 = plus $a $(plus $b $(plus  $c  $(times $ d $ (plus $e $ f))));
val llhs4 = plus $a $ (plus $b $(plus  $c  $(times $ a $ (plus $c $ b))));
val llhs5 = plus $a $(plus $b $(plus  $c  $(times $ (plus $b $ c)  $ a )));
val llhs6 = plus $a $(plus $b $(plus  $c  $(times $ (plus $c $ b)  $ a ))); 


val try111 = plus $  (plus $a $ b) $ (plus $c $e);  
val try222 = plus $  (plus $f $ c) $ (plus $b $a);  

val eqt1 = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
         eq $ lhs1 $ rhs1;
val eqt2 = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ lhs2 $ rhs2;


val thm1_lhs = plus $a $b ;
val thm1_rhs = plus $b $a ;
val thm1_rhs2 = plus $c $a ;

val thm2_lhs = ciaof $a $x $b ;
val thm2_rhs = ciaof $b $x $a ;

val thm3_lhs = zorba $a $b $c;
val thm3_rhs = zorba $b $a $c;
val thm3_rhs2 = zorba $c $b $a;

val thm4_lhs = times $a $b;
val thm4_rhs = times $b $a ;

val thm1 = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ thm1_lhs $ thm1_rhs;
val thm2= (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ thm2_lhs $ thm2_rhs;
val thm12 = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ thm1_lhs $ thm1_rhs2;

val thm3= (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ thm3_lhs $ thm3_rhs;
val thm32 = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ thm3_lhs $ thm3_rhs2;

val thm4 = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ thm4_lhs $ thm4_rhs;


val athm1_lhs = plus $a $ ( plus $b $c);
val athm1_rhs = plus $ (plus  $a $b) $c;
val athm1 = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ athm1_lhs $ athm1_rhs;

val atry1 = ciaof $ athm1_lhs  $ x $ d; 
val atry2= plus $a $(plus $b $ (plus $c $d)); 
val atry3 =  plus $ (plus $(plus $ a $b ) $d ) $c;

val athm2_lhs = ciaof $(ciaof $a $x $b) $y $c ;
val athm2_rhs = ciaof $a $x $ (ciaof $b $y $c);
val athm2= (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ athm2_lhs $ athm2_rhs;


val fiona1 = zorba $ (plus $a $(plus $(ciaof $a $x $ (plus $a $b)) $c)) $c $a ; 
val fiona2 = zorba $a $ (plus $(plus $a  $(ciaof $(plus $b $a) $y $ a)) $c) $c ; 
val fiona3 =  (plus $a $(plus $(ciaof $a $x $ (plus $a $b)) $c)) ; 
val fiona4 = (plus $(plus $a  $(ciaof $(plus $b $a) $y $ a)) $c); 

*}
ML {*
(*************************************** EXAMPLES *********************************************)
val  sthm1= Commfun.sign_of_comm_thm thm1;
val  sthm3 = Commfun.sign_of_comm_thm thm3;
val  sthm32 = Commfun.sign_of_comm_thm thm32;
val  sthm2 = Commfun.sign_of_comm_thm thm2;
val  sthm4 = Commfun.sign_of_comm_thm thm4;

val bb = Commfun.add_comm_sign sthm1  Commfun.emptyCTab;
(*val bb = Commfun.add_comm_sign sthm3 bb;
val bb = Commfun.add_comm_sign sthm32  bb;*)
val bb = Commfun.add_comm_sign sthm2  bb;
val bb = Commfun.add_comm_sign sthm4  bb;

val cc= Commfun.add_ass_sign ( Commfun.sign_of_ass_thm athm1) Commfun.emptyATab;


rhs1; rhs2;
print_depth 600;  


val comm_term1 = Commfun.isa_term_to_commtrm bb atry2;
val comm_term2 = Commfun.isa_term_to_commtrm bb atry3;
atry3;

val ass_term1 = Commfun.commterm_to_asstrm cc comm_term1;
val ass_term2 = Commfun.commterm_to_asstrm cc comm_term2;


val fiona1 = zorba $ (plus $a $(plus $(ciaof $a $x $ (plus $a $b)) $c)) $c $a ; 
val fiona11 = zorba $ (plus $a $(plus $(ciaof $a $x $ (plus $a $ (plus $ e  $(plus $ e $e)))) $c)) $c $a ; 
val fiona2 = zorba $d $ (plus $(plus $d  $(ciaof $(plus $b $d) $y $ d)) $c) $c ; 
val fiona3 =  (ciaof $a $x  $b) ; 
val fiona4 = (ciaof $b $y $ a) ; 

val try1 = (plus $a $b); 
val try2 = (plus $c $ (plus $ d $ (plus $e $f)));

val try3= ciaof $c $x $a;
val try4 = ciaof $a $x $(plus $c $ (plus $ d $ (plus $e $f)));
val try5 = ciaof $a $x $a;
val try6 = plus $b $a;
val try7 = plus $a $b;
val p1 = (plus $a $b); 
val p3 = (plus $a $(plus $b $c)); 
val p2 = (plus $c $ (plus $ d $ (plus $e $f)));
val t1 = zorba $a $c $d;
val t2 = zorba $a $a $(plus $b $(plus $d $(plus $e $ a))) ;



val poo2 = Commfun.eq_isa_trms2 cc bb t1 t2; (*no *)
val poo = Commfun.eq_isa_trms2 cc bb fiona1 fiona11;(*yes *)

map  (CMTTab.print (Commfun.pretty @{context})) poo2;



(*
fun eq_isa_trms2 atable ctable term1 term2  = let
    val comm_term1 = isa_term_to_commtrm ctable term1;
    val comm_term2 = isa_term_to_commtrm ctable term2;
    val ass_term1 = commterm_to_asstrm atable comm_term1;
    val ass_term2 = commterm_to_asstrm atable comm_term2;
    in match
   (ass_term1,ass_term2)  [VAmorph.empty]
    end;
*)





*}




ML {*

(*

exception match_failed;

fun add_match (v1,v2) env = 
    (case env |> VAmorph.try_change1 (VName.mk v1) (VName.mk v2) 
     of NONE => raise match_failed | SOME am' => am');

fun match c_fun ((Free(var1,Type(typ1,srt))),(Free(var2,Type(typ2,srt2)))) env  = 
    if (typ1 = typ2) andalso srt = srt2 then add_match (var1,var2) env
    else raise match_failed
  | match c_fun ( t1 , t2 ) env = 
    let val  (f1,body1) = strip_comb t1;
        val  (f2,body2) = strip_comb t2; 
        in  if (body1=[] andalso body2=[]) then  env
             else matchl c_fun body1 body2 env
handle match_failed => matchl_ass c_fun f1 (body1, body2) env
             handle match_failed => matchl_comm c_fun f1 (body1, body2) env
              
                
    end


and matchl c_fun l1 l2 env = 
    if length l1 = length l2 then  fold (match c_fun) (l1 ~~ l2) env

    else raise match_failed
and matchl_comm _ _ ([], []) env = env
  | matchl_comm c_fun f ([t11,t12], [t21,t22]) env = if ( member (=) c_fun f ) then 
    matchl c_fun [t12,t11] [t21,t22] env else raise match_failed
  | matchl_comm _ _ _ env = raise match_failed

and matchl_ass _ _ ([], []) env = env
  | matchl_ass c_fun f ([t11,t12], [t21,t22]) env = if ( member (=) c_fun f ) then 
     let 
     val (v1,b1) = Term.strip_comb t11;
     val (v2,b2) = Term.strip_comb t12;
     in   if v1 = f  then matchl c_fun [hd b1, Term.betapplys (f, (tl b1)@ [v2])]  [t21,t22] env
         else  if v2=f then matchl c_fun [Term.betapplys (f, (v1 :: [hd b2])), List.nth(b2,1)] [t21,t22] env 
         else raise match_failed  end

    else raise match_failed
  | matchl_ass _ _ _ env = raise match_failed;



(*
val env' = matchl cfun  [eqt1] [eqt2]  VAmorph.empty ;
VAmorph.print env';*)
val env' =  VAmorph.empty |> VAmorph.add  (VName.mk "a") (VName.mk "a") |> VAmorph.add (VName.mk "b") (VName.mk "b") 
|> VAmorph.add  (VName.mk "c") (VName.mk "c") ;


VAmorph.print env';

*)
ass3;
ass4;

(*match cfun (ass3, ass4) env' ; *)
val t1= ass3; val t2 = ass4;
val  (f1,body1) = strip_comb t1;
val  (f2,body2) = strip_comb t2; 




(*matchl_ass cfun f1 (body1, body2) env;*)

val [t11,t12] = body1;
val [t21,t22] = body2;
val (v1,b1) = Term.strip_comb t11;
  val (v2,b2) = Term.strip_comb t12;
v2 = f1;
body1;
(*matchl cfun [Term.betapplys (f1, (v1 :: [hd b2])), List.nth(b2,1)] [t21,t22] env'*)
*} 



ML {*

(*fun commutative_match  term1 term2 = 
   let 
     fun match (t1,t2) = if t1 = t2 then true
                         else(
                           let 
                           val  (f1,body1) =  strip_comb t1;
                           val  (f2,body2) =  strip_comb  t2;
                           in 
                              if not(f1 = f2)  then raise match_failed
                              else matchl(body1, body2)  
                              handle match_failed => matchl_comm f1 (body1, body2) end)

     and matchl ([], []) = true
    | matchl (t1::term1, t2::term2) = if (match (t1,t2)) then matchl (term1,term2) else raise match_failed (*matchLists (match t1 t1 ) (term1, term2) *)
    | matchl _= raise match_failed

and matchl_comm _ ([], []) = true
    | matchl_comm f ([t11,t12], [t21,t22]) = if (is_commutative f) 
                                then (if match (t12,t21) then matchl([t11],[t22]) else (raise match_failed )) else (raise match_failed)(*matchLists (match t1 t1 ) (term1, term2) *)
    | matchl_comm _ _ = raise match_failed;

        in matchl (term1,term2) end;



fun term_ac_eq eq1 eq2= 
let 
    val terms1 =  snd( Term.strip_comb eq1);
    val terms2 =  snd( Term.strip_comb eq2);
    val lhs1 = List.nth(terms1,1);
    val rhs1 = List.nth(terms1,2);
    val lhs2 = List.nth(terms2,1);
    val rhs2 = List.nth(terms2,2);
    val env1=  VAmorph.empty ;
    val env2 = matchLists env1 [lhs1] [lhs2] ;
    val rhs1_v2 = rename_var env2 rhs1  ;
in commutative_match [rhs1_v2] [rhs2] handle match_failed => false end;
*)

fun make_eq lhs rhs = (Const("Trueprop", Type("fun", [Type("bool", []), Type("prop", [])]))) $
          eq $ lhs $ rhs;

val try111 = plus $  (plus $a $ b) $ (plus $c $d);  
val try222 = plus $  (plus $f $ d) $ (plus $b $a);  

val try333 = times $  (times $a $ b) $ (times $c $d);
val try444 = times $  (times $b $ a) $ (times $d $f);

val try555 = make_eq try111 try333;
val try666 = make_eq try222 try444;




(***** EXAMPLES *****)
(*

val env1 = VAmorph.empty ;
lhs1;
lhs3;
val env2 = matchLists env1 [lhs1] [lhs3];
val env3 = matchLists env1 [llhs1] [llhs4];

val env5 = matchLists env1 [lhs1] [lhs6];
val env= env2;
VAmorph.print env3;


val env2 = VAmorph.empty  |> VAmorph.add (VName.mk "b") (VName.mk "b") |> VAmorph.add (VName.mk "a") (VName.mk "a")
   |> VAmorph.add (VName.mk "c") (VName.mk "c") |> VAmorph.add (VName.mk "d") (VName.mk "d");
val env3 = matchLists env2 [try111] [try222];



val env2 = matchLists env1 [llhs1] [llhs4];
val env3 = matchLists env1 [lhs1] [lhs4];
val env4 = match_lhs llhs1 llhs3;
val env5 = match_lhs lhs1 lhs6;
val env= env4;
VAmorph.print env;


val env3 = matchLists VAmorph.empty [try111] [try222];
VAmorph.print env3;
try222= commutative_match env3 try111;

commutative_match [lhs1] [lhs5];

term_ac_eq lhs1 lhs3 rhs1 rhs2;
*)
(***** END EXAMPLES *****)


*}




end;
