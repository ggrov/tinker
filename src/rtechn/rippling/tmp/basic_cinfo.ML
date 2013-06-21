(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/rippling/basic_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Created:    15 Mar 2003
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Basic contextual-information for performing rippling. The main purpose
    of this is to manage multiple skeletons, and tie together the
    database of wave rules to the process of rippling. Furthermore, we
    manage the overall ripppling process and provide information on
    matching rules.

*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature BASIC_RIPPLE_CINFO = 
sig
  type T

  structure RippleSkel : RIPPLE_SKEL;

  structure I : LOCAL_INFO_ITEM where type T = T

  exception rippling_cinfo_exp of string;
  exception rippling_cinfo2_exp of ((PPlan.gname * Term.term) list  (* skel *)
                                    * Term.term); (* tgt *)

    (* working with rippling cinfo: starting/updating *)
   (* to do: update type? *)
  val start : (PPlan.gname * Term.term) list 
              -> ParamRGraph.T ->
              PPlan.gname ->
              RState.T -> 
              RState.T Seq.seq;
      
  val update : PPlan.gname (* old goal *)
               -> PPlan.gname (* new goal *)
               -> RState.T -> RState.T Seq.seq

  val update_unrestricted : (* all applicable embeddings, 
                               even non-measure decreasing *)
      PPlan.gname  -> PPlan.gname -> RState.T -> RState.T Seq.seq

  (* internal update functions *)
  val update_i :  (PPlan.gname * 
                   ((PPlan.gname * Term.term) * RippleSkel.T option) list)
                -> PPlan.gname -> RState.T -> RState.T Seq.seq
  val update_unrestricted_i : (PPlan.gname *
                    ((PPlan.gname * Term.term) * RippleSkel.T option) list)
                   -> PPlan.gname -> RState.T -> RState.T Seq.seq

  val mk_rcinfo :  ParamRGraph.T -> 
                   ((PPlan.gname * Term.term) * RippleSkel.T option) list
                   -> T
                      
  (* do we have some valid embedding for rippling *)
  val is_valid_ripple_state_i : T -> bool
  val is_valid_ripple_state_goal : RState.T -> PPlan.gname -> bool
  val some_curgoal_is_ripple_valid : BWire.name -> RState.T -> bool
  (* we are blocked given possible nest states *)
  val blocked1_chk_i : T -> T list -> bool
  val blocked_chk : RState.T -> PPlan.gname -> (PPlan.gname list * RState.T) list -> bool
  (* are we trying to ripple, even if we don't have any embeddings *)
  val is_rippling_i : T -> bool
  val is_rippling : RState.T -> PPlan.gname -> bool
  val some_curgoal_is_rippling : BWire.name -> RState.T -> bool 
  (* is this goal's rippling successfull *) 
  val success_chk : RState.T -> PPlan.gname -> bool
                                               
  (* skeletons and measures *)
  val skels_of_i : T -> RippleSkel.T list
  val skels_of : RState.T -> PPlan.gname -> RippleSkel.T list
                                            
  val skeleton_namedterms_of_i : T -> (PPlan.gname * Term.term) list
  val skeleton_namedterms_of 
      : RState.T -> PPlan.gname -> (PPlan.gname * Term.term) list
  val skeleton_names_of  
      : RState.T -> PPlan.gname -> PPlan.gname list
                                   
  (* skeletons from all current rippling goals *)
  val all_skels_of_i : T -> ((PPlan.gname * Term.term) * 
                             RippleSkel.T option) list
  val all_skels_of : RState.T -> PPlan.gname-> 
                     ((PPlan.gname * Term.term) * 
                      RippleSkel.T option) list
                     
  val select_valid_skels :  ((PPlan.gname * Term.term) * 
                             RippleSkel.T option) list -> 
                            RippleSkel.T list
                            
  val measures_of_i : T -> RippleSkel.RippleMeasure.T list
  val measures_of : RState.T -> PPlan.gname-> 
                    RippleSkel.RippleMeasure.T list
                    
  val has_embedding : RState.T -> PPlan.gname -> bool
  val embeddings_of : RState.T -> PPlan.gname -> Embed.T list

  val inst_skels_terms : RState.T -> PPlan.gname -> Term.term list


  (* get relation graph used by relational rippling *)
  val get_relgraph :  RState.T -> PPlan.gname -> ParamRGraph.T

  (* lookup rulesets *)
  val lookup_substs_of_goal : PPlan.T -> PPlan.gname -> (Zipper.T * Substset.rule) list
  val lookup_bckimps_of_goal : PPlan.T -> PPlan.gname -> Bckimpset.rule list
  val lookup_fwdimps_of_goal : PPlan.T -> PPlan.gname -> Fwdimpset.rule list


  (* lookup and apply rules for given goal *)
  (* fixme: some returns only 1 goal some 2 different "types" of goal -- now flatten *)
  val apply_substs_of_goal : PPlan.T -> PPlan.gname -> (PPlan.gname list * PPlan.T) Seq.seq
  val apply_bckimps_of_goal : PPlan.T -> PPlan.gname -> (PPlan.gname list * PPlan.T) Seq.seq
  val apply_fwdimps_of_goal : PPlan.T -> PPlan.gname -> (PPlan.gname list * PPlan.T) Seq.seq

  val apply_bckrules_of_goal : PPlan.T -> PPlan.gname -> (PPlan.gname list * PPlan.T) Seq.seq
  val apply_fwdrules_of_goal : PPlan.T -> PPlan.gname -> (PPlan.gname list * PPlan.T) Seq.seq
  val apply_rules_of_goal_pplan : PPlan.T -> PPlan.gname -> (PPlan.gname list * PPlan.T) Seq.seq 

  val apply_rules_of_goal : PPlan.gname -> RState.T -> (PPlan.gname list * RState.T) Seq.seq 

  (* for debugging *)
  val set_skels_i : ((PPlan.gname * Term.term) 
                     * RippleSkel.T option) list -> T -> T

  (* pretty printing *)
  val pretty_i : Proof.context -> T -> Pretty.T
  val pretty : RState.T -> PPlan.gname -> Pretty.T

  val print : RState.T -> PPlan.gname -> unit
  
  val pretty_skels_i : Proof.context -> T -> Pretty.T
  val pretty_skels : RState.T -> PPlan.gname -> Pretty.T
                              
                                                          
end;


(* Contextual information for Rippling *)
functor BasicRippleCInfoFUN (RippleSkel : RIPPLE_SKEL)
 : BASIC_RIPPLE_CINFO
= struct

  structure RippleSkel = RippleSkel;

  exception rippling_cinfo_exp of string;
  exception rippling_cinfo2_exp of ((PPlan.gname * Term.term) list  (* skel *)
                                    * Term.term); (* tgt *)


  (* FIXME: make a clear notion of uninitialised cinfo - otherwsie
  failure to initialise it will be hard to debug. *)
  datatype T = RCInfo of 
            {relgraph : ParamRGraph.T, (* relational rippling relation graph *)
            skels : ((PPlan.gname * Term.term) (* skeleton name and term *)
                     * RippleSkel.T option) (* anntotations etc for a skel *)
                      list};

  (*Construct a basic rcinfo, for use by other variants of rippleCInfo *)
  fun mk_rcinfo relgraph skels = 
      RCInfo{relgraph = relgraph, skels=skels};

(* Return the skeletons that currently embedd *)
  fun select_valid_skels skels = (* clever filter for option lists *)
      List.mapPartial I (map snd skels);

  fun skels_of_i (RCInfo rep) = select_valid_skels (#skels rep);
  fun get_relgraph_i (RCInfo rep) = (#relgraph rep);
  fun all_skels_of_i (RCInfo rep) = (#skels rep);

  fun update_skels_i f (RCInfo rep) = 
      RCInfo {skels = f (#skels rep), 
              relgraph = #relgraph rep};
  fun update_relgraph_i f (RCInfo rep) = 
      RCInfo {skels = #skels rep, 
              relgraph = f (#relgraph rep)};


(*
  fun update_arules_i f (RCInfo rep) = 
      RCInfo {skels = #skels rep, 
              relgraph = #relgraph rep,
              arules = f (#arules rep)};
*)

  val set_skels_i = update_skels_i o K;
  val set_relgraph_i = update_relgraph_i o K;

(* pretty printing *)
  fun pretty_skels_i ctxt d =
      (case (skels_of_i d) of 
        [] => Pretty.str "No valid skeletons."
       | l => Pretty.chunks (([Pretty.str "Skeleton Measures:"]) @ 
                             (map (RippleSkel.pretty ctxt) l)));


  fun pretty_relgraph_i d = 
      let val relgraph = (get_relgraph_i d)
      in if ParamRGraph.is_empty relgraph then 
           Pretty.str "No relations graph."
         else 
           Pretty.block 
             [Pretty.str "RelGraph: ",
              ParamRGraph.pretty relgraph]
      end;

  fun pretty_i ctxt d = 
      Pretty.chunks [pretty_skels_i ctxt d,
                     pretty_relgraph_i d];



  (* contextual info sturcture *)
(* Information associated with goals in reasoning states during rippling *)
structure I = 
  LocalInfoFUN( 
    struct
      type T = T;
      val name = "local rippleinfo:" ^ RippleSkel.name;
      val copy = I; (* copy is just Id as no refs *)
      val pretty = (fn d => fn rst => pretty_i (RState.get_ctxt rst) d); (* print only rules *)
    end
  );

  fun pretty_relgraph rst goal =
      pretty_relgraph_i (I.get rst goal);
  val print_relgraph =
      Pretty.writeln oo pretty_relgraph;
  fun pretty_skels rst goal =
      pretty_skels_i (RState.get_ctxt rst) (I.get rst goal);

  fun pretty rst goal  =
      pretty_i (RState.get_ctxt rst) (I.get rst goal);

 (* managing skeletons *)
  (* implicit T *)
  val skeleton_namedterms_of_i = 
      map RippleSkel.get_named_skel_term o skels_of_i; 
  val skeleton_namedterms_of = skeleton_namedterms_of_i oo I.get;
  val skeleton_names_of = (map fst) oo skeleton_namedterms_of;

  (* get relational rippling graph *)
  val get_relgraph = get_relgraph_i oo I.get;

  (* implicit: rst gname *)
  val skels_of = skels_of_i oo I.get;
  (* fun replace_skel oldskel newskel goal rst = 
      let 
        val oldskels = skeleton_names_of rst goal;
        val filtered_oldskels = filter (fn h => (h = oldskel)) oldskels;
      in *)
        
        
  val all_skels_of = all_skels_of_i oo I.get;

  val measures_of_i = maps RippleSkel.get_measures o skels_of_i;
  fun measures_of rst gname = 
      case (I.get_opt rst gname) of 
        NONE => []
      | SOME info => measures_of_i info;

  fun has_embedding rst gname = 
      Option.isSome (I.get_opt rst gname);

  val embeddings_of_i = 
      maps RippleSkel.get_embeddings o skels_of_i;
  fun embeddings_of rst gname = 
      case (I.get_opt rst gname) of 
        NONE => []
      | SOME info => embeddings_of_i info;


  (* Return a version of this skeleton with sinks instantiated to
   their current contents. Might get multiple src terms, only give
   back one of each for each skeleton.*)
  fun inst_skels_terms rst gname =
      maps (map Embed.src o RippleSkel.get_embeddings) 
           (skels_of rst gname)
           |> Library.distinct (fn (skl1,skl2) => Trm.trm_name_eq skl1 skl2);

  (* all skels are blocked w.r.t all possible new skels. *)
  fun blocked1_chk_i d nextds = 
      let val sts = maps skels_of_i nextds
          val curskels = skels_of_i d
      in List.all (fn st => RippleSkel.blocked_chk st sts)
                  curskels
      end;

  (* A rst is blocked if every child goal of every child-rst is
     blocked. *)

  (* Assume applied on the output! - I don't think the wire is really necessary!! *)


  fun blocked_chk rst goal rsts =
      let (* Get the ripplecinfos of the subgoals that are rippling them. 
             Can can ignore goals that have any ripple info *)
        fun infolist (gs,rst) = map_filter (I.get_opt rst) gs;
        fun check_empty ([],rst) = true
         |  check_empty  _  = false         
      in 
        (not (* no solved state *)
           (List.exists check_empty rsts)) (* solved *)
        andalso 
        (List.all (* no states or all states do not ripple *)
           (fn st => (blocked1_chk_i (I.get rst goal) (infolist st)))
            rsts)
      end;

(*
  fun blocked_chk rst wire goal rsts =
      let (* Get the ripplecinfos of the subgoals that are rippling them. 
             Can can ignore goals that have any ripple info *)
        fun infolist rst = 
           rst |> RState.get_outputs
               |> GoalNode.get_matching_gnodes wire
               |> GNode.get_all_goals
               |> Goaln.NSet.list_of
               |> map_filter (I.get_opt rst);
        fun check_empty rst = (* was  (fn st => Goaln.NSet.is_empty (RState.get_names_of_wire st wire)) *)
           rst |> RState.get_outputs
               |> GoalNode.get_matching_gnodes wire
               |> GNode.GoalSet.is_empty              
      in 
        (not (* no solved state *)
           (List.exists check_empty rsts)) (* solved *)
        andalso 
        (List.all (* no states or all states do not ripple *)
           (fn st => (blocked1_chk_i (I.get rst goal) (infolist st)))
            rsts)
      end;
*)


  (* check to see if we are rippling ie have some skeleton that embeds *)
  (* implicit T *)
  val is_valid_ripple_state_i = not o null o skels_of_i;
  fun is_valid_ripple_state_goal rst goal = 
      case (I.get_opt rst goal) of
        NONE => false
      | SOME ripple_info => is_valid_ripple_state_i ripple_info;
  fun some_curgoal_is_ripple_valid wire rst = (* GG: changed for graphdev *)
    rst |> RState.get_outputs
        |> GoalNode.get_matching_gnodes wire
        |> GNode.get_all_goals
        |> Goaln.NSet.exists (is_valid_ripple_state_goal rst); 
        (* RstPP.forsome is_valid_ripple_state_goal; *)

  (* Checks if this state has any skeletons, regardless of if they embedd *)
  val is_rippling_i = not o null o all_skels_of_i;
  fun is_rippling rst goal = 
      case (I.get_opt rst goal) of
        NONE => false
      | SOME ripple_info => is_rippling_i ripple_info;
  fun some_curgoal_is_rippling wire rst = (* GG: changed for graphdev *)
    rst |> RState.get_outputs
        |> GoalNode.get_matching_gnodes wire
        |> GNode.get_all_goals
        |> Goaln.NSet.exists (is_rippling rst); 
        (* RstPP.forsome is_rippling; *)

  (* check to see if any skeleton has been rippled out
  completely, if so we can apply that assumption and solve the goal. *)
  (* implicit T *)
  val success_chk_i = 
     List.exists RippleSkel.success_chk o skels_of_i;
  fun success_chk rst goal = success_chk_i (I.get rst goal); 

  (* get applicable critics during rippling, eg case-splitting *)

(* GG: changes for graphdev *)
  fun applicable_critics_of rst goal = [];
(*
  fun applicable_critics_of rst goal = 
      if (SplitterRTechn.is_if rst goal) then 
        [SplitterRTechn.split_if_rtechn]
      else [];
*)

  (* get the applicable rules *) 

  fun lookup_substs_of_goal pplan gname = 
    let
      val t = Prf.get_ndname_ctrm pplan gname (* Term.term vs Trm.t ?? *)
      val db = WRulesGCtxt.get_sub_from_ctxt (PPlan.get_context pplan)
     in 
       Substset.match db t
     end;

  fun lookup_bckimps_of_goal pplan gname = 
    let
      val t = Prf.get_ndname_ctrm pplan gname (* fixme: Term.term vs Trm.T *)
      val db = WRulesGCtxt.get_bck_from_ctxt (PPlan.get_context pplan)
    in 
      Bckimpset.match db t
    end;

  fun lookup_fwdimps_of_goal pplan gname = 
    let
      val t = Prf.get_ndname_ctrm pplan gname
      val db = WRulesGCtxt.get_fwd_from_ctxt (PPlan.get_context pplan)
    in
      Fwdimpset.match db t
    end

  (* FIXME: is g already in gs? -- now only gs returned, should g be returned too? *)
  fun apply_substs_of_goal pplan gname = 
     let 
       fun app_subst' (zip,rule) = Subst.apply_thm_at (Substset.thm_of_rule rule) false gname zip pplan
       val app_subst = Seq.map (fn ((g,gs),p) => (gs,p)) o app_subst' (* flattens the goals - not sure if this is a good idea! *)
     in
       Seq.maps app_subst (Seq.of_list (lookup_substs_of_goal pplan gname))
     end;

  fun apply_bckimps_of_goal pplan gname = 
    let 
      fun app_bckimp rule = Prf.apply_rule_thm (Bckimpset.thm_of_rule rule) gname pplan
    in
      Seq.maps app_bckimp (Seq.of_list (lookup_bckimps_of_goal pplan gname))
    end;

   fun apply_fwdimps_of_goal pplan gname = 
    let 
      fun app_fwdimp' rule = Prf.apply_frule_thm (Fwdimpset.thm_of_rule rule) gname pplan
      val app_fwdimp = Seq.map (fn (g,p) => ([g],p)) o app_fwdimp' (* to make all of same type *)
    in
      Seq.maps app_fwdimp (Seq.of_list (lookup_fwdimps_of_goal pplan gname))
    end;

   fun apply_bckrules_of_goal pplan gname =
     Seq.append (apply_substs_of_goal pplan gname) (apply_bckimps_of_goal pplan gname);

   fun apply_fwdrules_of_goal pplan gname =
      Seq.append (apply_fwdimps_of_goal pplan gname) (apply_substs_of_goal pplan gname);

  (* Fixme: (I think) this will wrongly classify a new fact as a goal in fwd rippling *)
  fun apply_rules_of_goal_pplan pplan gname  = 
      if Prf.is_open_goal pplan gname then 
        apply_bckrules_of_goal pplan gname 
      else apply_fwdrules_of_goal pplan gname;
   
  fun apply_rules_of_goal gname rst =
    let 
      fun upd_rst (a,pp) = (a,RState.set_pplan pp rst)
      val arules = apply_rules_of_goal_pplan (RState.get_pplan rst) gname
    in 
      Seq.map upd_rst arules
    end;  

  (* lists with one of each list of list of lists *)
  fun one_of_each [] = []
    | one_of_each [[]] = []
    | one_of_each [(h::t)] = [h] :: (one_of_each [t])
    | one_of_each ([] :: xs) = []
    | one_of_each ((h :: t) :: xs) = 
      (map (fn z => h :: z) (one_of_each xs)) 
      @ (one_of_each (t :: xs));

(* IMPROVE: optimise inclusion of RippleSkel, ie creating the list of
   skeleton embeddings... *)
(* Make a list of lists of all combinations of embeddings for the goals in the
   reasoning state. Create a new rst for each such combo.*)
  (* create the initial possible rippling contextual informations given the 
  skeletons (name, term) pairs and the target *)
  fun start  skels relgraph goal rst = 
    let 
      val pplan = RState.get_pplan rst
      val goalterm = Prf.get_ndname_ctrm pplan goal 
      val ectxt = Embed.Ectxt.init (PPlan.get_ienv pplan) relgraph;

      val skellists = one_of_each
    (* Produce lists of states for each skeleton and combine them *)
          (map (fn (n,t) =>
                   case RippleSkel.init {ectxt=ectxt, skelterm=t, 
                                         skelname=n, target=goalterm} 
     (* skeleton does not currently embedd *)
                    of [] => [((n,t), NONE)] 
                     | (l as _::_) => map (fn e => ((n,t), SOME e)) l) skels)
    
      (* Check if any skeleton embed..*)
      val _ = if null (filter (fn skel => case skel of NONE => false | SOME _ => true) 
                              (map snd (flat skellists)) ) then 
                (writeln "NONE of the skeletons embed into the goal!";
                 raise rippling_cinfo2_exp (skels,goalterm))
              else ();
    in
      (map (fn sts => RCInfo{ relgraph = relgraph,
                              skels = sts})
           skellists)
        |> Seq.of_list
        |> Seq.map (fn rcinfo => I.put (goal, rcinfo) rst) 
    end;

(* update *)
fun update_i (oldgname,oldskels) newgname rst = 
    let
      val pplan = RState.get_pplan rst;
      val newgoalterm = Prf.get_ndname_ctrm pplan newgname;
      val oldrelgraph = get_relgraph rst oldgname;
      val ectxt = Embed.Ectxt.init (PPlan.get_ienv pplan) 
                                   oldrelgraph;
    in 
      (select_valid_skels oldskels) (* only look at improvements to non-NONE embeddings 
                                       Looking at other could lead to non-term. *)
        (* filter: keep only mes decreasing skels *)
        |> (Library.map_filter 
              (fn s => 
                  case RippleSkel.mk_better_next ectxt newgoalterm s
                   of [] => NONE
                    | (l as _::_ ) => 
                      SOME (
                      map (fn e =>
                              (RippleSkel.get_named_skel_term e,
                               SOME e)) l)))
        |> one_of_each
        |> map (fn sts2 => RCInfo{relgraph=oldrelgraph,
                                  skels=sts2})
        (* filter out cases where nothing embeds *)
        |> List.filter is_valid_ripple_state_i
        |> Seq.of_list
        (*|> fn l => if null l then delete_RCInfo newgname 
                     delete if no embeddings *)
        |> Seq.map (fn rcinfo => I.put (newgname, rcinfo) rst)
    end;

fun update oldgname newgname rst = 
    update_i (oldgname,all_skels_of rst oldgname) newgname rst;

(* Update without filtering out non-measure decreasing skels*)
fun update_unrestricted_i (oldgname,oldskels) newgname rst = 
    let 
      val pplan = RState.get_pplan rst
       val newgoalterm = Prf.get_ndname_ctrm pplan newgname;
      val oldrelgraph = get_relgraph rst oldgname 
      val ectxt = Embed.Ectxt.init (PPlan.get_ienv pplan) oldrelgraph;

      (* Create embedding for this skeleton if it
         has any in the current target. *)
      fun does_embed (n,t) target =
          (case RippleSkel.init {ectxt=ectxt, skelterm=t,
                                 skelname=n,target=target} of 
               (* If this skeleton does not embedd at the moment *)
                 [] => [((n,t), NONE)] 
             | (l as _::_) => map (fn e => ((n,t), SOME e)) l);
    in
      oldskels
        |> (map (fn ((n,t), skel) => 
                    case skel 
                (* No previous embedding, check if embedds in new target *)
                     of NONE => does_embed (n,t) newgoalterm
                (* The skeleton did embed previously, get new skels *)         
                      | SOME skeleton => 
                        case RippleSkel.mk_all_next ectxt newgoalterm skeleton 
                         of [] => [((n,t), NONE)]        
                          | (l as _::_) => 
                            map (fn e => (RippleSkel.get_named_skel_term e,  
                                          SOME e)) l ))
        |> one_of_each
        |> map (fn sts2 => RCInfo {relgraph = oldrelgraph,
                                   skels = sts2})
        |> Seq.of_list
        |> Seq.map (fn rcinfo => I.put (newgname, rcinfo) rst)
        (*  no filter: keep all skels *)
    end;

fun update_unrestricted  oldgoal newgoal rst = 
    update_unrestricted_i (oldgoal,all_skels_of rst oldgoal) newgoal rst;

(* Update function that can call critic that modifies
   skeleton if no current skel embed. *)
val mes_order = RippleSkel.RippleMeasure.ord;
fun best_mes e = hd (Library.sort mes_order (RippleSkel.get_measures e));


val print = Pretty.writeln oo pretty;

end; (* struct *)

(* old stuff *)
(*

  (* lookup substitutions possible *)
  (* + make RTechn from rule *)
  (* fixme: turn stuff into rtechn : need to sort out wiring stuff first - one for each goal? i.e. no input? *)
  fun lookup_substs_i pplan gname = 
      let
        val t = Prf.get_ndname_ctrm pplan gname (* Term.term vs Trm.t ?? *)
        val db = WRulesGCtxt.get_sub_from_ctxt (PPlan.get_context pplan)
        val eqs = Seq.of_list (Substset.match db t)
        fun app_subst (zip,rule) = Subst.apply_thm_at (Substset.thm_of_rule rule) false gname zip pplan
                      (* returns ((Prf.gname * Prf.gname list) * Prf.T) Seq.seq *)
                (*  WRules.eqrule_zipper_lookup  db pplan gname (Zipper.mktop t) *)
      in Seq.maps app_subst eqs end;

  fun lookup_and_apply_substs out_wire gname rst0 =
      let val substs = lookup_substs_i (RState.get_pplan rst0) gname
          fun upd_rst ((g,gs),ppl) = RState.set_pplan ppl rst0
                                  |> RState.add_names_to_wire out_wire (Goaln.NSet.of_list (g::gs))
                                  |> RState.remove_single_name gname
      in Seq.map upd_rst substs end;

  (* need to turn into a rtechn -- one for each goal ?  *)
  fun lookup_bck_res_i pplan gname = 
      let
        val t = Prf.get_ndname_ctrm pplan gname (* fixme: Term.term vs Trm.T *)
        val db = WRulesGCtxt.get_bck_from_ctxt (PPlan.get_context pplan)
        val imps = Seq.of_list (Bckimpset.match db t) (* WRules.imprule_concl_lookup db pplan gname t *)
        fun app_res rule = Prf.apply_rule_thm (Bckimpset.thm_of_rule rule) gname pplan 
                  (* returns (gname list * Prf.T) Seq.seq *)
                  (* alternative RTechnEnv.rule_wire *)
      in Seq.maps app_res imps end;

  fun lookup_and_apply_bck_res out_wire gname rst0 =
      let val bck_res = lookup_bck_res_i (RState.get_pplan rst0) gname
          fun upd_rst (gs,ppl) = RState.set_pplan ppl rst0
                                  |> RState.add_names_to_wire out_wire (Goaln.NSet.of_list gs)
                                  |> RState.remove_single_name gname
      in Seq.map upd_rst bck_res end;

  fun lookup_fwd_res_i pplan gname = 
      let
        val t = Prf.get_ndname_ctrm pplan gname
        val db = WRulesGCtxt.get_fwd_from_ctxt (PPlan.get_context pplan)
        (* do we assume that gname is a goal -- in that case we need to match with assumptions of gname *)
        val fwd_imps = Seq.of_list (Fwdimpset.match db t) (* fwd_imprule_prems_lookup db pplan gname t *)
        fun app_fres rule = Prf.apply_frule_thm (Fwdimpset.thm_of_rule rule) gname pplan
        (* returns (gname * Prf.T) Seq.seq *)
      in Seq.maps app_fres fwd_imps end; (* note return value fwd_imprule_prems_lookup in (old) WRules *)

  fun lookup_and_apply_fwd_res out_wire gname rst0 =
      let val fwd_res = lookup_fwd_res_i (RState.get_pplan rst0) gname
          fun upd_rst (g,ppl) = RState.set_pplan ppl rst0
                                  |> RState.add_names_to_wire out_wire (Goaln.NSet.single g)
                                  (* |> RState.remove_single_name gname *) (* should keep result *)
      in Seq.map upd_rst fwd_res end;

  (* lookup all rules and their aplication to the pplan. IMPROVE:
  rules should come from local contextual info: so we we can add to
  wave rules locally within a proof planning attempt *)
(*  fun lookup_bck_arules pplan gname = 
      let 
        val db = WRulesGCtxt.wrules_of_ctxt (PPlan.get_context pplan)
        val t = Prf.get_ndname_ctrm pplan gname
      in
        Seq.list_of
        (Seq.append (WRules.imprule_concl_lookup db pplan gname t)
                    (WRules.eqrule_zipper_lookup db pplan gname (Zipper.mktop t)))
      end;
*)

  fun lookup_bck_arules out_wire gname rst =
       Seq.append (lookup_and_apply_substs out_wire gname rst)
                  (lookup_and_apply_bck_res out_wire gname rst)

  (* lookup all rules and their aplication to the pplan. IMPROVE:
  rules should come from local contextual info: so we we can add to
  wave rules locally within a proof planning attempt *)
(*  fun lookup_fwd_arules pplan gname = 
      let 
        val db = WRulesGCtxt.wrules_of_ctxt (PPlan.get_context pplan)
        val t = Prf.get_ndname_ctrm pplan gname
      in
        (map (fn (imprule,(subgoals,pplan)) => 
                 DTac.mk ((fn ctxt => WRules.pretty_fwd_impwrule_sml ctxt imprule), 
                          K (Seq.single (([],subgoals),pplan))))
             (Seq.list_of 
                (WRules.fwd_imprule_prems_lookup db pplan gname t)))
         @ 
         ((Seq.list_of (WRules.eqrule_zipper_lookup 
                              db pplan gname (Zipper.mktop t))))
      end;
*)

   val lookup_fwd_arules = lookup_and_apply_fwd_res;

(*
  fun lookup_arules pplan gname = 
      if Prf.is_open_goal pplan gname then 
        lookup_bck_arules pplan gname
      else lookup_fwd_arules pplan gname;
*)
  fun lookup_arules out_wire pplan gname rst = 
      if Prf.is_open_goal pplan gname then 
        lookup_bck_arules out_wire gname rst
      else lookup_fwd_arules out_wire gname rst;

  (* fixme: change name and input/output *)
  fun lookup_arules_rtechn out_wire pplan gname = 
     RTechn.id |> RTechn.set_appf (lookup_arules out_wire pplan gname) 
*)
