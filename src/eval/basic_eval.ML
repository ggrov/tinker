signature EVAL =
sig
 type T
 exception eval_ex of string * T
 val empty : T
 val is_empty : T -> bool
 val push : V.name -> T -> T
 val pop : T -> (V.name * T) (* raises eval_ex exception *)
end (* signature *)


(* instead of updating context *)
functor EvalData (EV : EVAL) =
struct

  (* also ruleset *)
  datatype T = EData of { 
      pplan : PPlan.T,
      goals : PNode.T StrName.NTab.T,
      ruleset : Strategy_Theory.Ruleset.T, 
      active : EV.T
  }

end;



structure Ev_list =
struct
  type T = V.name list;
  exception eval_ex of string * T;

  val empty = [];
  val is_empty = List.null;
  fun delete_all x [] = []
   |  delete_all x (e::es) = if V.name_eq (x,e) then delete_all x es else e::(delete_all x es)
  fun contains x = List.exists (fn e => V.name_eq (x,e));

  fun pop [] = raise eval_ex ("empty enabled collection",[])
   |  pop (x::xs) = (x,xs);
end;

structure DepthEv : EVAL =
struct
  open Ev_list;
  fun push x xs = x::(delete_all x xs);
end;

structure BreadthEv : EVAL =
struct
  open Ev_list;
  fun push x xs = if contains x xs then xs else xs@[x]
end;

signature EVALF =
sig
 include EVAL
 val push_list : V.name list -> T -> T
 val push_set : V.NSet.T -> T -> T
 val of_list : V.name list -> T
 val apply : ((Strategy_Theory.Graph.T * PPlan.prf * V.name) -> (Strategy_Theory.Graph.T * PPlan.prf) Seq.seq) (* atomic fun eval *)
             -> (PPlan.prf -> Strategy_Theory.Graph.T -> V.name -> V.name list)  (* new enabled boxes *)
             -> (Strategy_Theory.Graph.T * PPlan.prf * T) (* input *)
             -> (Strategy_Theory.Graph.T * PPlan.prf * T) Seq.seq
end (* signature *)

functor Evaluate_Fun(Ev : EVAL) : EVALF =
struct
 structure Ev = Ev;
 open Ev;

 val push_list = fold push;
 val push_set  = V.NSet.fold push; 
 fun of_list xs = push_list xs empty;

 fun apply' appf new_enabled (g,rst,enabled) =
   let 
     val (v,vs) = pop enabled 
     fun update (g',rst') = (g',rst', push_list (new_enabled rst' g' v) vs)
   in 
     appf (g,rst,v)
     |> Seq.map update
   end;
  
  (* not sure about this! *)
  fun apply appf new_enabled st = 
    apply' appf new_enabled st handle eval_ex _ => Seq.empty;

end (* functor *)

structure EvalDF = Evaluate_Fun(DepthEv);
structure EvalBF = Evaluate_Fun(BreadthEv);

