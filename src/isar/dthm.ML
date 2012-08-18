(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./base/Isar/dthm.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Created:    14 Oct 2004
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Generic declarative theorems with attributes
    (Attributes are mappings of the form: thm -> thm)
*)

(* signature for an attribute for a declarative theorem This is only
for attributes that modify the theorem. Those that modify a context
are treated differently. *)
signature DTHM_ATTR = 
sig

type T; (* type of a declarative attribute *)

val kind_of : T -> SafeObject.kind (* unique kind of an attribute *)
(* pretty printing *)
val string_of : T -> string
val pretty : T -> Pretty.T
val print : T -> unit
(* attribute function we are a declarative representation of *)
val appl : T -> Thm.thm -> Thm.thm 

(* equality between attributes - using underlying hidden equality *)
val eq : T -> T -> bool

(* used in the functor for making new kinds of declarartive thy attrib *)
val mk_get_data :
    SafeObject.kind -> (SafeObject.T -> 'd) -> T -> 'd option

(* make a declarative attribute object *)
val mk_dattr :
       ('a -> Pretty.T)  (* prettyf *)
       * ('a -> Thm.thm -> Thm.thm) (* attrib f *)
       * ('a -> 'a -> bool) (* equality for attribute data *)
       * (SafeObject.T -> 'a) (* decoding function *)
       * ('a -> SafeObject.kind * SafeObject.T) (* encoding function  *)
       -> 'a (* data *)
       -> T (* the new declarative attribute object *)
end;


structure DThmAttr :> DTHM_ATTR 
= struct

(* Note: the object data has already been given to the attrf and pretty
functions. Any modification of the data must be done through a
mechanism that updates the other functions appropriately *)
datatype T = attr of { 
         kind : SafeObject.kind, (* get the unique kind object *)
         data : SafeObject.T, (* data for this kind of attribute *)
         eq : T -> bool, (* equality check with another dattr *)
         pretty : Pretty.T, (* pretty print this attribute *)
         attrf : Thm.thm -> Thm.thm }; (* the attribute function *)

fun kind_of (attr rep) = #kind rep;
fun eq (attr rep) = #eq rep;
fun pretty (attr rep) = (#pretty rep);
val print = Pretty.writeln o pretty;
val string_of = Pretty.string_of o pretty;
fun appl (attr rep) = #attrf rep;
fun data_of (attr rep) = #data rep;

(* create a function to get the data *)
fun mk_get_data k decf (attr rep) = 
    if SafeObject.eq_kind (k, #kind rep) then SOME (decf (#data rep)) 
    else NONE;
(* note: requires that kind uniquely specified data type, else we get a runtime exp *)
fun mk_eqf (kind,eqf,decf) da = 
    SafeObject.eq_kind (kind_of da, kind) andalso 
    eqf (decf (data_of da));

(* function to make a generic thy attrb, we place the data in the pretty
and attr function directly. This is not a problem as anything that
edits the data must update the prettyf and attrf also. *)
fun mk_dattr (prettyf, attrf, eqf, decf, encf) (d : 'b) = 
    let 
      val (kind, generic_d) = encf d
    in
      attr {kind = kind, 
            data = generic_d, 
            eq = mk_eqf (kind,eqf d,decf),
            pretty = prettyf d, 
            attrf = attrf d
           }
    end;


end; (* structure DThmAttr *)


(* the kind of a declarative attribute must have these things... *)
signature DTHM_ATTR_KIND =
sig
type T (* internal data type for attribute arguments *)
val attrf : T -> Thm.thm -> Thm.thm
val eq : T -> T -> bool
val prettyf : T -> Pretty.T
val name : string
end;


(* to get an instance of a declarative attribute kind *)
signature DTHM_ATTR_INST =
sig
type T (* data specirfically for this object *)
val kind : SafeObject.kind (* kind/name of this type of data *)
val dattr : T -> DThmAttr.T
val data : DThmAttr.T -> T option
end;

(* functor to protect the internal datatype of attribute arguments *)
functor DThmAttrInstFUN (structure K : DTHM_ATTR_KIND)
        : DTHM_ATTR_INST = 
struct
val kind = SafeObject.kind K.name;
type T = K.T;
local 
  exception Data of T;
  fun decf (Data x) = x;
  fun encf d = (kind, Data d);
in
(* implicit extra arg: DThyAttr.T *)
val data = DThmAttr.mk_get_data kind decf;
(* implicit extra arg: T *)
val dattr = DThmAttr.mk_dattr (K.prettyf, K.attrf, K.eq, decf, encf);
end; (* local *)

end; (* DAttrInstFUN *)




(* a handy wrapper for theorems with attributes that provides a
   declarative representation that can be printed and re-parsed. *)
signature DTHM =
sig

type T; (* type of declarative theorem - ie one with a name and attributes *)

val short_name_of : T -> string
val long_name_of : T -> string
val attrs_of : T -> DThmAttr.T list
val initthm_of : T -> Thm.thm
val finalthm_of : T -> Thm.thm 
val theory_of : T -> Context.theory

(* equality (name + attrs) of dtheorems *)
val eq : T -> T -> bool

(* make a dthm from a theorem and some attributes *)
val mk_i : ((string * Thm.thm) * DThmAttr.T list) -> T
val mk_a : (Thm.thm * DThmAttr.T list) -> T
val mk : Thm.thm -> T
val add_attrs : T -> DThmAttr.T list -> T

(* pretty printing  *)
val pretty : T -> Pretty.T
val print : T -> unit 

end;


structure DThm
 :> DTHM
= struct 

exception dthm_unnamed_exp of string;

(* type for an attributed theorem in Isar, using declarative attributes *)
(* FIXME: make attribute kind data dependent on 'a as a function! *)
datatype T = DThm of
       { name : string,
         thm : Thm.thm, (* initial (named) theorem *) 
         appl : Thm.thm  (* final theorem *)
                * (DThmAttr.T * Thm.thm) list (* stages of application *)
       };

fun short_name_of (DThm rep) = (#name rep);
fun attrs_of (DThm rep) = map fst (snd (#appl rep));
fun appl_of (DThm rep) = #appl rep;
fun initthm_of (DThm rep) = #thm rep;

(* make a dthm from a theorem and some attributes *)
(* Note: we zero var indecies after attribute application - we should
get Isar to do this also. *)
fun mk_i ((s,th),attrs) = 
     let 
       val _ = if s = "" then 
                 tracing ("IsaPlanner Warning: mk_attrthm: cannot make a declarative attribute of an unnamed theorem: " ^  (Display.string_of_thm_without_context th)) else ()
     in
       DThm { name = s,
              thm = th,
              appl = List.foldr (fn (a,(th,L)) => 
                               (DThmAttr.appl a th, (a, th) :: L))
                           (th, []) attrs }
     end;

fun mk_a (th,attrs) = mk_i ((Thm.get_name_hint th, th),attrs);
fun mk th = mk_i ((Thm.get_name_hint th, th),[]);

(* add attributes to a declarative theorem *)
fun add_attrs dth attrs = 
    DThm { name = short_name_of dth,
           thm = initthm_of dth,
           appl = List.foldr (fn (a,(th,L)) => 
                            (DThmAttr.appl a th, (a, th) :: L))
                        (appl_of dth) attrs };

(* pretty printing dthms with its attributes *)
fun pretty dth = 
    let val attrs = attrs_of dth
      val prettyname = Pretty.str (short_name_of dth)
    in
      case attrs of 
        [] => prettyname
      | _ => Pretty.block 
               [prettyname, Pretty.list "[" "]" (map DThmAttr.pretty attrs)]
    end;

val print = Pretty.writeln o pretty;

val long_name_of = Pretty.string_of o pretty;

fun finalthm_of' (DThm rep) = fst (#appl rep);
val theory_of = (Thm.theory_of_thm o finalthm_of');

fun finalthm_of dth = 
    Thm.put_name_hint (Pretty.string_of (pretty dth)) 
                 (finalthm_of' dth);

(* equality for lists of declarative attributes - must have the same
   number and they must be the same *)
fun attrs_eq [] [] = true
  | attrs_eq (h :: t) (h2 :: t2) = 
    DThmAttr.eq h h2 andalso attrs_eq t t2
  | attrs_eq _ _ = false;

(* declarative attributed theorems are checked for equality using
their names and the kinds of attributes that are applied. Note: maybe
we should use the stricter Thm.eq rather than names...? *)
fun eq dth1 dth2 = 
    short_name_of dth1 = short_name_of dth2 andalso 
    attrs_eq (attrs_of dth1) (attrs_of dth2);

end; (* DThm *)
