(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gproof/unify/typ_unify.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  
   Normal forms for terms

   Written by Lucas Dixon, inspired from Isabelle's Pure/envir.ML
   
   Naming convension:  
   ..._same = raises SAME exception if no change to object
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature NORMAL_FORMS
= sig
  (* typ inst *)
  val inst_type_same: InstEnv.T -> typ -> typ
  val inst_type: InstEnv.T -> typ -> typ

  (* beta *)
  val beta_norm_same: term -> term
  val beta_norm: term -> term

  val beta_inst_same: InstEnv.T -> term -> term
  val beta_inst: InstEnv.T -> term -> term

  val head_norm_same: InstEnv.T -> term -> term
  val head_norm: InstEnv.T -> term -> term

  (* eta *)
  val eta_short_same: term -> term
  val eta_short: term -> term
  val eta_long_beta_norm: typ list -> term -> term
  val beta_eta_contract: term -> term

  (* exotic and compound normal forms *)
  val fastype_typs: InstEnv.T -> typ list -> term -> typ
  val fastype_ntyps: InstEnv.T -> (string * typ) list -> term -> typ
  val eta_fun_short_instyps: InstEnv.T -> (string * typ) list -> term -> term
  val eta_short_head_norm: InstEnv.T -> (string * typ) list -> term -> term
end;

structure NormalForms 
: NORMAL_FORMS
= struct

(*** Beta normal form for terms (not eta normal form).
     Chases variables in env;  Does not exploit sharing of variable bindings
     Does not check types, so could loop. ***)

(*raised when norm has no effect on a term, to do sharing instead of copying*)
exception SAME;

(* naming convention: 
..._same = raises SAME exception if no change to object 
...1... or ...2... = indicates an internal function, without these
numbers we perform some preliminary checks, eg for empty ienv etc
*)

(* memory-efficient instantiation of types *)
fun inst_type1_same ienv =
    let 
      fun normT_same (Type (a, Ts)) = Type (a, normTs_same Ts)
        | normT_same (TFree _) = raise SAME
        | normT_same (TVar(n,_)) = (case InstEnv.lookup_tvar_inst ienv n of
                                    (* if in ienv, then already has been inst. *)
                                    SOME (_,U) => U 
                                  | NONE => raise SAME)
      and normT ty = normT_same ty handle SAME => ty
      and normTs_same [] = raise SAME
        | normTs_same (T :: Ts) =
          ((normT_same T :: (normTs_same Ts handle SAME => Ts))
           handle SAME => T :: normTs_same Ts);
    in normT end
fun inst_type1 ienv ty = inst_type1_same ienv ty handle SAME => ty;

(* prechecked versions of memory-efficient instantiation of types *)
fun inst_type_same ienv =
    if InstEnv.no_inst_tvars ienv then raise SAME
    else inst_type1_same ienv;
fun inst_type ienv ty = inst_type1_same ienv ty handle SAME => ty;


(* memory-efficient beta-contract *)
fun beta_norm_same (Abs(a,T,body)) = Abs(a, T, beta_norm_same body)
  | beta_norm_same (Abs(_,_,body) $ t) = beta_norm (subst_bound (t, body))
  | beta_norm_same (f $ t) =
    ((case beta_norm_same f of
        Abs(_,_,body) => beta_norm (subst_bound (t, body))
      | nf => nf $ (beta_norm_same t handle SAME => t))
     handle SAME => f $ beta_norm_same t)
  | beta_norm_same _ =  raise SAME
and beta_norm t = (beta_norm_same t) handle SAME => t;


(* memory-efficient beta-contract and instantiation of term vars *)
fun beta_inst1_same ienv =
    let fun norm_same (Var (n,ty)) =
            (case InstEnv.lookup_var_inst ienv n of
              (* if in ienv, then already has been inst. *)
              SOME (ty,u) => (beta_norm u)
             | NONE   => raise SAME)
          | norm_same (Abs(a,T,body)) = Abs(a, T, norm_same body)
          | norm_same (Abs(_,_,body) $ t) = norm (subst_bound (t, body))
          | norm_same (f $ t) =
            ((case norm f of
                Abs(_,_,body) => norm (subst_bound (t, body))
              | nf => nf $ (norm_same t handle SAME => t))
             handle SAME => f $ norm_same t)
          | norm_same _ =  raise SAME
      and norm t = (norm_same t) handle SAME => t
  in norm_same end;

(* memory-efficient beta-contract and instantiation term and typ vars *)
fun beta_inst2_same ienv =
  let 
    val norm_typf_same = inst_type_same ienv;
    fun norm_same (Const (a, T)) = Const(a, norm_typf_same T)
        | norm_same (Free (a, T)) = Free(a, norm_typf_same T)
        | norm_same (Var (w, T)) =
            (case InstEnv.lookup_var_inst ienv w of
                SOME (ty,u) => beta_norm u
              | NONE => Var(w, norm_typf_same T))
        | norm_same (Abs (a, T, body)) =
               (Abs (a, norm_typf_same T, 
                     norm body) handle SAME => Abs (a, T, norm_same body))
        | norm_same (Abs(_, _, body) $ t) = norm (subst_bound (t, body))
        | norm_same (f $ t) =
            ((case norm_same f of
               Abs(_, _, body) => norm (subst_bound (t, body))
             | nf => nf $ norm t)
            handle SAME => f $ norm_same t)
        | norm_same _ =  raise SAME
      and norm t = (norm_same t) handle SAME => t
  in norm_same end;

(* use most efficient function depending on instantiations in ienv *)
fun beta_inst_same ienv =
  if InstEnv.no_inst_tvars ienv then beta_inst1_same ienv
  else if InstEnv.no_inst_vars ienv then beta_norm_same
  else beta_inst2_same ienv;
fun beta_inst ienv t = beta_inst_same ienv t handle SAME => t;


(* Put a term into head normal form for unification. *)
fun head_norm_same ienv =
  let
    fun hnorm_same (Var (n,_)) = 
        (case InstEnv.lookup_var_inst ienv n of
           SOME (_,u) => hnorm u
         | NONE => raise SAME)
      | hnorm_same (Abs (a, T, body)) =  Abs (a, T, hnorm_same body)
      | hnorm_same (Abs (_, _, body) $ t) =
          hnorm (subst_bound (t, body))
      | hnorm_same (f $ t) = 
        (case hnorm_same f of
           Abs (_, _, body) => hnorm (subst_bound (t, body))
         | nf => nf $ t)
      | hnorm_same _ =  raise SAME
    and hnorm t = hnorm_same t handle SAME => t
  in hnorm_same end;

fun head_norm ienv t = head_norm_same ienv t handle SAME => t;


(* Eta-contract a term (fully) *)
fun decr lev (Bound i) = if i >= lev then Bound (i - 1) else raise SAME
  | decr lev (Abs (a, T, body)) = Abs (a, T, decr (lev + 1) body)
  | decr lev (t $ u) = (decr lev t $ decrh lev u handle SAME => t $ decr lev u)
  | decr _ _ = raise SAME
and decrh lev t = (decr lev t handle SAME => t);

fun eta_short_same (Abs (a, T, body)) =
    ((case eta_short_same body of
        body' as (f $ Bound 0) =>
          if loose_bvar1 (f, 0) then Abs (a, T, body')
          else decrh 0 f
     | body' => Abs (a, T, body')) handle SAME =>
        (case body of
          f $ Bound 0 =>
            if loose_bvar1 (f, 0) then raise SAME
            else decrh 0 f
        | _ => raise SAME))
  | eta_short_same (t $ u) = 
    (eta_short_same t $ eta_short u handle SAME => t $ eta_short_same u)
  | eta_short_same _ = raise SAME
and eta_short t = (eta_short_same t handle SAME => t);

(* put a term into eta long beta normal form *)
fun eta_long_beta_norm Ts (Abs (s, T, t)) = 
    Abs (s, T, eta_long_beta_norm (T :: Ts) t)
  | eta_long_beta_norm Ts t = (case strip_comb t of
      (Abs _, _) => eta_long_beta_norm Ts (beta_norm t)
    | (u, ts) =>
      let
        val Us = binder_types (fastype_of1 (Ts, t));
        val i = length Us
      in list_abs (map (pair "x") Us,
        list_comb (incr_boundvars i u, map (eta_long_beta_norm (rev Us @ Ts))
          (map (incr_boundvars i) ts @ map Bound (i - 1 downto 0))))
      end);


(*finds type of term without checking that combinations are consistent
  Ts holds types of bound variables*)
fun fastype_typs ienv =
let val funerr = "fastype_typs: expected function type";
    fun fast Ts (f $ u) =
        (case fast Ts f of
           Type ("fun", [_, T]) => T
         | TVar (ix,_) =>
                (case InstEnv.lookup_tvar_inst ienv ix of
                   SOME (_,Type ("fun", [_, T])) => T
                 | _ => raise TERM (funerr, [f $ u]))
         | _ => raise TERM (funerr, [f $ u]))
      | fast Ts (Const (_, T)) = T
      | fast Ts (Free (_, T)) = T
      | fast Ts (Bound i) =
        (List.nth (Ts, i)
         handle Subscript => raise TERM ("fastype_typs: Bound", [Bound i]))
      | fast Ts (Var (_, T)) = T
      | fast Ts (Abs (_, T, u)) = T --> fast (T :: Ts) u
in fast end;

(* as above but for binder list containing named types *)
fun fastype_ntyps ienv =
let val funerr = "fastype_ntyps: expected function type";
    fun fast Ts (f $ u) =
        (case fast Ts f of
           Type ("fun", [_, T]) => T
         | TVar (ix,_) =>
                (case InstEnv.lookup_tvar_inst ienv ix of
                   SOME (_,Type ("fun", [_, T])) => T
                 | _ => raise TERM (funerr, [f $ u]))
         | _ => raise TERM (funerr, [f $ u]))
      | fast Ts (Const (_, T)) = T
      | fast Ts (Free (_, T)) = T
      | fast Ts (Bound i) =
        (snd (List.nth (Ts, i))
         handle Subscript => raise TERM ("fastype_ntyps: Bound", [Bound i]))
      | fast Ts (Var (_, T)) = T
      | fast Ts (Abs (a, T, u)) = T --> fast ((a,T) :: Ts) u
in fast end;


(* Eta short normal form w.r.t. "fun" type, having instantiated tvars. *)
fun eta_fun_short_instyps ienv =
    let 
      fun etif (Type("fun",[T,U])) t =
          Abs("", T, etif U (incr_boundvars 1 t $ Bound 0))
        | etif (TVar (ix,_)) t =
          (case InstEnv.lookup_tvar_inst ienv ix of
             NONE => t | SOME(_,T) => etif T t )
        | etif _ t = t;

      fun eta_nm rbinder (Abs(a,T,body)) =
          Abs(a, T, eta_nm ((a,T)::rbinder) body)
        | eta_nm rbinder t = etif (fastype_ntyps ienv rbinder t) t 
    in eta_nm end;

fun eta_short_head_norm ienv rbinder t = 
    eta_fun_short_instyps ienv rbinder (head_norm ienv t);

(* beta-eta *)

val beta_eta_contract = eta_short o beta_norm;

end;
