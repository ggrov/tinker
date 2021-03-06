theory test                                           
imports       
  "../CIsaP"  
begin
 

ML{*-   
  val path = "/u1/staff/gg112/";
  val guiPath = "/u1/staff/gg112/tinker/src/tinkerGUI/release/";
*}

ML{*
  val tinker_path = "/Users/yuhuilin/Workspace/StrategyLang/psgraph/"
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


ML{*-
 close_gui_single ();
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
fun strip_trueprop (A $ B) = B;

  fun is_goal env pnode [C.PVar p] =
     (case StrName.NTab.lookup (C.Prover.get_pnode_env pnode) p of
               NONE => []
             | SOME (C.Prover.E_Trm t) => if t = (C.Prover.get_pnode_concl pnode |> strip_trueprop) then [env] else []
             | SOME _ => [])
  | is_goal _ _ _ = []

  fun is_not_goal env pnode [C.PVar p] =
     (case StrName.NTab.lookup (C.Prover.get_pnode_env pnode) p of
               NONE => []
             | SOME (C.Prover.E_Trm t) => if not(t = (C.Prover.get_pnode_concl pnode |> strip_trueprop)) then [env] else []
             | SOME _ => [])
  | is_not_goal _ _ _ = []
*}

ML{*
   val data = C.add_atomic "top_symbol" top_symbol C.default_data
   |> C.add_atomic "is_goal" is_goal
   |> C.add_atomic "is_not_goal" is_not_goal; 
   val scan_def = C.scan_data @{context};
   val def1 = "topconcl(Z) :- top_symbol(concl,Z).";
   val pdef1 = scan_def def1;
   val data = C.update_data_defs (K pdef1) data;
*}

ML{* 
   val t = @{prop "A \<Longrightarrow> B \<Longrightarrow> A \<and> B \<Longrightarrow> B \<longrightarrow> A"}; 
   val (pnode,pplan) = IsaProver.init @{context} [] t;                         
*}

ML{*
val t = C.Prover.get_pnode_concl pnode |> strip_trueprop;
val t2 = @{term "B \<longrightarrow> A"};
t = t2;
*}
ML{*
val env = (IsaProver.get_pnode_env pnode)
  |> StrName.NTab.ins ("g", C.Prover.E_Trm @{term "B \<longrightarrow> A"});
C.match data pnode (C.scan_goaltyp @{context} "is_goal(?g)") env;

*}

ML{* 
  C.match data pnode (C.scan_goaltyp @{context} "any") (IsaProver.get_pnode_env pnode);
  C.match data pnode (C.scan_goaltyp @{context} "top_symbol(concl,?x)") (IsaProver.get_pnode_env pnode);
  C.match data pnode (C.scan_goaltyp @{context} "top_symbol(X,implies)") (IsaProver.get_pnode_env pnode);

(C.scan_goaltyp @{context} "top_symbol(concl,implies)") |> snd;
top_symbol(IsaProver.get_pnode_env pnode) pnode [C.Var "X", C.Name "implies"];
"top_symbol(concl,implies)";
 "top_symbol(X,Implies)";


*}      

ML{*
   val def1 = "c(Z) :- top_symbol(concl,Z).";
   val pdef1 = scan_def def1;
   val data1 = C.update_data_defs (K pdef1) data;
*}

ML{*

C.imatch data1 pnode (C.scan_goaltyp @{context} "c(implies)") ;
C.scan_goaltyp @{context} ;
*}
 
ML{* 
  val ps = PSGraph.read_json_file (SOME data) (path^"clause_demo.psgraph");
val ps1 = PSGraph.read_json_file (SOME data) (path^"naive.psgraph");

*}


ML{* -
  TextSocket.safe_close();
*}

ML{* - 
Tinker.start_ieval @{context} (SOME ps) (SOME []) (SOME @{prop "A \<longrightarrow> A \<longrightarrow> A"});
*}

