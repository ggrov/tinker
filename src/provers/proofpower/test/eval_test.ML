
  val path = "/Users/yuhuilin/Desktop/";
  
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
  
  init_symbol_table [("and", "%and%"), ("implies", "%implies%")];
  
  val gt = GoalTyp.default;
  val gt_imp = "top_symbol(implies)";
  val gt_conj = "top_symbol(and)";
  
  val step_strip_any = RTechn.id
            |> RTechn.set_name (RT.mk "step_strip_any_tac") (* z_strip_tac for z, strip_tac for hol*)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "step_strip_any_tac"));
  val step_strip_conj = RTechn.id
            |> RTechn.set_name (RT.mk "step_strip_conj") (* z_strip_tac for z, strip_tac for hol*)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "step_strip_conj"));
  val step_strip_imp = RTechn.id
            |> RTechn.set_name (RT.mk "step_strip_imp") (* z_strip_tac for z, strip_tac for hol*)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "step_strip_imp"));
  val step_assm = RTechn.id
            |> RTechn.set_name (RT.mk "step_assm") (* z_strip_tac for z, strip_tac for hol*)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "step_assm"));
            
  val default_tacs = [("step_strip_any_tac", step_strip_tac), ("step_strip_conj", step_strip_tac), 
  		      ("step_strip_imp", step_strip_tac), ("step_assm", step_strip_tac)];
  		      
  val psstrip_any = PSComb.LIFT ([gt],[gt]) (step_strip_any);
  val psstrip_conj0 =  PSComb.LIFT ([gt_conj],[gt_conj, gt_imp]) (step_strip_conj);
  val psstrip_conj = PSComb.LIFT ([gt_conj],[gt]) (step_strip_conj);
  val psstrip_imp = PSComb.LIFT ([gt_imp],[gt]) (step_strip_imp);
  val psstrip_asm = PSComb.LIFT ([gt],[]) (step_assm);
  val psstrip_asm2 = PSComb.LIFT ([gt, gt],[]) (step_assm);  
  
(* attendtion: for each eval, strip_any will run 4 times*)
  val psgraph_buggy = (psstrip_any THENG psstrip_any THENG psstrip_any THENG psstrip_any) PSGraph.empty  
            |> PSGraph.load_atomics default_tacs; 
  val psgraph_simple = (psstrip_conj0 THENG psstrip_conj THENG psstrip_imp THENG psstrip_asm2) PSGraph.empty  
            (*|> PSGraph.load_atomics default_tacs*);
  
  val gt_not_imp = "not top_symbol(implies)";
  val psstrip_conj0 =  PSComb.LIFT ([gt_conj],[gt_not_imp, gt_imp]) (step_strip_conj);
  val psstrip_asm2 = PSComb.LIFT ([gt_not_imp, gt],[]) (step_assm);  
  val psgraph_simple' = (psstrip_conj0 THENG psstrip_imp THENG psstrip_asm2) PSGraph.empty  
            
  val graph = PSGraph.get_graph psgraph_simple ;
  (*PSGraph.PSTheory.write_dot (path^"graph.dot") graph;*)

  (*
  
  easy demno
  
  use "setup";
  use_file "../test/eval_test";
  
  set_psg_goal ([%<% A : BOOL %>%] %<% (A %and% A) %and% (A %implies% A) %>%) mode psg searchf goalf ;
  
  simple:
top_goals();

  val edata0 = EVal.init_with_assm psgraph_simple (get_current_pc()) 
[%<% A : BOOL %>%] %<% (A %and% A) %and% (A %implies% A) %>%|> hd;
  PSGraph.PSTheory.write_dot (path^"eval_test0.dot") (EData.get_graph edata0) ;
  
  val (EVal.Cont edata1) = EVal.evaluate_arbitrary edata0;
  val edata1 = EVal.normalise_gnode edata1;
  
  val (EVal.Cont edata2) = EVal.eevaluate_arbitrary edata1;
  val edata2 = EVal.normalise_gnode edata2;
  
  val (EVal.Cont edata3) = EVal.evaluate_arbitrary edata2;
  val edata3 = EVal.normalise_gnode edata3;
  
  buggy:
  
  val edata0 = EVal.init_with_assm psgraph_buggy (get_current_pc()) [] 
  	 %<% A %and% B  %implies% A %implies% A %implies% B %>%|> hd;
  PSGraph.PSTheory.write_dot (path^"eval_test0.dot") (EData.get_graph edata0) ;
  
  val (EVal.Cont edata1) = EVal.evaluate_any edata0;
  
  

   use "setup";
 use_file "../test/eval_test";

(* Example: run in the interactive mode *)
 set_psg_goal ([%<% B : BOOL %>%, %<% A : BOOL %>%], %<% (A %and% B) %and% (A %implies% A) %>%) "interactive" psgraph_simple "dummy" "dummy"; 

(* Exmaple run in interactive-current mode *) 
set_psg_goal ([], %<%A %implies% (A %and% A) %>%) "current" PSGraph.empty "dummy" "dummy";

top_goals();
  
  *)
