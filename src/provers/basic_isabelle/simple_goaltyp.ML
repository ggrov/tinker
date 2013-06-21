structure SimpleGoalTyp : BASIC_GOALTYPE = 
struct
  structure Atomic = BIsaAtomic;
  type T = string
  type gnode = string (* or with term? *)
   
  val default = "any";
  val default_gnode = "?";

  val ord = String.compare;
  fun eq (t1,t2) = case ord(t1,t2) of EQUAL => true | _ => false;

  val gnode_ord = String.compare;
  fun gnode_eq (g1,g2) = case gnode_ord(g1,g2) of EQUAL => true | _ => false;

  val goal_name = I;

  val gnode_to_json = Json.String;
  fun gnode_from_json (Json.String str) = str

(*
  val to_json = Json.String;
  fun from_json (Json.String str) = str;
*)
  fun to_json str = 
     Json.mk_object [("type", Json.String "GT"), ("gtyp_name", Json.String str)] 

  fun from_json (Json.Object jobj) = Json.get jobj "gtyp_name" |> (fn Json.String x => x)



  val pretty_gnode = Pretty.str;
  val pretty = Pretty.str;

  structure TF = TermFeatures;
  local open BIsaAtomic in

    fun top_level' str pn = 
      case TF.top_level_str (Logic.strip_imp_concl (#ptrm pn)) of
         NONE => false
       | SOME v => (v = str);
    
    fun top_level strs pn = map (fn str => top_level' str pn) strs;

    fun has_symbol strs pn = TF.has_constants strs (Logic.strip_imp_concl (#ptrm pn));

    fun liftp pn pred = 
     if pred then SOME (#pname pn) else NONE; 
 
    val splitstr =  String.tokens (member (op =) [#" ",#",",#"(",#")",#"[",#"]"]);
    
    fun hyp_embeds pn =
      let 
         val ctxt = #pctxt pn
         val hyps  = Logic.strip_imp_prems (#ptrm pn)
         val goal = Logic.strip_imp_concl (#ptrm pn)
      in
        exists (fn hyp => TF.ctxt_embeds ctxt hyp goal) hyps
      end;

    fun goal_embeds pn =
      let 
         val ctxt = #pctxt pn
         val hyps  = Logic.strip_imp_prems (#ptrm pn)
         val goal = Logic.strip_imp_concl (#ptrm pn)
      in
        exists (fn hyp => TF.ctxt_embeds ctxt goal hyp) hyps
      end;

    fun lift_list pn [] = false
     |  lift_list pn (x::xs) =
          ((case x of 
             "top_symbol" => exists I (top_level xs pn)
           | "has_symbol" => has_symbol xs pn
           | "goal_embeds" => goal_embeds pn (* to be tested *)
           | "hyp_embeds" => hyp_embeds pn (* to be tested *)
           | "not"        => not (lift_list pn xs) 
           | "any"       => true (* default *)
           | _           => false)
        handle _ => false);

   fun lift' pn str = lift_list pn (splitstr str);

   fun init_lift str pn =
     let 
        val ls = String.tokens (fn c => c = #";") str
    in 
     case ls of 
       [] => NONE
      | _ => ls |> map (lift' pn)
                |> forall I 
                |> liftp pn
   end;

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
