structure SimpleGoalTyp : BASIC_GOALTYPE = 
struct
  structure Atomic = PPAtomic;
  type T = string
  type gnode = string (* or with term? *)
  exception gt_exp of string
  val default = "any";
  val default_gnode = "?";
  
  val symbol_table: string StrName.NTab.T = 
    StrName.NTab.of_list [("and", "%and%"), ("implies", "%implies%")];

  val ord = String.compare;
  fun eq (t1,t2) = case ord(t1,t2) of EQUAL => true | _ => false;

  val gnode_ord = String.compare;
  fun gnode_eq (g1,g2) = case gnode_ord(g1,g2) of EQUAL => true | _ => false;

  val goal_name = I;

  val gnode_to_json = Json.String;
  fun gnode_from_json (Json.String str) = str

  fun to_json str = 
     Json.mk_object [("type", Json.String "GT"), ("gtyp_name", Json.String str)] 

  fun from_json (Json.Object jobj) = Json.get jobj "gtyp_name" |> (fn Json.String x => x)

  val pretty_gnode = Pretty.str;
  val pretty = Pretty.str;

  structure TF = TermFeature;
  local open Atomic in

    fun top_level' str pn = 
      case TF.top_level_str (get_pnode_concl pn) of
         NONE => false
       | SOME v => (v = str);
    
    fun top_level strs pn = 
      map (fn str => top_level' 
      			(case StrName.NTab.lookup symbol_table str of (SOME str') => str' | _ => str) 
      			pn) 
      strs;

    fun has_symbol strs pn = 
      forall (fn str => TF.has_constant_by_str 
    			(case StrName.NTab.lookup symbol_table str of (SOME str') => str' | _ => str) 
    			(get_pnode_concl pn)) 
      strs ;

    fun liftp pn pred = 
     if pred then SOME (get_pnode_name pn) else NONE; 
 
    val splitstr =  String.tokens (member (op =) [#" ",#",",#"(",#")",#"[",#"]"]);
    
    val keywords = ["top_symbol", "has_symbol", "not", "or", "any"];
    fun is_keyword x = exists (fn y => x = y) keywords

    fun get_args (x :: xs) = 
      if is_keyword x then ([], x::xs) 
      else (
        let val (p1,p2) = get_args xs in
       ( x ::p1,p2) end )
      | get_args [] = ([],[]);

    fun split_args xs = 
      let val (args, l) = get_args (tl xs) in 
      if l = [] then [(hd xs) :: args]
      else ((hd xs) :: args) :: (split_args l) end;

    fun debug_print pn gt ret = 
      if ret then writeln ("GoalType: " ^ gt ^ " is OK for " ^ (get_pnode_name pn))
      else writeln ("GoalType: " ^ gt ^ " fails for " ^ (get_pnode_name pn))
      
    fun lift_list pn [] = false
     |  lift_list pn (x::xs) =
          ((case x of 
             "top_symbol" => exists I (top_level xs pn) |> (fn r => (debug_print pn x r; r))
           | "has_symbol" => has_symbol xs pn |> (fn r => (debug_print pn x r; r))
           | "not"       => not (lift_list pn xs) 
           | "or"        => exists I (map (lift_list pn) (split_args xs)) 
           | "any"       => true (* default *)
           | _           => false)
        handle _ => false);

   fun lift' pn str = lift_list pn (splitstr str)
   handle _ => raise gt_exp "int lift'";

   fun init_lift str pn =
     let 
        val ls = String.tokens (fn c => c = #";") str
     in 
       case ls of 
         []  =>  NONE
         | _ => ls |> map (lift' pn)
                |> forall I 
                |> liftp pn
     end
     handle _ => raise gt_exp "in init lift";

  end; (* local open *)

  (* assume gn is the name of pn *)
  fun match gn gt pn = 
    case init_lift gt pn of
     NONE => false
    | SOME _ => true;

  val lift = K init_lift;

  (* delete *)
  fun lookup_fact_names _ _ = NONE;
  (* need to pretend there is a single fact *)
  fun get_fact_names _ _ = StrName.NSet.single ("True_def");

  structure BasicSharing =
  struct
    type T = T
    type gnode = gnode
  end
  
end;
