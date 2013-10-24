
structure IsaMethod =
struct
  (* Tactics *)

  val default_tacs = 
    [("assumption",K (atac 1)),("atac",K (atac 1)), (* assumption *)
     ("simp",(fn ctxt => Simplifier.simp_tac (Simplifier.simpset_of ctxt) 1)), (* simp *) 
     ("clarsimp",(fn ctxt => clarsimp_tac ctxt 1)), (* clarsimp *)
     ("all",K all_tac), (* always succeeds *)
     ("no",K no_tac), (* always fails *)
     ("induct",K (InductRTechn.induct_tac 1))
    ];

 structure TacticData = Theory_Data(struct 
    type T = (Proof.context -> tactic) StrName.NTab.T
    val empty =  StrName.NTab.of_list default_tacs;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 val add_tac = TacticData.map o StrName.NTab.ins;
 val get_tacs = TacticData.get;

 fun init_psgraph psgraphfn ctxt =
   psgraphfn PSGraph.empty
   |> PSGraph.set_atomics (get_tacs (Proof_Context.theory_of ctxt))

 fun init_with_named_assms psgraphfn ctxt trm assms =
    let 
     val psgraph = init_psgraph psgraphfn ctxt 
     val (pn,pp) = PPlan.init_named_asms ctxt trm assms;
     val pnode_tab = 
         StrName.NTab.ins
           (IsaProver.get_pnode_name pn,pn)
           StrName.NTab.empty
     val edata0 = EData.init psgraph pp pnode_tab []
    in
      EVal.init_goal pn edata0   
    end;

 fun init psgraphfn ctxt = EVal.init (init_psgraph psgraphfn ctxt) ctxt ;

 fun eval_interactive edata0 = 
     UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams 
      (SOME edata0) 
      (K edata0);

 (* to do - make proof method (like for simple!) *)
 fun init_thm thm graph = EVal.init_goals;

end (* *)
 val eval_interactive = IsaMethod.eval_interactive;


