theory test                                           
imports       
  "../CIsaP"  
begin

ML{*- 
  val path = "/u1/staff/gg112/";
  val guiPath = "/u1/staff/gg112/tinker/src/tinkerGUI/release/";
*}

ML{*
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_32"
*}

ML{*-
  val tinker_path ="/home/pierre/Documents/HW/Tinker/tinkerGit/tinker/" 
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "linux"
*}

ML{*
  set_guiPath guiPath sys;
*}

ML{*-
  open_gui_single();
*}

ML{*-
 close_gui_single ();
*}

ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
*}

ML{*structure C = Clause_GT*}
ML{*
  val ignore_module = List.last o String.tokens (fn ch => #"." = ch) ;

    fun top_level_str (Const (s,_)) = [ignore_module s]
  | top_level_str ((Const ("all",_)) $ f) = top_level_str f
  | top_level_str ((Const ("prop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("HOL.Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("==>",_)) $ _ $ f) = top_level_str f
  | top_level_str (f $ _) = top_level_str f
  | top_level_str (Abs (_,_,t)) = top_level_str t
  | top_level_str _ = [];

   fun top_symbol env pnode [r,C.Var p] = 
          let 
            val tops = C.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case StrName.NTab.lookup env p of
               NONE => map (fn s => StrName.NTab.ins (p,C.Prover.E_Str s) env) tops
             | SOME (C.Prover.E_Str s) => if member (op =) tops s then [env] else []
             | SOME _ => [])
          end
    |  top_symbol env pnode [r,C.Name n] = 
          let 
            val tops = C.project_terms env pnode r
                     |> maps top_level_str
          in 
             if member (op =) tops n then [env] else []
          end
    |  top_symbol env pnode [r,C.PVar p] = 
          let 
            val tops = C.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case StrName.NTab.lookup (C.Prover.get_pnode_env pnode) p of
               NONE => []
             | SOME (C.Prover.E_Str s) => if member (op =) tops s then [env] else []
             | SOME _ => [])
          end
    | top_symbol _ _ [] = []
    | top_symbol _ _ [_,_] = []
    | top_symbol env pnode (x::xs) =
        maps (fn r => top_symbol env pnode [x,r]) xs;   
*}

ML{*
   val data = C.add_atomic "top_symbol" top_symbol C.default_data; 
   val scan_def = C.scan_data @{context};
   val def1 = "topconcl(Z) :- top_symbol(concl,Z).";
   val pdef1 = scan_def def1;
   val data = C.update_data_defs (K pdef1) data;
*}

ML{* 
   val t = @{prop "A \<Longrightarrow> B \<Longrightarrow> A \<and> B \<Longrightarrow> B \<and> A"}; 
   val (pnode,pplan) = IsaProver.init @{context} [] t;                         
*}

ML{* 
   C.imatch data pnode ("any",[]);
   C.imatch data pnode ("topconcl",[C.Name "conj"]);
*}      

(* TODO:  1)fix any,2) combinator, e.g. not *)


ML{*  
  fun rule_tac ctxt i (arg as [IsaProver.A_Str thm_name]) =  rtac (IsaProver.get_thm_by_name ctxt thm_name) i;
  fun id_tac  _ _ _  = all_tac;
  val ps =
   PSGraph.read_json_file (path^"clause_demo.psgraph")
   |> PSGraph.set_goaltype_data data;       
*}

ML{*-
  TextSocket.safe_close();
*}

ML{*
Tinker.start_ieval @{context} ps [] @{prop "A \<longrightarrow> A \<longrightarrow> A"};
*}

