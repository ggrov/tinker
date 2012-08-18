(*  Title:      src/termination.ML
    ID:         $Id: termination.ML,v 1.010 2011/02/16 12:40:00 omar Exp $
    Author:     Omar Montano Rivas, University of Edinburgh School of Informatics
    Copyright   University of Edinburgh 2010

An Isabelle/HOL implementation of "Polymorphic Higher-Order Recursive Path Orderings"
(see paper with the same name by Jean-Pierre Jouannaud and Albert Rubio)
*)

signature RPO =
sig
  val lpo    : (term -> int) -> term * term -> order
  val horpo  : string list Unsynchronized.ref -> string list -> string list -> string list -> (string -> int) -> (term -> int) -> term * term -> order
  val lhorpo : string list Unsynchronized.ref -> string list -> string list -> string list -> (string -> int) -> (term -> int) -> term * term -> order
end

structure DB_Rpo
(* : RPO *)
= struct

fun union_ord o1 o2 e =
    case o1 e of GREATER => GREATER
               | EQUAL => (case o2 e of GREATER => GREATER
                                      | _ => EQUAL)
               | LESS => (case o2 e of GREATER => GREATER
                                     | EQUAL => EQUAL
                                     | LESS => LESS)

(* HO recursive path order without lambda abstraction *)
fun lpo f_ord (s,t) = 
    case (s,t) of
      (s,f as Free _) => if Term_Ord.term_ord (s,f) = EQUAL then EQUAL
                         else if Term.exists_subterm (fn t => Term_Ord.term_ord (f,t) = EQUAL) s then GREATER
                         else LESS
    | (s,v as Var _) => if Term_Ord.term_ord (s,v) = EQUAL then EQUAL
                        else if Term.exists_subterm (fn t => Term_Ord.term_ord (v,t) = EQUAL) s then GREATER
                        else LESS
    | (s,b as Bound _) => if Term_Ord.term_ord (s,b) = EQUAL then EQUAL
                          else if Term.exists_subterm (fn t => Term_Ord.term_ord (b,t) = EQUAL) s then GREATER
                          else LESS
    | (Free _, _ $ _) => LESS
    | (Var _, _ $ _) => LESS
    | (Bound _, _ $ _) => LESS
    | (Free _, Abs _) => LESS
    | (Var _, Abs _) => LESS
    | (Bound _, Abs _) => LESS
    | _ => let val (f, ss) = strip_comb s and (g, ts) = strip_comb t in
             if forall (fn si => lpo f_ord (si, t) = LESS) ss
             then case hd_ord f_ord (f, g) of
                    GREATER =>
                    if forall (fn ti => lpo f_ord (s, ti) = GREATER) ts
                    then GREATER else LESS
                  | EQUAL =>
                    if forall (fn ti => lpo f_ord (s, ti) = GREATER) ts
                    then list_ord (lpo f_ord) (ss, ts)
                    else LESS
                  | LESS => LESS
             else GREATER end
(*    | _ => LESS*)
and hd_ord f_ord (f, g) = case (f, g) of
    (Abs (_, T, t), Abs (_, U, u)) =>
      (case lpo f_ord (t, u) of EQUAL => Term_Ord.typ_ord (T, U) | ord => ord)
  | (_, _) => int_ord (f_ord f, f_ord g)

local
  fun remove1 eq x [] = []
    | remove1 eq x (y :: ys) = if eq (x, y) then ys else y :: remove1 eq x ys

  fun mdiff eq xs [] = xs
    | mdiff eq xs (y :: ys) = mdiff eq (remove1 eq y xs) ys
in
fun multiset ord (ms, ns)  =
    let val nms = mdiff (is_equal o ord) ns ms
        val mns = mdiff (is_equal o ord) ms ns in
      if null nms andalso null mns then EQUAL
      else if forall (fn n => exists (fn m => ord (m,n) = GREATER) mns) nms then GREATER
      else LESS end
end

fun left_flattening u =
    let fun stripc (f$t, []) = stripc (f, [t])
        |   stripc (f$t, ts) = (f$t :: ts) :: stripc (f, t::ts)
        |   stripc  (x, ts) =  [x :: ts]
    in filter_out (fn l => length l = 1) (stripc(u,[])) end

val exists_bound =
  let
    fun ex i tm = (is_equal o Term_Ord.term_ord) (Bound i, tm) orelse
      (case tm of
        t $ u => ex i t orelse ex i u
      | Abs (_, _, t) => ex (i+1) t
      | _ => false)
  in ex 0 end

(*fun pd thy m s t = tracing (m ^ ": s = " ^ Syntax.string_of_term_global thy s ^ ", t = " ^ Syntax.string_of_term_global thy t)
fun pd2 m = ()(*tracing m*)
fun pterm thy m s t v = v (*if v then (tracing (m ^ ": s = " ^ Syntax.string_of_term_global thy s ^ ", t = " ^ Syntax.string_of_term_global thy t); v) else v*)
fun pterm' thy m s t v = v(*if true
                         then (tracing (m ^ ": s = " ^ Syntax.string_of_term_global thy s ^ ", t = " ^ Syntax.string_of_term_global thy t); v) 
                         else v*)
fun ptyp thy m s t v = if v then (tracing (m ^ ": s = " ^ Syntax.string_of_typ_global thy (type_of s) ^ ", t = " ^ Syntax.string_of_typ_global thy (type_of t)); v) else v*)

fun equal_sorts s_ord (a as Type(cn,_),b as Type(dn,_)) =
    (is_equal o Term_Ord.typ_ord) (a,b) orelse (cn <> "fun" andalso dn <> "fun" andalso s_ord cn = s_ord dn)
  | equal_sorts _ (TFree _,TFree _) = true
  | equal_sorts _ (TVar _,TVar _) = true
  | equal_sorts _ T = (is_equal o Term_Ord.typ_ord) T

fun typ_quasi_ord s_ord (s,t) =
    let val (ss,c) = Term.strip_type s
        val (tt,d) = Term.strip_type t
        fun B tt = forall (fn v => let val ord = typ_quasi_ord s_ord (s,v) in (*ord = EQUAL orelse*) ord = GREATER end) tt
    in
      (* equal types *)
      if equal_sorts s_ord (s,t) then EQUAL
      (* case 1 *)
      else if null ss andalso (case c of Type (_, cl) => exists (fn ci => equal_sorts s_ord (ci,t)
                                                                          orelse typ_quasi_ord s_ord (ci,t) = GREATER) cl
                                       | _ => false) then GREATER
      (* case 2 *)
      else if null ss andalso null tt andalso
              (case (c,d) of (Type(cn,cl),Type(dn,dl)) => s_ord cn > s_ord dn andalso B dl
                           | _ => false) then GREATER
      (* case 3 *)
      else if null ss andalso null tt andalso
              (case (c,d) of (Type(cn,cl),Type(dn,dl)) => s_ord cn = s_ord dn
                                                          andalso (let val mult_ord = multiset (typ_quasi_ord s_ord) (ss,tt) in
                                                                     mult_ord = GREATER orelse mult_ord = EQUAL end)
                           | _ => false) then GREATER
      (* case 4 *)
      else if null ss andalso null tt andalso
              (case (c,d) of (Type(cn,cl),Type(dn,dl)) => s_ord cn = s_ord dn
                                                          andalso (let val lex_ord = list_ord (typ_quasi_ord s_ord) (ss,tt) in
                                                                     lex_ord = GREATER orelse lex_ord = EQUAL end)
                                                          andalso B dl
                           | _ => false) then GREATER
      (* case 5 *)
      else if (case s of Type ("fun",[_,T]) => (*equal_sorts s_ord (T,t)*)
                         let val ord = typ_quasi_ord s_ord (T,t) in
                           ord = EQUAL orelse ord = GREATER end
                       | _ => false) then GREATER
      (* case 6 *)
      else if (case (s,t) of (Type ("fun",[A,B]),Type ("fun",[A',B'])) => (*equal_sorts s_ord (A,A')*)
                             let val ord = typ_quasi_ord s_ord (A,A') in
                               (case ord of GREATER => false
                                          | EQUAL => let val ord' = typ_quasi_ord s_ord (B,B') in
                                                       ord' = EQUAL orelse ord' = GREATER end 
                                          | LESS => false) end
(*                                                                          andalso (equal_sorts s_ord (B,B')
                                                                                   orelse typ_quasi_ord s_ord (B,B') = GREATER)*)
                           (* Arrow decresing preservation! *)
                           | (Type ("fun", _),TVar _) => true
                           | (Type ("fun", _),TFree _) => true
                           | (Type ("fun", _),Type (n,_)) => "fun" <> n
                           | _ => false) then GREATER
      (* Type > TVar, TFree *)
      else if (*size_of_typ s = size_of_typ t
              andalso*) (case (s,t) of (Type _, TFree _) => true
                                     | (Type _, TVar _) => true
                                     | _ => false) then GREATER
        (* this is redundant? *)
        else if (case (s,t) of (TVar _,TVar _) => true
                             | (TFree _,TFree _) => true
                             | _ => false) then EQUAL
        else LESS
    end

fun strict_subterm s_ord (s,t) =
    let
      val sfrees = [] |> Term.add_frees s |> map Free
      val tfrees = [] |> Term.add_frees t |> map Free
      val svars = [] |> Term.add_vars s |> map Var
      val tvars = [] |> Term.add_vars t |> map Var
      val typ_ord = ((typ_quasi_ord s_ord) o (pairself type_of)) (s,t)
    in
      not (s aconv t)
      andalso Term.exists_subterm (fn si => si aconv t(*Term_Ord.term_ord (si,t) = EQUAL*)) s
      andalso (typ_ord = EQUAL orelse typ_ord = GREATER)
      andalso forall (fn vs => exists (fn vt => Term_Ord.term_ord (vs,vt) = EQUAL) tfrees) sfrees
      andalso forall (fn vs => exists (fn vt => Term_Ord.term_ord (vs,vt) = EQUAL) tvars) svars
    end

fun append_lexr s (lref: (string list) Unsynchronized.ref) = if exists (fn e => s = e) (!lref)
                        then () else lref := s :: (!lref)

fun horpo lref Mul Lex Lexr s_ord f_ord (s,t) =
    let val (f, ss) = strip_comb s and (g, tt) = strip_comb t
        val f_fun = Term.is_Const f
        val g_fun = Term.is_Const g
        val typ_ord = ((typ_quasi_ord s_ord) o (pairself type_of)) (s,t)
(*        fun A tt = forall (fn v => horpo Mul Lex s_ord f_ord (s,v) = GREATER orelse
                                   exists (fn u => horpo Mul Lex s_ord f_ord (u,v) = GREATER) ss) tt*)
        fun A tt = forall (fn v => let val typ_ord1 = ((typ_quasi_ord s_ord) o (pairself type_of)) (v,t) in
                                     if typ_ord1 = LESS orelse typ_ord1 = EQUAL
                                     then horpo lref Mul Lex Lexr s_ord f_ord (s,v) = GREATER
                                     else exists (fn u => let val typ_ord2 = ((typ_quasi_ord s_ord) o (pairself type_of)) (u,v) in
                                                            if typ_ord2 = EQUAL orelse typ_ord2 = GREATER
                                                            then u aconv v orelse horpo lref Mul Lex Lexr s_ord f_ord (u,v) = GREATER
                                                            else false end) ss end) tt
(*        fun A tt = forall (fn v =>  horpo Mul Lex s_ord f_ord (s,v) = GREATER orelse
                                    CC Mul Lex s_ord f_ord [] (Term.maxidx_of_term s) true (s,v)) tt*)
    in
      (* type checking *)
      if typ_ord = LESS then LESS
      (* case 1 *)
      else if f_fun andalso (exists (fn u => u aconv t orelse horpo lref Mul Lex Lexr s_ord f_ord (u, t) = GREATER) ss
                             orelse CC lref Mul Lex Lexr s_ord f_ord [] (Term.maxidx_of_term s) true (s,t)) then GREATER
      (* case 2 *)
      else if f_fun andalso g_fun andalso f_ord f > f_ord g andalso A tt then GREATER
      (* case 3 *)
      (* Multisets are implemented but not used in IsaScheme (lexicographic orders orient most rules we are interested) *)
      else if f_fun andalso g_fun andalso f_ord f = f_ord g andalso (let val ng = (fst o Term.dest_Const) g in exists (fn n => n = ng) Mul end)
              andalso multiset (horpo lref Mul Lex Lexr s_ord f_ord) (ss,tt) = GREATER then GREATER
      (* case 4 *)
      (* left-right lexicographic order *)
      else if f_fun andalso g_fun andalso f_ord f = f_ord g andalso (let val ng = (fst o Term.dest_Const) g in exists (fn n => n = ng) Lex end)
              andalso
              (let val foo = list_ord (horpo lref Mul Lex Lexr s_ord f_ord) (ss,tt) = GREATER in
                 if foo then true
                 (* Give hint that right-left lexicographic order could succeed  *)
                 else (append_lexr ((fst o Term.dest_Const) f) lref; false) end) andalso A tt then GREATER
      (* right-left lexicographic order *)
      else if f_fun andalso g_fun andalso f_ord f = f_ord g andalso (let val ng = (fst o Term.dest_Const) g in exists (fn n => n = ng) Lexr end)
              andalso list_ord (horpo lref Mul Lex Lexr s_ord f_ord) (rev ss,rev tt) = GREATER andalso A tt then GREATER
      (* case 5 *)
      else if (case s of s1 $ s2 => s1 aconv t orelse s2 aconv t orelse horpo lref Mul Lex Lexr s_ord f_ord (s1,t) = GREATER
                                    orelse horpo lref Mul Lex Lexr s_ord f_ord (s2,t) = GREATER | _ => false) then GREATER
      (* case 6 (apparently beta contraction avoids additional checks!) *)
      else if (case s of Abs (n,T,_) =>
                         let val beta = Term.betapply (s, Var ((n,1+Integer.max (Term.maxidx_of_term s) (Term.maxidx_of_term t)),T)) in
                         beta aconv t orelse horpo lref Mul Lex Lexr s_ord f_ord (beta,t) = GREATER end | _ => false) then GREATER
      (* case 7 *)
      else if f_fun andalso exists A (left_flattening t) then GREATER
      (* case 8 *)
      else if f_fun andalso (case t of Abs (n,T,v) =>
                                       (not o exists_bound) v andalso
                                       (let val beta = Term.betapply (t, Var ((n,1+Integer.max (Term.maxidx_of_term s) (Term.maxidx_of_term t)),T))
                                        in horpo lref Mul Lex Lexr s_ord f_ord (s, beta) = GREATER end)
                                     | _ => false) then GREATER
      (* case 9 *)
      else if (case s of s1 $ s2 => exists (fn tt => multiset (horpo lref Mul Lex Lexr s_ord f_ord) ([s1,s2],tt) = GREATER) (left_flattening t)
                       | _ => false)
      then GREATER
      (* case 10 *)
      else if (case (s,t) of (Abs (n1,A,_),Abs (n2,B,_)) =>
                             (is_equal o (typ_quasi_ord s_ord)) (A,B) andalso
                             (let val beta1 = Term.betapply (s, Var ((n1,1+Integer.max (Term.maxidx_of_term s) (Term.maxidx_of_term t)),A))
                                  val beta2 = Term.betapply (t, Var ((n2,1+Integer.max (Term.maxidx_of_term s) (Term.maxidx_of_term t)),B))
                              in horpo lref Mul Lex Lexr s_ord f_ord (beta1,beta2) = GREATER end)
                           | _ => false) then GREATER
      (* case 11 (not needed because we are working w.r.t. beta contracted terms?) *)
      (* Potential variable capture *)
      else if (case s of (Abs A $ v) => let val beta = Term.betapply (Abs A,v) in
                                                     (not o is_equal o Term_Ord.term_ord) (s,beta) andalso
                                                     (beta aconv t orelse horpo lref Mul Lex Lexr s_ord f_ord (beta,t) = GREATER) end
                       | _ => false) then GREATER
      (* case 12 *)
      else if (case s of Abs (n,T, u $ Bound 0) =>
                         (not o exists_bound) u andalso
                         (let val beta = Term.betapply (s, Var ((n,1+Integer.max (Term.maxidx_of_term s) (Term.maxidx_of_term t)),T))
                          in case beta of u' $ _ => u' aconv t orelse horpo lref Mul Lex Lexr s_ord f_ord (u',t) = GREATER
                                        | _ => false end) | _ => false) then GREATER
      else if s aconv t then EQUAL
      else LESS
    end
and CC lref Mul Lex Lexr s_ord f_ord Vs i foo (s,t) =
    let val (f, ss) = strip_comb s and (g, tt) = strip_comb t
        val f_fun = Term.is_Const f
        val g_fun = Term.is_Const g
    in
      (* smallest set containing all terms in ss *)
      if f_fun andalso exists (fn si => si aconv t) ss then true
      (* all variables in Vs *)
      else if f_fun andalso exists (fn vi => vi aconv t) Vs then true
      (* and closed under the following operations *)
      (* 2. precedence *)
      else if f_fun andalso g_fun andalso foo andalso f_ord f > f_ord g 
              andalso forall (fn ti => CC lref Mul Lex Lexr s_ord f_ord Vs i foo (s,ti)) tt then true
      (* 3. recursive call *)
      else if f_fun andalso g_fun andalso f_ord f = f_ord g andalso
              forall (fn ti => CC lref Mul Lex Lexr s_ord f_ord Vs i foo (s,ti)) tt andalso
              list_ord (fn (s',t') => case horpo lref Mul Lex Lexr s_ord f_ord (s',t') of
                                        GREATER => GREATER
                                      | _ => if strict_subterm s_ord (s',t') then GREATER else LESS) (ss,tt) = GREATER then true
      (* 4. application *)
      else if f_fun andalso not g_fun andalso not (null tt)
              andalso forall (fn ti => CC lref Mul Lex Lexr s_ord f_ord Vs i foo (s,ti))
                             (g :: tt) then true
      (* experimental *)
      else if f_fun andalso g_fun andalso f_ord f <> f_ord g andalso not (null tt)
              andalso forall (fn ti => CC lref Mul Lex Lexr s_ord f_ord Vs i foo (s,ti))
                             (g :: tt) then true
      (* 5. abstraction *)
      else if f_fun andalso (case t of (Abs (n,T,_)) => CC lref Mul Lex Lexr s_ord f_ord (Var ((n,i+1),T) :: Vs) (i+1) foo (s,Term.betapply (t,Var ((n,i+1),T)))
                                     | _ => false) then true
      (* 6. reduction *)
      (* too many reductions *)
      else false
    end

fun lhorpo lref Mul Lex Lexr s_ord f_ord = union_ord (lpo f_ord) (horpo lref Mul Lex Lexr s_ord f_ord)


end

structure Rpo : RPO = DB_Rpo
