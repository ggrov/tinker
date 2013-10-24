signature EVAL_ATOMIC =
sig
  structure EData : EVAL_DATA

  exception partition_exp of EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.pnode

  (* generalise *)
  val partition : 
     EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.pnode list (* new proof nodes *)
     -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.gnode (* old gnode [parent] *)
     -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.T list (* output types *)
     -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.gnode list list list (* one list for each goal type - outer when non-orthogonal outputs *)

  val partition_to_gnodes : 
   EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.gnode list list  
   -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.vdata  list

  val apply_atomic : 
        EData.T 
      -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.gnode (* the goal node  *)
      -> RTechn.T (* application function *)
      -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.T list (* outputs *)
      -> (EData.branch * EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.gnode list list list) Seq.seq

  val apply_appf : 
        EData.T 
      -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.gnode (* the goal node  *)
      -> RTechn.atomic (* application function *)
      -> (EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.pnode list * EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.pplan) Seq.seq

  val apply_tactic :
        EData.T 
      -> EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.gnode (* the goal node *)
      -> string (* the name of the tactic *)
      -> RTechn.tac_assms (* tactic assumption *)
      -> (EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.pnode list * EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.pplan) Seq.seq

end

functor EvalAtomicFun(EData : EVAL_DATA) : EVAL_ATOMIC =
struct
 local open DebugHandler in
  structure EData = EData;
  structure Prover = EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover;
  structure GData = EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData
  structure GoalTyp = EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp;

  exception no_such_fact of string
  exception eval_appf_exp of string;
  exception partition_exp of Prover.pnode

  fun lookup_fact node name = 
   case Prover.lookup_fact node name of
      NONE => (add_debug_msg (Pretty.str ("No such a fact/ thm : " ^ name) );raise no_such_fact name)
    | SOME f => (name,f)

  fun try_lookup_fact node name = 
   case Prover.lookup_fact node name of
      NONE => []
    | SOME f => [(name,f)]

  fun fact_list node fact_nms =
      fact_nms 
      |> StrName.NSet.list_of 
      |> map (lookup_fact node)

  val fact_seq = Seq.of_list oo fact_list;

  fun fact_seq_of_gnode edata gnode fact_nms =
    let 
      val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
    in
     Seq.of_list (fact_list pnode fact_nms)
    end;

  fun apply_tactic edata gnode tac_name RTechn.TNoAsm = 
       let 
         val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
         val pplan = EData.get_pplan edata
         val tac = EData.get_tactic edata tac_name
       in 
         Prover.apply_tactic tac_name [] tac (pnode,pplan)
       end
   |  apply_tactic edata gnode tac_name RTechn.TAllAsm = 
       let 
         val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
         val pplan = EData.get_pplan edata
         val tac = EData.get_tactic edata tac_name
         val facts = Prover.get_all_assms pnode
       in 
         Prover.apply_tactic tac_name facts tac (pnode,pplan)
       end
   |  apply_tactic edata gnode tac_name (RTechn.TClass class_nms) =
       let 
         val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
         val pplan = EData.get_pplan edata
         val tac = EData.get_tactic edata tac_name
         fun lookup_fact fname = case GoalTyp.lookup_fact_names fname gnode
                                  of NONE => StrName.NSet.empty
                                   | (SOME ns) => ns
         (* combines names of facts from all classes *)
         val fact_nms = C.NSet.fold 
                         (fn wn => StrName.NSet.union_merge (lookup_fact wn))
                         class_nms
                         StrName.NSet.empty
         (* get the actual facts *)
         val facts = fact_list pnode fact_nms |> map snd
       in
         Prover.apply_tactic tac_name facts tac (pnode,pplan)
       end;

  
  fun apply_appf edata gnode (RTechn.Rule fact_nms) =
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn (fnm,fact) => Prover.apply_rule fnm fact (pnode,pplan)) facts
          |> (fn x =>
          (case (Seq.pull x) of NONE  
           => add_debug_msg 
                (Pretty.chunks [Pretty.str ("Fail to apply RULES " ^
                                (StrName.NSet.list_of fact_nms |> map Pretty.str |> Pretty.block |> Pretty.string_of) ^ 
                                " to "), 
                                Prover.pretty_concl pnode]) 
           | _ => ()
          ;x))
        end
    |  apply_appf edata gnode (RTechn.ERule fact_nms) =
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn (fnm,fact) => Prover.apply_erule fnm fact (pnode,pplan)) facts
          |> (fn x =>
          (case (Seq.pull x) of NONE  
           => add_debug_msg 
                (Pretty.chunks [Pretty.str ("Fail to apply ERULES " ^
                                (StrName.NSet.list_of fact_nms |> map Pretty.str |> Pretty.block |> Pretty.string_of) ^ 
                                " to "), 
                                Prover.pretty_concl pnode]) 
           | _ => ()
          ;x))
        end
     (* it never fails: it tries of them once (should revisit this though) *)
   |  apply_appf edata gnode (RTechn.FRule (class_nm,fact_nms)) =
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          (* the class to apply to *)
          val hyps = GoalTyp.get_fact_names class_nm gnode 
                     |> fact_list pnode
          (* the fact to apply *) 
          val facts = fact_list pnode fact_nms
          (* one application of a frule of a fact to a hyp *)
          fun try_apply_as_list hyp fact (pn,pp) = 
             (case Prover.apply_frule hyp fact (pn,pp) |> Seq.list_of of
                [] => [([pn],pp)]
               | xs => xs)
          fun try_apply_frule' hyp fact (pnds,pp) =
             maps (fn pn => try_apply_as_list hyp fact (pn,pp)) pnds
          fun try_apply_frule hyp fact pnpps =
             maps (try_apply_frule' hyp fact) pnpps
          fun apply_frule hyp pnpps =
            fold (try_apply_frule hyp) facts pnpps
        in (* fold: ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b *)
           fold apply_frule hyps [([pnode],pplan)] 
           |> Seq.of_list
        end
   |  apply_appf edata gnode (RTechn.Subst fact_nms) = 
        let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn (fnm,fact) => Prover.apply_subst fnm fact (pnode,pplan)) facts
                    |> (fn x =>
          (case (Seq.pull x) of NONE  
           => add_debug_msg 
                (Pretty.chunks [Pretty.str ("Fail to apply SUBST " ^
                                (StrName.NSet.list_of fact_nms |> map Pretty.str |> Pretty.block |> Pretty.string_of) ^ 
                                " to "), 
                                Prover.pretty_concl pnode]) 
           | _ => ()
          ;x))
        end
   |  apply_appf edata gnode (RTechn.SubstAsm (class_nm,fact_nms)) =  (* why not a wire? *)
         let 
          val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
          val pplan = EData.get_pplan edata
          val hyps = GoalTyp.get_fact_names class_nm gnode 
                     |> fact_seq pnode 
          val eqs = fact_seq pnode fact_nms
          (* one application of subst of a eq to a fact *)
          fun apply_subst_asm' hyp eq = Prover.apply_subst_asm hyp eq (pnode,pplan)
          (* application of all equalities to a hyp *)
          fun apply_subst_asm hyp = Seq.maps (apply_subst_asm' hyp) eqs
        in
           Seq.maps apply_subst_asm hyps
        end
   |  apply_appf edata gnode (RTechn.Tactic (tac_data,name)) =
        apply_tactic edata gnode name tac_data
   |  apply_appf _ _ _ = raise eval_appf_exp "unknown application type";

  (*
    partitioning of outputs
  *)

  val lift  = GoalTyp.lift;

  (* need some filtering of empty here *)
  fun partition_one' [] _ _ _ [] = [] (* fails to lift for this branch *)
   |  partition_one' (gt::gts) gnode pnode bres (r::ares) = 
    (case lift gnode gt pnode of
      (* fails to lift *)
      NONE => partition_one' gts gnode pnode (bres@[r]) ares
      (* succeeds, and check for further successes *)
    | (SOME g') =>
        (* adds the succeded to the current result *)
        (bres @ [g'::r] @ ares) ::
        (* goes through and see if more succeeds (thus branching) *)
         partition_one' gts gnode pnode (bres@[r]) ares)
  | partition_one' _ _ _ _ _ = [];

  (* raises exception if one proof nodes fails *)
  fun partition_one goal_typs gnode pnode res =
    case partition_one' goal_typs gnode pnode [] res of
       [] => (
        (Pretty.chunks
          ([Pretty.str "Fail to lift ",
            Prover.pretty_concl pnode,
            Pretty.str ("with GoalTypes: " ^
            (Pretty.block (map (fn x =>  GoalTyp.pretty x) goal_typs) |> Pretty.string_of))]) 
        |> DebugHandler.add_debug_msg); raise partition_exp pnode)
     | xs => xs 

  (* return value : outer list - each branch: singleton 
                    middle list - one branch same length as goaltype input list
                    inner list - matching goal nodes for given goaltype
    invariant result = partition goal_typs pplan pnds 
       all res in result: length res  = length goal_typs (and they pairwise match)
                          
       outer list is all the possible options -> should be a singleton list if orthogonal
       length (result) > 0
  *)
  fun partition []     _       _     = []
   |  partition pnds gnode goal_typs =
        [map (K []) goal_typs] (* empty list to start *)
        |> fold (fn pnd => maps (partition_one goal_typs gnode pnd)) pnds;

  val partition_to_gnodes = map (GData.GN o GData.gnode_of_list o (map GData.GN_Node));

  (* fixme: make this into branch instead *)
  fun apply_atomic edata gnode rtechn goal_typs = 
   let 
     fun appf atom = apply_appf edata gnode atom
     fun apply_one (pnds,pplan) =
         Seq.single (EData.get_current edata
           |> EData.set_bpplan pplan
           |> EData.add_bgoals pnds,
         partition pnds gnode goal_typs)
      handle partition_exp _ => Seq.empty
   in
    case (RTechn.get_appf rtechn) of
       RTechn.Appf atom => appf atom 
                       (*|> Seq.list_of
                       |> map apply_one
                       |> Seq.of_list*)
                       |> Seq.maps apply_one
      | _ => Seq.empty (* TODO: raise exception *)
  end
 end (* local open *)
end (* functor *)
