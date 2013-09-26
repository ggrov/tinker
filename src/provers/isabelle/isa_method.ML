
structure IsaMethod =
struct
  (* Tactics *)

  val default_tacs = 
    [("assumption",K (atac 1)),("atac",K (atac 1)), (* assumption *)
     ("simp",(fn ctxt => Simplifier.simp_tac (Simplifier.simpset_of ctxt) 1)), (* simp *) 
     ("clarsimp",(fn ctxt => clarsimp_tac ctxt 1)), (* clarsimp *)
     ("all",K all_tac), (* always succeeds *)
     ("no",K no_tac) (* always fails *)
    ];

 structure TacticData = Theory_Data(struct 
    type T = (Proof.context -> tactic) StrName.NTab.T
    val empty =  StrName.NTab.of_list default_tacs;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 val add_tac = TacticData.map o StrName.NTab.ins;
 val get_tacs = TacticData.get;

 fun init_with_named_assms psgraphf ctxt trm assms =
    let 
     val psgraph = psgraphf PSGraph.empty 
     val (pn,pp) = PPlan.init_named_asms ctxt trm assms;
     val pnode_tab = 
         StrName.NTab.ins
           (IsaProver.get_pnode_name pn,pn)
           StrName.NTab.empty
     val edata0 = EData.init psgraph pp pnode_tab []
    in
      EVal.init_goal pn edata0   
    end;

 fun eval_interactive edata0 = 
     UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams 
      (SOME edata0) 
      (K edata0);

end (* *)
 val eval_interactive = IsaMethod.eval_interactive;


