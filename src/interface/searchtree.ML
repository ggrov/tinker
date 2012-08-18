(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./interface/searchtree.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Code to hold a partially explored, expandable, proof trees. 

    Note: we should generalise this and make it into a functor for
    dyanmic graphs, of which the expandable search tree is an instance
    of.

    A Search tree manager (for interactive exploration of the search
    tree, going back etc) that makes sure that states are not
    re-evaluated - this is needed to make sure that global information
    is not mangled.
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure SearchTree = 
struct

  exception searchtree_exp of string;

  structure Graph = Graph(type key = int val ord = int_ord);

  type nodeT = (bool * (* has its children been added to the graph *) 
                     RState.T); (* the data in the node *)

  fun add_rst rst = (* still takes a graph after this *)
      Graph.new_node (RState.get_id rst, (false, rst));

  fun init_rst rst = add_rst rst Graph.empty;

  fun add_child_of_rst rst (chld, T) = 
      Graph.add_edge (RState.get_id rst, RState.get_id chld)
                     (add_rst chld T);

  fun add_as_children_of_rst T rst children = 
      List.foldr (add_child_of_rst rst) T children;

  fun rst_of_id (T : nodeT Graph.T) (nid : int) = #2 (Graph.get_node T nid);

  fun try_expand_node T nid =
      let 
        val (expnded, rst) = (Graph.get_node T nid) 
      in
        if expnded then T
        else 
          let val T2 = add_as_children_of_rst 
                         T rst (Seq.list_of (RState.unfold rst)) 
          in
            Graph.map_node nid (fn (_,rst) => (true, rst)) T2
          end
      end;  

  fun try_expand_node_of_rst T rst = 
      try_expand_node T (RState.get_id rst);

  fun has_expanded_children T rst = 
      let val (expnded, rst) = Graph.get_node T (RState.get_id rst) in
        expnded end;

  fun get_children T rst = 
      let val T2 = try_expand_node_of_rst T rst in 
        (T2, map (rst_of_id T2) (Graph.imm_succs T2 (RState.get_id rst)))
      end;

  fun get_parent T rst = 
      (case Graph.imm_preds T (RState.get_id rst) of 
        [a] => rst_of_id T a
      | [] => (raise searchtree_exp 
                       ("State (id: " ^ 
                        (string_of_int (RState.get_id rst)) ^ 
                        ") has no parents."))
      | (a::b::c) => (raise searchtree_exp 
                       ("State " ^ 
                        (string_of_int (RState.get_id rst)) ^ 
                        " has more than one parent!???")));

(* Interactive stacked search *)
fun try_expand_node_stacked (T,sstack) nid =
      let 
        val (expnded, rst) = (Graph.get_node T nid) 
      in
        if expnded then (T, sstack)
        else 
          let
            val xf = (Seq.map RState.sol_setf o RState.unfold)
            val eqf = (fn st => fn st' => (RState.get_id st) = (RState.get_id st'))
            val popf = RState.pop_searchop
            val (children, new_sstack) = LSearch.lazy_search xf eqf popf sstack rst
            val T2 = add_as_children_of_rst 
                         T rst children 
          in
            ((Graph.map_node nid (fn (_,rst) => (true, rst)) T2), new_sstack)
          end
      end;

fun try_expand_node_of_rst_stacked (T,sstack) rst  = 
      try_expand_node_stacked (T,sstack) (RState.get_id rst);

fun get_children_stacked (T,sstack) rst = 
      let val (T2, new_sstack) = try_expand_node_of_rst_stacked (T,sstack) rst in 
        ((T2, new_sstack), map (rst_of_id T2) (Graph.imm_succs T2 (RState.get_id rst)))
      end;



end;
