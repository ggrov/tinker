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


end (* sig *)

structure TermFeatures =
struct

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
  val constants = StrName.NSet.of_list o StrTable.keys o num_constants;

  fun get_numconstants_table str tab =
    case StrTable.lookup tab str of
      NONE => 0
     | (SOME v) => v;    

  fun get_numconstants s t =
    t |> num_constants 
      |> get_numconstants_table s;

 fun top_level_str (Const (s,_)) = SOME s
  | top_level_str (f $ _) = top_level_str f
  | top_level_str (Abs (s,_,_)) = SOME s
  | top_level_str _ = NONE

 val term_size = Term.size_of_term;

 (* predicates *)

 val is_first_order = Pattern.first_order;

 fun is_top_level s t = case top_level_str t of
    NONE => false
  | (SOME v) => (v = s);

 fun const_pred str (Const (s,_)) = (str = s)
  |  const_pred _ _ = false;

 fun has_constant s = Term.exists_subterm (const_pred s);
 fun has_constants ss t = forall (fn s => has_constant s t);
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

(*
  fun ctxt_embeds ctxt t1 t2 =
    let
     val ienv = InstEnv.init ctxt;
     val emb_ext = Embed.Ectxt.init ienv ParamRGraph.empty
     fun is_nempty_seq ss = case Seq.pull ss of NONE => false | _ => true;
    in 
      Embed.embed emb_ext t1 t2 |> is_nempty_seq
    end;

  val embeds = ctxt_embeds o ProofContext.init_global
*)

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

end (* struct *)





