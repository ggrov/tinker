(* extracts and checks properties of single terms *)

structure StrTable = Table(struct type key = string; val ord = String.compare end);

signature TERM_FEATURES =
sig
  (* projections to abstraction spaces *)
  val num_constants : term -> int StrTable.table
  val constants : term -> StrName.NSet.T
  val top_level_str : term -> string option
  val term_size : term -> int
  
  val get_numconstants_table : string -> int StrTable.table  -> int
  val get_numconstants : string -> term -> int

  (* predicates *)
  val is_first_order : term -> bool
  val is_top_level : string -> term -> bool
  (* ignores type!! *)
  val has_constant : string -> term -> bool
  val has_constant_times : string * int -> term -> bool
  val has_constant_max_times : string * int -> term -> bool
  val has_constant_min_times : string * int -> term -> bool
  val has_constants : string list -> term -> bool
  val has_meta_var : term -> bool


  (* comparing terms projections *)
  val simple_diff : term -> term -> (term * term) list
  val first_order_au : term -> term -> term

  (* comparing terms predicates *)
  val is_shape : theory -> term -> term -> bool
  val has_shape : theory -> term -> term -> bool

  val fo_au_match : theory -> term -> term -> bool
  val ctxt_embeds : Proof.context -> term -> term -> bool
  val embeds : theory -> term -> term -> bool


  val is_inductable_structural : theory -> term -> bool

  val has_measure_decreasing_rules : 
    Proof.context -> 
    (int * Substset.rule) list -> (* a list of numbers of occs and applicable wrule*)
    term -> (* goal term *)
    bool
  val is_subterm : 
    theory 
    -> term 
    -> term (* subterm *)
    -> bool 
  
  val fix_alls_in_term : term -> term
end (* sig *)

structure TermFeatures =
struct

  exception term_feature_exp of string

  val ignore_module = List.last o String.tokens (fn ch => #"." = ch) ;

 (* projections *)

  fun insert_tab tab str = 
    case StrTable.lookup tab str of
      NONE => StrTable.update (str,1) tab
     | (SOME v) => StrTable.update (str,v+1) tab;

  fun num_constants' tab (Const (str,_)) = insert_tab tab str
   |  num_constants' tab (Abs (_,_,t)) = num_constants' tab t
   |  num_constants' tab (a $ b) = num_constants' (num_constants' tab a) b
   |  num_constants' tab _ = tab;

  (* bag of constants *)
  val num_constants = num_constants' StrTable.empty;

  (* set of contants *)

  val ignore_consts = ["HOL.Trueprop","all","==>"]

  (* the actual constants *)
  val delete_ignore = fold StrName.NSet.delete ignore_consts;

  val constants = delete_ignore o StrName.NSet.of_list o StrTable.keys o num_constants;

  fun get_numconstants_table str tab =
    case StrTable.lookup tab str of
      NONE => 0
     | (SOME v) => v;    

  fun get_numconstants s t =
    t |> num_constants 
      |> get_numconstants_table s;

 fun top_level_str (Const (s,_)) = SOME (ignore_module s)
  | top_level_str ((Const ("all",_)) $ f) = top_level_str f
  | top_level_str ((Const ("prop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("HOL.Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("==>",_)) $ _ $ f) = top_level_str f
  | top_level_str (f $ _) = top_level_str f
  | top_level_str (Abs (_,_,t)) = top_level_str t
  | top_level_str _ = NONE;

 val term_size = Term.size_of_term;

 (* predicates *)

 val is_first_order = Pattern.first_order;

 fun is_top_level s t = case top_level_str t of
    NONE => false
  | (SOME v) => ((ignore_module v) = (ignore_module s));

 fun const_pred str (Const (s,_)) = ((ignore_module str) = (ignore_module s))
  |  const_pred _ _ = false;

 fun has_constant s = Term.exists_subterm (const_pred s);
 fun has_constants ss t = forall (fn s => has_constant s t) ss;
 val has_meta_var = Term.exists_subterm Term.is_Var

  fun has_constant_times (s,n) t = (get_numconstants s t = n);
  fun has_constant_max_times (s,n) t = (get_numconstants s t <= n);
  fun has_constant_min_times (s,n) t = (n <= get_numconstants s t);


  (* comparing terms projections *)

  (* $ case - maybe if all args are different the whole term should be given? *)
  fun simple_diff (t1 $ u1, t2 $ u2) = simple_diff (t1,t2) @ simple_diff (u1,u2)
   | simple_diff (Abs (_, _, t1), Abs (_, _, t2)) = simple_diff (t1,t2)
   | simple_diff (t1 as Const (a, _), t2 as Const (b, _)) = if a = b then [] else [(t1,t2)]
   | simple_diff (t1 as Free (x, _), t2 as Free (y, _)) = if x = y then [] else [(t1,t2)]
   | simple_diff (t1 as Var (xi, _), t2 as Var (yj, _)) = if xi = yj then [] else [(t1,t2)]
   | simple_diff (Bound i, Bound j) = if i = j then [] else [(Bound i, Bound j)]
   | simple_diff (x,y) = [(x,y)];

  fun first_order_au t1 t2 = FirstOrderAU.generalise (t1,t2);

  (* comparing terms predicates *)

  fun is_shape th t1 t2 = 
    Pattern.matches th (t1,t2);

  fun has_shape th shape t =
    Term.exists_subterm (fn st => Pattern.matches th (shape,st)) t

 fun inductable_things_in_term thry t = 
    let 
    fun add_term_frees (t, frees: term list) = case t of
      Free   _ => Ord_List.insert Term_Ord.term_ord t frees
      | Abs (_,_,body) => add_term_frees(body,frees)
      | f$t =>  add_term_frees (f, add_term_frees(t, frees))
      | _ => frees;
    fun term_frees t = add_term_frees(t,[]);
      val frees_of_term = map Term.dest_Free o term_frees;
      fun datatype_chk (Type(tn,_))  = 
           Basics.is_some (Datatype.get_info thry tn)
        | datatype_chk _ = false;
    in 
      List.partition (datatype_chk o snd) 
                     ((frees_of_term t) @ 
                      (Term.strip_all_vars t))
    end;

  fun is_inductable_structural th t = 
   not ((inductable_things_in_term th t |> fst) = []);

  fun fo_au_match th patt t = Pattern.matches th (patt,t);

(* Currently NOT in use ! but maybe interesting to try and improve efficiency

   To centerlise the feature testing, we need a buffer to store some info, i.e. sharing some data.
   Because some features are related, e.g. embedding and measurement decreasing (sharing skeleon info),
   it would be painful if we can pass some info from one feature-testing func to another.
   Moreover, some feature testing and tactic is hightly related, e.g. measure decreasing 
   and rippling (sharing the subst info). It can make evaluation more efficient. *)
  structure Data = 
  struct

    val skel = Unsynchronized.ref NONE (* restore the skeleton if current rippling *);
    fun init_skel () = skel := NONE;
    fun update_skel (t : term) = skel := SOME t;
    fun get_skel () =
      if !skel = NONE then raise term_feature_exp "[No buffered skel]"
      else (!(skel) |> (fn (SOME x) => x));
    

    val subst_params : (int list * Substset.rule) list Unsynchronized.ref
    = Unsynchronized.ref []; (* store decreased measure to improve efficiency *)
    fun update_subst_params ll = subst_params := ll;
    fun get_subst_params () = 
      case !(subst_params) of [] 
        => raise term_feature_exp "[No buffered subst params]"
      | _ => !(subst_params);

    fun pretty_subst_params (occ, rule) = 
      Pretty.block
      ["(" ^ (Int.toString (hd occ)) |> Pretty.str, 
        Pretty.str ", ",
        Substset.name_of_rule rule |> Pretty.str,
        Pretty.str ")"]
  end

  fun ctxt_embeds ctxt t1 t2 =
    let
     val ienv = InstEnv.init ctxt;
     val emb_ext = Embed.Ectxt.init ienv ParamRGraph.empty
     fun is_nempty_seq ss = 
      case Seq.pull ss of NONE =>  ((*Data.init_skel () ;*) false) 
      | _ => ((*Data.update_skel t1 ;*) true);
    in 
      Embed.embed emb_ext t1 t2 |> is_nempty_seq 
    end;

  val embeds = ctxt_embeds o Proof_Context.init_global

(* measurment for rippling *)
  fun gen_occl' l  i = if i > 0 then gen_occl' ([i] :: l)  (i - 1)  else l;
  val gen_occl = gen_occl' [];

  fun is_measure_decreased ctxt skel old_gterm new_gterm = 
    let
      val ienv = (InstEnv.of_trm ctxt skel);
      val ectxt = Embed.Ectxt.init ienv ParamRGraph.empty;
      val old_embeddings = Embed.embed ectxt skel old_gterm |> Seq.list_of;
      val new_embeddings = Embed.embed ectxt skel new_gterm |> Seq.list_of;
(*
      fun pretty_dsum (a,b) = 
        if a = NONE then Pretty.block [Pretty.str(Int.toString b), Pretty.str"_", Pretty.str "NONE"]
        else Pretty.block [Pretty.str(Int.toString b), Pretty.str"_", Pretty.str "SOME sink"];
*)
   (*  val _ =  Pretty.block [Pretty.str " skel - ",
                            (Syntax.pretty_term ctxt skel)] |> Pretty.writeln;
      val _ = Pretty.block [Pretty.str " next g - ",
                            (Syntax.pretty_term ctxt new_gterm)] |> Pretty.writeln;
      val _ = Pretty.block [Pretty.str " cur g - ", 
                            (Syntax.pretty_term ctxt old_gterm)] |>  Pretty.writeln;
*)
    in
      DB_DSumMeasure.is_better_mes new_embeddings old_embeddings
      (*FlowMeasure.better_next_measures  (FlowMeasure.init_measures old_embeddings) new_embeddings
      |> FlowMeasure.Col.list_of 
      |> length 
      |> (fn x => if x > 0 then (writeln (Int.toString x );writeln "is better! "; true) else ("NOT better! ";false))*)
    end

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
         (fn ((_,r),y) => ((*writeln ("Test measure on rule : "^ (Substset.name_of_rule r));*)
          is_measure_decreased ctxt skel gtrm y))
         possL
        end
    in
      maps filter_valid_occ matches'
      |> map fst
    end;

  fun has_measure_decreasing_rules ctxt skel matches gtrm = 
    let
      val l = get_decreased_measure_params ctxt skel matches gtrm;
      (*val _ = Data.update_subst_params l*)  (* TODO: in some future, maybe enable it to improve efficiency *)
    in
      case l of [] => ((*isar_tracing "no decreased measures";*) false)
        | _ => ((*isar_tracing "found decreased measures";*) true)
    end;

  (*fun has_measure_decreasing_rules' ctxt = has_measure_decreasing_rules ctxt (Data.get_skel())*)

  fun is_subterm thy src sub =
    let
      val ctrm = (Thm.cterm_of thy src);
      val maxid = (#maxidx (rep_cterm ctrm))
      val searchinfo = (thy, maxid, Zipper.mktop src) 
      val sub' = case sub of ((Const ("HOL.Trueprop",_)) $ f) => f | _ => sub
    in 
      EqSubst.searchf_lr_unify_valid searchinfo sub'
      |> Seq.flat |> Seq.pull
      |> (fn x => (case x of NONE => false | _ => true))
    end;

 (*  copy from isabelle 2012 which is not available from 2013, it's used to unbound/free variables *)
  fun fix_alls_in_term alledt = 
    let
      val t = Term.strip_all_body alledt;
      val alls = rev (Term.strip_all_vars alledt);
      val varnames = map (fst o fst o Term.dest_Var) (Misc_Legacy.term_vars t)
      val names = Misc_Legacy.add_term_names (t,varnames);
      val fvs = map Free 
                    (Name.variant_list names (map fst alls)
                       ~~ (map snd alls));
    in ((subst_bounds (fvs,t))) end;

  fun fix_alls_as_var alledt = 
    let
      val t = Term.strip_all_body alledt;
      val alls = rev (Term.strip_all_vars alledt);
      val varnames = map (fst o fst o Term.dest_Var) (Misc_Legacy.term_vars t)
      val names = Misc_Legacy.add_term_names (t,varnames);
      val vars = Name.variant_list names (map fst alls);
      fun gen_idx_l 0 = []
        | gen_idx_l n = (n -1)  :: (gen_idx_l (n-1)) 
      val idx_list = gen_idx_l (length vars)
      val fvs = map Var 
                    ((vars
                     ~~ (idx_list))
                       ~~ (map snd alls))
    in ((subst_bounds (fvs,t))) end;

end (* struct *)





