
  val path = "/Users/yuhuilin/Desktop/";
  
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
  
  val gt = GoalTyp.default;

  val strip = RTechn.id
            |> RTechn.set_name (RT.mk "strip_tac") (* z_strip_tac for z, strip_tac for hol*)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "strip_tac"));

(* a very simple test *)
  val psstrip = PSComb.LIFT ([gt],[gt]) (strip);
  val psgraph = (psstrip THENG psstrip );
  val graph = PSGraph.get_graph (psgraph PSGraph.empty) ;
  PSGraph.PSTheory.write_dot (path^"graph.dot") graph;
  

  val psgraph = 
    psgraph PSGraph.empty 
    |> PSGraph.update_atomics (StrName.NTab.doadd ("strip_tac", strip_tac));
    
  val ctxt = get_current_pc();
  (* A & B --> A*)
  val edata0 = EVal.init_with_assm psgraph ctxt [] 
  	(*%<% A %and% B  %implies% A %and% B %>% *) %<% A %and% B  %implies% A %implies% B %>%|> hd;
  PSGraph.PSTheory.write_dot (path^"eval_test0.dot") (EData.get_graph edata0) ;
  PSGraph.PSTheory.write_json_file (path ^ "eval_test0.json") (EData.get_graph edata0);
  
  
  val (EVal.Cont edata1) = EVal.evaluate_any edata0;
  val edata1 = EVal.normalise_gnode edata1;
  PSGraph.PSTheory.write_dot (path^"eval_test1.dot") (EData.get_graph edata1) ;
  
    
  val (EVal.Cont edata2) = EVal.evaluate_any edata1;
  val edata2 = EVal.normalise_gnode edata2;
  PSGraph.PSTheory.write_dot (path^"eval_test2.dot") (EData.get_graph edata2) ;
  
  (*
  
  easy demno
  
  use "setup";
use_file "../test/eval_test";


set_psg_goal ([], %<% A %and% B  %implies% A %implies% B %>%) "dummy" psgraph "dummy" "dummy";
  
  *)
