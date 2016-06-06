(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gproof/prf/paramtab.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
                Initially written Oct 2006                             *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Abstract notion of totally ordered and named parameters for
    terms. Comes with a notion of liftening on parameter collection
    into another. This is renaming to avoid subst, and inerting at the
    front of the list of params, i.e. carefully extended ordering. 

  IMPROVE: add a notion of rename above: that steals a name and
  renames the everything beyond. This will allow for new params to be
  introduced above. Eg. fixing meta vars. 

  Note: parameters are stored with the inner-most binder first.
*)

signature PARAM_DATA = 
sig
structure Names : NAME;
type kind
val pretty_kind : Proof.context -> kind -> Pretty.T
end;

signature PARAM_TAB =
sig
  type name
  type kind

  structure NSet : NAME_SET where type name = name;
  structure NTab : NAME_TAB where type name = name;

  sharing NSet = NTab.NSet;

  (* new params come first *)
  type T

  val empty : T

  val is_empty : T -> bool
  val get_nparams : T -> int 
  val get_plist : T -> (name * kind) list 
  val get_tab : T -> (int * kind) NTab.T
  val get_pnames : T -> NSet.T

  val lookup : T -> name -> (int * kind) option (* pos in ordering and kind *)

  val of_plist : (name * kind) list -> T

  val map_params : (name * kind -> name * kind) -> T -> T

  (* only adds fresh stuff to param table *)
  val addifnew1: (name * kind) -> T -> ((name * kind) * T) option
  val addifnew_list : (name * kind) list -> T -> ((name * kind) list * T)

  (* makes names fresh *)
  val add1 : (name * kind) -> T -> (name * T)
  val add_list : (name * kind) list -> T -> (name list * T)

  (* unsafe append of two ptabs first on in front of the second *)
  val append_disjoint : T -> T -> T  

  (* safe append with renaming *)
  val refresh_name_front_append : T -> T -> (((name * kind) list * name NTab.T) * T)
  val refresh_name_back_append : T -> T -> (((name * kind) list * name NTab.T) * T)

  (* params of first beyond second: asssume first is 
     under=extends second *)
  val params_beyond : T -> T -> T
  
  (* drop params *)
  val drop_innern : int -> T -> T
  val drop_outern : int -> T -> T
  
  (* renaming *)
  val refresh_name1 
      : (name * kind) 
        -> (((name * kind) list * name NTab.T) * T) 
        -> (((name * kind) list * name NTab.T) * T)
  val refresh_name_list 
      : (name * kind) list (* new params to rename and add *)
        -> (((name * kind) list (* lifted so far = new params *)
            * name NTab.T) (* renaming *)
            * T) (* all params to be avoided *)
        -> (((name * kind) list (* new params *)
            * name NTab.T) (* renamings *)
            * T) (* all params *)
  val refresh_names
      : T 
        -> (((name * kind) list * name NTab.T) * T) 
        -> (((name * kind) list * name NTab.T) * T)

  val pretty_name : name -> Pretty.T
  val pretty_kind : Proof.context -> kind -> Pretty.T
 
  val pretty : Proof.context -> T -> Pretty.T
  val print : Proof.context -> T -> unit
end;

(* abstract notion of parameters *)
functor ParamTabFUN(ParamData : PARAM_DATA) 
  : PARAM_TAB 
= struct

type name = ParamData.Names.name;
type kind = ParamData.kind;

val name_ord = ParamData.Names.name_ord;

structure NTab = ParamData.Names.NTab;
structure NSet = ParamData.Names.NSet;

datatype T = PTab of
           (int (* number of params = length of list *)
            * (name * kind) list (* inner most binder first *)
  (* int is the location in the list of params = deBruijn Index *)
            * ((int * kind) NTab.T)); 

val empty = PTab (0, [],NTab.empty);


(* add a param to the outside *)
fun add1 (name,kind) (PTab (n,l,tab))  = 
    let val (name2,tab2) = NTab.add (name,(n,kind)) tab in
      (name2, PTab (n+1, (name2,kind)::l, tab2))
    end;

(* add a list of params to the outside - input order is inner-most one
   first, output order is outer-most first *)
fun add_list l pt = 
    fold
      (fn x => fn (L,pt1) => let val (n',pt2) = add1 x pt1 in (n'::L,pt2) end)
      l ([],pt);

(* add a param to the outside *)
fun addifnew1 (nk as (name,kind)) (ptab as PTab (n,l,tab))  = 
    (case NTab.lookup tab name of 
       NONE => 
       let val (n2,ptab2) = add1 nk ptab in 
         SOME ((n2,kind),ptab2) end
     | SOME _ => NONE)

fun addifnew_list l pt = 
    fold 
      (fn x => fn (lpt as (L,pt1)) => 
                  case addifnew1 x pt1 
                   of NONE => lpt
                    | SOME (n',pt2) => (n'::L,pt2))
      l ([],pt);


(* creating from a plist folded addition *)
(* of_plist [a0,...,an] for a term t = ALL [a0, ... an]. t. 
   outer-most binder first *)
fun of_plist l = fold_rev (snd oo add1) l empty;

(* #3 (rename_list l ([],NTab.empty,empty));*)

fun get_nparams (PTab (i,_,_)) = i;
fun get_plist (PTab (_,l,_)) = l;
fun lookup (PTab (_,_,pt)) n = 
    NTab.lookup pt n;

fun get_tab (PTab (_,_,pt)) = pt;
fun get_pnames (PTab (_,_,pt)) = NTab.get_nameset pt;

val is_empty = List.null o get_plist;

(* parameters of innerp, not in outerp *)
fun params_beyond inner outer = 
    of_plist (List.take (get_plist inner, 
                         (get_nparams inner) - (get_nparams outer)));

(* combine two param tables, second one after first 
   raises NTab.DUP on name clash 
*)
fun append_disjoint (PTab (i1, l1, t1)) (PTab (i2, l2, t2)) = 
    let val t2' = NTab.map_all (fn n => fn (i,ty) => (i + i1, ty)) t2 in 
      PTab (i1 + i2, l1 @ l2, NTab.merge_disjoint t1 t2') end;

(* rename params (frees) to avoid given paramtab, 
   returns param renametab. Note: overrides any earlier renaming. *)
fun refresh_name1 (nk as (name,kind)) ((newps, renamings), ptab) = 
    (case lookup ptab name
      of NONE => ((nk::newps, renamings), snd (add1 nk ptab))
       | SOME _ => 
         let val (name2,ptab2) = add1 nk ptab
         in (((name2,kind)::newps, 
              NTab.update (name,name2) renamings), 
             ptab2) end);
(* implicit: (name, kind) list, and liftings (newps, renamings, ptab) *)
val refresh_name_list = fold_rev refresh_name1;
(* implicit tab then tab *)
val refresh_names = refresh_name_list o get_plist;

(* safe append with renaming of front, newer params *)
fun refresh_name_front_append ptab ptab2 = 
    let val (ns, ptab') = refresh_names ptab (([],NTab.empty), ptab2)
    in (ns, append_disjoint ptab' ptab) end;

(* safe append with renaming of back, older params *)
fun refresh_name_back_append ptab ptab2 = 
    let val (ns, ptab2') = refresh_names ptab2 (([],NTab.empty), ptab)
    in (ns, append_disjoint ptab ptab2') end;


(* from the oldest dropn params -- those fixed first *)
(* IMPROVE: make more efficient *)
fun drop_innern dropn ptab = 
    of_plist (List.drop (get_plist ptab, dropn));

fun drop_outern dropn ptab = 
    of_plist (List.take (get_plist ptab, (get_nparams ptab) - dropn));


fun map_params f = of_plist o map f o get_plist;


(* pretty printing code *)
val pretty_name = ParamData.Names.pretty_name;
val pretty_kind = ParamData.pretty_kind;

fun pretty thry (PTab (_,_,pt)) = 
    Pretty.list 
      "[" "]" 
      (map (fn (name,(i,kind)) => 
               Pretty.block 
                 [ Pretty.str "(",
                   Pretty.str (Int.toString i),
                   Pretty.str ",",
                   pretty_name name, 
                   Pretty.str "::",
                   pretty_kind thry kind,
                   Pretty.str ")"  ])
           (Library.sort (fn ((_,(i,_)),(_,(i2,_))) => Int.compare (i,i2))
                         (NTab.list_of pt)));
val print = Pretty.writeln oo pretty;

end;
