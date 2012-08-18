(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      denv.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Updated:    8 Aug 2005
    Date:       25 Apr 2005
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Variable Instantiation Environment
    to manage dependencies between meta-variables and 
    the goal/result nodes in a proof graph
    POSSIBLE IMPROVEMENT: lazy update of instantiations? 
*)
signature DEPENV
= sig
    structure VarDeps : NAME_BINREL 
    where type Dom.name = Var.name
    and type Cod.name = Goaln.name

    structure TVarDeps : NAME_BINREL
    where type Dom.name = TVar.name 
    and type Cod.name = Goaln.name

    (* dependency table, where 'r is the type for names of things that
    are dependencies are for, eg names of theorems *)
    type T
    val empty : T; 

    (* adding things *)
    val add : (TVar.NSet.T * Var.NSet.T) -> Goaln.NSet.T -> T -> T

    val add_tvdeps : TVar.name -> Goaln.NSet.T -> T -> T
    val add_vdeps : Var.name -> Goaln.NSet.T -> T -> T

    val add1_tvdep : TVar.name -> Goaln.name -> T -> T
    val add1_vdep : Var.name -> Goaln.name -> T -> T

    (* removing *)
    val drop_tvdep : TVar.name -> Goaln.name -> T -> T 
    val drop_vdep : Var.name -> Goaln.name -> T -> T

    val del_tvar : TVar.name -> T -> T 
    val del_var : Var.name -> T -> T
    val del_gname : Goaln.name -> T -> T

    (* renaming *)
(* 
    val rename_var : Var.name -> Var.name -> T -> T
    val rename_tvar : TVar.name -> TVar.name -> T -> T 
    val rename_gname : Goaln.name -> Goaln.name -> T -> T
*)

    (* lookup deps *)
    val get_vdeps : T -> Var.name -> Goaln.NSet.T
    val get_tvdeps : T -> TVar.name -> Goaln.NSet.T

    val get_gname_vdeps : T -> Goaln.name -> Var.NSet.T
    val get_gname_tvdeps : T -> Goaln.name -> TVar.NSet.T

    (* general gets *)
    val get_tvrel : T -> TVarDeps.T
    val get_vrel : T -> VarDeps.T

    val get_tvars : T -> TVar.NSet.T
    val get_vars : T -> Var.NSet.T

    val get_tvdep_gnames : T -> Goaln.NSet.T
    val get_vdep_gnames : T -> Goaln.NSet.T
    val get_gnames : T -> Goaln.NSet.T

    val get_tvardeps : T -> (TVar.name * Goaln.NSet.T) list
    val get_vardeps : T -> (Var.name * Goaln.NSet.T) list

    (* pretty printing *)
    val pretty : Context.theory -> T -> Pretty.T
end;


(* Dependencies between variables and goals, 
   a pair of binary relations on named sets *)
structure DB_DepEnv
= struct 

structure VarDeps : NAME_BINREL = 
NameBRelFun(structure Dom = Trm.Var and Cod = Goaln)
structure TVarDeps : NAME_BINREL = 
NameBRelFun(structure Dom = Trm.TVar and Cod = Goaln)


(* datatype for meta variable environments *)
(* note: int list indicates theorem dependencies on this var *)
datatype T = Varenv of {
         vars : VarDeps.T,
         tvars : TVarDeps.T
};

(* make var env for node i *)
val empty = Varenv {vars = VarDeps.empty,
                    tvars = TVarDeps.empty };

(* basic gets *)
fun get_vrel (Varenv rep) = #vars rep;
fun get_tvrel (Varenv rep) = #tvars rep;

(* basic intrenal update functions *)
fun update_tvars f (Varenv rep) = 
    Varenv {vars = #vars rep,
            tvars = f (#tvars rep)};
fun update_vars f (Varenv rep) = 
    Varenv {vars = f (#vars rep),
            tvars = #tvars rep};

(* renaming *)
(* 
fun rename1_opt_var v1 v2 rel =
    rel |> update_vars (VarDeps.rename_dom v1 v2);

fun rename1_opt_tvar v1 v2 rel =
    rel |> update_tvars (TVarDeps.rename_dom v1 v2);

fun rename1_opt_gname g1 g2 rel =
    rel |> update_tvars (TVarDeps.rename_cod g1 g2)
        |> update_vars (VarDeps.rename_cod g1 g2);
*)

(* add deps *)
fun add (tvars, vars) gs (Varenv rep) = 
    Varenv {vars = VarDeps.add_many vars gs (#vars rep),
            tvars = TVarDeps.add_many tvars gs (#tvars rep) };

fun add_tvdeps v gs = update_tvars (TVarDeps.add_to_dom v gs);
fun add_vdeps v gs = update_vars (VarDeps.add_to_dom v gs);

fun add1_tvdep v g = update_tvars (TVarDeps.add1 v g);
fun add1_vdep v g = update_vars (VarDeps.add1 v g);


(* removed deps *)
fun del_tvar v = update_tvars (TVarDeps.del_dom v);
fun del_var v = update_vars (VarDeps.del_dom v);
fun del_gname g = 
    update_vars (VarDeps.del_cod g) 
    o update_tvars (TVarDeps.del_cod g);

fun drop_tvdep v g = update_tvars (TVarDeps.del1 v g);
fun drop_vdep v g = update_vars (VarDeps.del1 v g);

(* lookup dependencies from a var *)
fun get_tvdeps venv s = TVarDeps.domf (get_tvrel venv) s;
fun get_vdeps venv s = VarDeps.domf (get_vrel venv) s;

fun get_gname_tvdeps venv s = TVarDeps.codf (get_tvrel venv) s;
fun get_gname_vdeps venv s = VarDeps.codf (get_vrel venv) s;

(* get all *)
val get_vars = VarDeps.get_domset o get_vrel;
val get_tvars = TVarDeps.get_domset o get_tvrel;

val get_tvdep_gnames = TVarDeps.get_codset o get_tvrel;
val get_vdep_gnames = VarDeps.get_codset o get_vrel;

fun get_gnames deps = 
    Goaln.NSet.union_merge (get_vdep_gnames deps) (get_tvdep_gnames deps);

val get_vardeps = VarDeps.list_of o get_vrel;
val get_tvardeps = TVarDeps.list_of o get_tvrel;

(* pretty *)
fun pretty_deps vpf (v, gs) = 
    Pretty.block 
      [vpf v,
       Pretty.str ": " ,
       Goaln.NSet.pretty gs];

fun pretty thry (Varenv rep) = 
    Pretty.chunks
      [
       Pretty.str "Type Vars: ",
       Pretty.indent 
         2 (Pretty.chunks 
              (map (pretty_deps TVar.pretty_name)
                   (TVarDeps.list_of (#tvars rep)))),
       Pretty.str "Term Vars: ",
       Pretty.indent 
         2 (Pretty.chunks 
              (map (pretty_deps Var.pretty_name)
                   (VarDeps.list_of (#vars rep))))];

end;


structure DepEnv : DEPENV = DB_DepEnv;
