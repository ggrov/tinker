(* Reasoning technique independent of graph  *)

signature RTECHN = 
sig
  type T

  datatype tac_assms = TNoAsm | TAllAsm | TClass of StrName.NSet.T

  datatype atomic =
      Rule of StrName.NSet.T (* rules used - what about with wire? *)
    | ERule of StrName.name * StrName.NSet.T (* wire + rules used *)
    | FRule of StrName.name * StrName.NSet.T (* wire + rules used *)
    | Subst of StrName.NSet.T (* separate rule vs bwire? *)
    | SubstAsm of StrName.name * StrName.NSet.T (* bwre and rules - sep. rule vs bwire *)
    | Tactic of tac_assms * string (* bwire as fact + name of tactic *)

  type appfn 
  type wire = W.name;
  type wset = W.NSet.T;

  exception rtechn_exp of string * T;
  exception goal_lacks_type_exp of PNode.T;
  exception wrong_wire_type_exp of (PNode.T * wire);

  val get_name : T -> string
  val get_inputs : T -> wset
  val get_outputs : T -> wset
  val get_appf : T -> appfn

  val update_name : (string -> string) -> T -> T 
  val update_inputs : (wset -> wset) -> T -> T (* should only work for atomic? *)
  val update_outputs : (wset -> wset) -> T -> T 
  val update_appf : (appfn -> appfn) -> T -> T

  val set_name : string -> T -> T 
  val set_inputs : wset -> T -> T 
  val set_outputs :  wset -> T -> T 
  val set_appf : appfn -> T -> T

  val set_atomic_appf : atomic -> T -> T 
  val set_hgraph_appf : T -> T
  val set_merge_appf : T -> T
  val set_identity_appf : T -> T
  val set_or_appf : T -> T
  val set_try_appf : T -> T

  val set_io : wset -> T -> T

  val is_atomic : T -> bool
  val is_hgraph : T -> bool
  val is_identity : T -> bool
  val is_merge : T -> bool
  val is_or : T -> bool
  val is_try : T -> bool

  val get_atomic : T -> atomic option

  val union_inputs : T -> T -> T (* second technique with inputs unioned with first *)
  val union_outputs : T -> T -> T (* second technique with outputs unioned with first *)
  val union_io : T -> T -> T

  val id : T (* does nothing successfully for one step *)
  val id_of : wire -> T
  val merge_of : wire -> T
  val merge : T

  val id_str : string -> T
  val fail : T (* returns empty seq *)
  (* val ofstep : (RState.T -> RState.T) -> T *) (* technique of single function *)

  (* val apply_atomic  : T -> RState.T -> RState.T Seq.seq *) (* raises rtechn_exp *)
(*
  val fix_outputs : T -> RState.T -> RState.T (* fixes result map according to outputs of rtechn *)
  val fix_inputs : T -> RState.T -> RState.T  (* fixes result map according to inputs of rtechn *)
  val typecheck_rtechn_step : T -> RState.T -> RState.T -> bool (* raises exceptions *) 
*)

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

  type wire = W.name;
  type wset = W.NSet.T;

 type search_data = unit * unit * string list

 (* must be serialisable! *)
 datatype EvalData = EData of {
    eval_push : string -> string list -> string list,
    searchf : (search_data -> bool) -> (search_data -> search_data Seq.seq) -> search_data -> search_data Seq.seq,
    timeout : Time.time
    } 

 datatype tac_assms = TNoAsm | TAllAsm | TClass of StrName.NSet.T

 datatype atomic =
    Rule of StrName.NSet.T (* rules used - what about with wire? *)
  | ERule of StrName.name * StrName.NSet.T (* wire + rules used *)
  | FRule of StrName.name * StrName.NSet.T (* wire + rules used *)
  | Subst of StrName.NSet.T (* separate rule vs bwire? *)
  | SubstAsm of StrName.name * StrName.NSet.T (* bwre and rules - sep. rule vs bwire *)
  | Tactic of tac_assms * string (* bwires as facts + name of stactic *)

 (* must be serialisable! *)
 datatype appfn = Appf of atomic
                | HGraph of EvalData option
                | Merge
                | Identity
                | Or (* of EvalData option *)
                | Try (* of EvalData option *)

 (* must be serialisable *)
 datatype T =
   RTechn of {
  		name : string,
  		inputs : wset,
  		outputs: wset,
  		appf: appfn}
 
  (* what about global properties like instantiations of meta-vars? *)
  type appf = T -> tactic -> PNode.T -> (PNode.T * PNode.T list) Seq.seq

  exception rtechn_exp of string * T;
  exception goal_lacks_type_exp of PNode.T;
  exception wrong_wire_type_exp of (PNode.T * W.name);

  fun get_name (RTechn rep) = #name rep;
  fun get_inputs (RTechn rep) = #inputs rep;
  fun get_outputs (RTechn rep) = #outputs rep;
  fun get_appf (RTechn rep) = #appf rep;

  fun update_name f (RTechn rep) = 
      RTechn { name = f (#name rep), inputs = #inputs rep, outputs = #outputs rep, appf = #appf rep};
  fun update_inputs f (RTechn rep) = 
      RTechn { name = #name rep, inputs = f(#inputs rep), outputs = #outputs rep, appf = #appf rep};
  fun update_outputs f (RTechn rep) = 
      RTechn { name = #name rep, inputs = #inputs rep, outputs = f(#outputs rep), appf = #appf rep};
  fun update_appf f (RTechn rep) = 
      RTechn { name = #name rep, inputs = #inputs rep, outputs = #outputs rep, appf = f(#appf rep)};

  val set_name = update_name o K; 
  val set_inputs = update_inputs o K; 
  val set_outputs = update_outputs o K; 
  val set_appf = update_appf o K; 

  val set_atomic_appf = set_appf o Appf;
  val set_hgraph_appf = set_appf (HGraph NONE);
  val set_merge_appf = set_appf Merge;
  val set_identity_appf = set_appf Identity;
  val set_or_appf = set_appf Or;
  val set_try_appf = set_appf Try;

  fun set_io ws = set_inputs ws #> set_outputs ws;
  
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

  fun is_try_appfn Try      = true
   |  is_try_appfn    _     = false;

  val is_atomic = is_atomic_appfn o get_appf;
  val is_hgraph = is_hgraph_appfn o get_appf;
  val is_merge = is_merge_appfn o get_appf;
  val is_identity = is_identity_appfn o get_appf;
  val is_or = is_or_appfn o get_appf;
  val is_try = is_try_appfn o get_appf;

  fun get_atomic rt = 
    case get_appf rt 
    of (Appf atom) => SOME atom
    | _ => NONE;

  (* We should really check this w.r.t hgraph graphs since they have to be invariant *)
  val union_inputs = update_inputs o W.NSet.union_merge o get_inputs;

  val union_outputs = update_outputs o W.NSet.union_merge o get_outputs;
  fun union_io r1 = (union_inputs r1) o (union_outputs r1)

(*
  fun id_appf rst = (case RState.get_inputs rst of 
                       NONE => RState.set_outputs (GoalNode.G.NSet.empty) rst
                     | (SOME gnd) => RState.set_outputs (GoalNode.G.NSet.single gnd) rst)
                    |> Seq.single
*) 

  val id = RTechn {name = "id", inputs = W.NSet.empty, outputs = W.NSet.empty, 
                   appf = Identity};

  val merge = RTechn {name = "merge", inputs = W.NSet.empty, outputs = W.NSet.empty, 
                   appf = Merge};

  fun id_str str = id |> set_name str;

  fun id_of wire = 
   id |> set_inputs (W.NSet.single wire)
      |> set_outputs (W.NSet.single wire)

  fun merge_of wire = 
   merge |> set_inputs (W.NSet.single wire)
         |> set_outputs (W.NSet.single wire)

  val fail = id 
           |> set_atomic_appf (Tactic (TNoAsm,"no_tac"))
           |> set_name "fail";

(*  fun ofstep f = id
    |> set_name "ofstep"
    |> set_atomic_appf (Seq.single o f);

  fun apply_atomic rt st = 
       case (get_appf rt) of
          (Appf f) => Seq.map RState.new_id (f st)
        |  _ => raise rtechn_exp ("not atomic technique",rt);
*)

  fun ord (rt1,rt2) = 
   case String.compare (get_name rt1,get_name rt2) of
    EQUAL => EQUAL 
        (* this may be the problem with matching an empty output!!! - just do name (for now)
             prod_ord W.NSet.ord W.NSet.ord ((get_inputs rt1,get_inputs rt2),(get_outputs rt1,get_outputs rt1)) *)
    | x => x

  fun eq (rt1,rt2) = (ord (rt1,rt2) = EQUAL)

  fun pretty rt = Pretty.block 
                    [Pretty.chunks 
                       [Pretty.str "Name: ", Pretty.str (get_name rt)],
                     Pretty.chunks
                       [Pretty.str "Inputs: ", W.NSet.pretty (get_inputs rt)],
                     Pretty.chunks
                       [Pretty.str "Outputs: ", W.NSet.pretty (get_outputs rt)]];
  
  fun pretty_name rt = Pretty.str (get_name rt);

  val print = Pretty.writeln o pretty;

end; (* struct *)


