(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfos/htrace/htrace_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Contextual Information for Hierarchical Proof Descriptions 
    in proof planning.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature HTRACE_CINFO = 
sig

  type data; (* data in trees = rstates *)
  type tree; (* trees of states explored *)
  type T; (* the trace in progress *)

  exception end_refinement_exp of T;

  structure I : INFO_ITEM

  (* managing traces *)
  val empty : T
  val is_empty : T -> bool
  val current_depth : T -> int

  val add_then : data -> T -> T
  val add_refine : data -> T -> T
  val end_refine : T -> T

  (* rst *)
  val mk_empty_rst : RState.T -> RState.T
  val is_empty_rst : RState.T -> bool
  val current_depth_of_rst : RState.T -> int

  val add_then_rst : int * RState.T -> RState.T
  val add_refine_rst : int * RState.T -> RState.T
  val end_refine_rst : RState.T -> RState.T

  (* rtechn *)
  val thenify : RState.rtechn -> RState.rtechn
  val refinify : RState.rtechn -> RState.rtechn
  val orify : (RState.rtechn * RState.T) 
              -> (RState.rtechn * RState.T)
              -> RState.T Seq.seq

  (* pretty *)
  val pretty : T -> Pretty.T
  val pretty_rst : RState.T -> Pretty.T
  val pretty_cmp : T -> Pretty.T
  val pretty_cmp_rst : RState.T -> Pretty.T

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure HTraceCInfo : HTRACE_CINFO = 
struct
  exception then_exp of string;

  (* Node type: int is or-choice made, state is used for it's description. *)
  type data = (int * RState.T);
  (* data and children with first child as the latest *)
  datatype tree = Tree of (data * tree list);
  (* siblings and ancestors *)
  datatype T = Trace of tree list * T option;

  exception end_refinement_exp of T;

  val empty = Trace ([], NONE);
  fun is_empty (Trace ([], NONE)) = true
    | is_empty _ = false;

  fun mk_leaf d = Tree(d,[]);
  fun add_child child (Tree(d,siblings)) = 
      Tree(d, child :: siblings);
  fun add_children children (Tree(d,siblings)) = 
      Tree(d, children @ siblings);

  (* note that before applying a then or refine, we expect the new
  state/cinfo structure to contain its description, if it doesn't then
  we'll give our hiproof the old name. However this is OK as then is
  suposed to be used on existing reasoning techniques which are
  suposed to set the description anyway. *)
  fun add_then d (Trace (sibs,ancests)) = 
      Trace (mk_leaf d :: sibs,ancests);

  fun add_refine d (Trace (sibs,ancests)) = 
      Trace ([],SOME (Trace(mk_leaf d :: sibs, ancests)));

  fun end_refine (Trace (sibs, SOME (Trace(h :: psibs, ancests)))) =
      Trace( add_children sibs h :: psibs, ancests)
    | end_refine (p as Trace _) = 
      raise end_refinement_exp p;

  (* function to end all refinements, mostly used for pretty printing *)
  fun end_all_refinements (t as (Trace (sibs, NONE))) = sibs
    | end_all_refinements (t as (Trace (sibs, SOME _))) = 
      end_all_refinements (end_refine t);

  (* depths *)
  fun total_depth_of_tree (Tree (d, l)) = 
      List.foldr (fn (t,d) => let val d' = total_depth_of_tree t in
                           if d < d' then d' else d end) 
            1 l;

  fun current_depth (Trace (_,NONE)) = 0
    | current_depth (Trace (_,SOME x)) = 1 + current_depth x;


  (* pretty printing stuff *)
  val pretty_name_of_rst = DescripCInfo.I.pretty_rst;

(* Pretty printing functions, cmp is for a compressed version, ie with
   all higher subtree's closed (not showing subnodes). *)
  fun pretty_data openB (i,rst) = 
      Pretty.block 
        ([Pretty.str (if openB then "+" else "-"),
         Pretty.enclose "[" "] " [Pretty.str (string_of_int i)]]
         @
         (case RState.get_goalnames rst
           of [] => []
            | l => 
              [Pretty.block 
                [Pretty.str "on goals:",
                 Pretty.list "[" "]" (map Prf.pretty_gname l),
                 Pretty.str " "]])
         @ 
         (case RState.get_resultnames rst
           of [] => []
            | l => 
              [Pretty.block 
                [Pretty.str "on results:",
                 Pretty.list "[" "]" (map Prf.pretty_gname l),
                 Pretty.str " "]])
         @
         [pretty_name_of_rst rst]);

  (* Note: use of foldl to reverse the list as we parse it, cool *)

  (* pretty trees with and all children *)
  fun pretty_tree (Tree(d,[])) = pretty_data false d
    | pretty_tree (Tree(d, l)) = 
      Pretty.chunks 
      [ Pretty.block [pretty_data true d, Pretty.str "..." ],
        Pretty.indent 2 (pretty_treeL l) ]
  and pretty_treeL l = 
      Pretty.chunks (List.foldl (fn (n, pL) => (pretty_tree n) :: pL) [] l);
  fun pretty t = pretty_treeL (end_all_refinements t);

  (* pretty tree without children *)
  fun pretty_tree_nosubs (Tree(d,[])) = pretty_data false d
    | pretty_tree_nosubs (Tree(d, l)) = 
      Pretty.block [pretty_data true d, Pretty.str "..." ]
  and pretty_treeL_cmp l = 
      case l of 
        (h :: t) => Pretty.chunks 
                      (List.foldl (fn (n, pL) => (pretty_tree_nosubs n) :: pL) 
                             [pretty_tree_cmp h] t)
      | [] =>  Pretty.block []
  and pretty_tree_cmp (Tree(d,[])) = pretty_data false d
    | pretty_tree_cmp (Tree(d, l)) = 
      Pretty.chunks 
      [ Pretty.block [pretty_data true d, Pretty.str "..." ],
        Pretty.indent 2 (pretty_treeL_cmp l) ];
  fun pretty_cmp t = pretty_treeL_cmp (end_all_refinements t);


  (* structure added to CInfo... *)
  structure I = 
  InfoFUN( 
    struct
      type T = T;
      val name = "hiproof";
      val init = empty;
      val copy = I;
      val pretty : T -> RState.T -> Pretty.T = K o pretty;
    end
  );

  (* are we at the start? *)

(* functions to apply to reasoning states *)
  val is_empty_rst = is_empty o I.get_from_rst;
  val mk_empty_rst = I.put_in_rst empty;

  fun add_then_rst (i,rst) = I.update_rst (add_then (i,rst)) rst;
  fun add_refine_rst (i,rst) = I.update_rst (add_refine (i,rst)) rst;
  val end_refine_rst = I.update_rst end_refine;

(* the sequence of natural numbers *)
  val nat_seq = 
      let fun nseq i () = SOME (i, Seq.make (nseq (i+1)))
      in Seq.make (nseq 1)
      end;

  fun pair_seq seq1 seq2 = 
    let
      fun pseq s1 s2 () = 
          case Seq.pull s1 of 
            NONE => NONE
          | SOME (s1h, s1t) => 
            case Seq.pull s2 of 
              NONE => NONE
            | SOME (s2h, s2t) =>
              SOME ((s1h, s2h), Seq.make (pseq s1t s2t))
    in
      Seq.make (pseq seq1 seq2)
    end;

  (* returns a techn that makes all next states of r be added in
     "then" relationship to the given state *)
  (* This is done by unfolding r one step, then add each state as a 
     "then" state to the trace *)
  fun thenify r = r
    |> RTechn.set_appf (Seq.map 
                         add_then_rst
                         o pair_seq nat_seq o (RTechn.get_appf r));

  (* returns a techn that makes all next states of r be added as
  children of the current state in the trace. All further states in
  the unfolding of r will be within the state given to r, only when
  "r" completes will we end the refinement. *)
  fun refinify r = r
    |> RTechn.set_appf (Seq.map 
        add_refine_rst
        o pair_seq nat_seq o (RTechn.get_appf (RTechn.then_f r end_refine_rst)));

  (* inefficient,, but clear to read version: ** added hack to 
     force lazy evaluation - 14-03-2003 *)
  (* I think this is unused... ? *)
   fun orify (r1,st1) (r2,st2) = 
      Seq.append (Seq.make (fn () => Seq.pull ((RTechn.get_appf r1) st1)))
                 (Seq.make (fn () => Seq.pull ((RTechn.get_appf r2) st2)));

  (* normal pretty functions *)
  val pretty_rst = pretty o I.get_from_rst;
  val pretty_cmp_rst = pretty_cmp o I.get_from_rst;

  val current_depth_of_rst = current_depth o I.get_from_rst;
end;



