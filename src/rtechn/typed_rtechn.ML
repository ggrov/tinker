(* Reasoning technique independent of graph  *)

signature TYPED_RTECHN = 
sig


  type T
  type tac_assms

  type atomic 

  type appfn 

  type wire = StrName.name;
  type wset = StrName.NSet.T;

  exception rtechn_exp of string * T;
  (*
  exception goal_lacks_type_exp of PNode.T;
  exception wrong_wire_type_exp of (PNode.T * wire);
  *)
  val get_name : T -> StrName.name
  val get_inputs : T -> wset
  val get_outputs : T -> wset
  val get_appf : T -> appfn

  val update_name : (StrName.name -> StrName.name) -> T -> T 
  val update_inputs : (wset -> wset) -> T -> T (* should only work for atomic? *)
  val update_outputs : (wset -> wset) -> T -> T 
  val update_appf : (appfn -> appfn) -> T -> T

  val set_name : StrName.name -> T -> T 
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

  val id_str : StrName.name -> T
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
functor TypRTechn_FUN (rtechn : RTECHN) 
 : TYPED_RTECHN 
= struct

  type appfn = rtechn.appfn;
  type tac_assms = rtechn.tac_assms;
  type atomic = rtechn.atomic;

  type wire = StrName.name;
  type wset = StrName.NSet.T;

 type search_data = unit * unit * string list

 (* idea: we just look up a string with the relevant info. 
    TO DO: add more information  *)
  datatype EvalData = EData of string

 (* must be serialisable *)
  datatype T =
   TypRTechn of {
  		rt     : rtechn.T,
  		inputs : wset,
  		outputs: wset}
 
  exception rtechn_exp of string * T;
(*
  exception goal_lacks_type_exp of PNode.T;
  exception wrong_wire_type_exp of (PNode.T * W.name);
*)
  (*morphism of rtechn*)
  fun rtechn_of (TypRTechn rep) =  (#rt rep);
  val get_name = rtechn.get_name o rtechn_of;
  val get_appf = rtechn.get_appf o rtechn_of;

  fun get_inputs (TypRTechn rep) = #inputs rep;
  fun get_outputs (TypRTechn rep) = #outputs rep;
  

  fun update_rtechn f (trep as TypRTechn rep) = 
      TypRTechn { rt = f (rtechn_of trep), 
                  inputs = #inputs rep, outputs = #outputs rep };
  fun update_name f (trep as TypRTechn rep) = 
      TypRTechn { rt = rtechn.update_name f  (rtechn_of trep), 
                  inputs = #inputs rep, outputs = #outputs rep };
  fun update_appf f (trep as TypRTechn rep) = 
      TypRTechn { rt = rtechn.update_appf f (rtechn_of trep), 
                  inputs = #inputs rep, outputs = #outputs rep };

  fun update_inputs f (TypRTechn rep) = 
      TypRTechn { rt = #rt rep, inputs = f(#inputs rep), outputs = #outputs rep };
  fun update_outputs f (TypRTechn rep) = 
      TypRTechn { rt = #rt rep, inputs = #inputs rep, outputs = f(#outputs rep) };

  val set_rtechn = update_rtechn o K;
  val set_name = update_name o K; 
  val set_inputs = update_inputs o K; 
  val set_outputs = update_outputs o K; 
  val set_appf = update_appf o K; 

(*TODO: any sharing facility to avoid refering to definition of datatype in rtechn ? Or better idea ?*)
  fun set_atomic_appf atom trep = rtechn.set_atomic_appf atom (rtechn_of trep) |> (fn x => set_rtechn x trep);
(*TODO: yet to complete*)  
  fun set_hgraph_appf trep = rtechn.set_hgraph_appf (rtechn_of trep) |> (fn x => set_rtechn x trep);
  fun set_merge_appf trep = rtechn.set_merge_appf (rtechn_of trep) |> (fn x => set_rtechn x trep);
  fun set_identity_appf trep = rtechn.set_identity_appf (rtechn_of trep) |> (fn x => set_rtechn x trep);
  fun set_or_appf  trep = rtechn.set_or_appf (rtechn_of trep) |> (fn x => set_rtechn x trep);
  fun set_try_appf trep = rtechn.set_try_appf (rtechn_of trep) |> (fn x => set_rtechn x trep);

  fun set_io ws = set_inputs ws #> set_outputs ws;

  val is_atomic = rtechn.is_atomic o rtechn_of;
  val is_hgraph =  rtechn.is_hgraph o rtechn_of;
  val is_merge =  rtechn.is_merge o rtechn_of;
  val is_identity =  rtechn.is_identity o rtechn_of;
  val is_or =  rtechn.is_or o rtechn_of;
  val is_try =  rtechn.is_try o rtechn_of;

  val get_atomic = rtechn.get_atomic o rtechn_of;


  (* We should really check this w.r.t hgraph graphs since they have to be invariant *)
  val union_inputs = update_inputs o StrName.NSet.union_merge o get_inputs;

  val union_outputs = update_outputs o StrName.NSet.union_merge o get_outputs;
  fun union_io r1 = (union_inputs r1) o (union_outputs r1)

(*
  fun id_appf rst = (case RState.get_inputs rst of 
                       NONE => RState.set_outputs (GoalNode.G.NSet.empty) rst
                     | (SOME gnd) => RState.set_outputs (GoalNode.G.NSet.single gnd) rst)
                    |> Seq.single
*) 

  val id = TypRTechn {rt = rtechn.id, inputs = StrName.NSet.empty, outputs = StrName.NSet.empty };

  val merge = TypRTechn {rt = rtechn.merge, inputs = StrName.NSet.empty, outputs = StrName.NSet.empty };

  fun id_str str = id |> set_name str;

  fun id_of wire = 
   id |> set_inputs (StrName.NSet.single wire)
      |> set_outputs (StrName.NSet.single wire)

  fun merge_of wire = 
   merge |> set_inputs (StrName.NSet.single wire)
         |> set_outputs (StrName.NSet.single wire)

  val fail = id 
           |> set_rtechn rtechn.fail

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
             prod_ord StrName.NSet.ord StrName.NSet.ord ((get_inputs rt1,get_inputs rt2),(get_outputs rt1,get_outputs rt1)) *)
    | x => x

  fun eq (rt1,rt2) = (ord (rt1,rt2) = EQUAL)

  fun pretty rt = Pretty.block 
                    [Pretty.chunks 
                       [Pretty.str "Name: ", Pretty.str (get_name rt)],
                     Pretty.chunks
                       [Pretty.str "Inputs: ", StrName.NSet.pretty (get_inputs rt)],
                     Pretty.chunks
                       [Pretty.str "Outputs: ", StrName.NSet.pretty (get_outputs rt)]];
  
  fun pretty_name rt = Pretty.str (get_name rt);

  val print = Pretty.writeln o pretty;

end; (* struct *)

structure TypRTechn = TypRTechn_FUN (RTechn);
