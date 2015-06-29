structure EvalLog =
struct

  type label = String
  type gnode = String

  val no_label = "no_label";

  (*
     to do: evaluate by goal name ->
              lookup vertex by gname
              find next node / tactic
              apply tactic (note that if next node is not tactic then do other first)
              existence of label
  *)

  (* questions:
      - can we get this from evaluation?
         - at least needs update as evaluation will fail if one goal fails
      - should g only be positive if it is part of a positive proof?
      - now we see g in isolation 
      - sharing of edata: always do breath first - why if it fails?
      - we could just keep one per goal (or per branch) as they are independent!)
  *)


  (* don't think this will work in practise - problem is crossing of branches
    when evaluating - I think we need to build a small evaluator on top of existing 
   keeping track of edata etc. *)
  datatype res = Solved 
               | Failed
               (* outher list: or-branches, inner list: subgoals *)
               (* should we keep thm as well? EData? *)
               | Branch of (gnode * term * label) * (res list list)


  (* better? - how to share edata when using same goal - always to breadth first evaluation?*)
  datatype res1 = Node of (gnode * term * label) * res2
   and res2 =  Solved' | Failed' | Open of EData.T| Closed of (res1 list list)

  (* generate data - have to be very careful about crossing branches!
     I think we have to develop a separate evaluation for this! *)
  fun init ist edata = Node (ist,Open edata);
 
  (* using data *)

  fun has_pos Solved = true
   |  has_pos Failed = false
   |  has_pos (Branch (_,xs) = exists (forall x => has_pos x) xs
 
 (* map from label to: list of postitive examples, list of negative examples *)
  type map = ((gnode * term) list * (gnode * term) list) StrName.NTab.T
  val add_pos' p (pos,neg) = (p::pos,neg);
  val add_neg' n (pos,neg) = (pos,n::neg); 

  fun add_pos l x m = 
   case StrName.NTab.lookup m l of
     NONE => StrName.NTab.update (l,([x],[])) m
   | (SOME res) => StrName.NTab.update (l,add_pos' x res) m;

  fun add_neg l x m = 
   case StrName.NTab.lookup m l of
     NONE => StrName.NTab.update (l,([],[x])) m
   | (SOME res) => StrName.NTab.update (l,add_neg' x res) m;

  fun flatten [] = []
   |  flatten [[]] = []
   |  flatten x::ys = x @@ (flatten ys)

  fun get_all_examples (res as Branch ((g,t,l),xs)) map = 
     if has_pos res 
       (* don't care about brancking so can flatten lists *)
       then fold get_all_examples (flatten xs) (add_pos l (g,t) map) 
       else fold get_all_examples (flatten xs) (add_neg l (g,t) map) 
  |  get_all_examples _ map = map;

 fun get_examples res = get_all_examples res StrName.NTab.empty;

 fun get_examples_list res = fold get_all_examples StrName.NTab.empty res;

end
