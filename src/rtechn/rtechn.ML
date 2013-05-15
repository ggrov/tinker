(* Reasoning technique independent of graph  *)

signature RTECHN = 
sig
  type T
  exception rtechn_exp of string * T;

  datatype EvalData = EData of string
  datatype tac_assms = TNoAsm | TAllAsm | TClass of RT.NSet.T

  datatype atomic =
      Rule of RT.NSet.T (* rules used - what about with wire? *)
    | ERule of RT.name * RT.NSet.T (* wire + rules used *)
    | FRule of RT.name * RT.NSet.T (* wire + rules used *)
    | Subst of RT.NSet.T (* separate rule vs bwire? *)
    | SubstAsm of RT.name * RT.NSet.T (* bwre and rules - sep. rule vs bwire *)
    | Tactic of tac_assms * RT.name (* bwire as fact + name of tactic *)

  datatype appfn = Appf of atomic
                | HGraph of EvalData option
                | Merge
                | Identity
                | Or (* of EvalData option *)
                | OrElse (* of EvalData option *)

  val get_name : T -> RT.name
  val get_appf : T -> appfn

  val update_name : (RT.name -> RT.name) -> T -> T 
  val update_appf : (appfn -> appfn) -> T -> T

  val set_name : RT.name -> T -> T 
  val set_appf : appfn -> T -> T

  val set_atomic_appf : atomic -> T -> T 
  val set_hgraph_appf : T -> T
  val set_merge_appf : T -> T
  val set_identity_appf : T -> T
  val set_or_appf : T -> T
  val set_orelse_appf : T -> T

  val is_atomic : T -> bool
  val is_hgraph : T -> bool
  val is_identity : T -> bool
  val is_merge : T -> bool
  val is_or : T -> bool
  val is_orelse : T -> bool

  val get_atomic : T -> atomic option

  val id : T 
  val merge : T
  val id_str : RT.name -> T
  val fail : T 

  (* equality *)
  val ord : T * T -> order
  val eq : T * T -> bool

  (* pretty printing *)
  val pretty : T -> Pretty.T
  val pretty_name : T -> Pretty.T
  val print : T -> unit

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RTechn 
 : RTECHN 
= struct

 (* idea: we just look up a string with the relevant info. 
    TO DO: add more information  *)
 datatype EvalData = EData of string

 datatype tac_assms = TNoAsm | TAllAsm | TClass of RT.NSet.T

 datatype atomic =
    Rule of RT.NSet.T (* rules used - what about with wire? *)
  | ERule of RT.name * RT.NSet.T (* wire + rules used *)
  | FRule of RT.name * RT.NSet.T (* wire + rules used *)
  | Subst of RT.NSet.T (* separate rule vs bwire? *)
  | SubstAsm of RT.name * RT.NSet.T (* bwre and rules - sep. rule vs bwire *)
  | Tactic of tac_assms * RT.name (* bwires as facts + name of stactic *)

 datatype appfn = Appf of atomic
                | HGraph of EvalData option
                | Merge
                | Identity
                | Or (* of EvalData option *)
                | OrElse (* of EvalData option *)

 datatype T =
   RTechn of {
  		name : RT.name,
  		appf: appfn}
 
  exception rtechn_exp of string * T;

  fun get_name (RTechn rep) = #name rep;
  fun get_appf (RTechn rep) = #appf rep;

  fun update_name f (RTechn rep) = 
      RTechn { name = f (#name rep), appf = #appf rep};
  fun update_appf f (RTechn rep) = 
      RTechn { name = #name rep, appf = f(#appf rep)};

  val set_name = update_name o K; 
  val set_appf = update_appf o K; 

  val set_atomic_appf = set_appf o Appf;
  val set_hgraph_appf = set_appf (HGraph NONE);
  val set_merge_appf = set_appf Merge;
  val set_identity_appf = set_appf Identity;
  val set_or_appf = set_appf Or;
  val set_orelse_appf = set_appf OrElse;

  fun is_atomic_appfn (Appf _) = true
   |  is_atomic_appfn    _     = false;

  fun is_hgraph_appfn  (HGraph _) = true
   |  is_hgraph_appfn    _     = false;

  fun is_merge_appfn  Merge = true
   |  is_merge_appfn    _     = false;

  fun is_identity_appfn  Identity = true
   |  is_identity_appfn    _     = false;

  fun is_or_appfn  Or      = true
   |  is_or_appfn    _     = false;

  fun is_orelse_appfn OrElse   = true
   |  is_orelse_appfn    _     = false;

  val is_atomic = is_atomic_appfn o get_appf;
  val is_hgraph = is_hgraph_appfn o get_appf;
  val is_merge = is_merge_appfn o get_appf;
  val is_identity = is_identity_appfn o get_appf;
  val is_or = is_or_appfn o get_appf;
  val is_orelse = is_orelse_appfn o get_appf;

  fun get_atomic rt = 
    case get_appf rt 
    of (Appf atom) => SOME atom
    | _ => NONE;


  val id = RTechn {name = RT.mk "id", appf = Identity};

  val merge = RTechn {name = RT.mk "merge", appf = Merge};

  fun id_str str = id |> set_name str;

  val fail = id 
           |> set_atomic_appf (Tactic (TNoAsm,RT.mk "no_tac"))
           |> set_name (RT.mk "fail");

  (* to do: base this on appf function instead *)
  fun ord (rt1,rt2) = 
   case RT.name_ord (get_name rt1,get_name rt2) of
    EQUAL => EQUAL 
        (* this may be the problem with matching an empty output!!! - just do name (for now)
             prod_ord W.NSet.ord W.NSet.ord ((get_inputs rt1,get_inputs rt2),(get_outputs rt1,get_outputs rt1)) *)
    | x => x

  fun eq (rt1,rt2) = (ord (rt1,rt2) = EQUAL)

  fun pretty_name rt = RT.pretty_name (get_name rt);

  (* to do: do this in terms of appf as well *)
  fun pretty rt = Pretty.block 
                    [Pretty.chunks 
                       [Pretty.str "Name: ", pretty_name rt]];
  


  val print = Pretty.writeln o pretty;

end; (* struct *)



