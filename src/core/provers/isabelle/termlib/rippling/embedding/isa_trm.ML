

signature ISA_TRM = TRM
 where type TVar.name = string * int
   and type TFree.name = string
   and type Var.name = string * int
   and type Free.name = string
   and type sort = Term.sort
   and type typ = Term.typ
   and type T = Term.term


structure TVar = StrIntName;
structure TFree = StrName;
structure Var = StrIntName;
structure Free = StrName;

(* Isabelle terms where vars have a string and index *)
(* structure DB_BasicTrm *)
structure DB_Trm 
= struct

  type sort = Term.sort;
  type typ = Term.typ; 

  structure TVar = TVar;
  structure TFree = TFree;
  structure Var = Var;
  structure Free = Free;

  fun free_of_var_name (x,i) = x;
  fun tfree_of_tvar_name (x,i) = x;
  fun var_of_free_name x = (x,0);
  fun tvar_of_tfree_name x = (x,0);

  val pretty_sort = Syntax.pretty_sort;
  val pretty_typ = Syntax.pretty_typ;
  fun eq_sort x = (Term_Ord.sort_ord x = EQUAL)
  fun eq_typ x = (Term_Ord.typ_ord x = EQUAL);

  fun eq x = (Term_Ord.term_ord x = EQUAL);

(*   val default_var_name = ("vty",0);
  val default_free_pname = "fty"; *)

  structure TypParams : PARAM_TAB 
  = ParamTabFUN(
  struct
    structure Names = TFree;
    type kind = sort;
    val pretty_kind = pretty_sort;
  end);

  structure TrmParams : PARAM_TAB 
  = ParamTabFUN(
  struct
    structure Names = Free;
    type kind = typ;
    val pretty_kind = pretty_typ;
  end);

  type vtab = sort TVar.NTab.T * typ Var.NTab.T

  fun pretty_vtab (tvs,vs) = 
        Pretty.chunks 
          [ Pretty.block 
              [ Pretty.str "TVars: ",
                Pretty.list "[" "]" (map TVar.pretty_name 
                                         (TVar.NTab.keys tvs)) ],
            Pretty.block 
              [ Pretty.str "Vars: ",
                Pretty.list "[" "]" (map Var.pretty_name 
                                         (Var.NTab.keys vs)) ]
          ];
    val print_vtab : vtab -> unit = Pretty.writeln o pretty_vtab;

    type T = Term.term; (* Isabelle term *)
    
    (* general exception *)
    exception exp of string

    fun opt_dest_var (Var x) = SOME x
      | opt_dest_var _ = NONE;
    fun opt_dest_tvar (TVar x) = SOME x
      | opt_dest_tvar _ = NONE;

    fun dest_var (Var x) = x
      | dest_var _ = raise exp "dest_var" ;
    fun dest_tvar (TVar x) = x
      | dest_tvar _ = raise exp "dest_tvar";
  
    (* term constructor *)
    val mk_var = Var;
    val mk_abs = Abs;
    val mk_app = (op $);
    val mk_free = Free;
    val mk_tvar = TVar;
    val mk_tfree = TFree;

    (* structural info *)
    fun is_abs (Abs _) = true
      | is_abs _ = false;
    fun is_app (a $ b) = true
      | is_app _ = false;
    fun is_leaf (Abs _) = false
      | is_leaf (_ $ _) = false
      | is_leaf _ = true;
 
    (* Lookup consts in an equation, gives list (with repetitions for each occurance of the same
     constant) of all constants in the term eq. *)
    fun constnames_of t = 
        (Zipper.mktop t)
        |> ZipperSearch.leaves_lr
        |> Seq.map_filter (fn zl => case (Zipper.trm zl) of 
                                     Const(nm,ty) => SOME nm
                                     | _ => NONE)
        |> Seq.list_of;

    fun consts_of t = 
        (Zipper.mktop t)
        |> ZipperSearch.leaves_lr
        |> Seq.map_filter (fn zl => case (Zipper.trm zl) of 
                                     Const(nm,ty) => SOME (nm,ty)
                                     | _ => NONE)
        |> Seq.list_of;


    fun atomic_typconsts_of_typ (Type (s, [])) = [s]
      | atomic_typconsts_of_typ (Type (s, l)) = maps atomic_typconsts_of_typ l
      | atomic_typconsts_of_typ (TFree _) = []
      | atomic_typconsts_of_typ (TVar _) = [];

    (* map types and terms *)
    fun map_typ_tvars f = Term.map_type_tvar (fn x => f (x, TVar x));
    fun map_typ_tfrees f = Term.map_type_tfree (fn x => f (x, TFree x));
    val map_trm_types = Term.map_types;
    val map_trm_tvars = map_trm_types o map_typ_tvars;
    fun map_trm_vars f t = 
        let 
          fun subst (v as Var x) = f (x, v)
            | subst (Abs(s,ty,t)) = Abs(s,ty,subst t)
            | subst (a$b) = subst a $ subst b
            | subst t = t
        in subst t end;

    (* a lonely lost little library function: should be somewhere else. 
       see library.ML *)
    fun foldmap f x (h::t) = 
        let val (x2,h2) = f x h 
          val (x3,t2) = foldmap f x2 t
        in (x3,h2::t2) end
      | foldmap f x [] = (x,[]);

    (* folding and possibly changing vars *)
    fun foldmap_typ_tvars f x t = 
        let 
          fun fld x (Type(s, tyl)) = 
              let val (x2,tyl2) = foldmap fld x tyl
              in (x2,Type(s, tyl2)) end
            | fld x (t as (TVar rep)) = f x (rep,t)
            | fld x (t as (TFree _ )) = (x,t)
        in fld x t end;

    fun foldmap_trm_tvars f x t = 
        let 
          fun fld x (v as Var (n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tvars f x ty 
              in (x2,Var(n,ty2)) end
            | fld x (Abs(s,ty,t)) = 
              let val (x2,ty2) = foldmap_typ_tvars f x ty
                val (x3,t2) = fld x2 t
              in (x3,Abs(s,ty2,t2)) end
            | fld x (a$b) =  
              let val (x2,a2) = fld x a
                val (x3,b2) = fld x2 b
              in (x3,a2$b2) end
            | fld x (Free(n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tvars f x ty 
              in (x2,Free(n,ty2)) end
            | fld x (Const(n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tvars f x ty 
              in (x2,Const(n,ty2)) end
            | fld x (t as Bound _) = (x,t)
        in fld x t end;

    fun foldmap_trm_vars f x t = 
        let 
          fun fld x (v as Var rep) = f x (rep, v)
            | fld x (Abs(s,ty,t)) = 
              let val (x2,t2) = fld x t
              in (x2,Abs(s,ty,t2)) end
            | fld x (a$b) = 
              let val (x2,a2) = fld x a
                val (x3,b2) = fld x2 b
              in (x3,a2$b2) end
            | fld x t = (x,t)
        in fld x t end;

    (* foldmap over term and typ vars. Note those in the type of the
    var before we do the var itself *)
    fun foldmap_trm_vars_and_tvars tvarsf varf x t = 
        let 
          fun fld x (v as Var (n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tvars tvarsf x ty
              in varf x2 ((n,ty2), Var(n,ty2)) end
            | fld x (Abs(s,ty,t)) = 
              let val (x2,t2) = fld x t
                val (x3,ty2) = foldmap_typ_tvars tvarsf x2 ty
              in (x3,Abs(s,ty2,t2)) end
            | fld x (a$b) = 
              let val (x2,a2) = fld x a
                val (x3,b2) = fld x2 b
              in (x3,a2$b2) end
            | fld x (Const(c,ty)) = 
              let val (x2,ty2) = foldmap_typ_tvars tvarsf x ty
              in (x2,Const(c,ty2)) end
            | fld x (Free (n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tvars tvarsf x ty
              in (x2,Free(n,ty2)) end
            | fld x (t as Bound i) = (x,t)
        in fld x t end;




(* foldmaps for frees *)

    (* folding and possibly changing vars *)
    fun foldmap_typ_tfrees f x t = 
        let 
          fun fld x (Type(s, tyl)) = 
              let val (x2,tyl2) = foldmap fld x tyl
              in (x2,Type(s, tyl2)) end
            | fld x (t as (TVar rep)) = (x,t)
            | fld x (t as (TFree rep )) = f x (rep,t)
        in fld x t end;

    fun foldmap_trm_tfrees f x t = 
        let 
          fun fld x (v as Var (n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tfrees f x ty 
              in (x2,Var(n,ty2)) end
            | fld x (Abs(s,ty,t)) = 
              let val (x2,ty2) = foldmap_typ_tfrees f x ty
                val (x3,t2) = fld x2 t
              in (x3,Abs(s,ty2,t2)) end
            | fld x (a$b) =  
              let val (x2,a2) = fld x a
                val (x3,b2) = fld x2 b
              in (x3,a2$b2) end
            | fld x (Free(n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tfrees f x ty 
              in (x2,Free(n,ty2)) end
            | fld x (Const(n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tfrees f x ty 
              in (x2,Const(n,ty2)) end
            | fld x (t as Bound _) = (x,t)
        in fld x t end;

    fun foldmap_trm_frees f x t = 
        let 
          fun fld x (v as Free rep) = f x (rep, v)
            | fld x (Abs(s,ty,t)) = 
              let val (x2,t2) = fld x t
              in (x2,Abs(s,ty,t2)) end
            | fld x (a$b) = 
              let val (x2,a2) = fld x a
                val (x3,b2) = fld x2 b
              in (x3,a2$b2) end
            | fld x t = (x,t)
        in fld x t end;

   fun foldmap_trm_frees_and_tfrees tfreesf freesf x t = 
        let 
          fun fld x (Var (n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tfrees tfreesf x ty
              in (x2,Var(n,ty2)) end
            | fld x (v as Free (n,ty)) = 
              let val (x2,ty2) = foldmap_typ_tfrees tfreesf x ty
              in freesf x2 ((n,ty2), Free(n,ty2)) end
            | fld x (Abs(s,ty,t)) = 
              let val (x2,t2) = fld x t
                val (x3,ty2) = foldmap_typ_tfrees tfreesf x2 ty
              in (x3,Abs(s,ty2,t2)) end
            | fld x (a$b) = 
              let val (x2,a2) = fld x a
                val (x3,b2) = fld x2 b
              in (x3,a2$b2) end
            | fld x (Const(c,ty)) = 
              let val (x2,ty2) = foldmap_typ_tfrees tfreesf x ty
              in (x2,Const(c,ty2)) end
            | fld x (t as Bound i) = (x,t)
        in fld x t end;


(* Three kinds of mapping to term frees, optimised for need of
   different kinds of information *)
    fun map_trm_frees_wl l f t = 
        let 
          fun subst l (v as Free x) = f ((x,v),l)
            | subst l (Abs(s,ty,t)) = Abs(s,ty,subst (l + 1) t)
            | subst l (a$b) = subst l a $ subst l b
            | subst l t = t
        in subst l t end;
    fun map_trm_frees_wtys Ts f t = 
        let 
          fun subst Ts (v as Free x) = f ((x,v),Ts)
            | subst Ts (Abs(s,ty,t)) = Abs(s,ty,subst ((s,ty)::Ts) t)
            | subst Ts (a$b) = subst Ts a $ subst Ts b
            | subst Ts t = t
        in subst Ts t end;
    fun map_trm_frees f t = 
        let 
          fun subst (v as Free x) = f (x, v)
            | subst (Abs(s,ty,t)) = Abs(s,ty,subst t)
            | subst (a$b) = subst a $ subst b
            | subst t = t
        in subst t end;

    (* instantiation *)
    fun inst1_typ_typ (n,ty) bigty = 
        let fun subst(Type(a,Tys)) = Type(a, map subst Tys)
              | subst(oldty as TFree _) = oldty
              | subst(oldty as TVar(m,_)) = 
                (if n = m then ty else oldty)
        in subst bigty end;
    val inst1_trm_typ = map_trm_types o inst1_typ_typ;

    fun inst1_trm_trm (n,u) t = 
        let fun subst(v as Var(m,_)) = if m = n then u else v
              | subst(Abs(a,T,t)) = Abs(a,T,subst t)
              | subst(f$t) = subst f $ subst t
              | subst(t) = t
        in subst t end;


  (*iterate a function over all types in a term*)
  fun it_term_types f =
    let fun iter(Const(_,T), a) = f(T,a)
        | iter(Free(_,T), a) = f(T,a)
        | iter(Var(_,T), a) = f(T,a)
        | iter(Abs(_,T,t), a) = iter(t,f(T,a))
        | iter(f$u, a) = iter(f, iter(u, a))
        | iter(Bound _, a) = a
        in iter end

   (*Accumulates the TVars in a type, suppressing duplicates.*)
   fun add_typ_tvars(Type(_,Ts),vs) = List.foldr add_typ_tvars vs Ts
      | add_typ_tvars(TFree(_),vs) = vs
      | add_typ_tvars(TVar(v),vs) = insert (op =) v vs;

   fun add_typ_tfrees(Type(_,Ts),fs) = List.foldr add_typ_tfrees fs Ts
      | add_typ_tfrees(TFree(f),fs) = insert (op =) f fs
      | add_typ_tfrees(TVar(_),fs) = fs;

   (*Accumulates the TVars in a term, suppressing duplicates.*)
   val add_term_tvars = it_term_types add_typ_tvars;
   (*Accumulates the TFrees in a term, suppressing duplicates.*)
   val add_term_tfrees = it_term_types add_typ_tfrees;

   fun add_typ_tfrees(Type(_,Ts),fs) = List.foldr add_typ_tfrees fs Ts
      | add_typ_tfrees(TFree(f),fs) = insert (op =) f fs
      | add_typ_tfrees(TVar(_),fs) = fs;

    fun typ_tvars_of t = add_typ_tvars(t,[]); 
    fun tvars_of t = add_term_tvars(t,[]);
    fun typ_tfrees_of t = add_typ_tfrees(t,[]);
    fun tfrees_of t = add_term_tfrees(t,[]);

    (*Accumulates the Vars in the term, suppressing duplicates.*)
    fun add_term_vars (t, vars: term list) = case t of
        Var   _ => Ord_List.insert Term_Ord.term_ord t vars
        | Abs (_,_,body) => add_term_vars(body,vars)
        | f$t =>  add_term_vars (f, add_term_vars(t, vars))
        | _ => vars;

    fun vars_of t = map Term.dest_Var (add_term_vars (t,[])); 

    (*Accumulates the Frees in the term, suppressing duplicates.*)
    fun add_term_frees (t, frees: term list) = case t of
      Free   _ => Ord_List.insert Term_Ord.term_ord t frees
      | Abs (_,_,body) => add_term_frees(body,frees)
      | f$t =>  add_term_frees (f, add_term_frees(t, frees))
      | _ => frees;

    fun frees_of t = map Term.dest_Free (add_term_frees (t,[]));
    fun term_frees t = add_term_frees(t,[]);


    (* adding to paramss *)
    fun concat_to_params l params =
        TrmParams.refresh_name_list l (([], TrmParams.NTab.empty), params);

    fun concat_to_tparams l tparams =
        TypParams.refresh_name_list l (([], TypParams.NTab.empty), tparams);

    (* add to existing set of names anything new in this term. *)
    fun addto_params t params = TrmParams.addifnew_list (frees_of t) params;
    fun addto_tparams t tparams = TypParams.addifnew_list (tfrees_of t) tparams;

    (* add as fresh to existing set of names all frees in this term *)
    fun addfresh_in_params' params t = 
        let val ((newps, renamings), params2) = 
                concat_to_params (frees_of t) params 
        in ((newps, renamings), params2) end;
    (* implicit tab and term *)
    val addfresh_in_params = #2 oo addfresh_in_params';
    (* implicit term *)
    val params_of = addfresh_in_params TrmParams.empty;

    (* add to free type variable table the extra quote indicates that
       we record which params are new *)
    fun addfresh_in_tparams' tparams t = 
        let val ((newps, renamings), tparams2) = 
                concat_to_tparams (tfrees_of t) tparams 
        in ((newps, renamings), tparams2) end;
    (* implicit tab and term *)
    val addfresh_in_tparams = #2 oo addfresh_in_tparams';
    (* implicit term *)
    val tparams_of = addfresh_in_tparams TypParams.empty;

    (* params are taken to be fixed as new fresh frees *)
    fun fix_all_params' params alledt = 
        let val t = Term.strip_all_body alledt;
            val alls = rev (Term.strip_all_vars alledt);
            val ((newps, renamings), params2) = concat_to_params alls params;
        in (Term.subst_bounds (map Free newps, t), (newps, params2)) end;
    (* doesn't return new fixed things *)    
    fun fix_all_params params alledt = 
        let val (t2, (newps, params2)) = fix_all_params' params alledt 
        in (t2, params2) end;

    (* params will include those already in the table. *)
    (*  assumes that the alledt term already has the params from the
        table, possibly with some extra ones; drops the outer ones 
        (same as params), and adds the inner ones. *)
    fun refix_all_params' params alledt = 
        let 
          val i = TrmParams.get_nparams params
          val t = Term.strip_all_body alledt
          (* rev to get inner most binder first *)
          val alls = rev (List.drop (Term.strip_all_vars alledt,i));
          val ((newps, renamings), params2) = concat_to_params alls params;
          (* rev to get outer most binder first *)
          val L = rev (TrmParams.get_plist params)
        in (Term.subst_bounds (map Free (newps @ L), t), (newps, params2)) end;

(* copied and edited from term.ML - special case for free's, ignores
types. Observe hackyness using exceptions to avoid extra memory
allocation: surely the compiler/interpreter should be doing this for
us!!!??? *)
fun abstract_over_free (n, body) =
  let
    exception SAME;
    fun abs lev (Abs (a, T, t)) = Abs (a, T, abs (lev + 1) t)
      | abs lev (t $ u) = (abs lev t $ (abs lev u handle SAME => u) 
                           handle SAME => t $ abs lev u)
      | abs lev (Free (n2,_)) = 
        if n = n2 then Bound lev else raise SAME
      | abs _ _ = raise SAME;
  in abs 0 body handle SAME => body end;

(*Form an abstraction over a free variable.*)
fun absfree (a,T,body) = Abs(a, T, abstract_over_free (a, body));

(*Abstraction over a list of free variables*)
fun list_abs_free ([ ] ,     t) = t
  | list_abs_free ((a,T)::vars, t) =
      absfree(a, T, list_abs_free(vars,t));

    (* lambda abstract over L = introduce lambdas *)
    (* rev to change params into top binder first odering -
       by params stores innermost binder first *) 
    fun absify_params params t = 
        list_abs_free (rev (TrmParams.get_plist params), t);

(* Ugly hack, this had dissapeared from Isabelle's Term structure so moved it here *)
val propT : typ = Type("prop",[]);
fun all T = Const("all", (T-->propT)-->propT);

(* FIXME: THE Below is from Isabelle2011-1, how is it different from the version above? *)
(*fun absfree' (a, T) body = Abs (a, T, abstract_over_free (Free (a, T), body)); *)
 (*Quantification over a list of free variables*)
fun list_all_free ([], t: term) = t
  | list_all_free ((a,T)::vars, t) =
        all T $ absfree (a, T, list_all_free (vars, t));

    (* all-abstract over L = introduce foralls *)
fun allify_params params t = 
    list_all_free (rev (TrmParams.get_plist params), t); 

    (* just fix (unallify) these params, no more! assume alledt has
    exactly the given params alls *)
    fun fix_params params alledt = 
        let 
          val t = Term.strip_all_body alledt
          val params = rev (TrmParams.get_plist params)
        in Term.subst_bounds (map Free params, t) end;

    (* table of vars *)
type vtab = (sort TVar.NTab.T * typ Var.NTab.T)
val empty_vtab = (TVar.NTab.empty, Var.NTab.empty);
fun trm_var_tab_of t = 
    List.foldr (fn (x,tab) => snd (Var.NTab.add x tab))
               Var.NTab.empty (vars_of t);
    
fun typ_var_tab_of t = 
    List.foldr (fn (x,tab) => snd (TVar.NTab.add x tab))
               TVar.NTab.empty (tvars_of t);
    
fun typ_var_tab_of_typ typ = 
    List.foldr (fn (x,tab) => snd (TVar.NTab.add x tab))
               TVar.NTab.empty (typ_tvars_of typ);

fun vtab_of t = (typ_var_tab_of t, trm_var_tab_of t);
fun vtab_of_typ ty = (typ_var_tab_of_typ ty, Var.NTab.empty);

val dest_vtab = I;
val mk_vtab = I;
    
    (* merge collection of vars together *)
(* IMRPOVE: 

We ignore types of vars - this is because we only really care about
the name. But we should be able to checks types also. The reason not
to is effciency, and also because we don't correctly hold types in
variable tables - see bug note on wiki:

When we get an instantiation of a type, we don't update the variable
entry. This is because we don't record the variables dependent on a
type variable. 

*)
fun merge_joint_vtabs (trm_tvars,trm_vars) (tvars,vars) = 
    (TVar.NTab.merge_joint eq_sort trm_tvars tvars, 
     Var.NTab.merge_joint (K true) trm_vars vars);
(* (TVar.NTab.merge_joint eq_sort trm_tvars tvars, 
     Var.NTab.merge_joint eq_typ trm_vars vars);
*)

fun difference_vtab (tvars,vars) (tvars2,vars2) = 
    (TVar.NTab.difference tvars tvars2, 
     Var.NTab.difference vars vars2)


(* add names *)
fun add_typ_names ty tnames = 
    List.foldr 
      (fn (x as (n,ty), tnames) => 
          case TVar.NTab.lookup tnames n of 
            NONE => snd (TVar.NTab.add x tnames)
          | SOME _ => tnames)
      tnames
      (typ_tvars_of ty);
    
fun add_names t (tnames, names) = 
    (List.foldr 
       (fn (x as (n,srt), tnames) => 
           case TVar.NTab.lookup tnames n of 
             NONE => snd (TVar.NTab.add x tnames)
           | SOME _ => tnames)
       tnames  (tvars_of t), 
     List.foldr 
       (fn (x as (n,ty), names) => 
           case Var.NTab.lookup names n of 
             NONE => snd (Var.NTab.add x names)
           | SOME _ => names)
       names (vars_of t));
    
    (* add var names from flexflex pairs *)        
fun add_flexflex_names names flexes = 
    List.foldr 
      (fn ((x,y),names) => add_names y (add_names x names)) 
      names 
      flexes;
    
    (* lcacl things *)
val eta_contract = Envir.eta_contract;
val beta_norm = Envir.beta_norm;
    

(* check that two types are name-equivalent 
   (alpha convertable w.r.t. free types) *)
(* given two lists of types which must be structurally alpha-equivalent, 
   and the renaming so far *)
fun typl_name_eq' [] [] tyrn = SOME tyrn
  | typl_name_eq' (h1::t1) (h2::t2) tyrn = 
    (case typ_name_eq' h1 h2 tyrn 
      of NONE => NONE
       | SOME tyrn2 => typl_name_eq' t1 t2 tyrn2)
  | typl_name_eq' _ _ _ = NONE
(* given Two Isabelle types and the renaming so far *)
and typ_name_eq' (Type(s1,tyl1)) (Type(s2,tyl2)) tyrn = 
    if (fast_string_ord (s1,s2) = EQUAL) 
    then typl_name_eq' tyl1 tyl2 tyrn else NONE
  | typ_name_eq' (TFree(s1, srt)) (TFree(s2, srt2)) tyrn = 
    if Term_Ord.sort_ord (srt, srt2) = EQUAL 
    then TFree.try_compose_rename1 s1 s2 tyrn else NONE
  | typ_name_eq' ty1 ty2 tyrn = 
    if eq_typ (ty1, ty2) then SOME tyrn else NONE;

fun typ_name_eq ty1 ty2 = 
    is_some (typ_name_eq' ty1 ty2 TFree.Rnm.empty);


(* Checks if the first term is equal to the second in some name
convertable way, this differs from the aeconv in the Term.ML file of
Isabelle in that we check for any correspondence between variable
names rather than checking binders - which would fail if the
binder-ordering was different.  Assumes both terms are in normal
form. Equivalent to alpha conv when bound vars are expressed as
frees. *)
fun trm_name_eq' (Abs(_,ty1,t1)) (Abs(_,ty2,t2)) (rn, tyrn) =
    (case typ_name_eq' ty1 ty2 tyrn of 
       NONE => NONE | SOME tyrn2 => trm_name_eq' t1 t2 (rn,tyrn2))
  | trm_name_eq' (ah $ at) (bh $ bt) rn =
    (case trm_name_eq' ah bh rn
      of NONE => NONE | SOME rn2 => trm_name_eq' at bt rn2)
  | trm_name_eq' (Free (a,aty)) (Free (b,bty)) (rn, tyrn) =
    (case typ_name_eq' aty bty tyrn of 
       NONE => NONE
     | SOME tyrn2 => 
       (case Free.try_compose_rename1 a b rn of
         NONE => NONE | SOME rn2 => SOME (rn2,tyrn2)))
  | trm_name_eq' a b rn = if eq (a,b) then SOME rn else NONE;

fun trm_name_eq t1 t2 = 
    is_some (trm_name_eq' t1 t2 (Free.Rnm.empty, TFree.Rnm.empty));

val prems_of = Logic.strip_imp_prems;
val concl_of = Logic.strip_imp_concl;
fun list_implies prems concl = Logic.list_implies (prems, concl);
    

(* Changing frees to vars and visa-versa
   given set of used stuff (to avoid), 
     changed names so far, and term to be changed.  *)


fun change_vars_to_fresh_frees' d' t = 
    foldmap_trm_vars_and_tvars 
      (fn d as ((tpset,tvtab),(pset,vtab)) => 
       fn ((tvn,sort),_) => 
          case TVar.NTab.lookup tvtab tvn of 
            NONE => 
            let 
              val (tpn, tpset2) = 
                  TypParams.NSet.add_new (free_of_var_name tvn) tpset
              val tvtab2 = TVar.NTab.ins (tvn,tpn) tvtab 
            in (((tpset2,tvtab2),(pset,vtab)), TFree (tpn, sort)) end
          | SOME tpn => (d, TFree (tpn, sort)))
      (fn d as ((tpset,tvtab),(pset,vtab)) => 
       fn ((vn,ty),_) => 
          case Var.NTab.lookup vtab vn of 
            NONE => 
            let 
              val (pn, pset2) = 
                  TrmParams.NSet.add_new (free_of_var_name vn) pset
              val vtab2 = Var.NTab.ins (vn,pn) vtab 
            in (((tpset,tvtab),(pset2,vtab2)), Free (pn, ty)) end
          | SOME pn => (d, Free (pn, ty)))
      d' t;

fun change_frees_to_fresh_vars' d' t = 
    foldmap_trm_frees_and_tfrees
      (fn d as ((tvset : TVar.NSet.T, tparams),(vset : Var.NSet.T, params)) => 
       fn ((tpn,sort),_) => 
          case TypParams.NTab.lookup tparams tpn of 
            NONE => 
            let 
              val (tvn, tvset2) = 
                  TVar.NSet.add_new (tvar_of_tfree_name tpn) tvset
              val tparams2 = TypParams.NTab.ins (tpn,tvn) tparams 
            in (((tvset2,tparams2),(vset,params)), TVar (tvn, sort)) end
          | SOME tvn => (d, TVar (tvn, sort)))
      (fn d as ((tvset,tparams),(vset,params)) => 
       fn ((pn,ty),_) => 
          case TrmParams.NTab.lookup params pn of 
            NONE => 
            let 
              val (vn, vset2) = 
                  Var.NSet.add_new (var_of_free_name pn) vset
              val params2 = TrmParams.NTab.ins (pn,vn) params 
            in (((tvset,tparams),(vset2,params2)), Var (vn, ty)) end
          | SOME vn => (d, Var (vn, ty)))
      d' t;


fun change_frees_to_fresh_vars t = 
    let val tvset = TVar.NTab.get_nameset (typ_var_tab_of t)
        val vset = Var.NTab.get_nameset (trm_var_tab_of t)
        val tparams = TypParams.NTab.empty;
        val params = TrmParams.NTab.empty;
    in snd (change_frees_to_fresh_vars' ((tvset,tparams),(vset,params)) t) end;

fun change_vars_to_fresh_frees t = 
    let val tpset = TypParams.get_pnames (tparams_of t)
        val pset = TrmParams.get_pnames (params_of t)
        val tvtab = TVar.NTab.empty;
        val vtab = Var.NTab.empty;
    in snd (change_vars_to_fresh_frees' ((tpset,tvtab),(pset,vtab)) t) end;



  (* instantiate a term so that vars have no arguments 
                 (throw arguments away!) Used for pretty printing *)
val list_abs = uncurry (fold_rev (fn (x, T) => fn t => Abs (x, T, t)));

fun drop_trm_var_args t = 
    let 
      val vtab = vtab_of t;
      val vars = Var.NTab.list_of (snd vtab);
    in 
      fold (fn (n,ty) => 
               (case ty 
                 of Type _ => 
                    let 
                      val (argtyps, desttype) = strip_type ty
                      val inst = 
                          (list_abs (map (pair "") argtyps,
                                          Var(n,desttype)))
                    in
                      Term.subst_Vars [(n,inst)]
                    end
                  | _ => I))
           vars
           t 
    end;

  val drop_var_args_flag = Unsynchronized.ref true;

  fun pretty ctxt t = 
      Syntax.pretty_term 
        ctxt
        (if !drop_var_args_flag then drop_trm_var_args t else t);

  val print = Pretty.writeln oo pretty;


  structure MLSerialise = 
  struct 
    (* more pretty printing code for Isabelle terms etc *)
    (* ml_pretty_typelist l f = print a typelist.
       l = list of types to print : typ list
       f = function used to print a single type : typ -> string
    *)
    fun string_of_typelist [] f = ""
      | string_of_typelist [(h: typ)] (f : typ -> string) = (f h)
      | string_of_typelist ((h: typ) :: t) (f : typ -> string) =
          (f h) ^ ", " ^ (string_of_typelist t f);
    
    (* string_of_sort s = print a sort
       s = sort to print : string list
    *)
    fun string_of_sort [] = ""
      | string_of_sort ([h])  = "\"" ^ h ^ "\""
      | string_of_sort (h :: t)  = "\"" ^ h ^ "\"," ^ (string_of_sort t);
    
    (* string_of_type t = print a type
       t = type to print : type
    *)
    fun string_of_type (Type (n, l)) =
          "Type(\"" ^ n ^ "\", [" ^ (string_of_typelist l string_of_type) ^ "])"
      | string_of_type (TFree (n, s)) =
          "TFree(\"" ^ n ^ "\", [" ^ (string_of_sort s) ^ "])"
      | string_of_type (TVar ((n, i), s)) =
          "TVar( (\"" ^ n ^ "\", " ^ (string_of_int i) ^ "), [" ^ (string_of_sort s) ^ "])";
    
    (* string_of_term t = print a term prints types and sorts too.
       t = term to print : term
    *)
    fun string_of_term (Const (s, t)) =
          "Const(\"" ^ s ^ "\", " ^ (string_of_type t) ^ ")"
      | string_of_term (Free (s, t)) =
          "Free(\"" ^ s ^ "\", " ^ (string_of_type t) ^ ")"
      | string_of_term (Var ((n, i), t)) =
          "Var( (\"" ^ n ^ "\"," ^ (string_of_int i) ^ "), " ^ (string_of_type t) ^ ")"
      | string_of_term (Bound i) =
          "Bound(" ^ (string_of_int i) ^ ")"
      | string_of_term (Abs (s, t, r)) =
          "Abs(\"" ^ s ^ "\"," ^ (string_of_type t) ^ ", \n  " ^ (string_of_term r) ^ ")"
      | string_of_term (op $ (t1, t2)) =
          "(" ^ (string_of_term t1) ^ ") $\n (" ^ (string_of_term t2) ^ ")";
    
    (* Write the term out nicly instead of just creating a string for it *)
    fun print_term t = writeln (string_of_term t);
    fun print_type t = writeln (string_of_type t);
    fun print_sort s = writeln (string_of_sort s);

  end;

end;


structure Trm : ISA_TRM = DB_Trm;


