(* TO DO
     - information about tactics
     - hierarchies 
     - meta-variables
*)
structure PPExpThm = 
struct
 
  open PPlan;

  exception export_exp of string * StrName.name

  datatype export_res = 
      EClosed of Thm.thm (* no subgoals  *) 
    | EOpen of Thm.thm (* open goal *)
    | ESubgoals of Thm.thm (* still has open goals *)
    | ENone;

  fun isENone ENone = true
   |  isENone _ = false;

  fun export_asm_var ctxt ctxt0 goal =  
    (* should it be true or false? *)
    Assumption.export false ctxt ctxt0 goal
    |> (fn thm => Variable.export ctxt ctxt0 [thm])
    |> hd (* should fail if not one?? *);

  fun export_single gnode = export_asm_var (PNode.get_ctxt gnode) (PNode.parent_ctxt gnode) (PNode.get_goal gnode)
    | export_single gnode = raise export_exp ("cannot export single node",PNode.get_name gnode);

  fun prj_thm (EClosed thm) = thm
   |  prj_thm (EOpen thm) = thm
   |  prj_thm (ESubgoals thm) = thm

  fun get_thm_of_nopen n (EClosed thm) = [(n,thm)]
   |  get_thm_of_nopen n (ESubgoals thm) = [(n,thm)]
   |  get_thm_of_nopen _ _ = [];

  fun mapinms _ [] = []
   |  mapinms n (x::xs) = get_thm_of_nopen n x :: mapinms (n+1) xs;

  fun flatten [] = []
   |  flatten (x::xs) = x @ flatten xs;

  fun export prf gnode =
    case PNode.get_result gnode of
      NONE => export_single gnode |> EOpen
    | SOME [] => export_single gnode |> EClosed
    | SOME xs => 
      let 
        fun exp NONE = ENone
         |  exp (SOME g) = (export prf g);
        val gs = map (exp o (lookup_node prf)) xs
        val econs = if exists isENone gs then ESubgoals else EClosed;
        val thms = mapinms 1 gs
                 |> flatten
                 |> rev
     in
        gnode |> PNode.get_goal 
              (* FIXME: need to get rid of each assumption of a given goal
                     e.g. subgoal (A ==> B ==> sg) will spawn (A ==> B ==> A) ==> (A ==> B ==> B) ==> new subgoals *)
              |> fold (fn (n,sub) => fn cg => (Goal.conclude sub) RSN (n,cg)) thms
              |> export_asm_var (PNode.get_ctxt gnode) (PNode.parent_ctxt gnode)
              |> econs
     end;

 fun export_name prf name =
  case lookup_node prf name of
    NONE => raise export_exp ("name not present in proof",name)
  | SOME gn => export prf gn;

end

