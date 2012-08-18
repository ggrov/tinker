(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfos/counterex_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
      
     Contextual information for holding counter examples to goals
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature COUNTEREX_CINFO = 
sig
  
  type T = (string * Term.term) list list

  structure I : LOCAL_INFO_ITEM

  val quickcheck : PPlan.gname -> RState.T -> RState.T
  val quickcheck_concl : PPlan.gname -> RState.T -> RState.T
  val quickcheck_term : Proof.context ->
                        Term.typ option * (* default type *)
                        (string * Term.typ) list -> (* var insts *)
                        Term.term -> 
                        (string * Term.term) list option
  (* Use QuickChek in batch mode *)
  val quickcheck_terms :  
      Proof.context ->
      Term.typ option * (* default type *)
      (string * Term.typ) list -> (* var insts *)
      Term.term list -> (* Terms to be checked *)
      ((string * Term.term) list option) list option
     
  val quickcheck_validate_terms :  
      Proof.context ->
      Term.typ option * (* default type *)
      (string * Term.typ) list -> (* var insts *)
      Term.term list -> (* Terms to be checked *)
      bool list option

  val default_codegen_params : Term.typ option
 
                              
  val timed_quickcheck : PPlan.gname -> RState.T -> Time.time -> RState.T
  val timed_quickcheck_concl : PPlan.gname -> RState.T -> Time.time -> RState.T
  val timed_quickcheck_term : Proof.context ->
                              Term.typ option * (* default type *)
                              (string * Term.typ) list -> 
                              Term.term -> 
                              Time.time -> 
                              (string * Term.term) list option

  val pretty_rst : PPlan.gname -> RState.T -> Pretty.T
  val print_rst : PPlan.gname -> RState.T -> unit

  val has_counterex : PPlan.gname -> RState.T -> bool

  val get : RState.T -> PPlan.gname -> T option
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure CounterExCInfo_DB 
= struct

(* the type of a cikkection of counter examples *)
type T = (string * Term.term) list list;

(* 
fun pretty_counterex ctxt NONE = Pretty.str "No counterexamples found."
  | pretty_counterex ctxt (SOME cex) =
      Pretty.chunks (Pretty.str "Counterexample found:\n" ::
        map (fn (s, t) =>
          Pretty.block [Pretty.str (s ^ " ="), Pretty.brk 1, Syntax.pretty_term ctxt t]) cex);
*)

fun pretty_counterex ctxt cex =
    Pretty.chunks
      ([Pretty.str "Counterexample:\n"] 
       @ ((map (fn (s, t) =>
                   Pretty.block [Pretty.str (s ^ " ="), Pretty.brk 1,
                                 Syntax.pretty_term ctxt t]) cex)));

val print_counterex = Pretty.writeln oo pretty_counterex;


(* counter examples stored with each goal in a proof plan *)
structure I = 
  LocalInfoFUN( 
    struct
      type T = (string * Term.term) list list
      val name = "counter-example";
      val copy = I;
      fun pretty cex rst = 
          Pretty.chunks 
            (map (pretty_counterex (RstPP.get_ctxt rst)) cex);
    end);


(* end of copied code *)
val default_codegen_params = SOME (Type("Int.int", []));
fun quickcheck_prep_term ctxt (default_type, tvinsts) trm = 
    let
      fun strip (Const ("all", _) $ Abs (_, _, t)) = strip t
        | strip t = t;
          
      val frees = map Free (Term.rename_wrt_term trm (Logic.strip_params trm))
    in
      Object_Logic.atomize_term 
        (ProofContext.theory_of ctxt) 
        (map_types
           (map_type_tfree 
              (fn p as (s, _) =>
                  the_default (the_default (TFree p) default_type)
                              (AList.lookup (op =) tvinsts s)))
           (subst_bounds (frees, strip trm)))     
    end;


(* FIXME: Check how much of this pre-processing of the term we actually
   have to do with the new version. *)
fun quickcheck_terms ctxt (default_type, tvinsts) ts =
   (* One of the booleans is now a timeout option. How do we set this timeout? *)
    (* Returns a pair, think the second is some sort of profiling *)
    fst (Quickcheck.test_terms 
           ctxt 
           (map (quickcheck_prep_term ctxt (default_type, tvinsts)) ts));

fun quickcheck_validate_terms ctxt (default_type, tvinsts) ts =
    fst (Quickcheck.validate_terms 
           ctxt 
           (map (quickcheck_prep_term ctxt (default_type, tvinsts)) ts));

fun quickcheck_term ctxt (default_type, tvinsts) t = 
    (* One of the booleans is now a timeout option. How do we set this timeout? *)
  Quickcheck.counterexample_of 
 (* As of Isabelle2011-1, for single term checking, need to give a compile generator
   as an argument. Don't need to do this for the batch processing for some reason *)
       (Quickcheck.test_term Exhaustive_Generators.compile_generator_expr 
                             ctxt (false,false) 
                             (quickcheck_prep_term ctxt (default_type, tvinsts) t,[]));

fun quickcheck gname rst = 
    (case quickcheck_term (RstPP.get_ctxt rst) 
                          (default_codegen_params, [])
                          (RstPP.goalterm_with_asms rst gname)
      of NONE => rst
       | SOME cex => 
         case I.get_opt rst gname 
          of NONE => I.put (gname,[cex]) rst
           | SOME L => I.put (gname,cex::L) rst);



(* Moa: Workaround to be able to check speculated lemmas as we get problems
with foralls in the assumptions otherwise. Obviously this isn't a good idea if the
lemma depends on any assumptions, but I don't think they do at the moment. *)
fun quickcheck_concl gname rst = 
  let 
     val goalt = RstPP.goal_concl rst gname
     fun check g = 
       (case quickcheck_term (RstPP.get_ctxt rst) 
                             (default_codegen_params, [])
                             g
         of NONE => rst
          | SOME cex => 
            case I.get_opt rst gname 
             of NONE => I.put (gname,[cex]) rst
              | SOME L => I.put (gname,cex::L) rst)
  in
    if (null (Trm.vars_of goalt)) then 
       check goalt    
    else (* Change meta-variables to fresh Frees *)
       let val (ptab', goalt') =
              Trm.foldmap_trm_vars 
              (fn  ptab => fn (((var_nm,i), var_ty), t) =>
                           let 
                           val (nw_n, nw_ptab) = Trm.TrmParams.add1 (var_nm,var_ty) ptab
                           in (nw_ptab, Trm.mk_free(nw_n,var_ty)) 
                           end)
               (Trm.params_of goalt) goalt
       in
         check goalt'
       end
  end;

fun timed_quickcheck_term ctxt quickcheck_params t timeOut =
    TimeLimit.timeLimit timeOut (quickcheck_term ctxt quickcheck_params) t
    handle TimeLimit.TimeOut => NONE;
fun timed_quickcheck gname rst timeOut = 
    TimeLimit.timeLimit timeOut (quickcheck gname) rst
    handle TimeLimit.TimeOut => rst;
fun timed_quickcheck_concl gname rst timeOut =
    TimeLimit.timeLimit timeOut (quickcheck_concl gname) rst
    handle TimeLimit.TimeOut => rst;

fun pretty_rst gname rst =
    (case I.get_opt rst gname of 
       NONE => Pretty.str "No couterexample"
     | SOME cex => I.pretty cex rst);

val print_rst = Pretty.writeln oo pretty_rst;

fun has_counterex gname rst = 
    (case I.get_opt rst gname of NONE => false | SOME cex => true);

val get = I.get_opt;


end; (* struct *)

structure CounterExCInfo : COUNTEREX_CINFO = CounterExCInfo_DB;
