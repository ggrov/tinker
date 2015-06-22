structure SimpleGoalTyp : BASIC_GOALTYPE = 
struct
  local open LoggingHandler in

  structure Prover = IsaProver;
  type T = string
  type gnode = string (* or with term? *)
  type data  = unit;

  exception gt_exp of string
  val default = "any";
  val default_gnode = "?";
  val default_data = ();

  val ord = String.compare;
  fun eq (t1,t2) = case ord(t1,t2) of EQUAL => true | _ => false;

  val gnode_ord = String.compare;
  fun gnode_eq (g1,g2) = case gnode_ord(g1,g2) of EQUAL => true | _ => false;

  val goal_name = I;

  val gnode_to_json = Json.String;
  fun gnode_from_json (Json.String str) = str
  | gnode_from_json _ = raise gt_exp "gnode_from_json: ill-formed json structure"

  fun data_to_json _ = Json.String "";
  fun data_from_json _ = ()

(*
  val to_json = Json.String;
  fun from_json (Json.String str) = str;
*)
  fun to_json str = Json.String str

  fun from_json (Json.String str) = str
  | from_json _ = raise gt_exp "from_json: ill-formed json structure"


  fun pretty_data _ = Pretty.str "";
  val pretty_gnode = Pretty.str;
  val pretty = Pretty.str;

(**************************************************************
    Term manipulation and term related predicate definations
**************************************************************)
  structure TF = TermFeatures;
  local open IsaProver in

    fun top_level' str pn = 
      case TF.top_level_str (Logic.strip_imp_concl (#ptrm pn)) of
         NONE => false
       | SOME v => (let val _ = logging "GOALTYPE" (v ^ " " ^  (TF.ignore_module str)) in v = (TF.ignore_module str) end);
    
    fun top_level strs pn = map (fn str => top_level' str pn) strs;

    fun has_symbol strs pn = TF.has_constants strs (Logic.strip_imp_concl (#ptrm pn));

    fun liftp pn pred = 
     if pred then  [(#pname pn)] else []; 
 
    val splitstr =  String.tokens (member (op =) [#" ",#",",#"(",#")",#"[",#"]"]);
    
    fun get_hyps_and_goal ptrm = 
      let
        val sg = ptrm |> TF.fix_alls_in_term
        val hyps  = Logic.strip_imp_prems sg |> map TF.fix_alls_as_var 
        val goal = Logic.strip_imp_concl sg (*|> TF.fix_alls_as_var*)
 (* TODO: this may cause some problem due to the same binding and name in both hyps and goal *)
      in
        (hyps, goal)
      end

    fun hyp_embeds pn =
      let 
         val ctxt = #pctxt pn
         val (hyps, goal) = get_hyps_and_goal (#ptrm pn)
         val _ = Pretty.chunks ([Pretty.str "hyps in hyp_embed: "] @ (map (Syntax.pretty_term @{context}) hyps)) 
                 |> Pretty.string_of |> logging "GOALTYPE"
         val _ = Pretty.chunks ([Pretty.str "goal in hyp_embed: "] @ [((Syntax.pretty_term @{context} goal))]) 
                 |> Pretty.string_of |> logging "GOALTYPE"
      in 
        exists (fn hyp => TF.ctxt_embeds ctxt hyp goal) hyps 
        |> (fn x => if x then (logging "GOALTYPE" "find embeddings !"; x) 
            else  (logging "GOALTYPE" "no embeddings !"; x))
      end;
(*
    fun goal_embeds pn =
      let 
         val ctxt = #pctxt pn
         val (hyps, goal) = get_hyps_and_goal (#ptrm pn)
      in
        exists (fn hyp => TF.ctxt_embeds ctxt goal hyp) hyps
      end;
*)
    fun is_inductable pn =
      let
         val thy = #pctxt pn |> Proof_Context.theory_of
         val (_, goal) = get_hyps_and_goal (#ptrm pn)
      in
        TF.is_inductable_structural thy goal
      end
(* leave it for later
    fun measure_reduces pn =
      let
         val ctxt = #pctxt pn 
         val thy = #pctxt pn |> Proof_Context.theory_of
         val goal = Logic.strip_imp_concl (#ptrm pn)
         val wrules = BasicRipple.get_matched_wrules thy goal
      in
        TF.has_measure_decreasing_rules ctxt wrules goal
      end
*)
    fun measure_reduces pn =
      let
         val ctxt = #pctxt pn 
         (*val thy = #pctxt pn |> Proof_Context.theory_of*)
         val (hyps, goal) = get_hyps_and_goal (#ptrm pn)
         val embedd_hyp =
          filter (fn hyp => TF.ctxt_embeds ctxt  hyp goal) hyps (* use the hyp with no bindings *)
          |> hd (* only get the first embedding *)
         val wrules = BasicRipple.get_matched_wrules ctxt goal
      in
        TF.has_measure_decreasing_rules ctxt embedd_hyp wrules goal
        |> (fn x => if x then (logging "GOALTYPE" "find decreased measure !"; x) 
            else  (logging "GOALTYPE" "no decreased measure !"; x))
      end

    (* embedding is a subterm of goal, or if the embedding is eq type then 
      test if there is no wrule and either lhs or rhs of the embedding is a subterm of the goal*)
    fun is_rippled pn = 
      let 
        val ctxt = #pctxt pn
        val thy = #pctxt pn |> Proof_Context.theory_of
        val (hyps, goal) = get_hyps_and_goal (#ptrm pn)
        val embedd_hyp =
          filter (fn hyp => TF.ctxt_embeds ctxt hyp goal) hyps
          |> hd (* only get the first embedding *)
        fun mk_meta_eq_trm thry t = Thm.cterm_of thry t 
          |> Thm.trivial |> safe_mk_meta_eq |> Thm.concl_of;
        fun get_lhs_rhs thry trm = Logic.dest_equals (mk_meta_eq_trm thry trm) |> SOME
        handle _ => NONE;
        fun weak_fert trm = 
          case get_lhs_rhs thy trm of NONE => false
             | SOME(l,r) => (TF.is_subterm thy goal l orelse TF.is_subterm thy goal r)
      in
        if (TF.is_subterm thy goal embedd_hyp) orelse (not(measure_reduces pn) andalso (weak_fert embedd_hyp))
        then true
        else false            
    end

    fun hyp_subst pn = 
      let 
        val ctxt = #pctxt pn
        val thy = #pctxt pn |> Proof_Context.theory_of
        val (hyps, goal) = get_hyps_and_goal (#ptrm pn)
        val embedd_hyp =
          filter (fn hyp => TF.ctxt_embeds ctxt hyp goal) hyps
          |> hd (* only get the first embedding *)
        fun mk_meta_eq_trm thry t = Thm.cterm_of thry t 
          |> Thm.trivial |> safe_mk_meta_eq |> Thm.concl_of;
        fun get_lhs_rhs thry trm = Logic.dest_equals (mk_meta_eq_trm thry trm) |> SOME
        handle _ => NONE;
        fun weak_fert trm = 
          case get_lhs_rhs thy trm of NONE => false
             | SOME(l,r) => (TF.is_subterm thy goal l orelse TF.is_subterm thy goal r)
      in
        (weak_fert embedd_hyp)         
    end

    fun hyp_bck_res pn = 
      let 
        val ctxt = #pctxt pn
        val thy = #pctxt pn |> Proof_Context.theory_of
        val (hyps, goal) = get_hyps_and_goal (#ptrm pn)
        val embedd_hyp =
          filter (fn hyp => TF.ctxt_embeds ctxt hyp goal) hyps
          |> hd (* only get the first embedding *)
        val _ = Pretty.chunks ([Pretty.str "unif goal: "] @ 
                               [((Syntax.pretty_term @{context} goal))] @ 
                               [Pretty.str "with embeds: "] @
                               [((Syntax.pretty_term @{context} embedd_hyp))]
                               ) 
        |> Pretty.string_of |> logging "GOALTYPE"
      in
        TF.is_subterm thy goal embedd_hyp
      end
   
(**************************************************************
    ML String parsing 
**************************************************************)
  type gtyp = Prover.context -> Prover.term list -> Prover.term -> bool
  structure GoalTyp_ML_Exec = ML_Exec_Func (structure prover = Prover type ret = gtyp val struct_name = "SimpleGoalTyp");

    fun debug_trace str b = 
      if b then (logging "GOALTYPE" (str ^ " is good !"); b) 
      else (logging "GOALTYPE" (str ^ " fails !"); b);

    val keywords = ["top_symbol", "has_symbol", "goal_embeds", "hyp_embeds", "inductable",
                      "measure_reduces", "hyp_bck_res", "hyp_subst", "not", "or", "any", "anything"];
    fun is_keyword x = exists (fn y => x = y) keywords

    fun get_args (x :: xs) = 
      if is_keyword x then ([], x::xs) 
      else (
        let val (p1,p2) = get_args xs in
       ( x ::p1,p2) end )
      | get_args [] = ([],[]);
(*
    fun split_args xs = 
      let val (args, l) = get_args (tl xs) in 
      if l = [] then [(hd xs) :: args]
      else ((hd xs) :: args) :: (split_args l) end;
*)

(**************************************************************
    simple goaltype parsing 
**************************************************************)
    val split_args = String.tokens (member (op =) [#"|"]);

    fun lift_list _ _ [] = false
     |  lift_list pn data (x::xs) =
          ((case x of 
             "top_symbol" => exists I (top_level xs pn) |> debug_trace x
           | "has_symbol" => has_symbol xs pn |> debug_trace x
           (*| "goal_embeds" => goal_embeds pn to be tested *)
           | "hyp_embeds" => (hyp_embeds pn)  |> debug_trace x
           | "inductable" => is_inductable pn  |> debug_trace x
           | "rippling" => ((hyp_embeds pn) andalso (measure_reduces pn)) |> debug_trace x
           | "measure_reducible" => (measure_reduces pn)  |> debug_trace x
           | "hyp_bck_res" => hyp_bck_res pn  |> debug_trace x
           | "hyp_subst" => hyp_subst pn  |> debug_trace x
           | "rippled" => (is_rippled pn) |> debug_trace x
           | "not"       => not (lift_list pn data xs) 
           | "or"        => exists I (map (lift_list pn data) (map split_args (xs))) |> debug_trace x
           | "any"       => true (* default *)
           | "anything"   => true (* default *)
           | "label"      => true
           |  exp         =>  GoalTyp_ML_Exec.eval_ml exp (get_pnode_ctxt pn) (get_pnode_hyps pn) (get_pnode_concl pn)  |> debug_trace x)
        (*handle _ => false*));

   fun lift' pn (data, str) = lift_list pn data (splitstr str)
   (*handle _ => raise gt_exp "int lift'";*)

   fun init_lift (data,str) pn =
     let 
        val ls = String.tokens (fn c => c = #";") str
        val _ = logging "GOALTYPE" (("init goal " ^  (#pname pn) ^  " with goal type: " ^ str ))
    in 
     case ls of 
       [] => (logging "GOALTYPE" "warning; No goal types !"; [])
      | _ => ls |> map (fn x => lift' pn (data, x))
                |> forall I 
                |> liftp pn
   end
   (*handle _ => raise gt_exp "in init lift";*)

  end; (* local open *)

  (* assume gn is the name of pn *)
  fun check (data,str) (_,pn) = 
    case init_lift (data,str) pn of
     [] => false
    | _ => true;

  fun lift pn = (#pname pn)


  (* delete *)
  fun lookup_fact_names _ _ = NONE;
  (* need to pretend there is a single fact *)
  fun get_fact_names _ _ = StrName.NSet.single ("True_def");

  structure BasicSharing =
  struct
    type T = T
    type gnode = gnode
    type data = data
    type gtyp = gtyp
    structure Prover = Prover.Sharing
  end
  end (* local open *)
end(* struct *);
