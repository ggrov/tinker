(* simple test of proof representation *)
theory method_test                                           
imports       
  "../build/BIsaMeth"    
begin


(* create a new graph *)
ML{*
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "atac"));

   val gt = SimpleGoalTyp.default;

  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psgraph = psasm PSGraph.empty
              |> PSGraph.update_atomics (StrName.NTab.ins ("atac",K atac));
*}
 
  -- "register simple graph"
  setup {* PSGraphMethod.add_graph ("asm",psgraph) *}

 declare [[psgraph = asm]]

 lemma "A \<Longrightarrow> A"
  apply psgraph  
  done

end



