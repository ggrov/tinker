(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      basic_instenv.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Instantiation environment                                          *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*
Instantiations tables that cross-instantiate each other: every time an
instantiation is inserted it will update all other term/types that are
affected by the instantiation.

BELIEF: this is compositional: new instantiations can be made in a
separate instenv - assuming variables have same namespace - applying
and then merged with this one. This is because the process is just
that of simply adding more instantiations.

Question? what is the efficiency: is it any worse than doing it
directly? I think not.  

IDEA: improve by using mutli-hole context's (undergrounds?) for
instantiation of variables -- massive efficientcy improvements as
instantiation becomes contant time rather than on size of term. --
maybe this can be implemented by lazy instantiation with a record of
what has now become obsolete to further instantiate as you can look it
up from the table - all partial instantiations are obsolete and you
want to perform instantiation from last one made to first one.

CHECK: I've removed some exceptions: but I think they should still be
there - investigate: maybe instenv renaming
(invert_var_renamings,mk_invert_var_renamings,correct_var_renamings)
is messsing up the invarients. It should be that every variable in an
instantiation also exists in the dep table. *)



signature INSTENV =
sig

  type T;
  type renaming

  structure VTab : TABLE where type key = Var.name
  structure TVTab : TABLE where type key = TVar.name

  exception instenv_exp of string;
  exception bad_ienv_exp of (string * T);
  exception table_missing_elem_exp of string;
  exception rename_tvar_exp of renaming * ((TVar.name * Trm.sort) * Trm.typ);
  exception bad_tvar_inst_exp of (TVar.name * (Trm.sort * Trm.typ)) * T;
  exception bad_var_inst_exp of (Var.name * (Trm.typ * Trm.T)) * T;

  exception add_dep_exp of string * Term.typ * Term.typ;
  exception add_tdep_exp of string * Term.sort * Term.sort;

  val init : Proof.context -> T;

  val get_ctxt : T -> Proof.context;
  val get_theory : T -> Context.theory;
  val set_ctxt : Proof.context -> T -> T;

  val get_flexes : T -> (Trm.T * Trm.T) list
  val set_flexes : (Trm.T * Trm.T) list -> T -> T

  (* checking for different kinds of empty *)
  val no_uninst_tvars : T -> bool;
  val no_uninst_vars : T -> bool;
  val is_ground : T -> bool;

  val no_inst_tvars : T -> bool;
  val no_inst_vars : T -> bool;
  val no_insts : T -> bool;

  (* names table and if they are instantiated (true) or not (false) *)
  val typvar_names : T -> bool TVar.NTab.T
  val var_names : T -> bool Var.NTab.T

  val merge_trm : Trm.T -> T -> Trm.T * T
  val of_trm : Proof.context -> Trm.T -> T

  (* add instantiations of first ienv to second one and merge vars names *)
  val merge_union : T -> T -> T
  (* merge, but don't create instantiations for new vars that are
     themselves instantiated. *) 
  val merge_intersect_snd : T -> T -> T

  (* make a new ienv from these tvar and var names: only take these instantiations *)
  val select : TVar.NSet.T * Var.NSet.T -> T -> T
  val select_list : TVar.name list * Var.name list -> T -> T
  val select_fst : T -> T -> T

  (* split an ienv into the one mentioned by the NTab's and the bits that are not *)
  val split : 'a TVar.NTab.T * 'b Var.NTab.T -> T -> T * T

  (* Querying the instantiation environment *)
  val tvar_is_inst : T -> TVar.name -> bool
  val var_is_inst : T -> Var.name -> bool

  val lookup_tvar : T -> TVar.name -> ((TVar.name * Trm.sort)
                                         * Trm.typ option) option
  val lookup_var : T -> Var.name -> ((Var.name * Trm.typ)
                                         * Trm.T option) option

  (* gets might raise exp: table_missing_elem_exp *)
  val get_tvar : T -> Var.name -> (TVar.name * Trm.sort) * (Trm.typ option)
  val get_var : T -> Var.name -> (Var.name * Trm.typ) * (Trm.T option)
  val get_typ_of_var : T -> Var.name -> Trm.typ

  (* looking up instantiations *)
  val lookup_tvar_inst 
      : T -> TVar.name -> (Trm.sort * Trm.typ) option
  val lookup_var_inst 
      : T -> Var.name -> (Trm.typ * Trm.T) option
  val get_tvar_inst : T -> TVar.name -> (Trm.sort * Trm.typ)
  val get_var_inst : T -> Var.name -> (Trm.typ * Trm.T)

  val lookup_uninst_tvar : 
      T -> TVar.name 
      -> (Trm.sort * (TVar.name list * Var.name list)) option
  val lookup_uninst_var : 
      T -> Var.name -> (Trm.typ * Var.name list) option


  (* add to the instantiation environment *)
  val add_tvar_inst : (TVar.name * (Trm.sort * Trm.typ)) -> T -> T
  val add_var_inst : (Var.name * (Trm.typ * Trm.T)) -> T -> T
  
  (* instantiation that is not recorded *)
  val add_dum_tvar_inst : (TVar.name * (Trm.sort * Trm.typ)) 
                          -> T -> T
  val add_dum_var_inst : (Var.name * (Trm.typ * Trm.T)) -> T -> T
  
  (* make new vars - give back the used fresh name *)
  val new_uninst_tvar : (TVar.name * Trm.sort) -> T -> (TVar.name * T)
  val new_uninst_var : (Var.name * Trm.typ) -> T -> (Var.name * T)
  val new_uninst_tvars : (TVar.name * Trm.sort) list 
                         -> ((TVar.name * Trm.sort) list * T) 
                         -> ((TVar.name * Trm.sort) list * T)
  val new_uninst_vars : (Var.name * Trm.typ) list 
                        -> ((Var.name * Trm.typ) list * T) 
                        -> ((Var.name * Trm.typ) list * T)

  (* renaming *)
  val init_renaming : T (* avoid vars in this *) 
                      -> renaming 
  val var_is_ignored_by_renaming : renaming -> Var.name -> bool 
  val tvar_is_ignored_by_renaming : renaming -> TVar.name -> bool
  val get_var_renaming : renaming -> Var.name 
                         -> (Trm.typ * Trm.T) option
  val get_tvar_renaming : renaming -> TVar.name 
                          -> (Trm.sort * Trm.typ) option
  val inst_of_renaming : renaming -> T
  val avoid_of_renaming : renaming -> T
  val unchanged_tvars_of_renaming : renaming -> TVar.NSet.T
  val unchanged_vars_of_renaming : renaming -> Var.NSet.T

  (* rename trm vars *)
  val rename_var : renaming -> (Var.name * Trm.typ) * Trm.T 
                   -> renaming * Trm.T
  val rename_tvar : renaming -> (TVar.name * Trm.sort) * Trm.typ 
                    -> renaming * Trm.typ

  val rename_trm_vars : renaming -> Trm.T -> renaming * Trm.T
  val rename_typ_tvars : renaming -> Term.typ -> renaming * Term.typ

  (* merge in some new uninst vars *)
  val merge_uninst_tvar : (TVar.name * Trm.sort) -> T -> T
  val merge_uninst_var : (Var.name * Trm.typ) -> T -> T

  (* merge the uninstantiated variables the first ienv into the second *)
  (* ideally remove; hack for APrf.mk_subprf_into_meth *)
  val merge_uninsts_of_fst : T -> T -> T 

  (* apply instantiation to instenv without adding it *)
  val do_tvar_inst' : (TVar.name * (Trm.sort * Trm.typ)) 
                      -> T -> ((TVar.name list * Var.name list) * T)
  val do_tvar_inst : (TVar.name * (Trm.sort * Trm.typ)) 
                     -> T -> T
  val do_var_inst' : (Var.name * (Trm.typ * Trm.T)) -> T 
                     -> (Var.name list * T)
  val do_var_inst : (Var.name * (Trm.typ * Trm.T)) -> T -> T

  val inst_tvars_of : T -> TVar.name list
  val inst_vars_of : T -> Var.name list

  val tvar_insts : T -> (TVar.name * (Trm.sort * Trm.typ)) list
  val var_insts : T -> (Var.name * (Trm.typ * Trm.T)) list

  val uninst_tvars_of : T -> (TVar.name * Trm.sort) list
  val uninst_vars_of : T -> (Var.name * Trm.typ) list
  val uninst_tvar_names_of : T -> TVar.name list
  val uninst_var_names_of : T -> Var.name list

  val uninst_tvars_deps : T -> (TVar.name 
                               * (Trm.sort 
                                  * (TVar.name list 
                                     * Var.name list))) list
  val uninst_vars_deps : T -> (Var.name  
                              * (Trm.typ * Var.name list))
                                  list  

  (* changes to dependencies within this instantiation 
     Note: internally kept upto date. *)
  val dep_updates : 
      T -> (TVar.name list TVTab.table 
            * TVar.name list VTab.table) 
           * Var.name list VTab.table

  (* var renamings manipulations *)
  val mk_invert_var_renamings : TVar.NSet.T * Var.NSet.T -> T -> T
  val invert_var_renamings : T -> T
  val correct_var_renamings : T (* renamings *)
                           -> T 
                           -> T
  
  (* lift uninstantiated vars in the prfenv *)
  (* val lift_openvars : (Var.pname * Trm.typ) list * vtab -> T -> T *)

  (* extra stuff *)
  val remove_var_inst_wdep : Var.name list * TVar.name list
                             -> Var.name -> T -> T
  val remove_tvar_inst_wdep : TVar.name list -> TVar.name -> T -> T
  val remove_var_dep : Var.name -> T -> T
  val remove_tvar_dep : TVar.name -> T -> T

  (* Create inst env from a matching, the first term is the pattern *)
  (* val match : Proof.context -> Trm.T -> Trm.T -> T option *)
  (* and of course unification - note flexes are thrown away! *)
  (* val unify : Proof.context -> Trm.T -> Trm.T -> T Seq.seq *)

  (* instantiate things using this instantiation environment *)
  val inst_typ_tvars : T -> Trm.typ -> Trm.typ
  val inst_trm_typs : T -> Trm.T -> Trm.T
  val inst_trm : T -> Trm.T -> Trm.T
  val inst_dtrm : T -> TrmCtxt.D.dtrm -> TrmCtxt.D.dtrm
  val inst_zipper : T -> Zipper.T -> Zipper.T

  (* Isabelle stuff that sneaked into here for convenience *)
  val inst_thm : T -> Thm.thm -> Thm.thm
  val inst_cterm : T -> Thm.cterm -> Thm.cterm

  (* handy for debugging... *)
  val pretty_full : T -> Pretty.T;
  val pretty : T -> Pretty.T;
  val print_full : T -> unit;
  val print : T -> unit;
end;


structure DB_InstEnv
= struct
 
  structure Var = Trm.Var;
  structure TVar = Trm.TVar; 

  structure VTab = Table(type key = Var.name; 
                            val ord = Var.name_ord);
  structure TVTab = Table(type key = TVar.name;
                             val ord = TVar.name_ord);

  (* any vars not in the table are assumed to not be instantiated *)
  datatype T = Insts 
  of {
      ctxt : Proof.context, (* the context under which this is happening 
                               needed for checking subsort in instantiation *)

      tyns : bool TVar.NTab.T,  (* inst or not table of tvar name *)
      vns : bool Var.NTab.T,  (* inst or not table of var name *)

      (* instantiated vars and tvars *)
      tvars : (Trm.sort * Trm.typ) TVTab.table,
      vars : (Trm.typ * Trm.T) VTab.table,

      (* these correspond to uninstantiated types and types
         and vars that use them *)
      tdeps: (Trm.sort * (TVar.name list 
                           * Var.name list)) TVTab.table, 

      (* uninstantiated var -> type of var and names of vars that use it *)
      deps : (Trm.typ * Var.name list) VTab.table,

      (* flex-flex pairs for vars in this ienv *)
      flexes : (Trm.T * Trm.T) list
    }; 


fun typvar_names (Insts rep) = #tyns rep;
fun var_names (Insts rep) = #vns rep;

(* exception things *)
exception instenv_exp of string;
exception bad_ienv_exp of (string * T);
exception table_missing_elem_exp of string;
exception add_dep_exp of string * Term.typ * Term.typ;
exception add_tdep_exp of string * Term.sort * Term.sort;


(* basic list operations. IMPROVE: use tables, for better efficiency *)
val tvname_union = Library.union ((fn x => x = EQUAL) o TVar.NTab.ord);
val vname_union = Library.union ((fn x => x = EQUAL) o Var.NTab.ord);
val tvname_remove = Library.remove ((fn x => x = EQUAL) o TVar.NTab.ord);
val vname_remove = Library.remove ((fn x => x = EQUAL) o Var.NTab.ord);

(* pretty printing: inst and uninst vars and typ vars *)

fun pretty_inst_tv ctxt (v,(srt,typ)) = 
    Pretty.block 
      [Pretty.str "?", TVar.NTab.pretty_name v, Pretty.str " : ",
       Trm.pretty_sort ctxt srt, Pretty.str " == ",
       Trm.pretty_typ ctxt typ];

fun pretty_uninst_tv ctxt (v,(srt, (tdeps,vdeps))) = 
    Pretty.block 
      [Pretty.str "?", TVar.NTab.pretty_name v, Pretty.str " : ",
       Trm.pretty_sort ctxt srt, 
       Pretty.str " & typdeps:",
       Pretty.list "[" "]" (map TVar.NTab.pretty_name tdeps),
       Pretty.str " & vardeps:",
       Pretty.list "[" "]" (map Var.NTab.pretty_name vdeps)]

fun pretty_inst_v ctxt (v,(typ,t)) = 
     Pretty.block 
       [Pretty.str "?", Var.NTab.pretty_name v, Pretty.str " : ",
        Trm.pretty_typ ctxt typ, Pretty.str " == ",
        Trm.pretty ctxt t];

fun pretty_uninst_v ctxt (v,(typ,vdeps)) = 
     Pretty.block 
       [Pretty.str "?", Var.NTab.pretty_name v, Pretty.str " : ",
        Trm.pretty_typ ctxt typ, Pretty.str " & vardeps: ",
        Pretty.list "[" "]"
                    (map Var.NTab.pretty_name vdeps)];

(* Pretty Printing: tvars and vars from names and an inst env *)
fun pretty_tvar (ienv as Insts rep) v = 
    (case TVar.NTab.lookup (#tyns rep) v 
      of NONE => raise table_missing_elem_exp 
                         ("pretty_inst_tvar: " ^ 
                          (TVar.NTab.string_of_name v))
       | SOME true => 
         (case TVTab.lookup (#tvars rep) v of 
            NONE => raise bad_ienv_exp ("pretty_tvar : inst tvar : "
                                        ^ (TVar.NTab.string_of_name v)
                                        , ienv)
          | SOME i => pretty_inst_tv (#ctxt rep) (v,i))
       | SOME false => 
         (case TVTab.lookup (#tdeps rep) v of 
            NONE => raise bad_ienv_exp ("pretty_tvar : uninst tvar : "
                                        ^ (TVar.NTab.string_of_name v)
                                        , ienv)
          | SOME u => pretty_uninst_tv (#ctxt rep) (v,u)));

fun pretty_var (ienv as Insts rep) v = 
  (case Var.NTab.lookup (#vns rep) v 
      of NONE => raise table_missing_elem_exp 
                         ("pretty_inst_var: " ^ 
                          (Var.NTab.string_of_name v))
       | SOME true => 
         (case VTab.lookup (#vars rep) v of 
            NONE => raise bad_ienv_exp ("pretty_var : inst var : "
                                        ^ (Var.NTab.string_of_name v)
                                        , ienv)
          | SOME i => pretty_inst_v (#ctxt rep) (v,i))
       | SOME false => 
         (case VTab.lookup (#deps rep) v of 
            NONE => raise bad_ienv_exp ("pretty_var : uninst var : "
                                        ^ (Var.NTab.string_of_name v)
                                        , ienv)
          | SOME u => pretty_uninst_v (#ctxt rep) (v,u)) );

fun pretty_flexes ctxt trms = 
    Pretty.list "[" "]" 
                (map (fn (t1,t2) => 
                      Pretty.block [Trm.pretty ctxt t1, Pretty.str "=?=", Trm.pretty ctxt t2])
                     trms);

(* Pretty Printing: var and tvar tables *)
fun pretty_inst_tvars ctxt tvars = 
    Pretty.chunks (map (pretty_inst_tv ctxt) (TVTab.dest tvars));
fun pretty_inst_vars ctxt vars = 
    Pretty.chunks (map (pretty_inst_v ctxt) (VTab.dest vars))
fun pretty_uninst_tvars ctxt tvars = 
    Pretty.list "[" "]" (map (pretty_uninst_tv ctxt) (TVTab.dest tvars));
fun pretty_uninst_vars ctxt vars = 
    Pretty.list "[" "]" (map (pretty_uninst_v ctxt) (VTab.dest vars));

(* Pretty Printing Instenv *)
fun pretty_full (ienv as Insts rep) = 
    let val ctxt = #ctxt rep in
    Pretty.chunks 
    [Pretty.str "TVar Names: ",
     TVar.NSet.pretty (TVar.NTab.get_nameset (#tyns rep)),
     Pretty.str "Var Names: ",
     Var.NSet.pretty (Var.NTab.get_nameset (#vns rep)),
     Pretty.str "Instantiated Type Variables:",
     pretty_inst_tvars ctxt (#tvars rep),
     Pretty.str "Instantiated Variables:",
     pretty_inst_vars ctxt (#vars rep),
     Pretty.str "Uninstantiated Type Variables:",
     pretty_uninst_tvars ctxt (#tdeps rep),
     Pretty.str "Uninstantiated Variables:",
     pretty_uninst_vars ctxt (#deps rep),
     Pretty.str "Flex-Flex Pairs:",
     pretty_flexes ctxt (#flexes rep)]
    end;

fun print_full i = Pretty.writeln (pretty_full i);

fun pretty (ienv as Insts rep) = 
    if TVar.NTab.is_element_empty (#tyns rep) 
       andalso Var.NTab.is_element_empty (#vns rep)
    then Pretty.str "No Variables"
    else 
      Pretty.chunks 
      [Pretty.block 
         [Pretty.str "TVars: ", 
          Pretty.list "[" "]" 
                      (map (pretty_tvar ienv) 
                           (TVar.NTab.keys (#tyns rep)))],
       Pretty.block 
         [Pretty.str "Vars: ", 
          Pretty.list "[" "]" 
                      (map (pretty_var ienv) 
                           (Var.NTab.keys (#vns rep)))]];

fun print i = Pretty.writeln (pretty i);


(* lookup *)
fun tvar_is_inst (Insts rep) tv =
  (case TVar.NTab.lookup (#tyns rep) tv 
      of NONE => raise table_missing_elem_exp 
                         ("tvar_is_inst: " ^ (TVar.NTab.string_of_name tv))
       | SOME x => x);
fun var_is_inst (Insts rep) v =
  (case Var.NTab.lookup (#vns rep) v 
      of NONE => raise table_missing_elem_exp 
                         ("var_is_inst: " ^ (Var.NTab.string_of_name v))
       | SOME x => x);

fun lookup_tvar_insts (Insts rep) nL = 
    List.mapPartial (TVTab.lookup (#tvars rep)) nL;
fun lookup_var_insts (Insts rep) nL = 
    List.mapPartial (VTab.lookup (#vars rep)) nL;

fun lookup_tvar_inst (Insts rep) n = TVTab.lookup (#tvars rep) n;
fun lookup_var_inst (Insts rep) n = VTab.lookup (#vars rep) n;

fun lookup_uninst_tvar (Insts rep) n = TVTab.lookup (#tdeps rep) n;
fun lookup_uninst_var (Insts rep) n = VTab.lookup (#deps rep) n;

(* lookup a tvar, var *)
fun lookup_tvar (ienv as Insts rep) tv = 
     (case TVar.NTab.lookup (#tyns rep) tv 
       of NONE => NONE
        | SOME true => 
          (case lookup_tvar_inst ienv tv
            of NONE => raise bad_ienv_exp 
                   ("lookup_var: inst: " ^ (TVar.NTab.string_of_name tv), ienv)
             | SOME (ty,i) => SOME ((tv,ty), SOME i))
        | SOME false => 
          (case lookup_uninst_tvar ienv tv
            of NONE => raise bad_ienv_exp 
                   ("lookup_var: uninst: " ^ (TVar.NTab.string_of_name tv), ienv)
             | SOME (ty,i) => SOME ((tv,ty), NONE)));

fun get_tvar ienv n = 
    (case lookup_tvar ienv n 
      of NONE => raise table_missing_elem_exp "get_tvar"
       | SOME tv => tv);

fun lookup_var (ienv as Insts rep) v = 
     (case Var.NTab.lookup (#vns rep) v 
       of NONE => NONE
        | SOME true => 
          (case lookup_var_inst ienv v
            of NONE => raise bad_ienv_exp 
                  ("lookup_var: inst: " ^ (Var.NTab.string_of_name v), ienv)
             | SOME (ty,i) => SOME ((v,ty), SOME i))
        | SOME false => 
          (case lookup_uninst_var ienv v
            of NONE => raise bad_ienv_exp 
                  ("lookup_var: uninst: " ^ (Var.NTab.string_of_name v), ienv)
             | SOME (ty,i) => SOME ((v,ty), NONE)));

fun get_var ienv n = 
    (case lookup_var ienv n 
      of NONE => raise table_missing_elem_exp "get_var"
       | SOME v => v);

fun get_typ_of_var ienv n = 
    let val ((v,ty),inst) = get_var ienv n
    in ty end;

(*  *)
fun no_uninst_tvars (Insts rep) = TVTab.is_empty (#tdeps rep);
fun no_uninst_vars (Insts rep) = VTab.is_empty (#deps rep);
fun is_ground d = no_uninst_vars d andalso no_uninst_tvars d;

fun no_inst_tvars (Insts rep) = TVTab.is_empty (#tvars rep);
fun no_inst_vars (Insts rep) = VTab.is_empty (#vars rep);
fun no_insts d = no_inst_tvars d andalso no_inst_tvars d;


fun get_tvar_inst iv n = 
    case lookup_tvar_inst iv n 
     of NONE => raise table_missing_elem_exp 
                        ("get_tvar_inst: no such variable: " 
                         ^ (TVar.NTab.string_of_name n))
      | SOME i => i;

fun get_var_inst iv n = 
    case lookup_var_inst iv n 
     of NONE => raise table_missing_elem_exp 
                        ("get_var_inst: no such variable: " 
                         ^ (Var.NTab.string_of_name n))
      | SOME i => i;

(* basic empty instantiation env. *)
fun init ctxt = 
    Insts {ctxt = ctxt,
           tyns = TVar.NTab.empty,
           vns = Var.NTab.empty,
           tvars = TVTab.empty,
           vars = VTab.empty,
           tdeps = TVTab.empty,
           deps = VTab.empty,
           flexes = []};

fun get_ctxt (Insts rep) = #ctxt rep;
fun update_ctxt f (Insts rep) =
    Insts {ctxt = f (#ctxt rep),
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = #tvars rep,
           vars = #vars rep,
           tdeps = #tdeps rep,
           deps = #deps rep,
           flexes = #flexes rep};
val set_ctxt = update_ctxt o K;

val get_theory = ProofContext.theory_of o get_ctxt;


fun get_flexes (Insts rep) = (#flexes rep);
fun set_flexes flexes2 (Insts rep) =
    Insts {ctxt = #ctxt rep,
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = #tvars rep,
           vars = #vars rep,
           tdeps = #tdeps rep,
           deps = #deps rep,
           flexes = flexes2};

(* internal only: simply removes an entry, does not perform proper
checking of dependencies etc. *)
fun remove_var_inst n (Insts rep) =
    Insts {ctxt = #ctxt rep,
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = #tvars rep,
           vars = VTab.delete n (#vars rep),
           tdeps = #tdeps rep,
           deps = #deps rep,
           flexes = #flexes rep};
fun remove_tvar_inst n (Insts rep) =
    Insts {ctxt = #ctxt rep,
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = TVTab.delete n (#tvars rep),
           vars = #vars rep,
           tdeps = #tdeps rep,
           deps = #deps rep,
           flexes = #flexes rep};
fun remove_var_dep n (Insts rep) =
    Insts {ctxt = #ctxt rep,
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = #tvars rep,
           vars = #vars rep,
           tdeps = #tdeps rep,
           deps = VTab.delete n (#deps rep),
           flexes = #flexes rep};
fun remove_tvar_dep n (Insts rep) =
    Insts {ctxt = #ctxt rep,
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = #tvars rep,
           vars = #vars rep,
           tdeps = TVTab.delete n (#tdeps rep),
           deps = #deps rep,
           flexes = #flexes rep};


(* removing dependencies *)
fun remove_dep ndep n deps = 
    (case VTab.lookup deps n of
       NONE => deps
     | SOME (ty2,ds) => VTab.update (n,(ty2,vname_remove ndep ds)) deps);
fun remove_v_tdep ndep n tdeps = 
    (case TVTab.lookup tdeps n of
       NONE => tdeps
     | SOME (srt,(tds,ds)) => 
       TVTab.update (n,(srt,(tds, vname_remove ndep ds ))) tdeps);
fun remove_t_tdep ntdep n tdeps = 
    (case TVTab.lookup tdeps n of
       NONE => tdeps
     | SOME (srt,(tds,ds)) => 
       TVTab.update (n,(srt,(tvname_remove ntdep tds, ds))) tdeps);

(* remove instantiation and things dependent on it (ndeps and ntdeps) *)
fun remove_var_inst_wdep (ndeps, ntdeps) n (Insts rep) =
    Insts {ctxt = #ctxt rep,
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = #tvars rep,
           vars = VTab.delete n (#vars rep),
           tdeps = Basics.fold (remove_v_tdep n) ntdeps (#tdeps rep),
           deps = Basics.fold (remove_dep n) ndeps (#deps rep),
           flexes = #flexes rep};

fun remove_tvar_inst_wdep ntdeps n (Insts rep) =
    Insts {ctxt = #ctxt rep,
           tyns = #tyns rep,
           vns = #vns rep,
           tvars = TVTab.delete n (#tvars rep),
           vars = #vars rep,
           tdeps = Basics.fold (remove_t_tdep n) ntdeps (#tdeps rep),
           deps = #deps rep,
           flexes = #flexes rep};

(* adding dependencies *)
fun add_dep ds' (n,ty) deps = 
    (case VTab.lookup deps n of
       NONE => VTab.update_new (n,(ty,ds')) deps
     | SOME (ty2,ds) => 
       if ty = ty2 then 
         VTab.update (n,(ty2,ds' @ ds)) deps
       else raise add_dep_exp ("add_dep: type clash" ^ (Pretty.string_of (Var.pretty_name n)),ty,ty2)
    );

fun add_tdep (newds as (tds',ds')) (n,srt) tdeps = 
    (case TVTab.lookup tdeps n of
       NONE => TVTab.update_new (n,(srt,newds)) tdeps
     | SOME (srt2,(tds,ds)) => 
       if srt = srt2 then 
         TVTab.update (n,(srt2,(tds' @ tds, ds' @ ds))) tdeps
       else raise raise add_tdep_exp ("add_tdep: sort clash" ^ (Pretty.string_of (TVar.pretty_name n)),srt,srt2)
    );

(* update types of vars in the term var dep table *)
fun update_var_typ (n, newty) deps = 
    (VTab.map_entry n (fn (_,vdeps) => (newty,vdeps)) deps);
(*   never raised:
   handle VTab.UNDEF _ => raise table_missing_elem_exp ...  *)

(* update any type var instantiations dependent on us *)
fun tyinst_dep_tvars (tyinst as (n,ty)) tvars childtydeps =
    List.foldr 
      (fn (n2,x as (subdeps,tvars)) => 
          (n2::subdeps, 
           (TVTab.map_entry 
             n2 (fn (tyv,ty2) => (tyv, Trm.inst1_typ_typ tyinst ty2))
             tvars)))
  (* never raised:   handle TVTab.UNDEF _ => x
                     raise table_missing_elem_exp ... *)
      ([n], tvars) childtydeps;


(* update any term var instantiations dependent on us *)
fun tyinst_dep_vars tyinst vars deps childdeps =
    List.foldr 
      (fn (n2,x as (newdeps,deps,vars)) => 
          (case VTab.lookup vars n2 of 
             NONE => x (* if var doesn't exist anywhere, igore it *)
                       (* DONT: raise table_missing_elem_exp ... *)
           | SOME (ty2,t2) =>
             (n2::newdeps,
              update_var_typ (n2,ty2) deps,
              VTab.update (n2,(Trm.inst1_typ_typ tyinst ty2,
                               Trm.inst1_trm_typ tyinst t2))
                            vars)))
      ([],deps,vars) childdeps;

(* implicit args: ty *)
fun inst_typ_tvars (i as Insts rep) = 
  let val vtab = #tvars rep in
    Trm.map_typ_tvars 
      (fn ((n,srt),vty) => 
          (case TVTab.lookup vtab n of 
             NONE => vty 
           | SOME (isrt,ity) => 
             (* slow check: maybe we can make a safe interface to avoid this? *)
             if Sign.of_sort (get_theory i) (ity, srt) then ity
             else raise bad_ienv_exp ("inst_typ_tvars: tvar has too restrictive sort:" ^ (Pretty.string_of (TVar.pretty_name n)),i)
      ))
  end;
(* implicit args: instenv, term *)
val inst_trm_typs = Trm.map_trm_types o inst_typ_tvars;
(* implicit args: term *)
fun inst_trm_vars (i as Insts rep) = 
    let val vtab = #vars rep in
      Trm.map_trm_vars 
        (fn ((n,ty),vtrm) => 
            (case VTab.lookup vtab n of 
               NONE => vtrm 
             | SOME (ity,itrm) => if ty = ity then itrm
                                  else raise bad_ienv_exp ("inst_trm_vars: instantiation has type clash with var:" ^ (Pretty.string_of (Var.pretty_name n)),i)))
    end;
(* implicit args: term *)
fun inst_trm e = 
    (Trm.beta_norm o Trm.eta_contract) 
    o inst_trm_vars e o inst_trm_typs e;


fun inst_dtrm i (TrmCtxt.D.Abs (s,ty)) = 
    TrmCtxt.D.Abs(s,inst_typ_tvars i ty)
  | inst_dtrm i (TrmCtxt.D.AppL t) = 
    TrmCtxt.D.AppL (inst_trm i t)
  | inst_dtrm i (TrmCtxt.D.AppR t) = 
    TrmCtxt.D.AppR (inst_trm i t);

(* inst_zipper: T -> Zipper.T -> Zipper.T *)
fun inst_zipper i z = 
    z |> Zipper.map_on_ctxt (inst_dtrm i)
      |> Zipper.set_trm (inst_trm i (Zipper.trm z));

(* add new tvars and vars to uninstantiated dependency table *)
fun new_uninst_tvar (n,srt) (e as Insts rep) = 
    let val (n2,tyns2) = TVar.NTab.add (n,false) (#tyns rep) 
(*        val _ = Pretty.writeln (pretty_uninst_tv (#ctxt rep) (n2,(srt,([],[]))))  *)
    in
      (n2,Insts {ctxt = #ctxt rep,
                 tyns = tyns2,
                 vns = #vns rep,
                 tvars = #tvars rep,
                 vars = #vars rep,
                 tdeps = TVTab.update_new (n2,(srt,([],[]))) (#tdeps rep),
                 deps = #deps rep,
                 flexes = #flexes rep})
    end;



(* add tvars and vars to uninstantiated dependency table *)
fun merge_uninst_tvar_deps (chtdeps,chdeps) (n,srt) (e as Insts rep) = 
    (case TVTab.lookup (#tdeps rep) n
      of SOME (_,(tyds,ds)) =>
         Insts {ctxt = #ctxt rep,
                tyns = #tyns rep,
                vns = #vns rep,
                tvars = #tvars rep,
                vars = #vars rep,
                tdeps = TVTab.update 
                          (n,(srt,(tvname_union chtdeps tyds,
                                   vname_union chdeps ds)))
                          (#tdeps rep),
                deps = #deps rep,
                flexes = #flexes rep}
       | NONE => 
         Insts {ctxt = #ctxt rep,
                tyns = TVar.NTab.update (n,false) (#tyns rep),
                vns = #vns rep,
                tvars = #tvars rep,
                vars = #vars rep,
                tdeps = TVTab.update_new (n,(srt,(chtdeps,chdeps)))
                                         (#tdeps rep),
                deps = #deps rep,
                flexes = #flexes rep}
    );

val merge_uninst_tvar = merge_uninst_tvar_deps ([],[]);


fun add_uninst_tyn_to_tyns (n,srt) tyns = 
    case TVar.NTab.lookup tyns n of 
      NONE => TVar.NTab.ins (n,false) tyns
    | SOME false => tyns (* already know it is uninstantiated *)
    | SOME true => raise instenv_exp "add_uninst_tyn_to_tyns: tyn is already recorded as instantiated!"; (* it is recorded as instantiated! bad table! *)

(* new var may have type with tvars that are instantiated in e --
 think about what we really want, could we get more efficiency? *)
fun new_uninst_var (n,ty) (e as Insts rep) = 
    let 
      (* instantiate any type variables in the new tvar using the envir *)  
      val ty' = inst_typ_tvars e ty;
      (* Some new type variables that don't exist in the table 
         may be introduced, may also get re-occcurnaces of other 
         uninstantiated tvars. *)
      val tvars = Trm.typ_tvars_of ty';

      val (n2,vns2) = Var.NTab.add (n,false) (#vns rep) 
(*        val _ = Pretty.writeln (pretty_uninst_v (#ctxt rep) (n2,(ty,[]))) *)
    in
      (n2,Insts {ctxt = #ctxt rep,
                 tyns = Basics.fold add_uninst_tyn_to_tyns tvars (#tyns rep),
                 vns = vns2,
                 tvars = #tvars rep,
                 vars = #vars rep,
                 (* note that new var uses these type vars *)
                 tdeps = Basics.fold (add_tdep ([], [n2])) tvars 
                                     (#tdeps rep),
                 deps = VTab.update_new (n2,(ty',[])) (#deps rep),
                 flexes = #flexes rep}
                (* add in any new introduced tvars *)
                |> Basics.fold merge_uninst_tvar tvars)
    end;

 (* implicit args: names_and_sorts, ienv *)
val new_uninst_tvars = 
    fold (fn x as (n,srt) => fn (l',e') => 
             let val (n2,e2) = new_uninst_tvar x e' in ((n2,srt)::l', e2) end); 
         
(* implicit args: names_and_types, ienv *)
val new_uninst_vars = 
    fold (fn x as (n,ty) => fn (l',e') => 
             let val (n2,e2) = new_uninst_var x e' in ((n2,ty)::l', e2) end);


fun merge_uninst_var_deps chdeps (n,ty) (e1 as Insts rep) = 
    (case VTab.lookup (#deps rep) n
      of SOME (_,ds) =>
         Insts {ctxt = #ctxt rep,
                tyns = #tyns rep,
                vns = #vns rep,
                tvars = #tvars rep,
                vars = #vars rep,
                deps = VTab.update (n,(ty, vname_union chdeps ds))
                                   (#deps rep),
                tdeps = #tdeps rep,
                flexes = #flexes rep}
       | NONE => 
         let val tvars = Trm.typ_tvars_of ty 
           val (Insts rep2) = (* each type var in ty is used by this var *)
               Basics.fold (merge_uninst_tvar_deps ([],n::chdeps))
                            tvars e1
         in
           Insts {ctxt = #ctxt rep,
                  tyns = #tyns rep2,
                  vns = Var.NTab.update (n,false) (#vns rep2),
                  tvars = #tvars rep2,
                  vars = #vars rep2,
                  deps = VTab.update_new (n,(ty,chdeps)) (#deps rep2),
                  tdeps = #tdeps rep2,
                  flexes = #flexes rep}
         end);

val merge_uninst_var = merge_uninst_var_deps [];


(* *)
fun merge_uninsts_of_fst (Insts rep1) (i2 as Insts rep2) = 
    i2 |> (TVTab.fold (fn x as (n,(srt,_)) => merge_uninst_tvar (n,srt))
                      (#tdeps rep1))
       |> (VTab.fold (fn x as (n,(ty,_)) => merge_uninst_var (n,ty))
                     (#deps rep1));




(* merge variables in a term (also instantiate the term's variables) *)
fun merge_trm t ienv = 
    let val t2 = inst_trm ienv t
    in (t2, ienv |> fold merge_uninst_tvar (Trm.tvars_of t2)
                 |> fold merge_uninst_var (Trm.vars_of t2))
    end;

(* new ienv of the vars in the term *)
fun of_trm ctxt t = 
    (init ctxt) |> fold merge_uninst_tvar (Trm.tvars_of t)
                |> fold merge_uninst_var (Trm.vars_of t);

(* Adds a typ variable to the instantiations environment.  We assume
that it is not already instantiated! We update any type and variable
instantiations that depends on the instroduced type variable. 
Assumed that this does not introduce any new type variables. 
*)
fun do_tvar_inst' (n,(srt,ty)) (e as Insts rep) = 
    (* enforce freshness -- maybe take this out for optimised code *)
    case (TVTab.lookup (#tvars rep) n) of
      SOME (srt2,ty2) => 
      if ty2 = ty then (([],[]),e)
      else
        raise bad_ienv_exp ("do_tvar_inst': var is already instantiated differently: " 
              ^ (TVar.NTab.string_of_name n) ^ " previously: " 
              ^ (Pretty.string_of (Trm.pretty_typ (get_ctxt e) ty2)) ^  "; and now:" 
              ^ (Pretty.string_of (Trm.pretty_typ (get_ctxt e) ty)), e)
    | NONE =>  
    let  
      (* update types that depend on the new given type instantiation. 
         Note: this is an eager update of dependent instantiations. *)
      val childdepsopt = TVTab.lookup (#tdeps rep) n;
      val ((newtydeps,tvars),(newvardeps,deps,vars),tdeps) = 
          case childdepsopt of 
            NONE => (([], #tvars rep), ([], #deps rep, #vars rep), 
                     #tdeps rep)
          | SOME (depsrt,(childtydeps,childdeps)) => 
            if srt <> depsrt then 
              raise bad_ienv_exp ("do_tvar_inst': sorts do not match: " 
                                   ^ (TVar.NTab.string_of_name n),e)
            else
              (tyinst_dep_tvars (n,ty) (#tvars rep) childtydeps,
               tyinst_dep_vars (n,ty) (#vars rep) (#deps rep) childdeps,
               TVTab.delete n (#tdeps rep));
    in
      ((newtydeps, newvardeps), 
       Insts{ ctxt = #ctxt rep,
              tyns = #tyns rep,
              vns = #vns rep,
              tvars = tvars,
              vars = vars,
              tdeps = tdeps,
              deps = deps,
              flexes = map (fn (t1,t2) => (Trm.inst1_trm_typ (n,ty) t1, 
                                           Trm.inst1_trm_typ (n,ty) t2)) 
                           (#flexes rep)})
    end;

val do_tvar_inst = snd oo do_tvar_inst';

exception bad_tvar_inst_exp of (TVar.name * (Trm.sort * Trm.typ)) * T;

fun add_tvar_inst (v as (n,(srt,ty))) e = 
    let 
      val ctxt = get_ctxt e;

(*       val _ = Pretty.writeln (pretty_inst_tv thry v); *)

      (* instantiate any type variables in the new tvar using the envir *)  
      val ty' = inst_typ_tvars e ty;
      val v' = (n,(srt,ty'));

(*       val _ = Sign.certify_typ thry ty';
      val _ = Sign.certify_sort thry srt; *)

      (* Some new type variables that don't exist in the table 
         may be introduced, may also get re-occcurnaces of other 
         uninstantiated tvars. *)
      val new_tvars = Trm.typ_tvars_of ty';

      (* instantiate the inst env with this new inst *)
      val ((newtdeps, newdeps), e2 as Insts rep) = 
          e |> Basics.fold merge_uninst_tvar new_tvars
            |> do_tvar_inst' v';

      (* update any variables that refered to this type variable to
         depend on the type variables that are still uninstantiated in
         the instantiation. *)
      val tdeps = Basics.fold (add_tdep (n::newtdeps, newdeps)) new_tvars
                               (#tdeps rep);
    in
      Insts{ ctxt = #ctxt rep,
             tyns = TVar.NTab.update (n,true) (#tyns rep),
             vns = #vns rep,
             tvars = TVTab.update v' (#tvars rep),
             vars = #vars rep,
             tdeps = tdeps,
             deps = #deps rep,
             flexes = #flexes rep}
    end
    handle Term.TYPE _ => raise bad_tvar_inst_exp (v,e);

(* Instantiate, but do not add the instantiation of this variable to
the instenv. avoid leaving a trace that we were here because we are not
affecting anything else outside this instantiation: we are a dum
variable instantiation. *)
fun add_dum_tvar_inst (n,(srt,ty)) e = 
    let 
      (* instantiate any type variables in the new tvar using the envir *)  
      val ty' = inst_typ_tvars e ty;
      val v' = (n,(srt,ty'));

      (* Some new type variables that don't exist in the table 
         may be introduced, may also get re-occcurnaces of other 
         uninstantiated tvars. *)
      val new_tvars = Trm.typ_tvars_of ty';

      (* instantiate the inst env with this new inst *)
      val ((newtdeps, newdeps), e2 as Insts rep) = 
          e |> Basics.fold merge_uninst_tvar new_tvars
            |> do_tvar_inst' v';

      (* update any variables that refered to this type variable to
         depend on the type variables that are still uninstantiated in
         the instantiation. *)
      val tdeps = Basics.fold (add_tdep (newtdeps, newdeps)) new_tvars
                               (#tdeps rep);
    in
      Insts{ ctxt = #ctxt rep,
             tyns = #tyns rep,
             vns = #vns rep,
             tvars = #tvars rep,
             vars = #vars rep,
             tdeps = tdeps,
             deps = #deps rep,
             flexes = map (fn (t1,t2) => (Trm.inst1_trm_typ (n,ty) t1, 
                                          Trm.inst1_trm_typ (n,ty) t2)) 
                          (#flexes rep)}
    end;

(* Adds a variable instantiation to the environment.  We assume
that it is not already instantiated! We update any variable
instantiations that depends on the instroduced variable. 
Assumed that this does not introduce any new variables or type variables. 
*)
fun do_var_inst' (n,(ty,t)) (e as Insts rep) = 
    (* enforce freshness -- maybe take this out for optimised code *)
    case (VTab.lookup (#vars rep) n) of
      SOME (ty2,t2) => 
      if t = t2 then ([],e)
      else raise bad_ienv_exp ("do_var_inst': tvar is already instantiated differently: " ^ (Var.NTab.string_of_name n) ^ " previously: " ^ (Pretty.string_of (Trm.pretty (get_ctxt e) t2)) ^  "; and now:" ^ (Pretty.string_of (Trm.pretty (get_ctxt e) t)), e)
    | NONE =>
    let 
      (* update var instantiations that expect to use this variable *)
      val childvdepsopt = VTab.lookup (#deps rep) n;
      val ((newvdeps,vars), deps') = 
          case childvdepsopt of NONE => (([], #vars rep), #deps rep)
          | SOME (_, childvdeps) => 
            (List.foldr 
               (fn (n2,(subdeps,vars)) => 
                   case VTab.lookup vars n2 of 
                     NONE => raise bad_ienv_exp 
                                     ("do_var_inst': missing var: "
                                      ^ (Var.NTab.string_of_name n2), e)
                   | SOME (ty2,t2) =>
                     (n2::subdeps, 
                      VTab.update (n2,(ty2, (Trm.inst1_trm_trm (n,t) t2)))
                                     vars))
               ([], #vars rep)
               childvdeps, 
             VTab.delete n (#deps rep));
    in
      (newvdeps, 
       Insts { ctxt = #ctxt rep,
               tyns = #tyns rep,
               vns = #vns rep,
               tvars = #tvars rep, 
               vars = vars,
               tdeps = #tdeps rep,
               deps = deps',
               flexes = map (fn (t1,t2) => (Trm.inst1_trm_trm (n,t) t1, 
                                             Trm.inst1_trm_trm (n,t) t2)) 
                          (#flexes rep)})
    end;


(* do instantiation in instenv, i.e. 
   without recording/add variable to deps etc *)
val do_var_inst : (Var.name * (Trm.typ * Trm.T)) -> T -> T
  = snd oo do_var_inst';


(* to instantiation and add variable to table, deps etc *)
exception bad_var_inst_exp of (Var.name * (Trm.typ * Trm.T)) * T;

fun add_var_inst (v as (n,(ty,t))) e = 
    let 
      val ctxt = get_ctxt e;

(*      val _ = Pretty.writeln (pretty_inst_v thry v); *)

      (* replace any type variables in the new var using the envir *)  
      val ty' = inst_typ_tvars e ty 
      val t' = inst_trm e t;
      val v' = (n, (ty',t'));

(*       val _ = Sign.certify_term thry t'; 
      val _ = Sign.certify_typ thry ty'; *)
      
      (* introduced new variables that don't exist in the table *)
      val new_tvars = Trm.tvars_of t';
      val new_vars = Trm.vars_of t';

      (* do internal instantiation *)
      val (newvdeps, (e2 as Insts rep)) = 
          e |> Basics.fold merge_uninst_tvar new_tvars
            |> Basics.fold merge_uninst_var new_vars
            |> do_var_inst' v';

      val vdeps =  n::newvdeps;

      (* new dependnecies on variables introduced by this instantiation. *)
      val deps' = Basics.fold (add_dep (vdeps)) new_vars (#deps rep);
      val tdeps' = Basics.fold (add_tdep ([],vdeps)) new_tvars (#tdeps rep);
    in      
      Insts{ ctxt = #ctxt rep,
             tyns = #tyns rep,
             vns = Var.NTab.update (n,true) (#vns rep),
             tvars = #tvars rep,
             vars = VTab.update v' (#vars rep),
             tdeps = tdeps',
             deps = deps',
             flexes = #flexes rep}
    end
    handle Term.TYPE _ => raise bad_var_inst_exp (v,e);


(* to instantiation and add variable to table, deps etc. This time,
don't leave a trace that we were here - that's because we are not
effecting anything else outside this instantiation: we are a dum
variable instantiation. *)
fun add_dum_var_inst (v as (n,(ty,t))) e = 
    let 
      (* replace any type variables in the new var using the envir *)  
      val ty' = inst_typ_tvars e ty 
      val t' = inst_trm e t;
      val v' = (n, (ty',t'));

      (* introduced new variables that don't exist in the table *)
      val new_tvars = Trm.tvars_of t';
      val new_vars = Trm.vars_of t';

      (* do internal instantiation *)
      val (newvdeps, (e2 as Insts rep)) = 
          e |> Basics.fold merge_uninst_tvar new_tvars
            |> Basics.fold merge_uninst_var new_vars
            |> do_var_inst' v';

      val vdeps = newvdeps;

      (* new dependnecies on variables introduced by this instantiation. *)
      val deps' = Basics.fold (add_dep (vdeps)) new_vars (#deps rep);
      val tdeps' = Basics.fold (add_tdep ([],vdeps)) new_tvars (#tdeps rep);
    in
      Insts{ ctxt = #ctxt rep,
             tyns = #tyns rep,
             vns = #vns rep,
             tvars = #tvars rep,
             vars = (#vars rep),
             tdeps = tdeps',
             deps = deps',
             flexes = map (fn (t1,t2) => (Trm.inst1_trm_trm (n,t) t1, 
                                          Trm.inst1_trm_trm (n,t) t2)) 
                          (#flexes rep) }
    end;


(* note: we use fold to get faster versions than dest and keys, (these
   perform a rev operation). We do not care about ordering being preserved. *)
fun inst_tvars_of (Insts rep) =  TVTab.fold (cons o #1) (#tvars rep) [];
fun inst_vars_of (Insts rep) =  VTab.fold (cons o #1) (#vars rep) [];
fun tvar_insts (Insts rep) =  TVTab.fold cons (#tvars rep) [];
fun var_insts (Insts rep) =  VTab.fold cons (#vars rep) [];
fun uninst_tvars_of (Insts rep) = 
    TVTab.fold (cons o (fn (n,(s,_)) => (n,s))) (#tdeps rep) [];
fun uninst_vars_of (Insts rep) = 
    VTab.fold (cons o (fn (n,(ty,_)) => (n,ty))) (#deps rep) [];
fun uninst_tvar_names_of (Insts rep) = 
    TVTab.fold (cons o (fn (n,_) => n)) (#tdeps rep) [];
fun uninst_var_names_of (Insts rep) = 
    VTab.fold (cons o (fn (n,_) => n)) (#deps rep) [];

fun uninst_tvars_deps (Insts rep) = TVTab.fold cons (#tdeps rep) [];
fun uninst_vars_deps (Insts rep) = VTab.fold cons (#deps rep) [];



(* instantiation of Isabelle cterm and thms... one day this may be moved *)
fun inst_cterm e ct = 
    Thm.cterm_of (get_theory e) (inst_trm e (Thm.term_of ct));

fun inst_thm ienv th = 
    let 
      val thry = get_theory ienv;
      val ctermify = Thm.cterm_of thry;
      val ctypify = Thm.ctyp_of thry 
    in
      th |> (Thm.instantiate 
               (map (fn (n,(srt,ty)) => (ctypify (TVar (n,srt)), ctypify ty))
                    (tvar_insts ienv),[]))
         |> (Thm.instantiate 
               ([],map (fn (n,(typ,t)) => (ctermify (Var (n,typ)), ctermify t))
                       (var_insts ienv)))
    end;


(* *)
fun dep_updates (Insts rep) = 
    let 
      fun add_tvar_dep d v tab =
          case TVTab.lookup tab v 
           of NONE => TVTab.update_new (v,[d]) tab
            | SOME deps => TVTab.update (v,d::deps) tab
      fun add_var_dep d v tab =
          case VTab.lookup tab v 
           of NONE => VTab.update_new (v,[d]) tab
            | SOME deps => VTab.update (v,d::deps) tab

      val (tvs_onty,vs_onty) = 
          TVTab.fold (fn (v,(_,(dtvs,dvs))) => (fn (tvs,vs) => 
                         (Basics.fold (add_tvar_dep v) dtvs tvs,
                          Basics.fold (add_var_dep v) dvs vs)))
                     (#tdeps rep) (TVTab.empty, VTab.empty);

      val vs_onv = 
          VTab.fold 
            (fn (v,(_,dvs)) => (fn vs =>
              Basics.fold (add_var_dep v) dvs vs))
            (#deps rep) VTab.empty;

    in ((tvs_onty,vs_onty), vs_onv) end;

datatype renaming = 
         Renaming of { inst : T,
                       avoid : T,
                       ignorevs : Var.NSet.T,
                       ignoretvs : TVar.NSet.T };

fun init_renaming avoid = 
    Renaming { inst = init (get_ctxt avoid),
               avoid = avoid, 
               ignorevs = Var.NSet.empty,
               ignoretvs = TVar.NSet.empty };

fun var_is_ignored_by_renaming (Renaming rep) v = 
    Var.NSet.contains (#ignorevs rep) v;
fun tvar_is_ignored_by_renaming (Renaming rep) v = 
    TVar.NSet.contains (#ignoretvs rep) v;
fun get_var_renaming (Renaming rep) v = 
    lookup_var_inst (#inst rep) v;
fun get_tvar_renaming (Renaming rep) v = 
    lookup_tvar_inst (#inst rep) v;
fun prep_tvar_for_renaming (vs as (v,srt)) (Renaming rep) = 
    let val (v2, avoid2) = new_uninst_tvar vs (#avoid rep)
    in if TVar.NTab.name_eq (v2, v) then 
         (NONE, Renaming {inst = #inst rep,
                          avoid = avoid2,
                          ignoretvs = TVar.NSet.add v2 (#ignoretvs rep),
                          ignorevs = #ignorevs rep})
       else
         (SOME v2, Renaming {inst = #inst rep,
                             avoid = avoid2,
                             ignoretvs = #ignoretvs rep,
                             ignorevs = #ignorevs rep})
    end;
fun prep_var_for_renaming (vt as (v,ty)) (Renaming rep)= 
    let val (v2, avoid2) = new_uninst_var vt (#avoid rep)
    in if Var.NTab.name_eq (v2, v) then 
         (NONE, Renaming {inst = #inst rep,
                          avoid = avoid2,
                          ignoretvs = #ignoretvs rep,
                          ignorevs = Var.NSet.add v2 (#ignorevs rep)})
       else
         (SOME v2, Renaming {inst = #inst rep,
                             avoid = avoid2,
                             ignoretvs = #ignoretvs rep,
                             ignorevs = #ignorevs rep})
    end;
fun add_tvar_renaming (Renaming rep) (v,srt) v2 =
    let val newtvar = TVar(v2,srt)
    in (Renaming {inst = add_tvar_inst (v,(srt,newtvar)) (#inst rep),
                  avoid = #avoid rep,
                  ignoretvs = #ignoretvs rep,
                  ignorevs = #ignorevs rep},
        newtvar)
    end;
fun add_var_renaming (Renaming rep) (v,ty) v2 =
    let val newvar = Var(v2,ty)
    in (Renaming {inst = add_var_inst (v,(ty,newvar)) (#inst rep),
                  avoid = #avoid rep,
                  ignoretvs = #ignoretvs rep,
                  ignorevs = #ignorevs rep}, 
        newvar)
    end;

fun inst_of_renaming (Renaming rep) = #inst rep;
fun avoid_of_renaming (Renaming rep) = #avoid rep;
fun unchanged_tvars_of_renaming (Renaming rep) = #ignoretvs rep;
fun unchanged_vars_of_renaming (Renaming rep) = #ignorevs rep;


exception rename_tvar_exp of renaming * ((TVar.name * Trm.sort) * Trm.typ);

(* assumes that, names(avoid) >= names(renaming) ignore is a set of
   names that do not need to be renamed (e.g. name is already fresh) *)
fun rename_tvar renaming (vs as (v,srt), ty) = 
    (if tvar_is_ignored_by_renaming renaming v then (renaming, ty)
     else
       case get_tvar_renaming renaming v of
         NONE => 
         (case prep_tvar_for_renaming vs renaming of 
            (* doesn't need to be renamed *)
            (NONE, renaming2) => (renaming2,ty) 
          | (SOME v2, renaming2) => 
            (* should be renamed to v2 *)
            add_tvar_renaming renaming2 vs v2)
       | SOME (_,ty2) => (renaming, ty2));
      (* handle *** _ => raise rename_tvar_exp (renaming, (vs, ty)); *)

fun rename_var renaming (vt as (v,ty), t) = 
    if var_is_ignored_by_renaming renaming v then (renaming, t)
    else
      case get_var_renaming renaming v of
        NONE => 
        (case prep_var_for_renaming vt renaming of 
           (* doesn't need to be renamed *)
           (NONE, renaming2) => (renaming2,t)
           (* should be renamed to v2 *)
         | (SOME v2, renaming2) => add_var_renaming renaming2 vt v2)
      | SOME (_,t2) => (renaming, t2);



(* rename_trm_vars : 
     (renaming_so_var : ienv, avoid_these_names : ienv) 
     -> rename_this_term : trm 
     -> ((renaming_used, avoids), renamed_term) *)
(* renames vars in a term to avoid a given set, returns the used renaming *)
val rename_trm_vars = 
    Trm.foldmap_trm_vars_and_tvars rename_tvar rename_var;

val rename_typ_tvars = Trm.foldmap_typ_tvars rename_tvar; 

(* merge two instenv's which share the same variable name space. Add
   entries in i1 to those in i2. Takes context of last ienv. *)
(* commutative, but is faster if smaller argument is first *)
fun merge_union i1 i2 = 
    i2 |> set_ctxt (get_ctxt i2)
       |> set_flexes ((get_flexes i1) @ (get_flexes i2))
       |> Basics.fold add_tvar_inst (tvar_insts i1)
       |> Basics.fold add_var_inst (var_insts i1)
       |> (Basics.fold (fn (v,(srt,deps)) => merge_uninst_tvar_deps deps (v, srt)) 
                        (uninst_tvars_deps i1))
       |> (Basics.fold (fn (v,(ty,deps)) => merge_uninst_var_deps deps (v, ty))
                         (uninst_vars_deps i1))

(* NOT comutative: drops new instantiations from i1, 
   adds only to insts in i2; ends with context of i2 *)
fun merge_intersect_snd (i1 as Insts rep1) (i2 as Insts rep2) = 
    let 
      val deps = #deps rep2
      val tdeps = #tdeps rep2
    in
      i2 |> set_ctxt (get_ctxt i2)
         |> set_flexes ((get_flexes i1) @ (get_flexes i2))
         |> (TVTab.fold 
               (fn x as (n,(srt,i)) => case TVTab.lookup tdeps n 
                         of NONE => I
                          | SOME _ => add_tvar_inst x)
               (#tvars rep1))
         |> (VTab.fold 
               (fn x as (n,(ty,i)) => case VTab.lookup deps n 
                         of NONE => I (* add new instantiation *)
                          | SOME _ => add_var_inst x) (* already instantiated, so ignore *)
               (#vars rep1))
    end;


(* split an instantiation env so that one has the given tvars and
vars, and the other has the rest (both get full set of flexes) *)
fun split (tvars,vars) i = 
    let val init = (init (get_ctxt i))
                     |> set_flexes (get_flexes i)
    in 
      (init, init) 
        |> (Basics.fold 
              (fn (v as (n,_)) => 
                  (fn (inclenv,exclenv) => 
                      if TVar.NTab.contains tvars n then
                        (add_tvar_inst v inclenv, exclenv)
                      else (inclenv, add_tvar_inst v exclenv)))
              (tvar_insts i))
        |> (Basics.fold 
              (fn (v as (n,_)) => 
                  (fn (inclenv,exclenv) => 
                      if Var.NTab.contains vars n then
                        (add_var_inst v inclenv, exclenv)
                      else (inclenv, add_var_inst v exclenv)))
              (var_insts i))
    end;

(* select these from the instenv and put in a new instenv *)
fun select (tvar_nms,var_nms) (Insts rep) = 
    let 
      val vars = #vars rep 
      val tvars = #tvars rep 
    in
      (init (#ctxt rep))
        |> (TVar.NSet.fold 
              (fn n => fn ienv => case TVTab.lookup tvars n 
                        of NONE => ienv
                         | SOME i => add_tvar_inst (n,i) ienv)
              tvar_nms)
        |> (Var.NSet.fold 
              (fn n => fn ienv => case VTab.lookup vars n 
                        of NONE => ienv
                         | SOME i => add_var_inst (n,i) ienv)
              var_nms)
    end;

(* select these from the instenv and put in a new instenv *)
fun select_list (tvar_nms,var_nms) (Insts rep) = 
    let 
      val vars = #vars rep 
      val tvars = #tvars rep 
    in
      (init (#ctxt rep))
        |> (Basics.fold 
              (fn n => fn ienv => case TVTab.lookup tvars n 
                        of NONE => ienv
                         | SOME i => add_tvar_inst (n,i) ienv)
              tvar_nms)
        |> (Basics.fold 
              (fn n => fn ienv => case VTab.lookup vars n 
                        of NONE => ienv
                         | SOME i => add_var_inst (n,i) ienv)
              var_nms)
    end;

fun select_fst (Insts rep1) = 
    select_list (TVTab.keys (#tvars rep1), VTab.keys (#vars rep1));

  



(* important: do types first, so that we don't loose the depinfo for
   vars in which the types occur *)
fun correct_var_renamings renamings insts = 
    insts
      |> (fn i => 
             List.foldr
               (fn (vi as (n, (_,ty)), i2) => 
                   case Trm.opt_dest_tvar ty of 
                     NONE => raise bad_ienv_exp 
            ("correct_var_renamings: bad renamings env: tvar", renamings)
                   | SOME (n2,_) => 
                     i2 |> do_tvar_inst vi
                        |> remove_tvar_inst_wdep [n] n2)
               i (tvar_insts renamings))
      |> (fn i => 
             List.foldr
               (fn (vi as (n, (_,t)), i2) => 
                   case Trm.opt_dest_var t of 
                     NONE => raise bad_ienv_exp 
            ("correct_var_renamings: bad renamings env: var", renamings)
                   | SOME (n2,_) => 
                     i2 |> do_var_inst vi
                        |> remove_var_inst_wdep ([n],[]) n2)
               i (var_insts renamings))


(* whenever a var is instantiated to another variable, 
   then invert it insts = [X = Var Y...] 
   get: insts = [Y = Var X...] 
 *)
fun invert_var_renamings (insts as Insts rep) = 
    insts
      |> (fn i => List.foldr 
                    (fn ((n, (ty,t)), i2) => 
                        case Trm.opt_dest_var t of 
                          NONE => i2
                        | SOME (n2,ty2) => 
                          i2 |> remove_var_inst n
                             |> remove_var_dep n2
                             |> add_var_inst (n2,(ty2, Trm.mk_var (n,ty)))
                             )
                    i (var_insts i))
      |> (fn i => List.foldr 
                    (fn ((n, (srt,ty)), i2) => 
                        case Trm.opt_dest_tvar ty of 
                          NONE => i2
                        | SOME (n2,srt2) => 
                          i2 |> remove_tvar_inst n
                             |> remove_tvar_dep n2
                             |> add_tvar_inst (n2,(srt2, Trm.mk_tvar (n,srt)))
                             )
                    i (tvar_insts i));

(* when an instantiation is to a var in the given set of tvar and var names, then
   invert it in the resulting instenv, otherwise ignore the instantiation.
   eg. 
   given: trm_vs = [X0,...]  insts = [X0 = Var Y...] 
   get: insts = [Y = Var X0...] 
 *)
fun mk_invert_var_renamings (typ_vs,trm_vs) insts = 
    let 
      fun check_var_inst (n, (ty,t)) ienv = 
          case Trm.opt_dest_var t  (* if inst is to another var *)
           of NONE => ienv
            | SOME (n2,_) => 
              if Var.NSet.contains trm_vs n2 then ienv
              else add_var_inst (n2,(ty,Trm.mk_var(n,ty))) ienv

       fun check_tvar_inst (n, (srt,ty)) ienv = 
          case Trm.opt_dest_tvar ty
           of NONE => ienv
            | SOME (n2,_) => 
              if TVar.NSet.contains typ_vs n2 then ienv
              else add_tvar_inst (n2,(srt,Trm.mk_tvar(n,srt))) ienv
    in
      (init (get_ctxt insts)) 
        |> fold check_var_inst (var_insts insts)
        |> fold check_tvar_inst (tvar_insts insts) 
    end;
end;


structure InstEnv : INSTENV = DB_InstEnv;
