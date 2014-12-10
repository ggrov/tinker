functor PSGraphFun(Theory : PS_THEORY) : PS_GRAPH =
struct

   structure Theory = Theory;
   structure Prover = Theory.Data.GoalTyp.Prover;
   
   (* prover tactic : what about evaluation? should this be in the tactic or as args here? *)
   datatype T = PSGraph of {
        graph : Theory.Graph.T,
        graph_tactics : (Theory.Graph.T list) StrName.NTab.T, (* only name of parent *)
        atomic_tactics : Prover.tactic StrName.NTab.T, (* what about args? *)
        goaltype_data : Theory.Data.GoalTyp.data
        (* parent field ? *)
    }

   fun update_graph f (PSGraph rep) = 
     PSGraph { graph = f (#graph rep), graph_tactics = #graph_tactics rep, 
               atomic_tactics = #atomic_tactics rep, goaltype_data = #goaltype_data rep}
   fun update_graph_tactics f (PSGraph rep) = 
     PSGraph { graph = #graph rep, graph_tactics = f (#graph_tactics rep), 
               atomic_tactics = #atomic_tactics rep, goaltype_data = #goaltype_data rep}
   fun update_atomic_tactics f (PSGraph rep) = 
     PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
               atomic_tactics = f (#atomic_tactics rep), goaltype_data = #goaltype_data rep}
   fun update_goaltype_data f (PSGraph rep) = 
     PSGraph { graph = #graph rep, graph_tactics = #graph_tactics rep, 
               atomic_tactics = #atomic_tactics rep, goaltype_data = f (#goaltype_data rep)}


   fun get_graph (PSGraph rep) = #graph rep;
   fun get_graph_tactics (PSGraph rep) = #graph_tactics rep;
   fun get_atomic_tactics (PSGraph rep) = #atomic_tactics rep;
   fun get_goaltype_data (PSGraph rep) = #goaltype_data rep;

   val set_graph = update_graph o K;
   val set_graph_tactics = update_graph_tactics o K;
   val set_atomic_tactics = update_atomic_tactics o K;
   val set_goaltype_data = update_goaltype_data o K;

   fun of_graph graph = 
     PSGraph { graph = graph,
               graph_tactics = StrName.NTab.empty,
               atomic_tactics = StrName.NTab.empty,
               goaltype_data = Theory.Data.GoalTyp.default_data };

   val empty = of_graph Theory.Graph.empty;

   fun all_names ps = 
     let
       val gtac_nms = StrName.NTab.get_nameset (get_graph_tactics ps)
       val tac_nms = StrName.NTab.get_nameset (get_atomic_tactics ps)
     in
       StrName.NSet.union_merge gtac_nms tac_nms
     end;

   fun fresh_name ps = StrName.NSet.new (all_names ps);

   fun combine ps1 ps2 = ps1; (* fixme *)

   fun load_atomics tacs ps = 
     fold
     (fn (str, tac) => update_atomic_tactics (StrName.NTab.doadd (str, tac)))
     tacs ps;

end
