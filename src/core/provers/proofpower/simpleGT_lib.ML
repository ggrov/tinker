structure SimpleGT_Lib  = 
struct
  local open LoggingHandler TermFeatures in

  (* use a symbol table to represent those non-standdatd ascii symbols *)
  val symbol_table : string StrName.NTab.T Unsynchronized.ref  = Unsynchronized.ref StrName.NTab.empty;
  fun init_symbol_table l = symbol_table := StrName.NTab.of_list l; 

  (* "use_file" can only be used in the top level, otherwise some strange problem will occur,
   this hack is to avoid the probelm *)

  fun GT_NOT gt ctxt tl t : bool = not (gt ctxt tl t);
  fun GT_OR gt_l ctxt tl t : bool = exists I (map (fn f => f ctxt tl t) gt_l)
  
(**************************************************************
  A List of Simple GT: ctxt -> assms -> concl -> bool 
  GT_top_symbol (symbol_list : string list)
  GT_has_symbol (symbol_list : string list)
**************************************************************)

(**************************************************************
    Term manipulation and term related predicate definations
**************************************************************)
    fun top_level' str goal = 
      case top_level_str goal of
         NONE => false
       | SOME v => (*v = str*)(
       (*let val _ = writeln v  val _ = writeln str in v = str end *) v = str
       );
    
    fun top_level strs _ _ goal = 
      map (fn str => top_level' 
      			(case StrName.NTab.lookup (!symbol_table) str of (SOME str') => str' | _ => str) 
      			goal) strs
      |> exists I ;
      

    fun has_symbol strs _ _ goal = 
      forall (fn str => has_constant_by_str 
    			(case StrName.NTab.lookup (!symbol_table) str of (SOME str') => str' | _ => str) 
    			goal) 
      strs ;

     val GT_top_symbol = top_level;
     val GT_has_symbol = has_symbol;

     (*handle _ => raise gt_exp "in init lift";*)

  end (* local open *)
end(* struct *);

open SimpleGT_Lib;
init_symbol_table [("HOL.conj", "%and%"), ("HOL.implies", "%implies%")];

