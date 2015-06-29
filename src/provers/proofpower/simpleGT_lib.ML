structure SimpleGT_Lib  = 
struct
  local open LoggingHandler TermFeatures in

  (* use a symbol table to represent those non-standdatd ascii symbols *)
  val symbol_table : string StrName.NTab.T Unsynchronized.ref  = Unsynchronized.ref StrName.NTab.empty;
  fun init_symbol_table l = symbol_table := StrName.NTab.of_list l; 
  init_symbol_table [("HOL.conj", "%and%"), ("HOL.implies", "%implies%")];

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
      |> exists I (top_level xs goal)
      

    fun has_symbol strs _ _ goal = 
      forall (fn str => has_constant_by_str 
    			(case StrName.NTab.lookup (!symbol_table) str of (SOME str') => str' | _ => str) 
    			goal) 
      strs ;

     val GT_top_symbol = top_level;
     val GT_has_symbol = has_symbol;
(**************************************************************
    simple goaltype parsing 
**************************************************************)
    fun lift_list pn data [] = false
     |  lift_list pn data (x::xs) =
          (case x of 
           "any"       => true (* default *)
           |  exp         => eval_gt pn data exp 
          (* | others      => case (StrName.NTab.lookup (!default_GT) others) 
           			of (SOME gt) => gt (get_GOAL_from_pnode pn)
           			| _ => false) *)
        (*handle _ => (writeln "exception catched when checking goaltypes "; false)*))

   fun lift' pn (data, str) = lift_list pn data (splitstr str)
   (*handle _ => raise gt_exp "int lift'";*)

   fun init_lift (_,str) pn =
     let 
        val ls = String.tokens (fn c => c = #";") str
     in 
       case ls of 
         []  =>  []
         | _ => ls |> map (lift' pn)
                |> forall I 
                |> liftp pn
     end
     (*handle _ => raise gt_exp "in init lift";*)

  end; (* local open *)

  (* assume gn is the name of pn *)
  fun match gn gt pn = 
    case init_lift ((), gt) pn of
     [] => false
    | _ => true;

  val lift : gnode -> (data * T) -> Prover.pnode -> gnode list = K init_lift;

  (* delete *)
  fun lookup_fact_names _ _ = NONE;
  (* need to pretend there is a single fact *)
  fun get_fact_names _ _ = StrName.NSet.single ("True_def");
  
  fun data_to_json _ = Json.String "";
  fun data_from_json _ = ()
  fun pretty_data _ = Pretty.str "";

  structure BasicSharing =
  struct
    type T = T
    type gnode = gnode
    type data = data
    type gt_pred = gt_pred
  end
  end (* local open *)
end(* struct *);
