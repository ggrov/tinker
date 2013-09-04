(* contains the data structure for a proof strategy graph *)
signature PS_GRAPH =
sig
  structure PSTheory : PS_THEORY 
  (* Prover = PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover *)
  (* structure Prover : ATOMIC *)
  type T

  val empty : T
  val of_graph : PSTheory.PS_Theory.Graph.T -> T

  (* get methods *)
  val get_graph : T -> PSTheory.PS_Theory.Graph.T
  val get_g_tacs : T -> PSTheory.PS_Theory.Rule.T StrName.NTab.T
  val get_or_tacs : T -> (PSTheory.PS_Theory.Graph.T list) StrName.NTab.T
  val get_orelse_tacs : T -> (PSTheory.PS_Theory.Graph.T * PSTheory.PS_Theory.Graph.T) StrName.NTab.T
  val get_atomics : T -> PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.tactic StrName.NTab.T

  (* set methods *)
  val set_graph : PSTheory.PS_Theory.Graph.T -> T -> T 
  val set_g_tacs : PSTheory.PS_Theory.Rule.T StrName.NTab.T -> T -> T 
  val set_or_tacs : (PSTheory.PS_Theory.Graph.T list) StrName.NTab.T -> T -> T 
  val set_orelse_tacs : (PSTheory.PS_Theory.Graph.T * PSTheory.PS_Theory.Graph.T) StrName.NTab.T -> T -> T 
  val set_atomics : PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.tactic StrName.NTab.T -> T -> T 

  (* update methods *)
  val update_graph : (PSTheory.PS_Theory.Graph.T -> PSTheory.PS_Theory.Graph.T) -> T -> T 
  val update_g_tacs : 
       (PSTheory.PS_Theory.Rule.T StrName.NTab.T -> PSTheory.PS_Theory.Rule.T StrName.NTab.T)
        -> T -> T 
  val update_or_tacs : 
       ((PSTheory.PS_Theory.Graph.T list) StrName.NTab.T -> (PSTheory.PS_Theory.Graph.T list) StrName.NTab.T)
       -> T -> T 
  val update_orelse_tacs : 
       ((PSTheory.PS_Theory.Graph.T * PSTheory.PS_Theory.Graph.T) StrName.NTab.T 
       -> (PSTheory.PS_Theory.Graph.T * PSTheory.PS_Theory.Graph.T) StrName.NTab.T) 
       -> T -> T 
  val update_atomics : 
  (PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.tactic StrName.NTab.T 
  -> PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.tactic StrName.NTab.T) -> T -> T 

  (* fresh name generation *)
  val fresh_name : T -> StrName.name -> StrName.name
  
  (* load a list of atomics *)
  val load_atomics : 
  (StrName.NTab.name *
    PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.tactic) list 
  -> T -> T

end

functor PSGraphFun(structure PSTheory : PS_THEORY) : PS_GRAPH =
struct

   structure PSTheory = PSTheory;
   structure PS_Theory = PSTheory.PS_Theory;
   structure Prover = PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover;
   
   (* no longer uses underlying storage of data in isabelle? *)
   datatype T = PSGraph of {
        graph : PS_Theory.Graph.T,
        g_tacs : PS_Theory.Rule.T StrName.NTab.T, (* only name of parent *)
        or_tacs : (PS_Theory.Graph.T list) StrName.NTab.T,
        orelse_tacs : (PS_Theory.Graph.T * PS_Theory.Graph.T) StrName.NTab.T, (* (try,orelse) *)
        (* fixme: should depend on underlying theorem prover *)
        atomics : Prover.tactic StrName.NTab.T
    }

   fun update_graph f (PSGraph rep) = PSGraph
     {graph = f (#graph rep), g_tacs = #g_tacs rep, or_tacs = #or_tacs rep, 
      orelse_tacs = #orelse_tacs rep, atomics = #atomics rep};
   fun update_g_tacs f (PSGraph rep) = PSGraph
     {graph = #graph rep, g_tacs = f (#g_tacs rep), or_tacs = #or_tacs rep, 
      orelse_tacs = #orelse_tacs rep, atomics = #atomics rep};
   fun update_or_tacs f (PSGraph rep) = PSGraph
     {graph = #graph rep, g_tacs = #g_tacs rep, or_tacs = f (#or_tacs rep), 
      orelse_tacs = #orelse_tacs rep, atomics = #atomics rep};
   fun update_orelse_tacs f (PSGraph rep) = PSGraph
     {graph = #graph rep, g_tacs = #g_tacs rep, or_tacs = #or_tacs rep, 
      orelse_tacs = f (#orelse_tacs rep), atomics = #atomics rep};
   fun update_atomics f (PSGraph rep) = PSGraph
     {graph = #graph rep, g_tacs = #g_tacs rep, or_tacs = #or_tacs rep, 
      orelse_tacs = #orelse_tacs rep, atomics = f (#atomics rep)};

   fun get_graph (PSGraph rep) = #graph rep;
   fun get_g_tacs (PSGraph rep) = #g_tacs rep;
   fun get_or_tacs (PSGraph rep) = #or_tacs rep;
   fun get_orelse_tacs (PSGraph rep) = #orelse_tacs rep;
   fun get_atomics (PSGraph rep) = #atomics rep;

   val set_graph = update_graph o K;
   val set_g_tacs = update_g_tacs o K;
   val set_or_tacs = update_or_tacs o K;
   val set_orelse_tacs = update_orelse_tacs o K;
   val set_atomics = update_atomics o K;

   fun of_graph graph = 
     PSGraph { graph = graph,
               g_tacs = StrName.NTab.empty,
               or_tacs = StrName.NTab.empty,
               orelse_tacs = StrName.NTab.empty,
               atomics = StrName.NTab.empty };

   val empty = of_graph PS_Theory.Graph.empty;

   fun all_names ps = 
     let
       val gtacn = StrName.NTab.get_nameset (get_g_tacs ps)
       val gorn = StrName.NTab.get_nameset (get_or_tacs ps)
       val goren = StrName.NTab.get_nameset (get_orelse_tacs ps)
       val gatn = StrName.NTab.get_nameset (get_atomics ps)
     in
       gtacn 
       |> StrName.NSet.union_merge gorn
       |> StrName.NSet.union_merge goren
       |> StrName.NSet.union_merge gatn
     end;

   fun fresh_name ps = StrName.NSet.new (all_names ps);

   fun combine ps1 ps2 = ps1; (* fixme *)

   fun load_atomics tacs ps = 
     fold
     (fn (str, tac) => update_atomics (StrName.NTab.doadd (str, tac)))
     tacs ps;

end
