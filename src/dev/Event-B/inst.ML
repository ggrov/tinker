structure Insts =
struct

 fun thms_ctxt ctxt name = 
   Proof_Context.get_fact ctxt (Facts.named name)

 fun simple_string ctxt trm =
   Print_Mode.setmp [] (fn () => Syntax.string_of_term ctxt trm) ();

 fun inst_term thm_name ctxt term =
   let val str = simple_string ctxt term
  in 
   map (read_instantiate ctxt [(("x",0),str)]) (thms_ctxt ctxt thm_name) 
   handle _ => []
  end;

 fun inst_str thm_name ctxt str =
   map (read_instantiate ctxt [(("x",0),str)]) (thms_ctxt ctxt thm_name)
   handle _ => [];

 (* move to goal - or elsewhere combining goals and wires *)
 fun fact_name_of_wire wire =
   BWire.NSet.fold
     (fn w => GNode.WTab.update (w,Goaln.NSet.empty))
     (FWire.get_facts (WireNode.get_fwire wire))
     GNode.WTab.empty;

  (* (RState.T -> GoalNode -> term list * string list)-> BWire.name -> (BWire.name*WireNode.T) -> GNode.T -> PPlan.T ->  (GNode.T list,PPlan.T) Seq.seq *)
 fun frule_gnode_appf thm f fact (newfact,outp) gnd pplan0 =
   let 
     val (trms,strs) = f pplan0 gnd;
     val thms = maps (inst_term thm (PPlan.get_context pplan0)) trms
              @ maps (inst_str thm (PPlan.get_context pplan0)) strs;
     fun mk_goal_node facts = GNode.mk_goal (fact_name_of_wire outp) (FWire.get_goal (WireNode.get_fwire outp)) (GNode.get_goal gnd)
                           |> GNode.add_facts (newfact,Goaln.NSet.of_list facts)
     fun app' fact thm (gs,pplan) = 
        ((PPlan.apply_frule_thm thm fact pplan
          |> Seq.map (fn (g',pplan') => (gs @ [g'],pplan'))) 
        handle _ => Seq.single (gs,pplan)); (* since may fail! - what if all fails?? should it fail then? *)
    (* since app' may produce empty then behave as identity *) 
    fun app fact thm (gs,pplan) = 
        case Seq.pull (app' fact thm (gs,pplan)) of 
           NONE =>  Seq.single (gs,pplan)
         | SOME (v,vs) => Seq.cons v vs;
     val facts = GNode.lookup_facts fact gnd;
     fun app_thms fact (gs,pplan) = 
        fold 
         (fn thm => Seq.maps (app fact thm))
         thms
         (Seq.single (gs,pplan));
     val goal_pplan_seq =  
       Goaln.NSet.fold
         (fn fact => Seq.maps (app_thms fact))
         facts
         (Seq.single ([],pplan0))
    in
      Seq.map (fn (gs,pplan) => ([mk_goal_node gs],pplan)) goal_pplan_seq
    end;
     

 (* f is a GoalNode -> terms function *)
 (* Fixme: there may be two outputs depending on if we want to iterate to ensure all 
    quantifiers are removed? *)
 fun frule_rtechn thm f name (fact,inp) (newfact,outp) =
   RTechn.id |> RTechn.set_name name
             |> RTechn.set_inputs (WireNode.W.NSet.single inp)
             |> RTechn.set_outputs (WireNode.W.NSet.single outp)
             |> RTechn.set_atomic_appf (RTechnEnv.apply_tac (WireNode.get_main_wire outp) (frule_gnode_appf thm f fact (newfact,outp)));

end (* struct *)
