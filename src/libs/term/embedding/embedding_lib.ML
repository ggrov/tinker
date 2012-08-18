(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/embedding_lib.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Embedding code using focus terms and generates a rich
    representation of the embeddings, and also keeps a name-matching
    table, so giving better (and stricter) matching criteria than old
    embeding_lib. We also are able to generate nice-ish looking terms
    for the embedding containing sinks, wavefronts and waveholes, by
    using the embedding_notaqtion theory.

    USES: FocusTermLib
    USES: TypeTreeTermsLib (for eta-expanding a term, in prepare_dest_term)
    USES: TermLib (for pretty printing, and try_dest_Trueprop)

*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* creates a nice syntax output for embedded terms + hack to restore
the original context
val tmp_context = the_context();
use_thy "embedding_notation";
context tmp_context;
*)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature EMBEDDING_LIB =
sig

datatype eterm = eApp of ((eterm * eterm) * TrmCtxt.T)
  | eAbs of ((string * Term.typ * eterm) * TrmCtxt.T)
  | eConst of ((string * Term.typ) * TrmCtxt.T)
  | eFree of ((string * Term.typ) * TrmCtxt.T)
  | eVar of (((string * int) * Term.typ) * TrmCtxt.T)
  | eBound of (int * TrmCtxt.T)
  | eSink of (((string * int) * Term.term) * TrmCtxt.T);

type T

exception embedding_term_exp of Term.term * Term.term;
exception embedding_exp of string

val embed : Term.term -> Term.term -> T Seq.seq

val embeddings : (string * Term.typ) option list * Term.typ list ->
       TrmCtxt.T -> Term.term * Term.term -> eterm list

val eterm_of_embedding : T -> eterm
val vtab_of_embedding : T -> Term.term list Vartab.table

val contains_sink : eterm -> bool

val wf_of_emb : T -> TrmCtxt.T
val wf_of_eterm : eterm -> TrmCtxt.T

val set_wf_of_emb : TrmCtxt.T -> T -> T
val set_wf_of_eterm : eterm -> TrmCtxt.T -> eterm

val prepare_dest_term : Term.term -> Term.term
val prepare_source_term : Term.term -> Term.term

val mk_term_of_wf : Term.typ list -> TrmCtxt.T -> Term.term -> Term.term

(* for pretty printing *)
val term_of_embedding : T -> Term.term
val pretty_embedding : Context.theory -> T -> Pretty.T
val pretty_embedding_in_ctxt : Proof.context -> T -> Pretty.T

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure DB_EmbeddingLib 
= struct 

exception embedding_exp of string;
exception embedding_dbg_exp of 
          {sbn : int, 
           bnds : (string * Term.typ) option list,
           bTs : Term.typ list,
           vtab : Term.term list Term.Vartab.table,
           wf : TrmCtxt.T, (* wave front part - bit that's different *)
           a : Term.term,
           b :  Term.term};


(* datatype for embedded terms, with the wave fronts attached, note
that sinks are an addiotnal leaf object *)
datatype eterm = eApp of ((eterm * eterm) * TrmCtxt.T)
  | eAbs of ((string * Term.typ * eterm) * TrmCtxt.T)
  | eConst of ((string * Term.typ) * TrmCtxt.T)
  | eFree of ((string * Term.typ) * TrmCtxt.T)
  | eVar of (((string * int) * Term.typ) * TrmCtxt.T)
  | eBound of (int * TrmCtxt.T)
  | eSink of (((string * int) * Term.term) * TrmCtxt.T);

fun wf_of_eterm (eApp(_,wf)) = wf
  | wf_of_eterm (eAbs(_,wf)) = wf
  | wf_of_eterm (eConst(_,wf)) = wf
  | wf_of_eterm (eBound(_,wf)) = wf
  | wf_of_eterm (eFree(_,wf)) = wf
  | wf_of_eterm (eVar(_,wf)) = wf
  | wf_of_eterm (eSink(_,wf)) = wf;

fun set_wf_of_eterm (eApp(e,w)) w2 = (eApp(e,w2))
  | set_wf_of_eterm (eAbs(e,w)) w2 = (eAbs(e,w2))
  | set_wf_of_eterm (eConst(e,w)) w2 = (eConst(e,w2))
  | set_wf_of_eterm (eBound(i,w)) w2 = (eBound(i,w2))
  | set_wf_of_eterm (eFree(e,w)) w2 = (eFree(e,w2))
  | set_wf_of_eterm (eVar(e,w)) w2 = (eVar(e,w2))
  | set_wf_of_eterm (eSink(e,w)) w2 = (eSink(e,w2));

fun add_wf_to_eterm wf (eApp(d,wf2)) = eApp(d,TrmCtxt.add_outerctxt wf wf2)
  | add_wf_to_eterm wf (eAbs(d,wf2)) = eAbs(d,TrmCtxt.add_outerctxt wf wf2)
  | add_wf_to_eterm wf (eConst(d,wf2)) = eConst(d,TrmCtxt.add_outerctxt wf wf2)
  | add_wf_to_eterm wf (eBound(d,wf2)) = eBound(d,TrmCtxt.add_outerctxt wf wf2)
  | add_wf_to_eterm wf (eFree(d,wf2)) = eFree(d,TrmCtxt.add_outerctxt wf wf2)
  | add_wf_to_eterm wf (eVar(d,wf2)) = eVar(d,TrmCtxt.add_outerctxt wf wf2)
  | add_wf_to_eterm wf (eSink(d,wf2)) = eSink(d,TrmCtxt.add_outerctxt wf wf2);

(* the type of an embedding is the variable table (for sinks?) 
   and the embedding term *)
type T = (Term.term list Vartab.table * eterm);

fun eterm_of_embedding ((tab,e) : T) = e;
fun vtab_of_embedding ((tab,e) : T) = tab;

fun direct_eterm_of_term (Abs (s,ty,t)) = 
    eAbs((s,ty, direct_eterm_of_term t),TrmCtxt.empty)
  | direct_eterm_of_term (a $ b) = 
    eApp((direct_eterm_of_term a, direct_eterm_of_term b), TrmCtxt.empty)
  | direct_eterm_of_term (Const x) = eConst (x,TrmCtxt.empty)
  | direct_eterm_of_term (Free x) = eFree (x,TrmCtxt.empty)
  | direct_eterm_of_term (Var x) = eVar (x,TrmCtxt.empty)
  | direct_eterm_of_term (Bound x) = eBound (x,TrmCtxt.empty);

fun contains_sink (eApp((e1,e2),w)) = contains_sink e1 orelse contains_sink e2
  | contains_sink (eAbs((a,ty,t),w)) = contains_sink t
  | contains_sink (eConst((s,ty),w)) = false
  | contains_sink (eBound(i,w)) = false
  | contains_sink (eFree((s,ty),w)) = false
  | contains_sink (eVar(((s,i),ty),w)) = false
  | contains_sink (eSink((ix,t),w)) = true;

(* get and set wave fronts (stored as upterms) for an embedding *)
fun wf_of_emb ((ntab,etrm) : T) = (wf_of_eterm etrm);
fun set_wf_of_emb wf ((ntab,etrm) : T) = 
  (ntab, set_wf_of_eterm etrm wf) : T;

fun merge_sinktabs (tab1, tab2) = 
    let 
      fun update ((k,l), tab) = 
          (case Vartab.lookup tab k of 
             NONE => Vartab.update (k,l) tab
           | SOME l2 => Vartab.update (k,l @ l2) tab)
    in
      foldr update tab2 (Vartab.dest tab1)
    end;

fun merge_emb (atab,a) (btab,b) = 
    (merge_sinktabs (atab, btab), eApp((a,b),TrmCtxt.empty));

(* combine two sequences of embeddings in every possible way with
first embedding being left side of application and second embedding
being the right side of application *)
fun combine_emb aseq bseq = 
    case (Seq.pull aseq) of
      NONE => Seq.empty
    | SOME (a,am) => 
      (case (Seq.pull bseq) of
         NONE => Seq.empty
       | SOME (b,bm) => 
         Seq.append 
           (Seq.cons (merge_emb a b)
                     (Seq.append (Seq.map (merge_emb a) bm)
                                 (Seq.map (fn a => merge_emb a b) am)))
           (combine_emb am bm)
      );


(* Embedding version 4 *) 

(* version 2 was based on HOAS, version 3 is based on the flattened syntax 
ie a left most leaf node can't be place right of its arguments!

Version 4 uses vars as sinks, thus avoiding all bound variable issues
(they must earlier be converted into var representation). "sbn" is the
number of ("SOME") related abstractions between the source and target
terms, this is used just for speed. "bnds" is the list of optional
abstarction relations, and "bTs" is the bound variables in the target
term. "vtab" is a table holding sink instantiations, and "wf" is the
current wave front as a term context. THINK ABOUT: do we want to
maintain a table to type-variable instantiations and also do type
embeddings? or do we want types to match/unify? Current we are strict:
we require types to be equal. *)

fun embeddings4 (sbn,bnds,bTs) vtab wf (a as Abs(s1,ty1,t1), Abs(s2,ty2,t2)) = 
    let 
      val subembeddings = embeddings4 (sbn,NONE::bnds,ty2::bTs) vtab 
                                      (TrmCtxt.add_abs (s2,ty2) wf) (a, t2)
    in
      if ty1 = ty2 then 
        Seq.append
          (Seq.map 
             (fn (tab, t) => (tab,eAbs((s2,ty2,t),wf)))
             (embeddings4 (sbn+1,(SOME(s2,ty2))::bnds, ty2::bTs) vtab 
                          TrmCtxt.empty (t1, t2)))
          subembeddings
      else subembeddings
    end

  | embeddings4 (sbn,bnds,bTs) vtab wf (at, (Abs(s,ty,bt))) = 
    embeddings4 (sbn,NONE::bnds,ty::bTs) vtab 
                (TrmCtxt.add_abs (s,ty) wf) (at, bt)

  | embeddings4 bnds vtab wf (a as (ah $ at), bh $ bt) = 
    let val h = (embeddings4 bnds vtab TrmCtxt.empty (ah, bh))
        val t = (embeddings4 bnds Vartab.empty TrmCtxt.empty (at, bt)) 
        val l = (embeddings4 bnds vtab (TrmCtxt.add_appr bt wf) (a, bh) ) 
        val r = (embeddings4 bnds vtab (TrmCtxt.add_appl bh wf) (a, bt) ) 
    in 
      Seq.append (Seq.map (set_wf_of_emb wf) (combine_emb h t))
                 (Seq.append l r)
    end

  | embeddings4 bnds vtab wf (ah $ at, b) = Seq.empty
                  
    (* leaf base cases *)
  | embeddings4 _ vtab wf (Var (v as (ix,_)), sunkt as Var _) = 
    let 
      val other_sunk_ts = case Vartab.lookup vtab ix of 
                            NONE => [] | SOME l => l
    in
      Seq.single (Vartab.update (ix, sunkt :: other_sunk_ts) vtab, 
                  add_wf_to_eterm wf (eVar(v,TrmCtxt.empty)))
    end
        
  | embeddings4 bnds vtab wf (Const (s1,ty1), Const (s2,ty2)) =  
    if s1 = s2 andalso ty1 = ty2 then  
      Seq.single (vtab, eConst((s2,ty2),wf))
    else Seq.empty

  | embeddings4 bnds vtab wf (Free(s1,ty1), Free(s2,ty2)) = 
    if s1 = s2 andalso ty1 = ty2 then  
      Seq.single (vtab, eFree((s2,ty2),wf))
    else Seq.empty 

  | embeddings4 (bnds as (sbn,bndl,bTs)) vtab wf 
                (a as Var(ix,ty1), b) = 
    if ty1 = Term.type_of1 (bTs, b) then 
      let 
        val sunkt = TrmCtxt.apply wf b 
        val other_sunk_ts = case Vartab.lookup vtab ix of 
                              NONE => [] | SOME l => l
      in
        Seq.single (Vartab.update (ix, sunkt :: other_sunk_ts) vtab,
                    eSink((ix,sunkt),TrmCtxt.empty))
      end
    else
      (case b of 
         bh $ bt => 
         let 
           val l = (embeddings4 bnds vtab (TrmCtxt.add_appr bt wf) (a, bh))
           val r = (embeddings4 bnds vtab (TrmCtxt.add_appl bh wf) (a, bt))
         in Seq.append l r end
       | _ => Seq.empty)

  | embeddings4 (bnds as (sbn,bndl,bTs)) vtab wf (a as (Bound i), b as Bound j) = 
    let 
       (* check is the source bound var i1 is embedded in the
           destination bound var i2 *)
      fun aux_chk (i1,i2) [] = false
        | aux_chk (0,0) ((SOME(s, ty)) :: bnds) = true
        | aux_chk (i1,0) (NONE :: bnds) = false
        | aux_chk (i1,i2) ((SOME _) :: bnds) =
          aux_chk (i1 -1,i2 - 1) bnds
        | aux_chk (i1,i2) (NONE :: bnds) =
          aux_chk (i1,i2 - 1) bnds 
    in if (aux_chk (i,j) bndl) then 
         Seq.single (vtab, eBound(j,wf))
       else Seq.empty end

  | embeddings4 bnds vtab wf (a, bh $ bt) = 
    let 
      val l = (embeddings4 bnds vtab (TrmCtxt.add_appr bt wf) (a, bh) )
      val r = (embeddings4 bnds vtab (TrmCtxt.add_appl bh wf) (a, bt) )
    in Seq.append l r end

   | embeddings4 _ _ _ _ = Seq.empty;


(* for debugging exceptions add something like this:
   handle TYPE _ => (raise embedding_dbg_exp
          {sbn = sbn, 
           bnds = bndl,
           bTs = bTs,
           vtab = vtab,
           wf = wf,
           a = a,
           b = b}) *)


fun try_dest_Trueprop (Const("HOL.Trueprop", _) $ T) = T
  | try_dest_Trueprop T = T;

(* prepare a term to be used as a source.  THINK ABOUT: do we want
this to be eta expanded? I think its OK not to do it as a non-eta
expanded term embeds into an eta expanded version. *)
fun prepare_source_term s = (try_dest_Trueprop) s;

(*  o (Term.map_term_types Type.unvarifyT) *)

(* unvarify, eta expand, and then change all bounds to frees *)
fun prepare_dest_term t =
    (TypedTermsLib.eta_expand
     o try_dest_Trueprop) t;

(*  o (Term.map_term_types Type.unvarifyT) *)


(* A simplified version fo embeddings -- with a more obvious
correspondence to the theory. The first list is bound vars and the
second is the option list that relates the embedding of bound vars in
the current context. wf is the wave front at this point in the term
tree. The first term is the skeleton/source and the second is the
erasure/target. This version does not give back a sink table - instead
you will have to extract this from the resulting embedding: this is a
function for computing the embedding term only! Also note it is not
lasy and results in a list, not a sequence.
*)

local 
(* combine two sequences of embeddings in every possible way with
first embedding being left side of application and second embedding
being the right side of application *)
fun merge_emb a b = eApp((a,b),TrmCtxt.empty);
fun combine_emb [] _ = []
  | combine_emb (h :: t) [] = []
  | combine_emb (a :: am) (b :: bm) = 
    ((merge_emb a b) :: 
     (map (merge_emb a) bm) @ 
     (map (fn a => merge_emb a b) am)) @ 
    combine_emb am bm;
in
  (* abs case *)
fun embeddings (bnds,bTs) wf (a as Abs(s1,ty1,t1), Abs(s2,ty2,t2)) = 
    (if ty1 = ty2 then 
      (map (fn t => eAbs((s2,ty2,t),wf)) 
         (embeddings ((SOME(s2,ty2))::bnds, ty2::bTs) 
                     TrmCtxt.empty (t1, t2))) 
     else [])
    @ (embeddings (NONE::bnds,ty2::bTs) (TrmCtxt.add_abs (s2,ty2) wf) (a, t2))
  | embeddings (bnds,bTs) wf (at, (Abs(s,ty,bt))) = 
    embeddings (NONE::bnds,ty::bTs) (TrmCtxt.add_abs (s,ty) wf) (at, bt)
  (* app case *)
  | embeddings bnds wf (a as (ah $ at), bh $ bt) = 
    let val h = embeddings bnds TrmCtxt.empty (ah, bh)
        val t = embeddings bnds TrmCtxt.empty (at, bt)
        val l = embeddings bnds (TrmCtxt.add_appr bt wf) (a, bh)
        val r = embeddings bnds (TrmCtxt.add_appl bh wf) (a, bt)
    in 
      ((map (fn e => set_wf_of_eterm e wf) (combine_emb h t)) @ (l @ r))
    end
  | embeddings bnds wf (ah $ at, b) = []
  (* leaf base cases *)
  | embeddings _ wf (Var v, Var _) = 
    [add_wf_to_eterm wf (eVar(v,TrmCtxt.empty))]
  | embeddings bnds wf (Const (s1,ty1), Const (s2,ty2)) =  
    if s1 = s2 andalso ty1 = ty2 then  
      [eConst((s2,ty2),wf)]
    else []
  | embeddings bnds wf (Free(s1,ty1), Free(s2,ty2)) = 
    if s1 = s2 andalso ty1 = ty2 then  
      [eFree((s2,ty2),wf)]
    else []
  | embeddings (bnds as (bndl,bTs)) wf (a as Var(ix,ty1), b) = 
    if ty1 = Term.type_of1 (bTs, b) then 
      [eSink((ix,TrmCtxt.apply wf b), TrmCtxt.empty)]
    else
      (case b of 
         bh $ bt => 
         let 
           val l = (embeddings bnds (TrmCtxt.add_appr bt wf) (a, bh))
           val r = (embeddings bnds (TrmCtxt.add_appl bh wf) (a, bt))
         in l @ r end
       | _ => [])
  | embeddings (bnds as (bndl,bTs)) wf (a as (Bound i), Bound j) = 
    let 
       (* check is the source bound var i1 is embedded in the
           destination bound var i2 *)
      fun aux_chk (i1,i2) [] = false
        | aux_chk (0,0) ((SOME(s, ty)) :: bnds) = true
        | aux_chk (i1,0) (NONE :: bnds) = false
        | aux_chk (i1,i2) ((SOME _) :: bnds) =
          aux_chk (i1 -1,i2 - 1) bnds
        | aux_chk (i1,i2) (NONE :: bnds) =
          aux_chk (i1,i2 - 1) bnds 
    in if (aux_chk (i,j) bndl) then [eBound(j,wf)] else [] end
  | embeddings bnds wf (a, bh $ bt) = 
    let 
      val l = (embeddings bnds (TrmCtxt.add_appr bt wf) (a, bh) )
      val r = (embeddings bnds (TrmCtxt.add_appr bh wf) (a, bt) )
    in l @ r end
  | embeddings _ _ _ = [];

end;(* local *)

exception embedding_term_exp of Term.term * Term.term;

(* embed term s in t, preparing both before hand *)
fun embed s t = 
    embeddings4 (0,[],[]) Vartab.empty TrmCtxt.empty 
                (prepare_source_term s, prepare_dest_term t)
    handle Term.TYPE _ => 
           raise embedding_term_exp (s,t);
    

(* OLD: creates free variables to represent wave fronts and wave holes *) 
(* NOW: creates consts defined in embedding_notation.thy which to
represent wave fronts and wave holes - this also has syntax for
diaplying them. *)
fun mk_term_of_wf T u t = 
    if TrmCtxt.is_empty u then t 
    else 
      let 
        val Ts = (rev (TrmCtxt.ty_ctxt u)) @ T
        val ty = Term.type_of1 (Ts, t)
        val t2 = Const("embedding_notation.wave_hole",ty --> ty) $ t
        val t3 = TrmCtxt.apply u t2
        val ty2 = Term.type_of1 (T, t3)
      in
        Const("embedding_notation.wave_front",ty2 --> ty2) $ t3
      end;


(* creates free variables to represent wave fronts and wave holes *)
(* fun mk_term_of_wf T TrmCtxt.empty t = t
  | mk_term_of_wf T u t = 
    let 
      val (bnds,tf) = FTerm.mk_termf_of_upterm u
      val Ts = (map (fn x => #2 x) (rev bnds)) @ T
      val ty = Term.type_of1 (Ts, t)
      val t2 = Free("wh",ty --> ty) $ t
      val t3 = tf t2
      val ty2 = Term.type_of1 (T, t3)
    in
      Free("wf",ty2 --> ty2) $ t3
    end;
*)

(* function that retruns bound vars (in right order) and a function
   to put a term into the context of an upterm. *)
fun bnds_and_termf_of_wf T wf =  
    if TrmCtxt.is_empty wf then (T, fn t => t)
    else 
      let val Ts = (rev (TrmCtxt.ty_ctxt wf)) @ T
      in
        (Ts, 
         (fn t => 
             let 
               val ty = Term.type_of1 (Ts, t)
               val t2 = Const("embedding_notation.wave_hole",ty --> ty) $ t
               val t3 = TrmCtxt.apply wf t2
               val ty3 = Term.type_of1 (T, t3)
             in
               Const("embedding_notation.wave_front",ty --> ty3) $ t3
             end)
        )
      end; 
    
fun mk_sink_of (ix, t, ty) = 
    Const("embedding_notation.sink" (*^ s ^ ""*),ty --> ty) $ t;
 
(* This can be used to change get a nice readable term-representation 
   of the embedding, with wave fronts, wave holes and sinks all annotated. *)

fun term_of_embedding_aux T (eApp((e1,e2),w)) = 
    let val (T2, wf) = bnds_and_termf_of_wf T w in
      wf((term_of_embedding_aux T2 e1) 
           $ (term_of_embedding_aux T2 e2))
    end
  | term_of_embedding_aux T (eAbs((s,ty,t),w)) = 
    let val (T2, wf) = bnds_and_termf_of_wf (ty::T) w in
      wf (Abs(s,ty,(term_of_embedding_aux T2 t)))
    end
  | term_of_embedding_aux T (eVar(((s,i),ty),w)) =  
    mk_term_of_wf T w (Var((s,i),ty))
  | term_of_embedding_aux T (eFree((s,ty),w)) =  
    mk_term_of_wf T w (Free(s,ty))
  | term_of_embedding_aux T (eBound(i,w)) =  
    mk_term_of_wf T w (Bound i)
  | term_of_embedding_aux T (eConst((s,ty),w)) =  
    mk_term_of_wf T w (Const(s,ty))
  | term_of_embedding_aux T (eSink((ix,t),w)) = 
    let 
      val (T2, wf) = bnds_and_termf_of_wf T w 
      (* val Tys = map (fn p => (#2 p)) T2 *)
    in
      wf (mk_sink_of (ix,t,Term.type_of1(T2, t))) 
    end;

fun term_of_embedding ((tab,etrm) : T) =
      (term_of_embedding_aux []) etrm;


(* pretty stuff *)
fun pretty_embedding thry = 
    Trm.pretty (ProofContext.init thry) o term_of_embedding;
fun pretty_embedding_in_ctxt ctxt = 
    Trm.pretty ctxt o term_of_embedding;


(* testing... 
open embedding_libS;

fun readwty tstr tystr = 
    let 
      val sgn = Theory.sign_of (the_context())
    in
      Sign.simple_read_term sgn (Sign.read_typ (sgn, K NONE) tystr) tstr
    end;

(** EXAMPLE Ordinals **)
use_thy "theories/O";
val skel = readwty "Zero + f (?x :: nat) = f ?x" "prop";
val gterm = readwty "(%n. Zero + f (n :: nat)) = f" "prop";
Seq.list_of (EmbeddingLib.embed skel gterm);

val skel = readwty "Zero + f (?x :: nat)" "O.Ord";
val gterm = readwty "(%n. Zero + f (n :: nat))" "nat => O.Ord";
Seq.list_of (EmbeddingLib.embed skel gterm);

val skel = readwty "(f :: nat => O.Ord) ?x" "O.Ord";
val gterm = readwty "f" "nat => O.Ord";
Seq.list_of (EmbeddingLib.embed skel gterm);


(**EXAMPLE 1**)
val trm = (read "(Q ((f (x::nat)) + (y::nat))) ==> (P ((sup (f :: nat => nat)) + (y :: nat)))");
val trm = (read "P ==> Q P");
val trm = (read "(ALL x. P (f x + y)) ==> P (sup f + y)");
TermLib.pp_term trm;

val s = hd (Logic.strip_imp_prems trm);
TermLib.pp_term s;
val (tab, source) = (mk_sinks_of NTab.empty s);

val t = (Logic.strip_imp_concl trm);
TermLib.pp_term t;
val es = Seq.list_of (embed s t);

val e = hd es;
TermLib.pp_term (term_of_embedding e);

val t2 = ((Free("sup", Type("fun", [Type("fun", [TFree("'a", ["HOL.type"]), TFree("'b", ["HOL.plus"])]), TFree("'b", ["HOL.plus"])]))) $ (Free("f", Type("fun", [TFree("'a", ["HOL.type"]), TFree("'b", ["HOL.plus"])]))));
val t2 = prepare_dest_term t2;

val s2 = ((Free("f", Type("fun", [TFree("'a", ["HOL.type"]), TFree("'b", ["HOL.plus"])]))) $ (Bound(0)));

val es = Seq.list_of (embeddings1 (0,[]) tab TrmCtxt.empty (s2, t2));
val e = hd es;
TermLib.pp_term (term_of_embedding e);

fun term_of_embedding (tab,etrm) =
    let val T = NTab.typ_list_of_sinks tab in
      (term_of_embedding_aux T) etrm
    end;




> > TermLib.writeterm s;
(Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
 ((Const("HOL.All", Type("fun", [Type("fun", [TFree("'a", ["HOL.type"]), Type("HOL.bool", [])]), Type("HOL.bool", [])]))) $
 (Abs("x",TFree("'a", ["HOL.type"]), 
  (Free("P", Type("fun", [TFree("'b", ["HOL.plus"]), Type("HOL.bool", [])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [TFree("'b", ["HOL.plus"]), Type("fun", [TFree("'b", ["HOL.plus"]), TFree("'b", ["HOL.plus"])])]))) $
 ((Free("f", Type("fun", [TFree("'a", ["HOL.type"]), TFree("'b", ["HOL.plus"])]))) $
 (Bound(0)))) $
 (Free("y", TFree("'b", ["HOL.plus"])))))))
val it = () : unit

> TermLib.writeterm t;
(Const("HOL.Trueprop", Type("fun", [Type("HOL.bool", []), Type("prop", [])]))) $
 ((Free("P", Type("fun", [TFree("'b", ["HOL.plus"]), Type("HOL.bool", [])]))) $
 (((Const("HOL.plus_class.plus", Type("fun", [TFree("'b", ["HOL.plus"]), Type("fun", [TFree("'b", ["HOL.plus"]), TFree("'b", ["HOL.plus"])])]))) $
 ((Free("sup", Type("fun", [Type("fun", [TFree("'a", ["HOL.type"]), TFree("'b", ["HOL.plus"])]), TFree("'b", ["HOL.plus"])]))) $
 (Free("f", Type("fun", [TFree("'a", ["HOL.type"]), TFree("'b", ["HOL.plus"])]))))) $
 (Free("y", TFree("'b", ["HOL.plus"])))))
val it = () : unit
> 


(* val s = (read "(f (x::nat)) + (y::nat)");
val t = (read "(sup (f :: nat => nat)) + (y :: nat)");*)
val es = Seq.list_of (embedding_libS.embed s t);

val e = hd es;
TermLib.pp_term (embedding_libS.term_of_eterm (#2 e));


(**EXAMPLE 2**)
val s = (read "ALL y. P ((f (x::nat)) + (y::nat))");
TermLib.pp_term s;
val t = (read "(P ::nat => bool) ((sup (f :: nat => nat)) + ((y :: nat) * z))");
TermLib.pp_term t;
TermLib.pp_term (focus_embeddingS.prepare_source_term s);
val e = Seq.hd (focus_embeddingS.embed s t);
TermLib.pp_term (focus_embeddingS.term_of_eterm (#2 e));
*)

end; (* struct *)


structure EmbeddingLib : EMBEDDING_LIB = DB_EmbeddingLib;
