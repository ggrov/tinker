(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/typed_terms_lib.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Date:       17 March 2003
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Code to create a term tree which contains the full type
    information at the application nodes.  (based on type1...)
    Essentially this is just used for quick eta-expansion
*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature TYPED_TERMS_LIB =
  sig
    type T

    val eta_expand : Term.term -> Term.term

    val eta_expand1 : T -> Term.term

    val of_term : Term.term -> T
    val term_of : T -> Term.term
    val type_of : T -> Term.typ
  end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure DB_TypedTermsLib 
= struct

datatype leaf = 
         TConst of string * typ
       | TFree of string * typ 
       | TVar of indexname * typ 
       | TBound of int;

datatype T = 
         TLf of (Term.typ * leaf)
       | TAbs of (Term.typ * (string * Term.typ * T))
       | TApp of (Term.typ * (T * T));

fun term_of_lf (TConst(s, ty)) = Term.Const (s, ty)
  | term_of_lf (TFree(s, ty)) = Term.Free (s, ty)
  | term_of_lf (TVar(i, ty)) = Term.Var (i, ty)
  | term_of_lf (TBound i) = Term.Bound i;

fun term_of (TApp (T,(s,t))) = (term_of s) $ (term_of t)
  | term_of (TAbs (T,(s,ty,t))) = Abs (s,ty, term_of t)
  | term_of (TLf (T,lf)) = term_of_lf lf;

fun type_of (TLf(T,_)) = T
  | type_of (TAbs(T,_)) = T
  | type_of (TApp(T,_)) = T;

(* Compute the type of the term, checking that combinations are well-typed
   Ts = [T0,T1,...] holds types of bound variables 0, 1, ...*)
fun of_term1 (Ts, Const (s,T)) = TLf(T, TConst(s,T))
    | of_term1 (Ts, Free  (s,T)) = TLf(T, TFree(s,T))
    | of_term1 (Ts, Bound i) = 
      (TLf(List.nth (Ts,i), TBound i)
       handle Subscript => raise TYPE("type_treetrm_of1: bound variable", 
                                   [], [Term.Bound i]))
    | of_term1 (Ts, Term.Var (n,T)) = TLf(T, TVar(n,T))
    | of_term1 (Ts, Term.Abs (s,T,t)) = 
      let val body = of_term1(T::Ts, t) in
        TAbs(T --> (type_of body),(s,T,body))
      end
    | of_term1 (Ts, f$u) =
      let val U = of_term1(Ts,u)
        and V = of_term1(Ts,f)
      in case type_of V of
           Type("fun",[T1,T2]) =>
           if T1 = (type_of U) then TApp(T2,(V,U)) else 
           raise TYPE ("type_treetrm_of1: type mismatch in application", 
                       [(type_of V), (type_of U)], [f$u])
         | _ => raise 
             TYPE ("type_treetrm_of1: function type is expected in application",
                   [(type_of V), (type_of U)], [f$u])
end
(* a type-annotated term from an Isabelle term.
   Starting with no outer bound vars (empty list) *)
fun of_term t = of_term1 ([], t);

(* add abstractions and applications of args to this term *)
fun add_abs args t = 
        (* add bound var args *)
    let 
      val (_,bnds) = 
          fold 
            (fn _ => fn (i,bnds) => (i+1, (Bound i)::bnds))
            args (0,[])
    in 
      Term.list_abs (map (fn x => ("", x)) args,Term.list_comb (t,bnds))
    end;

(* eta-expand non-head branches of a term *)
fun eta_expand_nonhd (TLf(ty, t)) = (term_of_lf t)
  | eta_expand_nonhd (TApp(ty,(t1,t2))) = 
    (eta_expand_nonhd t1) $ (eta_expand1 t2)
  | eta_expand_nonhd (TAbs(ty,(s,aty,t))) = 
    Abs(s,aty,eta_expand1 t)
(* exta-expand *)
and eta_expand1 (TLf(ty, lf)) = 
    let val (arg_types, dest_type) = Term.strip_type ty
    in add_abs arg_types (term_of_lf lf) end
  | eta_expand1 (t as TApp(ty,(t1,t2))) = 
    let val (arg_types, dest_type) = Term.strip_type ty
    in add_abs arg_types (eta_expand_nonhd t) end
  | eta_expand1 (TAbs(ty, (s, aty, t))) = 
    Abs (s,aty,eta_expand1 t);

(* eta-expand an Isabelle term *)
val eta_expand = eta_expand1 o of_term;

end;

structure TypedTermsLib : TYPED_TERMS_LIB = DB_TypedTermsLib;
