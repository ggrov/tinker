(* Turns proof term into proof graph *)
structure PTParse =
struct

  structure Graph = PSGraph.PSTheory.PS_Theory.Graph;
  structure GData = PSGraph.PSTheory.PS_GraphParam.GraphSubstData;

  (* Tree Construction *)

  (* Datatypes for trees *)
  datatype tmp_prftree = TmpPrf of proof * (tmp_prftree list)
  datatype prftree = Prf of (string * term option) * (prftree list)

  (* Finding proof term representation of a proof *)  
  fun prf thm = Proofterm.proof_of (Proofterm.strip_thm (Thm.proof_body_of thm));

  (* Stripping unnecessary information from proof term *)
  fun stripp (A %% B) = (stripp A) %% (stripp B)
   | stripp (A % _) = stripp A
   | stripp (Abst (_, _, A)) = stripp A
   | stripp (AbsP (_,_,A)) = stripp A
   | stripp A = A;

  (* Converts each element of proof term to a singleton list. Combines these into a 
    list of all goals/tactics *)
  fun app_list (A %% B) = app_list A @ [B]
   |  app_list (A % _) = app_list A
   |  app_list (Abst (_,_,X)) = app_list X
   |  app_list (AbsP (_,_,X)) = app_list X
   |  app_list X = [X];

  (* Finds pairs of tactics (strings) and goals (terms) at each stage *)
  fun pair_trm_tac (PAxm (x,t,_)) = (x,SOME t)
   |  pair_trm_tac (PThm (_,((s,t,_),_))) = (s,SOME t)
   |  pair_trm_tac (Abst (_,_,X)) = pair_trm_tac X
   |  pair_trm_tac (AbsP (_,_,X)) = pair_trm_tac X
   |  pair_trm_tac (PBound _) = ("assumption",NONE);

  (* Takes term from tmp_prftree datatype to prftree (proof to (string*term) pair) *)
  fun project_trm_tac (TmpPrf (x,xs)) =  Prf (pair_trm_tac x,map project_trm_tac xs);

 (* Applies basic tree structure to proof term *)
  fun simple_tree' prf = 
    case app_list prf of
      [x] => TmpPrf (x,[])
    | (x::xs) => TmpPrf (x,map simple_tree' xs);

  val simple_tree = simple_tree' o stripp;

 (* Generates structured tree from proof term. Each node represented as a Prf object. 
   Subgoals generated recursively. *)  
  val build_tree = project_trm_tac o simple_tree;

  (* Graph Construction *)

 (* Naming reasoning techniques - vertex labels *)
 fun mk_rt "assumption" =
      RTechn.id
      |> RTechn.set_name (RT.mk "assumption")
      |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"))
  | mk_rt str =  
      RTechn.id
      |> RTechn.set_name (RT.mk str)
      |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single str));

 (* Functions defining new vertices/edges *)
 fun mk_vertex str = Graph.OVData.NVert (GData.RT (mk_rt str));
 fun mk_edge_data gtf data = (Graph.Directed,GData.GT (gtf data));

 (* Recursive case *)
 fun mk_step gtf parent (Prf ((vdata,edata),children))  graph =
   let 
     val vertdata = mk_vertex vdata;
     val edgedata = mk_edge_data gtf edata;
     val (l,g1) = Graph.add_vertex (vertdata) graph
     val g2 = Graph.add_edge (edgedata) parent l g1
             |> snd
   in
     fold (fn prf => fn cgraph => mk_step gtf l prf cgraph) children g2
   end;

  (* Root case *)
  fun mk_graph gtf prf = 
    let
      val (parent,g1) = Graph.add_vertex Graph.OVData.WVert Graph.empty
    in
      mk_step gtf parent prf g1
       end;



  fun graph_of_prfterm gtf ptrm = mk_graph gtf (build_tree ptrm);

  fun graph_of_thm gtf thm = graph_of_prfterm gtf (prf thm);

end
