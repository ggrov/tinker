signature EVAL =
sig
 type T
 exception eval_ex of string * T
 val empty : T
 val is_empty : T -> bool
 val push : V.name -> T -> T
 val pop : T -> (V.name * T) (* raises eval_ex exception *)
end (* signature *)

structure Ev_list =
struct
  type T = V.name list;
  exception eval_ex of string * T;

  val empty = [];
  val is_empty = List.null;
  fun delete_all _ [] = []
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
 val apply : ((Strategy_Theory.Graph.T * PPlan.T * V.name) -> (Strategy_Theory.Graph.T * PPlan.T) Seq.seq) (* atomic fun eval *)
             -> (PPlan.T -> Strategy_Theory.Graph.T -> V.name -> V.name list)  (* new enabled boxes *)
             -> (Strategy_Theory.Graph.T * PPlan.T * T) (* input *)
             -> (Strategy_Theory.Graph.T * PPlan.T * T) Seq.seq
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

structure EvalF_DF = Evaluate_Fun(DepthEv);
structure EvalF_BF = Evaluate_Fun(BreadthEv);

(* instead of updating context *)
functor EvalData (EV : EVALF) =
struct

  structure EV = EV;

  (* also ruleset *)
  datatype T = EData of { 
      pplan : PPlan.T,
      goals : PNode.T StrName.NTab.T,
      (* maybe something similar for relations? *)
      fmatch : (Feature.T -> Proof.context -> Thm.thm -> bool) StrName.NTab.T,
      ruleset : Strategy_Theory.Ruleset.T, 
      active : EV.T
  }

  fun get_pplan (EData rep) = #pplan rep;
  fun get_goals (EData rep) = #goals rep;
  fun get_fmatch (EData rep) = #fmatch rep;
  fun get_ruleset (EData rep) = #ruleset rep;
  fun get_active (EData rep) = #active rep;

  fun update_pplan f (EData rep) =
    EData {pplan = f (#pplan rep), goals = #goals rep, fmatch = #fmatch rep, 
           ruleset = #ruleset rep,active = #active rep};
  fun update_goals f (EData rep) =
    EData {pplan = #pplan rep, goals = f (#goals rep), fmatch = #fmatch rep, 
           ruleset = #ruleset rep,active = #active rep};
  fun update_fmatch f (EData rep) =
    EData {pplan = #pplan rep, goals = #goals rep, fmatch = f (#fmatch rep), 
           ruleset = #ruleset rep,active = #active rep};
  fun update_ruleset f (EData rep) =
    EData {pplan = #pplan rep, goals = #goals rep, fmatch = #fmatch rep, 
           ruleset = f (#ruleset rep),active = #active rep};
  fun update_active f (EData rep) =
    EData {pplan = #pplan rep, goals = #goals rep, fmatch = #fmatch rep, 
           ruleset = #ruleset rep,active = f (#active rep)};

  val set_pplan = update_pplan o K;
  val set_goals = update_goals o K;
  val set_fmatch = update_fmatch o K;
  val set_ruleset = update_ruleset o K;
  val set_active = update_active o K;

  fun init_of prf gs active th =
    EData {pplan = prf, goals = gs, fmatch = FeatureData.get th,
           ruleset = Strategy_RS.Ctxt.get th, active = EV.push_list active EV.empty};
           
  fun ins_tab pnode = StrName.NTab.ins (PNode.get_name pnode,pnode);
  val lookup_goal = StrName.NTab.lookup o get_goals;
  val get_goal = StrName.NTab.get o get_goals;
  fun add_goal pnode = update_goals (ins_tab pnode)
  fun add_goals pnods = update_goals (fold ins_tab pnods);
  fun del_goal pname = update_goals (StrName.NTab.delete pname);


end; (* functor *)

structure EvalD_DF = EvalData(EvalF_DF);
structure EvalD_BF = EvalData(EvalF_DF);

