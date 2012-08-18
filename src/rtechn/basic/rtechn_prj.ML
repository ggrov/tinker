structure RTechnPrj
= struct

  fun goal_concl_term g pplan =
      PPlan.get_varified_ltrm pplan g |> Logic.strip_imp_concl;

  (* fixme: should this be unification instead *)
  fun matches_hyp g rst ((_:string),t) = 
      Pattern.matches 
        (Proof_Context.theory_of (RState.get_ctxt rst)) 
        (t, goal_concl_term g (RState.get_pplan rst));

  (* filtering (move to other place?) *)
  fun gfilter_patt pat rst ((_:string),t) = 
      Pattern.matches 
        (Proof_Context.theory_of (RState.get_ctxt rst)) 
        (pat, t);

  fun gfilter_subterm_patt pat rst ((_:string),t) = 
       Pattern.matches_subterm 
        (Proof_Context.theory_of (RState.get_ctxt rst)) 
        (pat, t);

  val gfilter_eq = gfilter_patt (Logic.varify_global @{term "HOL.Trueprop (A = B)"})
  val gfilter_and = gfilter_patt (Logic.varify_global @{term "HOL.Trueprop (A \<and> B)"})
  val gfilter_imp = gfilter_patt (Logic.varify_global @{term "HOL.Trueprop (A \<longrightarrow> B)"})
  val gfilter_forall = gfilter_patt (Logic.varify_global @{term "HOL.Trueprop (\<forall> x. P x)"})
  
  val gfilter_haseq = gfilter_subterm_patt (Logic.varify_global @{term "(A = B)"})

  (* prefix stuff *)
  (* this is due the naming used in Isabelle, Union is Set.Union *)
  (* Fixme: must be a less hacky way (how does Isabelle actually handle namespaces?) *)
  fun all_prefix str = 
    let val tokens = (String.tokens (fn s => s = #".") str) |> rev
    in case tokens of 
      [t] => [t]
      | _ => (fold 
               (fn n => fn (str,res) => ((n ^ "." ^ str),res @ [(n ^ "." ^ str)]))
               (tl tokens)
               (hd tokens,[hd tokens]))
            |> snd
   end;

  fun check_suffix name full_name = 
    member (op = ) (all_prefix full_name) name;

  fun check_suffix_suffix full_name1 full_name2 = 
    (all_prefix full_name1)
    |> exists (member (op = ) (all_prefix full_name2));

  fun contains_symb str (Const (s,_)) = (check_suffix str s)
   |  contains_symb str (Free (s,_)) = (check_suffix str s)
   |  contains_symb str (Var ((s,_),_)) = (check_suffix str s)
   |  contains_symb _ (Bound _) = false
   |  contains_symb str (Abs (_, _, t)) = contains_symb str t
   |  contains_symb str (t $ u) = contains_symb str t orelse contains_symb str u;

  fun contains_symb' str (_,t) = contains_symb str t;

  (* project premise *)

  fun app_term_pred pred rst (_,t) = pred rst t;

  (* what about siblings - i.e. we do a forward step - does it come up? *)
  fun all_hyps goal rst = PPlan.get_aasms (RState.get_pplan rst) goal;
  fun all_hypsterms goal rst = PPlan.get_aasmtrms (RState.get_pplan rst) goal;

  fun project_and_filter_facts pred rst gnode = 
    all_hypsterms (GNode.get_goal gnode) rst 
    |> filter (fn gs => pred rst gs gnode)
    |> map fst;

  fun project_to_fact_gnode pred prem_wire rst gnode =
    project_and_filter_facts pred rst gnode
    |> Goaln.NSet.of_list
    |> (fn gs => GNode.add_facts (prem_wire,gs) gnode);

  fun project_prem_rtechn pred prem_wire inp_wire (out_wire as (mwire,_)) =
    let
      fun appf gs rst = gs
        |> GNode.GoalSet.list_of
        |> map (project_to_fact_gnode pred prem_wire rst)
        |> GNode.GoalSet.of_list
        |> (fn gs => (mwire,gs))
        |> GoalNode.G.NSet.single
        |> (fn outs => RState.set_outputs outs rst)
        |> Seq.single
    in 
      RTechn.id
      |> RTechn.set_name "project"
      |> RTechn.set_inputs (WireNode.W.NSet.single inp_wire)
      |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
      |> RTechn.set_atomic_appf (RTechnEnv.tac_appf appf)
  end;

  (* filter reasoning technique *)

  fun filter_fact_gnode pred in_prem_wire out_prem_wire rst gnode =
    GNode.lookup_facts in_prem_wire gnode 
    |> Goaln.NSet.list_of
    (* a bit of a hack - don't want all the assumptions in this case!! *)
    |> map (fn g => (g,goal_concl_term g (RState.get_pplan rst)))
    |> filter (fn gs => pred rst gs gnode)
    |> map fst
    |> Goaln.NSet.of_list
    |> (fn gs => GNode.add_facts (out_prem_wire,gs) (GNode.delete_fact in_prem_wire gnode));
 
  fun filter_prem_rtechn pred in_prem_wire out_prem_wire inp_wire (out_wire as (mwire,_)) =
    let
      fun appf gs rst = gs
        |> GNode.GoalSet.list_of
        |> map (filter_fact_gnode pred in_prem_wire out_prem_wire rst)
        |> GNode.GoalSet.of_list
        |> (fn gs => (mwire,gs))
        |> GoalNode.G.NSet.single
        |> (fn outs => RState.set_outputs outs rst)
        |> Seq.single
    in 
      RTechn.id
      |> RTechn.set_name "filter"
      |> RTechn.set_inputs (WireNode.W.NSet.single inp_wire)
      |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
      |> RTechn.set_atomic_appf (RTechnEnv.tac_appf appf)
    end;

  fun if_rtechn (predname,pred) inp_wire (true_wire as (twire,_)) (false_wire as (fwire,_)) =
    let
      fun appf gs rst = gs
        |> GNode.GoalSet.list_of
        |> (fn gs => fold (fn g => fn (good,bad) => 
                       case pred g rst of 
                          SOME g' => (g'::good,bad) 
                        | NONE    => (good,g::bad))
                     gs ([],[])) 
        |> (fn (good,bad) => [(twire,GNode.GoalSet.of_list good),(fwire,GNode.GoalSet.of_list bad)])
        |> GoalNode.G.NSet.of_list
        |> (fn outs => RState.set_outputs outs rst)
        |> Seq.single
    in 
      RTechn.id
      |> RTechn.set_name ("if " ^ predname)
      |> RTechn.set_inputs (WireNode.W.NSet.single inp_wire)
      |> RTechn.set_outputs (WireNode.W.NSet.of_list [false_wire,true_wire])
      |> RTechn.set_atomic_appf (RTechnEnv.tac_appf appf)
    end;

end;
