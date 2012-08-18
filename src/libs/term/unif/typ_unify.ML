(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gproof/unify/typ_unify.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  
   Unification for Types using instantiation environments.

   Written by Lucas Dixon, inspired from Isabelle's Pure/type.ML
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature TYPUNIFY =
sig
  (* raised when types do not unify/match *)
  exception TUNIFY;
  exception TYPE_MATCH;

  (* raised when ienv doesnt contain an expected var *)
  exception not_in_ienv_exp of string * InstEnv.T 
  (* internal error *)
  exception badness_exp of string;
  exception unify_typsof_terms_exp of (Term.term * Term.term) list * InstEnv.T;

  (* unification and matching *)
  (* throws exception! *)
  val unify: typ * typ -> InstEnv.T  
             -> (Trm.TVar.NSet.T (* new introduced vars *)
                 * InstEnv.T)
                
  val try_unify: typ * typ -> InstEnv.T 
                 -> (Trm.TVar.NSet.T (* new introduced vars *)
                     * InstEnv.T) option

  val unify_trms: (term * term) list -> InstEnv.T 
                  -> InstEnv.T

  val match: typ * typ -> InstEnv.T -> InstEnv.T

end;


(* TYPE unification: copied from Isabelle type.ML *)
structure TypUnify : TYPUNIFY= 
struct

(* raised when types do not unify/match *)
exception TUNIFY;
exception TYPE_MATCH;

exception not_in_ienv_exp of string * InstEnv.T ;
exception badness_exp of string;

(* Occurs check *)
fun occurs v ienv =
  let
    fun occ (Type (_, Ts)) = List.exists occ Ts
      | occ (TFree _) = false
      | occ (TVar (w, S)) =
          Trm.TVar.NTab.name_eq (v, w) orelse
            (case InstEnv.lookup_tvar ienv w of
              NONE => raise not_in_ienv_exp ("occurs:", ienv)
            | SOME (_,NONE) => false
            | SOME (_,SOME U) => occ U);
  in occ end;

(* indicates an error: somehow the same variable ended up with two different sorts. *)
fun tvar_clash n S S' =
    raise Term.TYPE ("Type variable " 
                ^ Library.quote (Trm.TVar.NTab.string_of_name n) 
                ^ " has two distinct sorts",
                [TVar (n, S), TVar (n, S')], []);

(* get instantiated type: lookup from table in case it is now instantiated *)
fun devar ienv (T as TVar (v,ty)) =
    (case InstEnv.lookup_tvar_inst ienv v of
        SOME (srt,U) => U (* do not chase; instenv has done it for us *)
      | NONE => T)
  | devar ienv T = T;

(*order-sorted unification*)
(* assumes all type vars are already known about in ienv *)
fun unify TU ienv =
  let
    val thry = InstEnv.get_theory ienv;

    val {classes = (_, classes), ...} = Type.rep_tsig (Sign.tsig_of thry);
 
    (* makes a list of most general sorts for arguments of "a", based
       on result type of "a" being in sort "S" *)
    fun mg_domain a S = Sorts.mg_domain classes a S
      handle Sorts.CLASS_ERROR _ => raise TUNIFY;

    (* try to unify given type (possibly-non-var type) 
       with sorts of another var, *)
    fun meet (_, []) newvs_ienv = newvs_ienv
      | meet (TVar (n, S'), S) (newvs_ienv as (newvs,ienv)) =
          if Sorts.sort_le classes (S', S) then newvs_ienv
          else (* instantiate to new var of sort intersection *)
            let val S2 = (Sorts.inter_sort classes (S', S))
              val (n2,ienv2) = InstEnv.new_uninst_tvar (("'a",0),S2) ienv
            in (Trm.TVar.NSet.add n2 newvs,
                InstEnv.add_tvar_inst (n,(S', TVar(n2,S2))) ienv2) end
      | meet (TFree (_, S'), S) ienv =
          if Sorts.sort_le classes (S', S) then ienv else raise TUNIFY
      | meet (Type (a, Ts), S) ienv = meets (Ts, mg_domain a S) ienv
    (* assumes length Ts = length Ss *)
    and meets (T :: Ts, S :: Ss) (newvs_ienv as (newvs,ienv)) = 
        meets (Ts, Ss) (meet (devar ienv T, S) newvs_ienv)
      | meets _ newvs_ienv = newvs_ienv;

    (* unification of two types, creates list of new vars *)
    fun unif (ty1, ty2) (newvs_ienv as (newvs,ienv)) =
        (case (devar ienv ty1, devar ienv ty2) of
           (T as TVar (v, S1), U as TVar (w, S2)) =>
           if Trm.TVar.NTab.name_eq (v, w) then
             if S1 = S2 then newvs_ienv 
             else tvar_clash v S1 S2 (* Should never happen! *)
           else if Sorts.sort_le classes (S1, S2) then
             (newvs, InstEnv.add_tvar_inst (w, (S2, T)) ienv)
           else if Sorts.sort_le classes (S2, S1) then
             (newvs, InstEnv.add_tvar_inst (v, (S1, U)) ienv)
           else
             let val S3 = Sorts.inter_sort classes (S1, S2) 
               val (n3,ienv2) = InstEnv.new_uninst_tvar (("'a",0),S3) ienv
               val v3 = TVar(n3,S3)
             in
               (Trm.TVar.NSet.add n3 newvs,
                ienv2 |> InstEnv.add_tvar_inst (v, (S1, v3)) 
                      |> InstEnv.add_tvar_inst (w, (S2, v3)))
             end
      | (TVar (v, S), T) =>
        if occurs v ienv T then raise TUNIFY
        else meet (T, S) (newvs,InstEnv.add_tvar_inst (v, (S, T)) ienv)
      | (T, TVar (v, S)) =>
        if occurs v ienv T then raise TUNIFY
        else meet (T, S) (newvs,InstEnv.add_tvar_inst (v, (S, T)) ienv)
      | (Type (a, Ts), Type (b, Us)) =>
        if a <> b then raise TUNIFY (* a = b ==> length Ts == length Us *)
        else unifs (Ts, Us) newvs_ienv
      | (T, U) => (* TFree ... = TFree ... *)
        if T = U then newvs_ienv else raise TUNIFY)
    (* assumes length Ts = length Us *)
    and unifs (T :: Ts, U :: Us) newvs_ienv = 
        unifs (Ts, Us) (unif (T, U) newvs_ienv)
      | unifs _ newvs_ienv = newvs_ienv;
  in unif TU (Trm.TVar.NSet.empty,ienv) end;


fun try_unify (ty1,ty2) ienv = 
    SOME (unify (ty1,ty2) ienv) handle TUNIFY => NONE;


fun match (ty1,ty2) ienv =
  let
    val thry = InstEnv.get_theory ienv;
    val tsig = Sign.tsig_of thry;
    fun matchr (TVar (v, S), T) subs =
          (case InstEnv.lookup_tvar_inst subs v of
            NONE =>
              if Type.of_sort tsig (T, S) then 
                InstEnv.add_tvar_inst (v, (S, T)) subs
              else raise TYPE_MATCH
          | SOME (_,U) => if U = T then subs else raise TYPE_MATCH)
      | matchr (Type (a, Ts), Type (b, Us)) subs =
          if a <> b then raise TYPE_MATCH
          else matches (Ts, Us) subs
      | matchr (TFree x, TFree y) subs =
          if x = y then subs else raise TYPE_MATCH
      | matchr _ _ = raise TYPE_MATCH
    and matches (T :: Ts, U :: Us) subs = matches (Ts, Us) (matchr (T, U) subs)
      | matches _ subs = subs;
  in matchr (ty1,ty2) ienv end;

exception unify_typsof_terms_exp of 
          (Term.term * Term.term) list * InstEnv.T;

fun unify_trms ts ienv = 
    fold (fn (t1,t2) => snd o (unify (Term.type_of t1, Term.type_of t2)))
         ts ienv
    handle Term.TYPE _ => raise unify_typsof_terms_exp (ts, ienv);

end; (* struct *)


(* 

Type("List.list", [TFree("'a", ["HOL.type"])])


(* create a new theory using IsaP and Main *)
val thry = Theory.begin_theory "test" [theory "Main"];
ML_Context.set_context (SOME (Context.Theory thry));

TermDbg.writeterm (Sign.read_term thry "((a :: nat) + b) + length t");

val (tyenv,maxidx) = 
    Type.unify tsig (Type("fun", [Type("nat", []), 
                                  Type("fun", [Type("nat", []), Type("nat", [])])]),
                     TVar(("X",0),[]))
               (Vartab.empty,0);

*)
