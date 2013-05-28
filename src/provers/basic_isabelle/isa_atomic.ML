structure BIsaAtomic : ATOMIC =
struct
  type fact = Thm.thm

  exception atomic_exp of string

  type pnode = string (* could also hold the thm? *)
  type pplan = { goal : Thm.thm, opengs : string list, usedgs : StrName.NSet.T }
  type tactic = Proof.context -> int -> Tactical.tactic
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  fun get_ind str _ [] = raise atomic_exp ("goal " ^ str ^ " does not exists")
   |  get_ind str n (x::xs) = if str = x then n else get_ind str (n+1) xs;

  fun othergs str _ [] _ = raise atomic_exp ("goal " ^ str ^ " does not exists")
   |  othergs str n (x::xs) b =
         if str = x then (b,n,xs) else othergs str (n+1) xs (b@[x]);

  fun get_index pnode pplan = get_ind pnode 1 (#opengs pplan);

  fun insert_at 1 newgs allgs = newgs @ gs
   |  insert_at n newgs x::xs = x :: insert_at (n-1) newgs xs;

  fun to_goal_nms goals nameset = 
    let 
      fun ins g (gls,gset) =
       let 
        val (n,gset') = StrName.NSet.add_new g gset
       in (gls@[n],gset') end
    in
      fold ins goals ([],nameset)
    end;     

  fun update (pnode,pplan) newgoal = 
   let 
    val (b,ind,a) = othergs pnode (#opengs pplan) []; 
    val numb = (Thm.nprems_of newgoal) - (Thm.nprems_of (#goal pplan))
    val prems = Thm.prems_of newgoal
    val newgoals' = 
      if numb > 0 
       then drop (ind-1) prems 
            |> take numb  
       else []
    val (newgoals,goalset) = to_goal_nms newgoals' (#usedgs pplan)
    val pplan' = {goal = newgoal,opengs = newgoals, usedgs = goalset}
  in
    (newgoals,pplan')
  end;

  fun apply_rule _ thm (pnode,pplan) _ = 
    rtac thm (get_index pnode pplan)
    |> Seq.map (update (pnode,pplan));

  fun apply_erule _ thm (pnode,pplan) _ = Seq.empty;
    etac thm (get_index pnode pplan)
    |> Seq.map (update (pnode,pplan));

  fun apply_frule (fst_nm,fst_thm) (snd_nm,snd_thm) (pnode,pplan) = Seq.empty;

  fun apply_subst _ thm (pnode,pplan) ctxt =
    EqSubst.eqsubst_tac ctxt [0] [thm] (get_index pnode pplan)
    |> Seq.map (update (pnode,pplan));

  fun apply_subst_asm (fst_nm,fst_thm) (snd_nm,snd_thm) (pnode,pplan) = Seq.empty 

  fun apply_tactic _ thms tac (pnode,pplan) ctxt = 
    tac ctxt (get_index pnode pplan)
    |> Seq.map (update (pnode,pplan));

  fun lookup_fact pnode name = 
    SOME (Global_Theory.get_thm @{theory} name) handle _ => NONE

  fun get_all_facts pnode = []

  fun get_all_name_facts pnode = []
 
  val get_pnode_name = I;
  val get_pnode_ctxt = K @{context};
  
  (* FIXME: requires pplan!! *)
  val get_pnode_goal = ??;

