signature PS_THEORY_SHARING = 
sig
  structure Data : PSGRAPH_DATA_SHARING
end

signature PS_THEORY = 
sig
  structure Data : PSGRAPH_DATA
  structure Theory : GRAPHICAL_THEORY
  structure PSDataIO : GRAPH_COMPONENT_DATA_IO
  include GRAPHICAL_THEORY


  sharing type Graph.T = Theory.Graph.T
  sharing type Graph.nvdata = Data.nvdata
  sharing type Graph.edata = Data.edata
  sharing type PSDataIO.nvdata = Data.nvdata
  sharing type PSDataIO.edata = Data.edata
  sharing type Theory.Graph.Sharing.nvdata = Data.nvdata
  sharing type Theory.Graph.Sharing.edata = Data.edata

  structure Sharing : PS_THEORY_SHARING
    sharing Sharing.Data = Data.Sharing


end (* signature *)

functor PSGraph_TheoryFun ( structure  Data : PSGRAPH_DATA ) : PS_THEORY=
struct

  structure GoalTyp = Data.GoalTyp;

  (* may need some sharing stuff here *)
  structure Data = Data (*PSGraphDataFun(GoalTyp);*);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);


  structure Theory = GraphicalTheory(
    structure Data = Data
    structure DataIO = PSDataIO
  );
  open Theory;

 structure Graph_Utils =
  struct local open LoggingHandler in
    (* actual rewriting *)
    fun rewrite_lazy rule graph = 
      let 
        val graph' = Graph.normalise graph;
        val matches = Theory.Rewriter.find_matches rule graph';
        fun rewr match = 
          Theory.Rewriter.rewrite_at rule match
          |> snd
      in
        Seq.map rewr matches
      end;

    val rewrite = Seq.list_of oo rewrite_lazy;

  (* simplify ? *)
  fun input_boundary g = 
    let val bvertexes = Graph.get_inputs g (* Vertex.NSet.T *)
        fun dest_name bv e =(bv,(e,Graph.get_edge_data g e),Graph.get_edge_target g e)
        fun mk_pairs v = Graph.get_out_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

  fun output_boundary g = 
    let val bvertexes = Graph.get_outputs g (* Vertex.NSet.T *)
        fun dest_name bv e =(Graph.get_edge_source g e,(e,Graph.get_edge_data g e),bv)
        fun mk_pairs v = Graph.get_out_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

    fun edge_dest g e = Graph.get_edge_target g e;
    fun edge_src g e = Graph.get_edge_source g e;
    fun edge_data g e = Graph.get_edge_data g e;

   (* checks data *)
    fun lookup_ivertex_data g v = 
      case Graph.get_vertex_data g v of 
          (Graph.NVert nv) => SOME nv
        | _ => NONE

    fun lookup_ivertex_data g v = 
      case Graph.get_vertex_data g v of 
          (Graph.NVert nv) => SOME nv
        | _ => NONE

   val vertex_data = the oo lookup_ivertex_data;

   fun out_edges graph v = 
      Graph.get_out_edges graph v 
      |> E.NSet.list_of;

   fun in_edges graph v = 
      Graph.get_in_edges graph v 
      |> E.NSet.list_of;

    fun insert_node_on_edge node edge graph0 =
      let val (l,graph') = Graph.add_vertex (Graph.NVert node) graph0
          val from' = edge_src graph' edge
          val to' = edge_dest graph' edge
          val edata = edge_data graph' edge
          val graph' = Graph.delete_edge edge graph'
          val (src, graph') = Graph.add_edge (Directed,edata) from' l graph'
          val (dest, graph') = Graph.add_edge (Directed,edata) l to' graph'
      in
        (src,dest,graph')
      end;

   (* assumes: 1/1 - so just replace by wire node *)
   fun del_gnode gnode g = Graph.update_vertex_data (K Theory.Graph.WVert) gnode g |> Theory.Graph.minimise;

   fun mk_binput edata dest graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) n dest g);

   fun mk_boutput edata source graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) source n g);

   fun is_gtyp graph e = 
     case edge_data graph e of (Data.GT _) => true | _ => false;

   fun is_tactic graph v = 
   case lookup_ivertex_data graph v of 
       SOME (Data.T_Atomic _) => true
     | SOME (Data.T_Graph _) => true
     | SOME Data.T_Identity => true
     | _ => false; 

   fun get_hgragh_with_graph_name graph n vname = 
     let val v = lookup_ivertex_data graph vname in case  v of 
       SOME (Data.T_Graph (name,_)) => if (n = name) then SOME v else NONE
       | _ => NONE end

   fun is_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (Data.G _) => true
       | _ => false; 

   fun lookup_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (Data.G gn) => SOME gn
       | _ => NONE; 

   fun goaltype_of graph e = 
     case edge_data graph e of (Data.GT g) => g   
     |  _ => (logging "FAILURE" ("Unknown goaltype type in edge" ^ (E.string_of_name e)); raise tinker_fail true)

   fun gnode_of graph v = 
     case vertex_data graph v of (Data.G gn) => gn
     | _ => (logging "FAILURE" ("This is not a goal node" ^ (V.string_of_name v)); raise tinker_fail true) 

   fun mk_gnode gnode = Data.G gnode;

   fun get_vertex_list graph =  
     Graph.get_vertices graph
     |> V.NSet.list_of

   fun all_tactics graph = 
     get_vertex_list graph
     |> filter (is_tactic graph);

   fun all_gnodes graph = 
     get_vertex_list graph
     |> filter (is_gnode graph);
(*
   fun all_hgraghs graph =  
     Graph.get_vertices graph
     |> filter (is_hgragh graph);
*)
(*
   fun lookup_hgragh_by_graph_name graph graph_name vname=  
     get_hgragh_with_graph_name graph graph_name vname
     |> (fn x => (case x of 
                   NONE => 
                   	(logging "FAILURE" ("Fail to find hgraph by name:" ^ graph_name); 
                   	raise tinker_fail true) 
                 | SOME v => v))
*) 
   (* FIXME: makes one for each input - can be generalised by vars on the edges  instead - then we only need on lhs per rule  *)
   fun mk_lhs graph v =
     let 
      val ins = Graph.get_in_edges graph v  
      val outs = Graph.get_out_edges graph v
      val gnode = Graph.NVert (Data.G_Var "g")
      val (v_rt,g) = Graph.empty
                   |> Graph.add_vertex (Graph.get_vertex_data graph v)
      (* adding goalnode variable *)
      val (v_gvar,g) = Graph.add_vertex gnode g 
      (* one lhs for each input node *)
      fun mk_lhs' inp = g
          |> Graph.add_edge_anon (Directed,Data.GT (goaltype_of graph inp)) v_gvar v_rt
          |> mk_binput (Data.GT (goaltype_of graph inp)) v_gvar
          |> E.NSet.fold (fn outp => mk_boutput (Data.GT (goaltype_of graph outp)) v_rt) outs
          |> E.NSet.fold (fn o_inp => mk_binput (Data.GT (goaltype_of graph o_inp)) v_rt) 
                         (E.NSet.delete' inp ins) 
     in 
       map mk_lhs' (E.NSet.list_of ins)    (* one match per input *)
     end;

   (* Should be one tactic and one graph *)
   fun match_lhs graph lhs =
     Theory.Rewriter.find_matches
           (Theory.Rule.mk(lhs,lhs)) (* make a dummy rule *)
           graph
      |> Seq.map (fn m => (Theory.Match.get_subst m, Graph.apply_data_subst (Theory.Match.get_subst m) lhs));
        
   fun matched_lhs graph v = Seq.maps (match_lhs graph) (mk_lhs graph v |> Seq.of_list)

   (* vertex list -> partition -> graph -> graph *)
   fun add_outs [] [] graph = graph
    |  add_outs  (i::is) (p::ps) graph = 
       add_outs is ps (#3 (insert_node_on_edge p i graph));

   fun symmetric_rule rule = Theory.Rule.mk (Theory.Rule.get_rhs rule,Theory.Rule.get_lhs rule);

(* environment tactics and variables *)
  fun is_env_tactic_name name = 
  let
    fun is_prefix_ENV name = 
    let val _ =  Symbol.explode name |> Scan.this_string "ENV_" in
    true end;
    fun is_prefix_qmark name = 
    let val _ =  Symbol.explode name |> $$ "?" in
    true end;
  in
    (Scan.catch (is_prefix_ENV) name handle _ => false) orelse
    (Scan.catch (is_prefix_qmark) name handle _ => false)
  end

 (* is a tactic node and also follows the name convension that has a prefix of ENV *)
  fun is_env_tactic g v = 
    let
      fun get_tactic_node_name graph vgraph = 
        case lookup_ivertex_data graph vgraph of 
           SOME (Data.T_Atomic n ) => fst n
           | _ => raise tinker_fail true (*"This is not a tatic node"*) (* no need to logging this, as it won't happen *)
    in
      is_tactic g v andalso is_env_tactic_name (get_tactic_node_name g v)
    end

(* check the format is "?_" *)
  fun parse_env_var_name str = 
  let
    fun get_env_arg_name0 str = 
      str |> Symbol.explode 
      |> $$ "?"
      |> snd
      |> implode
      |> SOME;
  in
    Scan.catch (get_env_arg_name0) str
    handle RunCallFail _ => NONE
  end
  
  fun parse_arg_data ctxt pnode args = 
   let 
    fun de_hd_last l = tl l |>  rev |> tl |> rev (* remove both hd and last ele *)
    val env = GoalTyp.Prover.get_pnode_env pnode 
    fun split_args str = String.tokens ((op member) (op =) [#"[", #"]", #" ", #"," ]) str
    fun parse_singleton typ def = 
     case typ 
      of "term" => GoalTyp.Prover.trm_of_string ctxt def|> GoalTyp.Prover.A_Trm
       | "thm" => GoalTyp.Prover.get_thm_by_name ctxt def|> GoalTyp.Prover.A_Thm
       | "string" => GoalTyp.Prover.A_Str def
       | "var" => Option.valOf (parse_env_var_name def)|> GoalTyp.Prover.A_Var
       | x => GoalTyp.Prover.parse_ML_arg def typ        
   in
    map 
    (fn arg (* [def, type] / [?env_var]*) 
      => if List.length arg = 1  (* env var or predefine antiqunto, e.g. Hyps, Concl *)
         then case (hd arg) 
           of "Concl" => GoalTyp.Prover.get_pnode_concl pnode |> GoalTyp.Prover.A_Trm
           | "concl" => GoalTyp.Prover.get_pnode_concl pnode |> GoalTyp.Prover.A_Trm
           | "Hyps" => GoalTyp.Prover.get_pnode_hyps pnode |> GoalTyp.Prover.A_L_Trm
           | "hyps" => GoalTyp.Prover.get_pnode_hyps pnode |> GoalTyp.Prover.A_L_Trm
           |  x => 
           (* first to check if it is a string i.e. in the format of "..." *)
            if ((String.explode x |> hd) = #"\"" andalso (String.explode x |> List.last) = #"\"" ) (* see if it is a string *)
            then
             String.substring (x, 1, size x - 2) 
             (*|> (fn x => (writeln x; x)) *)
             |> GoalTyp.Prover.A_Str
            else (* otherwise, it is a variable , then to get its value in the env *)
             ((StrName.NTab.get env (Option.valOf (parse_env_var_name (hd arg)))
             handle _ => (logging "FAILURE" ("fail to get arg: " ^ (hd arg) ^ " from env"); raise tinker_fail true))
             |> GoalTyp.Prover.env_to_arg)
         else if (List.last arg = "list") then
           map (parse_singleton (de_hd_last arg |> List.foldr (op ^) "")) 
            (split_args (hd arg)) 
           |>  GoalTyp.Prover.A_L
         else
          parse_singleton (List.foldr (op ^) "" (List.tl arg)) (hd arg)
    )
    args end
    


  end (* end of local open *)
  end (* structure Util *)

  structure Sharing = 
  struct
    structure Data = Data.Sharing
  end
end


