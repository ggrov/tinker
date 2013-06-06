structure BIsaAtomic : ATOMIC  =
struct
  type fact = Thm.thm
  type goal = term (* this is not part of the structure *)
  type context = Proof.context
  type concl = Term.term  

  exception atomic_exp of string

  type pnode = { pname : string, pctxt : Proof.context, ptrm : Term.term } 
    (* could also hold the thm? *)
  type pplan = { goal : Thm.thm, opengs : pnode list, usedgs : StrName.NSet.T }
  type tactic = Proof.context -> int -> Tactical.tactic
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  fun get_ind str _ [] = raise atomic_exp ("goal " ^ str ^ " does not exists")
   |  get_ind str n (x::xs) = if str = (#pname x) then n else get_ind str (n+1) xs;

  fun othergs str _ [] _ = raise atomic_exp ("goal " ^ str ^ " does not exists")
   |  othergs str n (x::xs) b =
         if str = #pname x then (b,n,xs) else othergs str (n+1) xs (b@[x]);

  fun get_index (pnode:pnode) (pplan:pplan) = get_ind (#pname pnode) 1 (#opengs pplan);

(*
  fun insert_at 1 newgs allgs = newgs @ gs
   |  insert_at n newgs x::xs = x :: insert_at (n-1) newgs xs;
*)

  fun to_goal_nms ctxt goals nameset = 
    let 
      fun ins t (gls,gset) =
       let 
        val (n,gset') = StrName.NSet.add_new "a" gset
        val g' = {pname = n,ptrm = t,pctxt = ctxt}
       in (gls@[g'],gset') end
    in
      fold ins goals ([],nameset)
    end;     

  fun update (pnode,pplan) newgoal = 
   let 
    val (b,ind,a) = othergs (#pname pnode) 1 (#opengs pplan) []; 
    val numb = (Thm.nprems_of newgoal) - (Thm.nprems_of (#goal pplan))
    val prems = Thm.prems_of newgoal
    val newgoals' = 
      if numb > 0 
       then drop (ind-1) prems 
            |> take numb  
       else []
    val (newgoals,goalset) = to_goal_nms (#pctxt pnode) newgoals' (#usedgs pplan)
    val ogoals = b @ newgoals @ a
    val pplan' = {goal = newgoal,opengs = ogoals, usedgs = goalset}
  in
    (newgoals,pplan')
  end;

  fun apply_rule _ thm (pnode,pplan) = 
    rtac thm (get_index pnode pplan) (#goal pplan) 
    |> Seq.map (update (pnode,pplan));

  fun apply_erule _ thm (pnode,pplan) =
    etac thm (get_index pnode pplan) (#goal pplan) 
    |> Seq.map (update (pnode,pplan));

  (* not sure how to do this! ~ just ignore second one... *)
  fun apply_frule (_,fst_thm) (_,_) (pnode,pplan) = 
    ftac fst_thm (get_index pnode pplan) (#goal pplan) 
    |> Seq.map (update (pnode,pplan));

  fun apply_subst _ thm (pnode,pplan) =
    EqSubst.eqsubst_tac (#pctxt pnode) [0] [thm] (get_index pnode pplan) (#goal pplan)
    |> Seq.map (update (pnode,pplan));

  (* is this correct? *)
  fun apply_subst_asm (_,fst_thm) (_,_) (pnode,pplan) =  
    EqSubst.eqsubst_asm_tac (#pctxt pnode) [0] [fst_thm] (get_index pnode pplan) (#goal pplan)
    |> Seq.map (update (pnode,pplan));

  (* FIXME: currently ignores all the assumptions *)
  fun apply_tactic _ _ tac (pnode,pplan) = 
    tac (#pctxt pnode) (get_index pnode pplan) (#goal pplan)
    |> Seq.map (update (pnode,pplan));

  fun lookup_fact _ name = 
    SOME (Global_Theory.get_thm @{theory} name) handle _ => NONE

  fun get_all_assms _ = []

  fun get_all_named_facts_pair _ = []
 
  fun get_pnode_name (pnode:pnode) = #pname pnode;
  fun get_pnode_ctxt (pnode:pnode) = #pctxt pnode;

  fun get_pnode_concl (pnode:pnode) = #ptrm pnode;

  structure Sharing =
  struct
    type fact = fact
    type tactic = tactic
    type pplan = pplan
    type pnode = pnode
    type context = context
    type concl = concl
  end

end
