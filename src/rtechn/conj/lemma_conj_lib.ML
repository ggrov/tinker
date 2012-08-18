(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/lemma_conj_lib.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Conjecture a lemma library...

    USES: generalise_lib (for generalisaing)
    USES: TermLib (for various term utils)
   ???  USES: goal_utils (for various utils, eg nth)
    USES: TermConstLib (for checking constants in terms)
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* Observations of the proof state, depends on some logic delated
   stuff, ie pulling number of vars depends on having vars.
*)

signature LEMMA_CONJ =
sig

  (* Information specific to the conjetcuring in order to apply the
  conjectured lemma, eg generalisation kind, or symmetry *) 
  type appinfo 

  val mk_dthm : Proof.context -> appinfo -> string * Thm.thm -> DThm.T

  exception try_mk_eq_conj_exp of (InstEnv.T * Term.term);
  
  (* Conjecture a lemma and generate info on how to apply it once proved *)
  val conjs : PPlan.T
              -> Trm.TrmParams.T -> Term.term 
              -> (appinfo * (Trm.TrmParams.T * Term.term)) Seq.seq 

  (* given a lemma theorem and the application info, create a dtac
  to apply it, eg specialisation of a generalisation 
  val lemma_dtac : Context.theory -> (DThm.T * appinfo) -> DTac.T
*)

  (* The number of generalisations made so far *)
  val gen_counter : int Unsynchronized.ref

end; 


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature LEMMA_CONJ_DATA =
sig

val dest_rw : Term.term -> (Term.term * Term.term) option
val dest_eq_term : Term.term -> (Term.term * Term.term * Term.term) option
val mk_imp : Term.term * Term.term -> Term.term
val mk_eq : Term.term * Term.term -> Term.term
val mk_meta_eq : Term.term * Term.term -> Term.term

val mk_Trueprop : Term.term -> Term.term
val dest_Trueprop : Term.term -> Term.term

val try_mk_Trueprop : Term.term -> Term.term
val try_dest_Trueprop : Term.term -> Term.term
val try_dest_Goal : Term.term -> Term.term

val try_arg_cong_gen : InstEnv.T ->
                       (Term.term * Term.term * Term.term) -> 
                       (bool * Term.term * Term.term)

val arg_cong_attr : DThmAttr.T
val symmetric_attr : Context.generic -> DThmAttr.T

end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
functor LemmaConjLibFUN(Data : LEMMA_CONJ_DATA) 
(* : LEMMA_CONJ *)
= struct 

structure Data = Data;

datatype appinfo 
  = LemInfo of
    {sym : bool, (* rotated equation *)
     argcong : bool (* generalised with argument congruence  *)
    };

fun mk_dthm ctxt (LemInfo {sym,argcong}) (conjname, th) = 
    let val attrs = (if sym then [Data.symmetric_attr (Context.Proof ctxt)] else [])
                    @ (if argcong then [Data.arg_cong_attr] else []);
    in DThm.mk_i ((conjname, th), attrs) end;

(* global counter for statistics checking *)
val gen_counter = Unsynchronized.ref 0;

(* for Isabelle/HOL as we use Object logic ops = and --> we are
   essentially just doing a subsumption check that the lhs isn't in the
   rhs of the term when its treated as a rewrite rule. *)
fun non_simp_looping typsg tm = 
      case Data.dest_rw tm of 
        (SOME(l, r)) => Pattern.matches_subterm typsg (Logic.varify_global l, r)
      | NONE => true;

(* first term contains the second in some name convertable way: Vars
and Frees can match up to other vars and Frees as long as there is a
name iso-morphism (bijection) *)
fun term_contains1 (Bs, FVs) (Abs(s,ty,t)) (Abs(s2,ty2,t2)) =
      if ty = ty2 then
        term_contains1 ((SOME(s,s2,ty)::Bs), FVs) t t2
      else []

  | term_contains1 T t1 (Abs(s2,ty2,t2)) = []

  | term_contains1 (Bs, FVs) (Abs(s,ty,t)) t2 =
    term_contains1 (NONE::Bs, FVs) t t2

  | term_contains1 T (ah $ at) (bh $ bt) =
    (term_contains1 T ah (bh $ bt)) @
    (term_contains1 T at (bh $ bt)) @
    (List.concat (map (fn inT => (term_contains1 inT at bt))
               (term_contains1 T ah bh)))

  | term_contains1 T a (bh $ bt) = []

  | term_contains1 T (ah $ at) b =
    (term_contains1 T ah b) @ (term_contains1 T at b)

  | term_contains1 T a b =
  (* simple list table lookup to check if a named variable has been
  mapped to a variable, if not adds the mapping and return some new
  list mapping, if it is then it checks that the pair are mapped to
  each other, if so returns the current mapping list, else none. *)
    let
      fun bterm_from t [] = NONE
        | bterm_from t ((a,b)::m) =
          if t = a then SOME b else bterm_from t m

  (* check to see if, w.r.t. the variable mapping, two terms are leaf
  terms and are mapped to each other. Note constants are only mapped
  to the same constant. *)
      fun same_leaf_check (T as (Bs,FVs)) (Bound i) (Bound j) =
          let
            fun aux_chk (i1,i2) [] = false
              | aux_chk (0,0) ((SOME _) :: bnds) = true
              | aux_chk (i1,0) (NONE :: bnds) = false
              | aux_chk (i1,i2) ((SOME _) :: bnds) =
                aux_chk (i1 - 1,i2 - 1) bnds
              | aux_chk (i1,i2) (NONE :: bnds) =
                aux_chk (i1,i2 - 1) bnds
          in
            if (aux_chk (i,j) Bs) then [T]
            else []
          end
        | same_leaf_check (T as (Bs,(Fs,Vs)))
                          (a as (Free (an,aty)))
                          (b as (Free (bn,bty))) =
          (case bterm_from an Fs of
             SOME b2n => if bn = b2n then [T]
                         else [] (* conflict of var name *)
           | NONE => [(Bs,((an,bn)::Fs,Vs))])
        | same_leaf_check (T as (Bs,(Fs,Vs)))
                          (a as (Var (an,aty)))
                          (b as (Var (bn,bty))) =
          (case bterm_from an Vs of
             SOME b2n => if bn = b2n then [T]
                         else [] (* conflict of var name *)
           | NONE => [(Bs,(Fs,(an,bn)::Vs))])
        | same_leaf_check T (a as (Const _)) (b as (Const _)) =
          if a = b then [T] else []
        | same_leaf_check T _ _ = []

    in
      same_leaf_check T a b
    end;

  (* wrapper for term_contains1: checks if the term "a" contains in
  some embedded way, (w.r.t. name -convertable) the term "b" *)
fun term_contains a b =
      case term_contains1 ([],([],[])) a b of
        (_ :: _) => true
      | [] => false;

exception try_mk_eq_conj_exp of (InstEnv.T * Term.term);

(* try to make an equality conjecture - if it is an equality then try
   to provide a normal form for the orientation. *)
fun try_mk_eq_conj ienv t = 
    (case Data.dest_eq_term t  
      of NONE => (LemInfo{ sym = false, argcong = false },t)
       | SOME (c,l,r) => 
         let
           val thry = (InstEnv.get_theory ienv)
           val (arg_cong, l', r') = Data.try_arg_cong_gen ienv (c,l,r);
            (* if arg cong, then we must use object level 
               equality reconstruction as types on left and right
                may have changed *)
           val mkeqf = if arg_cong then Data.mk_eq 
                      else (fn (l,r) => (c $ l) $ r);
           val (lv, rv) = (Logic.varify_global l', Logic.varify_global r');
           val (sym,conjt') = 
               if Pattern.matches_subterm thry (lv, r')
               then (true, mkeqf (r', l') )
               else if Pattern.matches_subterm thry (rv, l')
               then (false, mkeqf (l', r') )
               else if Term_Ord.term_ord (lv, rv) = LESS
               then (true, mkeqf (r', l'))
               else (false, mkeqf (l', r') )
         in (LemInfo{ sym = sym, argcong = arg_cong }, conjt') end)
   (*  handle *** _ => raise try_mk_eq_conj_exp (ienv, t); *)
;

(* create a generalisation from only the term we are trying to prove 
   and wraps it in a single element of a sequence *)
fun possible_gens_no_prems ctxt ptab t = 
      case (GeneraliseLib.gen_term ptab t) of 
        [] => Seq.empty
      | (g::gs) => Seq.single g;

(* make a generalisation from the premices and the conclusion *)
(* returns sequence of possible generalisations, in particular we 
   we check to see if we can make a generalisation from an 
   implication using an assumption, eg: 
      sorted (insort list) ==> sorted (ins a (insort list))
   give gen:
      sorted g --> sorted (ins a g)
 *)
fun possible_gens_from_prems ptab (prems, t) =  
    let 
      (* sequence of implication generalisations *)
      fun mk_imp_gens_seq t [] () = NONE
        | mk_imp_gens_seq t (tpremh::tpremt) () = 
          if (term_contains t tpremh) then (* only do for cases when prem exists in conlc, ie for induction case, where simp failed to unfold fully, ie left a new case same as prem *)
          case (GeneraliseLib.gen_term ptab (Data.mk_imp (tpremh, t))) of
            [] => (mk_imp_gens_seq t tpremt)()
          | ((ptab2,g)::gs) => SOME ((ptab2,g), 
                                     Seq.make (mk_imp_gens_seq t tpremt))
          else
            (mk_imp_gens_seq t tpremt)()
    in
      let 
        val impgenseq = Seq.make (mk_imp_gens_seq t prems)
      in
        case (GeneraliseLib.gen_term ptab t) of 
          [] => impgenseq
        | ((ptab2,g)::gs) => Seq.cons (ptab2, Data.mk_Trueprop g) impgenseq
      end
    end;


     
(* as above,  but arranged to avoid looping in simp *)
fun possible_gens_from_prems_and_no_loops typsg ptab (prems, t) = 
    let 
      (* sequence of implication generalisations *)
      fun mk_imp_gens_seq t [] () = NONE
        | mk_imp_gens_seq t (tpremh::tpremt) () = 
          if (term_contains t tpremh) then (* only do for cases when prem exists in conlc, ie for induction case, where simp failed to unfold fully, ie left a new case same as prem  *)
          case (GeneraliseLib.gen_term ptab (Data.mk_imp (tpremh, t))) of
            [] => (mk_imp_gens_seq t tpremt)()
          | ((ptab2,g)::gs) => 
            if non_simp_looping typsg g then 
              SOME ((ptab2,g), Seq.make (mk_imp_gens_seq t tpremt))
            else
              (mk_imp_gens_seq t tpremt)()
          else
            (mk_imp_gens_seq t tpremt)()
    in
      let 
        val impgenseq = Seq.make (mk_imp_gens_seq t prems)
      in
        case (GeneraliseLib.gen_term ptab t) of 
          [] => impgenseq
        | ((ptab2,g)::gs) => Seq.cons (ptab2, Data.mk_Trueprop g) impgenseq 
      end
    end;

(* drop premices, clean bound var stuff, and make a trueprop... *)
  fun cleaned_term_parts t =
      let
        val concl = Logic.strip_imp_concl t
        val prems = map Data.try_dest_Trueprop (Logic.strip_imp_prems t)
      in
        (prems, (Data.try_dest_Trueprop (Data.try_dest_Goal concl)))
      end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* including the term in the gens causes massive massive search
spaces!!! this is because you go in both a generalisation direcrtion
as well as a induction dir, and thus get lots of permutations of
orders of terms and a huge huge search spaciness. Would be nice to use
counter example finding tools. 
IMPROVE: clarify when and how to add Trueprop;
*)
fun conjs ppl ptab sgterm =  
  let 
    val ctxt = Prf.get_context ppl;
    val ienv = Prf.get_ienv ppl;

    val (subgoals_prems, subgoal_conc) = cleaned_term_parts sgterm;
    val gens_seq = Seq.map (fn x => (gen_counter := (! gen_counter) + 1; x))
                           (possible_gens_no_prems ctxt ptab subgoal_conc);

    fun prep_dir_Trueprop (ptab2,gt) = 
        let 
          val lt = MinimalRenameLib.rename_term gt
          val (d,lt2) = try_mk_eq_conj ienv lt
        in
          (d,(ptab2,Data.try_mk_Trueprop lt2))
        end;
  in 
    if InstEnv.is_ground (InstEnv.of_trm ctxt sgterm) then 
      Seq.map prep_dir_Trueprop
              (case Seq.pull gens_seq of
                 NONE => Seq.single (ptab,subgoal_conc)
               | SOME (h,t) => Seq.cons h t)
    (* IMRPOVE: what kind of conjecturing should we do if the 
       goal still has meta-vars? *)
    else Seq.empty
  end;

(* the tac to apply the conjectured lemma *)

(* fun lemma_dtac thry (dth, LemInfo rep) = 
    IsaDTac.Rule.rule 
      (DThm.add_attrs 
         dth ((if #sym rep then [Data.symmetric_attr thry] else []) @ 
              (if #argcong rep then [Data.arg_cong_attr] else []))); *)


end; (* structure *)
