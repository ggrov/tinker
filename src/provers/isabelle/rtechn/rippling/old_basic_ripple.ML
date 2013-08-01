signature BASIC_RIPPLE = 
sig
end

structure BasicRipple = 
struct
  exception ripple_exp of string;

  structure RippleInfo = 
  struct
    val skel = Unsynchronized.ref NONE (* restore the skeleton if current rippling *);

    fun init_skel () = skel := NONE;

    fun update_skel (t : term) = skel := SOME t;

    val subst_params : (int list * Substset.rule) list Unsynchronized.ref
    = Unsynchronized.ref []; (* store decreased measure to improve efficiency *)

    fun update_subst_params ll = subst_params := ll;
  end

  fun get_subst_params () = 
    case !(RippleInfo.subst_params) of [] => raise ripple_exp "[No buffered subst params]"
    | _ => !(RippleInfo.subst_params);

  fun gen_occl' l  i = if i > 0 then gen_occl' ([i] :: l)  (i - 1)  else l;

  val gen_occl = gen_occl' [];
    
  fun get_embeddings' nth ctxt hyps goal =
    let 
      val ienv = (InstEnv.init ctxt);
      val ectxt = Embed.Ectxt.init ienv ParamRGraph.empty
    in
      map (fn hyp => (hyp, Embed.embed ectxt hyp goal)) hyps
      |> filter (fn (_, y) => length (Seq.list_of y) > 0) (* filter out which don't have any embeddings *)
      |> (fn l => 
        if length l > nth 
        then (List.nth (l,nth)) 
        else raise ripple_exp "[no embedded hyp is found]")
    end;

  fun is_hyps_embedd ctxt hyps goal = 
    get_embeddings' 0 ctxt hyps goal
    |> (fn x => (RippleInfo.update_skel (fst x); x))
    |> (fn _ => true)
  handle _ => (RippleInfo.init_skel () ; false);

  fun get_decreased_measures ctxt skel old_gterm new_gterm = 
    let
      val ienv = (InstEnv.init ctxt);
      val ectxt = Embed.Ectxt.init ienv ParamRGraph.empty;
      val old_embeding = Embed.embed ectxt skel old_gterm |> Seq.list_of;
      val new_embedding = Embed.embed ectxt skel new_gterm |> Seq.list_of
    in
      FlowMeasure.better_next_measures (FlowMeasure.init_measures old_embeding) new_embedding
    end;
    
  fun is_measure_decreased ctxt skel old_gterm new_gterm =  
    case get_decreased_measures ctxt skel old_gterm new_gterm |> FlowMeasure.Col.list_of of [] => false
      | _ => true;
 
  (* return a list of pair of rule and occ to subst *)
  fun get_decreased_measure_params ctxt skel matches gtrm = 
    let
      val matches' = map (fn (x,y) => (gen_occl x, y)) matches; (* occs -> occL *)
      val gthm = Thm.cterm_of (Proof_Context.theory_of ctxt) gtrm |> Thm.trivial;
      fun filter_valid_occ (occL, rule) = 
        let
          val thm = Substset.thm_of_rule rule;
          val possL = 
            map
            (fn occ => 
              (EqSubst.eqsubst_tac ctxt occ [thm] 1 gthm (* apply eqsubst to get the next goal term *)
              |> Seq.list_of |> hd (* only pull the first, very hacky, but works *)
              |> Thm.prems_of |> hd (* get the substed goal term *)
              |> (fn x => ((occ, rule), x)))) (* pair with the occ and rule info for further use *)
            occL;
        in
         filter 
         (fn (_,y) => (is_measure_decreased ctxt skel gtrm y))
         possL
        end
    in
      maps filter_valid_occ matches'
      |> map fst
    end;

  fun has_measure_decreasing_rules ctxt skel matches gtrm = 
    let
      val l = get_decreased_measure_params ctxt skel matches gtrm;
      val _ = RippleInfo.update_subst_params l
    in
      case l of [] => false
        | _ => true
    end;
   
  fun ripple_tac ctxt i thm = 
    let 
      val params = get_subst_params ();
      fun pre_ripple_tac (occ, rule) =  
        EqSubst.eqsubst_tac ctxt occ [(Substset.thm_of_rule rule)] i thm |> Seq.hd |> Seq.single
    in 
      Seq.maps pre_ripple_tac (Seq.of_list params)
    end;
end;
