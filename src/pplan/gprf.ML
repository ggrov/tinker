signature GRAPH_PROOF =
sig
 type T (* graph *)
 
 (* makes a graph representation of an abstract proof *)
 val mk_graph_proof : DB_APrf.T -> T
 val empty_graph : T

end;

structure GraphProof =
struct

 (* fixme: for a nested proof - how do we know which input goes where:
      - solution by label on the rewrite
      - that means that proof data also need input and output name? *)

 (* Vertex *)

 structure Prf_Data : ORD_DATA = 
 struct
   (* represents a proof node *)
   datatype gprf = PAtom of DB_APrf.nd
                 | PNested of string (* remove or keep? *)
                 | POpen (* Dummy node for remaining goals? *)
   type data = gprf;
   fun pretty_data _ = Pretty.chunks [];
   val print_data = Pretty.writeln o pretty_data;
   fun data_ord (PAtom d1,PAtom d2) = EQUAL (* ??? *)
     | data_ord (PAtom d1,PNested d2) = LESS 
     | data_ord (PNested d1,PAtom d2) = GREATER
     | data_ord (PNested d1,PNested d2) = String.compare(d1,d2);
   fun data_eq (d1,d2) = (data_ord(d1,d2) = EQUAL);
 end (* struct Prf_Data *)

 structure Vertex : NAME_AND_DATA where type data = Prf_Data.data = 
 struct
   open SStrName;
   val default_name = mk "empty";
   open Prf_Data;
   val default_data = POpen; 
   structure Map = NameMapFun(structure Dom = SStrName and Cod = SStrName);
   structure Amorph = NameAmorphFun(SStrName);
   structure SharingWithData = struct 
     open Sharing; type data = data; 
     structure Map = Map.Sharing;
     structure Amorph = Amorph.Sharing;
   end;
 end; (* struct Vertex *)

 (* Edge *)

 structure Edge_Data : ORD_DATA =
 struct
   datatype ggoal = PGoal of {name : gname, term: Trm.T}
   type data = ggoal;
   fun pretty_data _ = Pretty.chunks [];
   val print_data = Pretty.writeln o pretty_data;
   fun data_ord (PGoal pg1,PGoal pg2) = String.compare(#name pg1,#name pg2);
   fun data_eq (d1,d2) = (data_ord(d1,d2) = EQUAL);
 end; (* end struct Edge_Data *)

 structure Edge_Name_Data : NAME_AND_DATA = 
 struct
   open SStrName;
   val default_name = mk "empty";
   open Edge_Data;
   val default_data = PGoal {name = Goaln.default_name , term = Const("",Term.propT)} ; 
   structure Map = NameMapFun(structure Dom = SStrName and Cod = SStrName);
   structure Amorph = NameAmorphFun(SStrName);
   structure SharingWithData = struct 
     open Sharing; type data = data; 
     structure Map = Map.Sharing;
     structure Amorph = Amorph.Sharing;
   end; 
 end (* struct Edge_Name_Data *)

 structure Edge = EdgeFun(structure Nm = Edge_Name_Data);

 (* Graph *)

 structure BGraph = BasicGraphFun(
             structure Vertex = Vertex and Edge = Edge
             type data = unit
             val empty_data = ());
 structure Graph = GraphFun(structure BasicGraph = BGraph);

 (* should only need goals and opengs *)
 fun mk_graph_proof (Proof ({top_cxname,context,denv,ienv,goals,ctxts,opengs})) =
 (* find top-level goal *)
 (* create node, find all subgoals,create their node,make edges between 
    and recurse until no more goals (maybe need to check with subgoals too) *)
    let val e_graph = Graph.empty
        val top_level_goal =
        fun mk_vertex g = 
        fun mk_edge v1 v2 g =  
        fun iter graph gs = 
    in
      iter e_graph top_level_goal
    end;
end (* structure GraphProof *)


