structure PPProver : PROVER =
struct

  type pos = PPTermLib.pos
  type typ = TYPE
  type term = TERM
  type thm = THM
  type tactic = TACTIC
  type context = string list * string (* context string list * theory string *)

  type fact = thm
  type concl = term

  datatype Object =  Fact of fact | Concl of concl

  (* get_current_pc () open_theory, set_pc *)

  exception gterm_exp
  
  val current_ctxt = get_current_pc (); (* used in those place need context in general *)
  val typ_of = type_of
  fun match ctxt = (op ~=$) 

  val eq_pos = PPTermLib.eq_pos
    
  fun intlist_of_pos pos = pos
  fun pos_of_intlist il = il
  
  val root_of_trm = PPTermLib.root_of_trm
  val subtrm_of_pos = PPTermLib.subtrm_of_pos
  val trm_of_pos = PPTermLib.trm_of_pos
  
  val concl_of_thm = concl
  val asms_of_thm =  asms
  (* get asm of thm - asms*)
  fun trm_of_string _ = mk_string 
  
(* TODO: how to print those fancy symbols in proofpower ?*)
  fun string_of_trm _ = fn trm => PrettyPrinter.format_term true trm |> String.concat
  fun pretty_trm dummy t = Pretty.str "pretty term - not supported in pp"

(* atomic part *)
  type pnode = 
      {pname : string (* goal ref in psg *), 
       g: GOAL (* ([ams], concl ) *), 
       pctxt : context,
       glabel : string list (* referece used in subgoal system in pp, it's defnied as string list, but only the first one is used *)} 
  
  (* TODO: maybe to add a table to store some meta info, e.g. hints? measures? *)
  type pplan = 
      {opengs : pnode StrName.NTab.T, 
      usedgs : StrName.NSet.T}
  
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq (* in pp, tactic is deteminted, seq is always single *)

  exception atomic_exp of string
  val psgraph_prover_i = "proofpower";
  (* there is no interface to init a pnode and pplan ?*)
  (* if paralle evalation then it would be problematic*)
  
  fun init _ _  = raise atomic_exp "init is not expected to be called in pp"
  fun init_with_assm ctxt asms_trms concl_trm : (pnode * pplan) =
    let
      val (pcs, thy) = ctxt
      val _ = (set_merge_pcs pcs; set_goal (asms_trms, concl_trm)); (* setup goal *)
      val goal = top_goal ();
      val ctxt' = get_current_pc();
      val name = StrName.NSet.new StrName.NSet.empty "g"
      val pnode = {pname = name, g = goal,  pctxt = ctxt', glabel = []};
      val pplan = {opengs = StrName.NTab.of_list [((#pname pnode), pnode)], 
      			 usedgs = StrName.NSet.add name StrName.NSet.empty}
    in
      (pnode, pplan)
    end;
    
  (*fun update _ _ = ([], {opengs = [], usedgs = StrName.NSet.empty})*)
  
  (*val update : TACTIC -> (pnode * pplan) -> (pnode list * pplan) *)
  
  fun update (tac : tactic) (pnode : pnode, pplan : pplan)  : (pnode list * pplan) = 
    let 
      fun gen_fresh_psgname nset (g : (string list * GOAL)) = 
        if (fst g) = [""] 
        then 
          (StrName.NSet.new nset "g",  g)
        else
          (hd (fst g), g)
      (*val _ = writeln "called update"*)
      val _ = ((if (#glabel pnode) = [] then () else set_labelled_goal (hd (#glabel pnode)));
      		apply_tactic tac); (* set current goal and apply tactic*)
      val sgs = top_goals(); (* string list * (term list * term) list *)
      val ctxt = get_current_pc();   
      fun filter_goals plist name = 
        filter 
        (fn (x : pnode) => 
          (case String.compare ((#pname x), name) of EQUAL => false 
          | _ => true))
        plist
      fun gen_pnode (name, g) = ({pname = name, pctxt = ctxt, g =snd g, glabel = fst g});
    in
      if (List.length sgs) = 0 (* no sgs *) 
      then 
        ([], {opengs = StrName.NTab.empty, usedgs = (#usedgs pplan)})
      else((* a list of sgs*)
        let
          val sgs' = map (gen_fresh_psgname (#usedgs pplan)) sgs
	  val new_pnodel = map gen_pnode sgs' (* all open subgoals *)
	  val new_pnodel' = 
	    List.foldr
	    (fn (n, pns) =>
	        filter 
	        (fn x => (case String.compare ((#pname x), n) 
	        		of EQUAL => false 
	        		| _ => true))
        	pns)
            new_pnodel
	    (StrName.NSet.list_of (#usedgs pplan))

          val new_pplan = 
            {opengs = (map (fn x => ((#pname x), x)) new_pnodel) 
        		 |> StrName.NTab.of_list, (* get all current sgs name *)
             usedgs = StrName.NSet.add_list (map fst sgs') (#usedgs pplan)  }
	in
	  (new_pnodel', new_pplan) 
	end

      )
     end
  
  (* TACTIC in pp is always determined, no branching ?? *)
  fun apply_rule _ thm pinfo = update (bc_thm_tac thm) pinfo |> Seq.single
 
  fun apply_erule _ _ _ = raise atomic_exp "apply_erule is not supported"
  
  (* first assumption, next rule, but in pp ,it's applied blindly *)
  fun apply_frule _ (_ , thm) pinfo =  update (all_fc_tac [thm]) pinfo |> Seq.single
  
  fun apply_subst _ thm pinfo = update (rewrite_tac [thm]) pinfo|> Seq.single
  
  (* first assumption, second the equality rule *)
  fun apply_subst_asm _ (_ , thm) pinfo = update (rewrite_tac [thm]) pinfo |> Seq.single
  
  fun apply_tactic _ _ tactic pinfo = (writeln "call apply_tactic in psg" ; update tactic pinfo |> Seq.single)

  (* only look up *)
  fun lookup_fact pnode key = 
    (get_axiom (snd (#pctxt pnode)) key |> SOME
    handle _ => 
      (get_thm (snd (#pctxt pnode)) key |> SOME
       handle _ => NONE))

  fun get_all_assms pnode  = (#g pnode) 
  			      |> fst (* a list of term *)
  			      |> map asm_rule (* to thm type *)
  			      
  (* need to think about more for this *)			 
  fun get_all_named_facts_pair _ = [] (*pnode -> (string * fact) list*)

  fun get_pnode_name (pnode:pnode) = #pname pnode;
  
  fun get_pnode_concl (pnode:pnode) = (#g pnode) |> snd
  
  fun get_pnode_ctxt (pnode:pnode) = (#pctxt pnode)
  
  fun get_open_pnodes (pplan:pplan) = StrName.NTab.list_of (#opengs pplan) |> map snd (* should return some goals as top_goals () *)
  
  fun pretty_concl _ = Pretty.str "pretty_concl - not supported in pp"
  
  fun intf_pprint _ = ();

  structure Sharing = 
  struct   
    type pos = pos
    type typ = typ
    type term = term
    type thm = thm
    type context = context
    type tactic = tactic
    type concl = concl
    type fact = fact
    type pplan = pplan
    type pnode = pnode
    type Object = Object
  end
end
