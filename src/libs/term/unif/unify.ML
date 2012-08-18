(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gproof/unify/unify.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  
Higher-Order Unification.

Based on Isabelle's: Pure/unify.ML

Uses Instantiation environments instead of combined maxidx and
isabelle envir.

Types as well as terms are unified.  The outermost functions assume
the terms to be unified already have the same type. In resolution,
this is assured because both have type "prop".

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature MYUNIFY =
sig
  exception CANTUNIFY;  (* Signals non-unifiability.  Does not signal errors! *)
  exception ASSIGN;  (* Raised if not an assignment *)
  exception CHANGE_FAIL;   (* flexible occurrence of banned variable *)

  (* This exception is rasied when unification tries to instantiate a
     var with a badly typed term (cterm of it fails). In these cases
     Isabelle loops finding infinite unifiers and IsaPlanner raises
     the exception shown below. *)
  exception hounifiers_exp of (InstEnv.T * (term*term)list);

  val trace_bound: int Unsynchronized.ref
  val trace_simp: bool Unsynchronized.ref
  val trace_types: bool Unsynchronized.ref
  val search_bound: int Unsynchronized.ref

  (* no exceptions *)
  val match :  (term * term) list -> InstEnv.T -> InstEnv.T option
  val pattern_unify : (term * term) list -> InstEnv.T -> InstEnv.T option

  val unifiers : (InstEnv.T * ((term * term) list)) -> InstEnv.T Seq.seq
  val unifies : (InstEnv.T * ((term * term) list)) -> bool

  (* smash flex-flex pairs *)
  val smash_unifiers: ((term * term) list) -> InstEnv.T -> InstEnv.T Seq.seq

end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure MyUnify : MYUNIFY =
struct

(* Unification options *)

val trace_bound = Unsynchronized.ref 31  (* tracing starts above this depth, 0 for full *) (* 31 No-tracing!*)
and search_bound = Unsynchronized.ref 30 (* unification quits above this depth *)
and trace_simp = Unsynchronized.ref false  (* print dpairs before calling SIMPL *)
and trace_types = Unsynchronized.ref false (* announce potential incompleteness of type unification *)

type binderlist = (string*typ) list;

type dpair = binderlist * term * term;

fun body_type ienv =
let fun bT (Type("fun",[_,T])) = bT T
      | bT (T as TVar (ix,_)) = (case InstEnv.lookup_tvar_inst ienv ix of
                                   NONE => T | SOME(_,T') => bT T')
      | bT T = T
in bT end;

fun binder_types ienv =
let fun bTs (Type("fun",[T,U])) = T :: bTs U
      | bTs (T as TVar (ix,_)) = (case InstEnv.lookup_tvar_inst ienv ix of
                                    NONE => [] | SOME(_,T') => bTs T')
      | bTs _ = []
in bTs end;

fun strip_type ienv T = (binder_types ienv T, body_type ienv T);


(* OCCURS CHECK
  Does the uvar occur in the term t?
  two forms of search, for whether there is a rigid path to the current term.
  "seen" is list of variables passed thru, is a memo variable for sharing.
  This version searches for nonrigid occurrence, returns true if found.
  Since terms may contain variables with same name and different types,
  the occurs check must ignore the types of variables. This avoids
  that ?x::?'a is unified with f(?x::T), which may lead to a cyclic
  substitution when ?'a is instantiated with T later. *)
fun occurs_terms (seen: (indexname list) Unsynchronized.ref,
      ienv: InstEnv.T, v: indexname, ts: term list): bool =
  let fun occurs [] = false
  | occurs (t::ts) =  occur t  orelse  occurs ts
      and occur (Const _)  = false
  | occur (Bound _)  = false
  | occur (Free _)  = false
  | occur (Var (w, T))  =
      if member (op =) (!seen) w then false
      else if Trm.Var.NTab.name_eq(v,w) then true
        (*no need to lookup: v has no assignment*)
      else (seen := w:: !seen;
            case InstEnv.lookup_var_inst ienv w of
          NONE    => false
        | SOME (_,t) => occur t)
  | occur (Abs(_,_,body)) = occur body
  | occur (f$t) = occur t  orelse   occur f
  in  occurs ts  end;


(* f(a1,...,an)  ---->   (f,  [a1,...,an])  using the assignments *)
fun head_of_in (ienv,t) : term = case t of
    f$_ => head_of_in(ienv,f)
  | Var (ix,_) => (case InstEnv.lookup_var_inst ienv ix of
                     SOME (_,u) => head_of_in(ienv,u)   | NONE => t)
  | _ => t;


datatype occ = NoOcc | Nonrigid | Rigid;

(* Rigid occur check
Returns Rigid    if it finds a rigid occurrence of the variable,
        Nonrigid if it finds a nonrigid path to the variable.
        NoOcc    otherwise.
  Continues searching for a rigid occurrence even if it finds a nonrigid one.

Condition for detecting non-unifable terms: [ section 5.3 of Huet (1975) ]
   a rigid path to the variable, appearing with no arguments.
Here completeness is sacrificed in order to reduce danger of divergence:
   reject ALL rigid paths to the variable.
Could check for rigid paths to bound variables that are out of scope.
Not necessary because the assignment test looks at variable's ENTIRE rbinder.

Treatment of head(arg1,...,argn):
If head is a variable then no rigid path, switch to nonrigid search
for arg1,...,argn.
If head is an abstraction then possibly no rigid path (head could be a
   constant function) so again use nonrigid search.  Happens only if
   term is not in normal form.

Warning: finds a rigid occurrence of ?f in ?f(t).
  Should NOT be called in this case: there is a flex-flex unifier
*)
fun rigid_occurs_term (seen: (indexname list) Unsynchronized.ref, ienv, v: indexname, t) =
  let fun nonrigid t = if occurs_terms(seen,ienv,v,[t]) then Nonrigid
           else NoOcc
      fun occurs [] = NoOcc
  | occurs (t::ts) =
            (case occur t of
               Rigid => Rigid
             | oc =>  (case occurs ts of NoOcc => oc  |  oc2 => oc2))
      and occomb (f$t) =
            (case occur t of
               Rigid => Rigid
             | oc =>  (case occomb f of NoOcc => oc  |  oc2 => oc2))
        | occomb t = occur t
      and occur (Const _)  = NoOcc
  | occur (Bound _)  = NoOcc
  | occur (Free _)  = NoOcc
  | occur (Var (w, T))  =
      if member (op =) (!seen) w then NoOcc
      else if Term.eq_ix(v,w) then Rigid
      else (seen := w:: !seen;
            case InstEnv.lookup_var_inst ienv w of
          NONE    => NoOcc
        | SOME (_,t) => occur t)
  | occur (Abs(_,_,body)) = occur body
  | occur (t as f$_) =  (* switch to nonrigid search? *)
     (case head_of_in (ienv,f) of
        Var (w,_) => (* w is not assigned*)
    if Term.eq_ix(v,w) then Rigid
    else  nonrigid t
      | Abs(_,_,body) => nonrigid t (* not in normal form *)
      | _ => occomb t)
  in  occur t  end;


exception CANTUNIFY;  (* Signals non-unifiability.  Does not signal errors! *)
exception ASSIGN; (* Raised if not an assignment *)


fun unify_types (T,U,ienv) =
  (if T=U then ienv
   else snd (TypUnify.unify (U, T) ienv))
    handle TypUnify.TUNIFY => raise CANTUNIFY;


fun test_unify_types (args as (T,U,ienv)) =
let val str_of = Syntax.string_of_typ (InstEnv.get_ctxt ienv);
    fun warn() = tracing ("Potential loss of completeness: " ^ str_of U 
                          ^ " = " ^ str_of T);
    val ienv' = unify_types args
in if is_TVar T orelse is_TVar U then warn() else ();
   ienv'
end;

(* Is the term eta-convertible to a single variable with the given rbinder?
  Examples: ?a   ?f(B.0)   ?g(B.1,B.0)
  Result is var a for use in SIMPL. *)
fun get_eta_var ([], _, Var vT)  =  vT
  | get_eta_var (_::rbinder, n, f $ Bound i) =
  if  n=i  then  get_eta_var (rbinder, n+1, f)
     else  raise ASSIGN
  | get_eta_var _ = raise ASSIGN;

fun fastype ienv (bounds,u) = NormalForms.fastype_ntyps ienv bounds u;


(* Solve v=u by assignment -- "fixedpoint" to Huet -- if v not in u.
  If v occurs rigidly then nonunifiable.
  If v occurs nonrigidly then must use full algorithm. *)
fun assignment (ienv, rbinder, t, u) =
    let val (v,T) = get_eta_var (rbinder, 0, t)
    in  case rigid_occurs_term (Unsynchronized.ref [], ienv, v, u) of
          NoOcc => 
          let val ienv = unify_types (body_type ienv T,
                                          fastype ienv (rbinder,u), ienv)
          in InstEnv.add_var_inst (v, (T, Logic.rlist_abs (rbinder, u))) ienv end
        | Nonrigid =>  raise ASSIGN
        | Rigid =>  raise CANTUNIFY
    end;


(* Extends an rbinder with a new disagreement pair, if both are abstractions.
  Tries to unify types of the bound variables!
  Checks that binders have same length, since terms should be eta-normal;
    if not, raises TERM, probably indicating type mismatch.
  Uses variable a (unless the null string) to preserve user's naming.*)
fun new_dpair (rbinder, Abs(a,T,body1), Abs(b,U,body2), ienv) =
    let val ienv' = unify_types (T,U,ienv)
      val c = if a="" then b else a
    in new_dpair ((c,T) :: rbinder, body1, body2, ienv') end
  | new_dpair (_, Abs _, _, _) = raise TERM ("new_dpair", [])
  | new_dpair (_, _, Abs _, _) = raise TERM ("new_dpair", [])
  | new_dpair (rbinder, t1, t2, ienv) = ((rbinder, t1, t2), ienv);


fun head_norm_dpair (ienv, (rbinder,t,u)) : dpair * InstEnv.T =
    new_dpair (rbinder,
                    NormalForms.eta_short_head_norm ienv rbinder t,
                    NormalForms.eta_short_head_norm ienv rbinder u, 
                    ienv);

(* flexflex: the flex-flex pairs,  flexrigid: the flex-rigid pairs
  Does not perform assignments for flex-flex pairs:
    may create nonrigid paths, which prevent other assignments.
  Does not even identify Vars in dpairs such as ?a =?= ?b; an attempt to
    do so caused numerous problems with no compensating advantage.
*)
fun SIMPL0 (dp0, (ienv,flexflex,flexrigid))
    : InstEnv.T * dpair list * dpair list =
    let val (dp as (rbinder,t,u), ienv) = head_norm_dpair (ienv,dp0);
        fun SIMRANDS(f$t, g$u, ienv) =
            SIMPL0 ((rbinder,t,u), SIMRANDS(f,g,ienv))
          | SIMRANDS (t as _$_, _, _) =
            raise TERM ("SIMPL: operands mismatch", [t,u])
          | SIMRANDS (t, u as _$_, _) =
            raise TERM ("SIMPL: operands mismatch", [t,u])
          | SIMRANDS(_,_, ienv) = (ienv,flexflex,flexrigid);
    in case (head_of t, head_of u) of
         (Var(_,T), Var(_,U)) =>
         let val T' = body_type ienv T and U' = body_type ienv U;
                                       val ienv = unify_types (T',U',ienv)
         in (ienv, dp::flexflex, flexrigid) end
       | (Var _, _) =>
         ((assignment (ienv,rbinder,t,u), flexflex, flexrigid)
          handle ASSIGN => (ienv, flexflex, dp::flexrigid))
       | (_, Var _) =>
         ((assignment (ienv,rbinder,u,t), flexflex, flexrigid)
          handle ASSIGN => (ienv, flexflex, (rbinder,u,t)::flexrigid))
       | (Const(a,T), Const(b,U)) =>
         if a=b then SIMRANDS(t,u, unify_types (T,U,ienv))
         else raise CANTUNIFY
       | (Bound i,    Bound j)    =>
         if i=j  then SIMRANDS(t,u, ienv) else raise CANTUNIFY
       | (Free(a,T),  Free(b,U))  =>
         if a=b then SIMRANDS(t,u, unify_types (T,U,ienv))
         else raise CANTUNIFY
       | _ => raise CANTUNIFY
    end;


(* changed(ienv,t) checks whether the head of t is a variable assigned in ienv *)
fun changed (ienv, f$_) = changed (ienv,f)
  | changed (ienv, Var (ix,_)) =
      (case InstEnv.lookup_var_inst ienv ix of NONE=>false  |  _ => true)
  | changed _ = false;


(* Recursion needed if any of the 'head variables' have been updated
  Clever would be to re-do just the affected dpairs*)
fun SIMPL (ienv,dpairs) : InstEnv.T * dpair list * dpair list =
    let val all as (ienv',flexflex,flexrigid) =
            List.foldr SIMPL0 (ienv,[],[]) dpairs;
        val dps = flexrigid@flexflex
    in if exists (fn ((_,t,u)) => changed(ienv',t) orelse changed(ienv',u)) dps
       then SIMPL (ienv',dps) else all
    end;


(* Makes the terms E1,...,Em,    where Ts = [T...Tm].
  Each Ei is   ?Gi(B.(n-1),...,B.0), and has type Ti
  The B.j are bound vars of binder.
  The terms are not made in eta-normal-form, SIMPL does that later.
  If done here, eta-expansion must be recursive in the arguments! *)
fun make_args name (binder: typ list, ienv, []) = (ienv, [])   (*frequent case*)
  | make_args name (binder: typ list, ienv, Ts) : InstEnv.T * term list =
    let fun funtype T = (("F",0), binder ---> T);
        val binderlen = length binder;
        val (newvs, ienv') = 
            InstEnv.new_uninst_vars (map funtype Ts) ([],ienv)
    in  (ienv',  map (fn var => Logic.combound(Var var, 0, binderlen)) 
                     newvs)  end;

(* Abstraction over a list of types, like list_abs *)
fun types_abs ([],u) = u
  | types_abs (T::Ts, u) = Abs("", T, types_abs(Ts,u));

(* Abstraction over the binder of a type *)
fun type_abs (ienv,T,t) = types_abs(binder_types ienv T, t);


(* MATCH taking "big steps".
  Copies u into the Var v, using projection on targs or imitation.
  A projection is allowed unless SIMPL raises an exception.
  Allocates new variables in projection on a higher-order argument,
    or if u is a variable (flex-flex dpair).
  Returns long sequence of every way of copying u, for backtracking
  For example, projection in ?b'(?a) may be wrong if other dpairs constrain ?a.
  The order for trying projections is crucial in ?b'(?a)
  NB "vname" is only used in the call to make_args!!   *)
fun matchcopy vname = 
  let fun mc(rbinder, targs, u, ed as (ienv,dpairs))
    : (term * (InstEnv.T * dpair list))Seq.seq =
    let (* Produce copies of uarg and cons them in front of uargs *)
      fun copycons uarg (uargs, (ienv, dpairs)) =
          Seq.map(fn (uarg', ed') => (uarg'::uargs, ed'))
                 (mc (rbinder, targs,
                      NormalForms.eta_short_head_norm ienv rbinder uarg,
                      (ienv, dpairs)));
    (* Produce sequence of all possible ways of copying the arg list *)
      fun copyargs [] = Seq.cons ([],ed) Seq.empty
        | copyargs (uarg::uargs) = Seq.maps (copycons uarg) (copyargs uargs);
      val (uhead,uargs) = strip_comb u;
      val base = body_type ienv (fastype ienv (rbinder,uhead));
      fun joinargs (uargs',ed') = (list_comb(uhead,uargs'), ed');
        (* attempt projection on argument with given typ *)
      val Ts = map (curry (fastype ienv) rbinder) targs;
      fun projenv (head, (Us,bary), targ, tail) =
          let val ienv = if !trace_types then test_unify_types (base,bary,ienv)
                         else unify_types (base,bary,ienv)
          in Seq.make (fn () =>
                          let val (ienv',args) = make_args vname (Ts,ienv,Us);
                          (* higher-order projection: plug in targs for bound vars *)
                            fun plugin arg = list_comb(head_of arg, targs);
                            val dp = (rbinder, list_comb(targ, map plugin args), u);
                            val (ienv2,frigid,fflex) = SIMPL (ienv', dp::dpairs)
                          (* may raise exception CANTUNIFY *)
                          in  SOME ((list_comb(head,args), (ienv2, frigid@fflex)),
                                    tail)
                          end  handle CANTUNIFY => Seq.pull tail)
          end handle CANTUNIFY => tail;
          (* make a list of projections *)
      fun make_projs (T::Ts, targ::targs) =
          (Bound(length Ts), T, targ) :: make_projs (Ts,targs)
        | make_projs ([],[]) = []
        | make_projs _ = raise TERM ("make_projs", u::targs);
          (* try projections and imitation *)
      fun matchfun ((bvar,T,targ)::projs) =
          (projenv(bvar, strip_type ienv T, targ, matchfun projs))
        | matchfun [] = (* imitation last of all *)
          (case uhead of
             Const _ => Seq.map joinargs (copyargs uargs)
           | Free _  => Seq.map joinargs (copyargs uargs)
           | _ => Seq.empty)  (* if Var, would be a loop! *)
    in case uhead of
         Abs(a, T, body) =>
         Seq.map(fn (body', ed') => (Abs (a,T,body'), ed'))
                (mc ((a,T)::rbinder,
                     (map (incr_boundvars 1) targs) @ [Bound 0], body, ed))
       | Var (n,uary) => (* a flex-flex dpair: make variable for t *)
         let 
           val ty = Ts ---> base
           val (n2, ienv') = InstEnv.new_uninst_var (n, ty) ienv
           val newhd = Var (n2, ty)
           val tabs = Logic.combound(newhd, 0, length Ts)
           val tsub = list_comb(newhd,targs)
         in  Seq.single (tabs, (ienv', (rbinder,tsub,u):: dpairs))
         end
       | _ =>  matchfun(rev(make_projs(Ts, targs)))
    end
in mc end;


(* Call matchcopy to produce assignments to the variable in the dpair *)
fun MATCH (ienv, (rbinder,t,u), dpairs) : (InstEnv.T * dpair list) Seq.seq =
  let val (Var (vT as (v, T)), targs) = strip_comb t;
      val Ts = binder_types ienv T;
      fun new_dset (u', (ienv',dpairs')) =
    (* if v was updated to s, must unify s with u' *)
          case InstEnv.lookup_var_inst ienv' v of
            NONE => (InstEnv.add_var_inst (v, (T, types_abs(Ts, u'))) ienv', dpairs')
          | SOME (_,s) => (ienv', ([], s, types_abs(Ts, u'))::dpairs')
  in Seq.map new_dset (matchcopy (#1 v) (rbinder, targs, u, (ienv,dpairs)))
      
  end;



(**** Flex-flex processing ****)

(* At end of unification, do flex-flex assignments like ?a -> ?f(?b)
  Attempts to update t with u, raising ASSIGN if impossible *)
fun ff_assign (ienv, rbinder, t, u) : InstEnv.T =
let val vT as (v,T) = get_eta_var(rbinder,0,t)
in if occurs_terms (Unsynchronized.ref [], ienv, v, [u]) then raise ASSIGN
   else let val ienv = unify_types 
                        (body_type ienv T,
                             fastype ienv (rbinder,u), ienv)
  in InstEnv.add_var_inst (v, (T,Logic.rlist_abs (rbinder, u))) ienv end
end;


(* Flex argument: a term, its type, and the index that refers to it. *)
type flarg = {t: term,  T: typ,  j: int};


(* Form the arguments into records for deletion/sorting. *)
fun flexargs ([],[],[]) = [] : flarg list
  | flexargs (j::js, t::ts, T::Ts) = {j=j, t=t, T=T} :: flexargs(js,ts,Ts)
  | flexargs _ = error"flexargs";


(* If an argument contains a banned Bound, then it should be deleted.
  But if the only path is flexible, this is difficult; the code gives up!
  In  %x y.?a(x) =?= %x y.?b(?c(y)) should we instantiate ?b or ?c *)
exception CHANGE_FAIL;   (* flexible occurrence of banned variable *)


(*Check whether the 'banned' bound var indices occur rigidly in t*)
fun rigid_bound (lev, banned) t =
  let val (head,args) = strip_comb t
  in
      case head of
    Bound i => member (op =) banned (i-lev)  orelse
               exists (rigid_bound (lev, banned)) args
  | Var _ => false  (* no rigid occurrences here! *)
  | Abs (_,_,u) =>
         rigid_bound(lev+1, banned) u  orelse
         exists (rigid_bound (lev, banned)) args
  | _ => exists (rigid_bound (lev, banned)) args
  end;

(* Squash down indices at level >=lev to delete the banned from a term. *)
fun change_bnos banned =
  let fun change lev (Bound i) =
      if i<lev then Bound i
      else  if member (op =) banned (i-lev)
      then raise CHANGE_FAIL (**flexible occurrence: give up**)
      else  Bound (i - length (List.filter (fn j => j < i-lev) banned))
  | change lev (Abs (a,T,t)) = Abs (a, T, change(lev+1) t)
  | change lev (t$u) = change lev t $ change lev u
  | change lev t = t
  in  change 0  end;

(* Change indices, delete the argument if it contains a banned Bound*)
fun change_arg banned ({j,t,T}, args) : flarg list =
    if rigid_bound (0, banned) t  then  args  (* delete argument! *)
    else  {j=j, t= change_bnos banned t, T=T} :: args;


(* Sort the arguments to create assignments if possible:
  create eta-terms like ?g(B.1,B.0) *)
fun arg_less ({t= Bound i1,...}, {t= Bound i2,...}) = (i2<i1)
  | arg_less (_:flarg, _:flarg) = false;

(* Test whether the new term would be eta-equivalent to a variable --
  if so then there is no point in creating a new variable*)
fun decreasing n ([]: flarg list) = (n=0)
  | decreasing n ({j,...}::args) = j=n-1 andalso decreasing (n-1) args;

(* Delete banned indices in the term, simplifying it.
  Force an assignment, if possible, by sorting the arguments.
  Update its head; squash indices in arguments. *)
fun clean_term banned (ienv,t) =
    let val (v as Var(n,T), ts) = strip_comb t
      val (Ts,U) = strip_type ienv T
      val js = ((length ts) - 1) downto 0
      val args = sort (make_ord arg_less)
                      (List.foldr (change_arg banned) [] (flexargs (js,ts,Ts)))
      val ts' = map (#t) args
    in
      if decreasing (length Ts) args then (ienv, (list_comb(v, ts')))
      else 
        let 
          val ty = map (#T) args ---> U;
          val (n',ienv') = InstEnv.new_uninst_var (n, ty) ienv
          val v' = Var(n',ty)
          val body = list_comb(v', map (Bound o #j) args)
          val ienv2 = InstEnv.add_var_inst (n, (T,types_abs(Ts, body))) ienv'
             (* the vupdate affects ts' if they contain v *)
        in
          (ienv2, NormalForms.beta_inst ienv2 (list_comb(v',ts')))
        end
    end;


(* Add tpair if not trivial or already there.
  Should check for swapped pairs?? *)
fun add_tpair (rbinder, (t0,u0), tpairs) : (term*term) list =
  if t0 aconv u0 then tpairs
  else
  let val t = Logic.rlist_abs(rbinder, t0)  and  u = Logic.rlist_abs(rbinder, u0);
      fun same(t',u') = (t aconv t') andalso (u aconv u')
  in  if exists same tpairs  then tpairs  else (t,u)::tpairs  end;


(* Simplify both terms and check for assignments.
  Bound vars in the binder are "banned" unless used in both t AND u *)
fun clean_ffpair ((rbinder, t, u), (ienv,tpairs)) =
  let val loot = loose_bnos t  and  loou = loose_bnos u
      fun add_index (((a,T), j), (bnos, newbinder)) =
            if  member (op =) loot j  andalso  member (op =) loou j
            then  (bnos, (a,T)::newbinder)  (*needed by both: keep*)
            else  (j::bnos, newbinder);   (*remove*)
      val indices = 0 upto (length rbinder - 1);
      val (banned,rbin') = List.foldr add_index ([],[]) (rbinder~~indices);
      val (ienv', t') = clean_term banned (ienv, t);
      val (ienv'',u') = clean_term banned (ienv',u)
  in  (ff_assign (ienv'', rbin', t', u'), tpairs)
      handle ASSIGN => (ff_assign (ienv'', rbin', u', t'), tpairs)
      handle ASSIGN => (ienv'', add_tpair(rbin', (t',u'), tpairs))
  end
  handle CHANGE_FAIL => (ienv, add_tpair(rbinder, (t,u), tpairs));


(* IF the flex-flex dpair is an assignment THEN do it  ELSE  put in tpairs
  eliminates trivial tpairs like t=t, as well as repeated ones
  trivial tpairs can easily escape SIMPL:  ?A=t, ?A=?B, ?B=t gives t=t
  Resulting tpairs MAY NOT be in normal form:  assignments may occur here. *)
fun add_ffpair ((rbinder,t0,u0), (ienv,tpairs))
      : InstEnv.T * (term*term)list =
  let val t = NormalForms.beta_inst ienv t0 
      val u = NormalForms.beta_inst ienv u0
  in case  (head_of t, head_of u) of
      (Var(v,T), Var(w,U)) =>  (*Check for identical variables...*)
  if Term.eq_ix(v,w) then     (*...occur check would falsely return true!*)
      if T=U then (ienv, add_tpair (rbinder, (t,u), tpairs))
      else raise TERM ("add_ffpair: Var name confusion", [t,u])
  else if Term_Ord.indexname_ord (v, w) = LESS then 
       (*prefer to update the LARGER variable*)
       clean_ffpair ((rbinder, u, t), (ienv,tpairs))
        else clean_ffpair ((rbinder, t, u), (ienv,tpairs))
    | _ => raise TERM ("add_ffpair: Vars expected", [t,u])
  end;


(* Print a tracing message + list of dpairs.
  In t==u print u first because it may be rigid or flexible --
    t is always flexible. *)
fun print_dpairs msg (ienv,dpairs) =
  let fun pdp (rbinder,t,u) =
        let fun termT t = Syntax.pretty_term (InstEnv.get_ctxt ienv)
                              (NormalForms.beta_inst 
                                 ienv (Logic.rlist_abs(rbinder,t)))
            val bsymbs = [termT u, Pretty.str" =?=", Pretty.brk 1,
                          termT t];
        in tracing(Pretty.string_of(Pretty.blk(0,bsymbs))) end;
  in  tracing msg;  List.app pdp dpairs  end;


exception hounifiers_exp of (InstEnv.T * (term*term)list);

(* Unify the dpairs in the environment.
  Returns flex-flex disagreement pairs NOT IN normal form.
  SIMPL may raise exception CANTUNIFY. *)
(* Note: assumes the types of the terms already unify *)
fun hounifiers (ienv, tus : (term*term)list)
  : (InstEnv.T * (term*term)list)Seq.seq =
  let 
    fun add_unify tdepth ((ienv,dpairs), reseq) =
          Seq.make (fn()=>
            let val (ienv',flexflex,flexrigid) =
                    (if tdepth> !trace_bound andalso !trace_simp
                     then print_dpairs "Enter SIMPL IsaP" (ienv,dpairs)  else ();
                     SIMPL (ienv,dpairs))
            in case flexrigid of
                 [] => SOME (List.foldr add_ffpair (ienv',[]) flexflex, reseq)
               | dp::frigid' =>
                 if tdepth > !search_bound then
                   (warning "Unification bound exceeded (raising a TimeOut exception!)"; Seq.pull reseq; raise TimeLimit.TimeOut)
                 else
                   (if tdepth > !trace_bound then
                      print_dpairs "Enter MATCH IsaP" (ienv',flexrigid@flexflex)
                    else ();
                    Seq.pull (Seq.it_right 
                                (add_unify (tdepth+1))
                                (MATCH (ienv',dp, frigid'@flexflex), reseq)))
            end handle CANTUNIFY =>
                       (if tdepth > !trace_bound then tracing"Failure node" else ();
                        Seq.pull reseq)
                       (* happens when the terms types do not unify? *)
                     | Term.TYPE _ => 
                       raise hounifiers_exp (ienv, tus)
                   );
      val dps = map (fn(t,u)=> ([],t,u)) tus
  in add_unify 1 ((ienv, dps), Seq.empty) end;

(* IMPROVE: possible efficiency improvement: pass flex-flex-pairs
separately, as we have already checked that their types unify. Also
avoid term instantiation if it is not needed. *)
fun unifiers (params as (ienv, tus)) =
    let 
      val thry = InstEnv.get_theory ienv;
      (** Lucas: added unification of types before terms **)
      val ienv2 = TypUnify.unify_trms tus ienv
      (* val _ = writeln " --- outer TYP UNIF done. --- ";
      val _ = InstEnv.print_full ienv2; *)
      val tus' = map (fn (t,s) => (InstEnv.inst_trm ienv2 t, 
                                   InstEnv.inst_trm ienv2 s))
                     tus; 
    in (Seq.cons (fold MyPattern.unify tus' ienv2) Seq.empty)
       handle MyPattern.Unif => Seq.empty
            | MyPattern.Pattern => 
              Seq.map 
                (fn (ienv3,flexes) =>
                    InstEnv.set_flexes flexes ienv3)
                (hounifiers (InstEnv.set_flexes [] ienv2,
                             tus' @ (InstEnv.get_flexes ienv2)))
    end
    handle TypUnify.TUNIFY => Seq.empty;
(** **)

fun unifies params = 
    (case Seq.pull (unifiers params) of
       NONE => false
     | SOME _ => true);

(* matching and pattern unification without raising exceptions *)
fun match tus ienv = 
    SOME (fold MyPattern.match tus ienv)
    handle MyPattern.MATCH => NONE;

fun pattern_unify tus ienv = 
    SOME (fold MyPattern.unify tus ienv)
    handle MyPattern.Unif => NONE
         | MyPattern.Pattern => NONE;


(* For smash_flexflex1 *)
fun var_head_of (ienv,t) : indexname * typ =
  case head_of (strip_abs_body (NormalForms.beta_inst ienv t)) of
      Var(v,T) => (v,T)
    | _ => raise CANTUNIFY;  (* not flexible, cannot use trivial substitution *)


(* Eliminate a flex-flex pair by the trivial substitution, see Huet (1975)
  Unifies ?f(t1...rm) with ?g(u1...un) by ?f -> %x1...xm.?a, ?g -> %x1...xn.?a
  Unfortunately, unifies ?f(t,u) with ?g(t,u) by ?f, ?g -> %(x,y)?a,
  though just ?g->?f is a more general unifier.
  Unlike Huet (1975), does not smash together all variables of same type --
    requires more work yet gives a less general unifier (fewer variables).
  Handles ?f(t1...rm) with ?f(u1...um) to avoid multiple updates. *)
fun smash_flexflex1 ((t,u), ienv) : InstEnv.T =
  let val vT as (v,T) = var_head_of (ienv,t)
      and wU as (w,U) = var_head_of (ienv,u);
      val v2_ty = body_type ienv T;
      val (v2, ienv') = InstEnv.new_uninst_var (v,v2_ty) ienv
      val var = Var (v2, v2_ty)
      val ienv'' = InstEnv.add_var_inst (w, (U, type_abs (ienv', U, var))) ienv'
  in  if v = w then ienv''  (* the other update would be identical *)
      else InstEnv.add_var_inst (v, (T, type_abs (ienv', T, var))) ienv''
  end;


(* Smash all flex-flexpairs.  Should allow selection of pairs by a predicate? *)
fun smash_flexflex ienv : InstEnv.T =
  List.foldr smash_flexflex1 
        (InstEnv.set_flexes [] ienv) 
        (InstEnv.get_flexes ienv);

(* Returns unifiers with no remaining disagreement pairs *)
fun smash_unifiers tus ienv =
    Seq.map smash_flexflex (unifiers (ienv,tus));

end;
