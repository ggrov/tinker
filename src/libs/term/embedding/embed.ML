(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/embed.ML
    Authors:    Lucas Dixon, ldixon@inf.ed.ac.uk
                updated 1 Dec 2008
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Term Embeddings for difference annotation.

*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* PolyML.Compiler.debug := true; *)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature EMBED 
= sig

exception impossible_exp of string;
exception embedding_exp of string;

(* embedding context info *)
structure Ectxt : ECTXT
structure Em : SINT_NAME;
structure Wf : SINT_NAME;
sharing Em.Sharing = Ectxt.Em.Sharing
sharing Wf.Sharing = Ectxt.Wf.Sharing

type eterm = Ectxt.eterm;

type T (* result of a difference unification/embedding *)

exception embed_pretty_exp of T;

val embed : Ectxt.T
            -> Term.term -> Term.term (* embed first into second *)
            -> T Seq.seq; (* resulting embeddings *)

val get_ectxt : T -> Ectxt.T
val get_eterm : T -> eterm
val get_subs : T -> (Wf.name * TrmCtxt.T * eterm) Em.NTab.T
val get_sub : T -> Em.name -> Wf.name * TrmCtxt.T * eterm
val get_ienv : T -> InstEnv.T
val get_theory : T -> theory
val get_wfs : T -> TrmCtxt.T Wf.NTab.T
val get_wf : T -> Wf.name -> TrmCtxt.T
val contains_sink : eterm -> bool

val set_eterm : eterm -> T -> T

(* uninstantiated src and dest, upto alpha equiv (and type-inst?) *)
val src : T -> Term.term
val tgt : T -> Term.term

(* *) 
(* val abstracted_src : Zipper.T -> T -> Term.term *)

                                                            
(* for pretty printing *)
val mk_prettyterm : T -> Term.term

val pretty_ectxt_of : T -> Pretty.T
val print_ectxt_of : T -> unit

val pretty : T -> Pretty.T
val print : T -> unit

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure DB_Embed
= struct 

structure Em : SNAME = Ectxt.Em;
structure Wf : SNAME = Ectxt.Wf;
structure Ectxt : ECTXT = Ectxt;

structure Eterm : ETERM = Ectxt;
open Eterm;

(* the type of an embedding is the instantiation environemtn (for sinks & meta vars) 
and the embedding term *)
datatype T = Embedding of
           { ectxt : Ectxt.T, (* global context of embedding *)
             eterm : eterm (* embedding term *)
           };

fun get_eterm (Embedding rep) = #eterm rep;
fun get_ectxt (Embedding rep) = #ectxt rep;
val get_ienv = Ectxt.get_ienv o get_ectxt; 
val get_theory = Ectxt.get_theory o get_ectxt; 
val get_subs = Ectxt.get_subs o get_ectxt; 
val get_rels = Ectxt.get_rels o get_ectxt; 
val get_wfs = Ectxt.get_wfs o get_ectxt; 
val get_wf = Ectxt.get_wf o get_ectxt; 
val get_curwf = Ectxt.get_curwf o get_ectxt;
val get_bnds = Ectxt.get_bnds o get_ectxt;
val get_agenda = Ectxt.get_agenda o get_ectxt;

val get_ctxt = ProofContext.init_global o InstEnv.get_theory o get_ienv;
val get_sub = Em.NTab.get o get_subs;


fun update_ectxt f (Embedding rep) = 
    Embedding { ectxt = f (#ectxt rep), eterm = #eterm rep };
fun update_eterm f (Embedding rep) = 
    Embedding { ectxt = #ectxt rep, eterm = f(#eterm rep) };

val set_eterm = update_eterm o K;
val update_ienv = update_ectxt o Ectxt.update_ienv;
val update_subs = update_ectxt o Ectxt.update_subs;
val update_wfs = update_ectxt o Ectxt.update_wfs;
val update_rels = update_ectxt o Ectxt.update_rels;
val update_curwf = update_ectxt o Ectxt.update_curwf;
val update_bnds = update_ectxt o Ectxt.update_bnds;
val update_agenda = update_ectxt o Ectxt.update_agenda;

val set_agenda = update_agenda o K;


fun id_eterm_of_term (Abs (s,ty,t)) = 
    eAbs((s,ty, id_eterm_of_term t),NONE)
  | id_eterm_of_term (a $ b) = 
    eApp(id_eterm_of_term a, id_eterm_of_term b)
  | id_eterm_of_term (Const x) = eConst (x,NONE)
  | id_eterm_of_term (Free x) = eRelFree (((x,x),[]),NONE)
  | id_eterm_of_term (Var x) = eSrcVar (((x,[]),[],Var x), NONE)
  | id_eterm_of_term (Bound x) = eBound ((x,[]),NONE)

(* sinks are source vars *)
fun contains_sink (eApp (e1,e2)) = contains_sink e1 orelse contains_sink e2
  | contains_sink (eAbs ((_,_,t),_)) = contains_sink t
  | contains_sink (eConst _) = false
  | contains_sink (eBound _) = false
  | contains_sink (eIntoBound _) = false
  | contains_sink (eRelFree _) = false
  | contains_sink (eDestVar _) = false
  | contains_sink (eSrcVar _) = true;
  (* get and set wave fronts (stored as upterms) for top level of an embedding *)


(* source term of embedding, upto alpha and type instantiations *)
fun src e = 
    let 
      fun src' (eApp (e1,e2)) = (src' e1) $ (src' e2)
        | src' (eAbs ((s,ty,t),_)) = Abs (s,ty,src' t)
        | src' (eConst (d,_)) = (Const d)
        | src' (eBound ((d,_),_)) = (Bound d)
        | src' (eIntoBound ((en,_),_)) = src' (#3 (Em.NTab.get (get_subs e) en))
        | src' (eRelFree (((nty,_),_),_)) = Free nty
        | src' (eDestVar ((t,_,_),_)) = t
        | src' (eSrcVar (((ixty,ts),_,_),_)) = Term.list_comb (Var ixty,ts)
    in src' (get_eterm e) end;


exception impossible_exp of string;

(* terget term of an eterm *)
fun tgt e = 
    let 
      fun apply_wf (SOME wn) t = 
          TrmCtxt.apply (Wf.NTab.get (get_wfs e) wn) t
        | apply_wf NONE t = t;
      fun eterm_target' (et as eApp _) = raise impossible_exp "tgt:eterm_target'"
        | eterm_target' (eAbs ((s,ty,t),wf)) = Abs (s,ty,eterm_target t)
        | eterm_target' (eConst (d,wf)) = Const d
        | eterm_target' (eBound ((d,bnds),wf)) = Bound (Ectxt.target_of_src_bound bnds d)
        | eterm_target' (eIntoBound ((_,i),wf)) = Bound i
        | eterm_target' (eRelFree (((_,nty),_), wf)) = Free nty
        | eterm_target' (eDestVar ((_,_,(ixty,ts)),wf)) = Term.list_comb (Var ixty, ts)
        | eterm_target' (eSrcVar ((_,_,t),wf)) = t
      and eterm_target (et as eApp _) = 
          let val (eh,ets) = (Ectxt.dest_app et)
          in apply_wf (Ectxt.get_top_wf eh) 
                      (Term.list_comb (eterm_target' eh, map eterm_target ets))
          end
        | eterm_target et = 
          apply_wf (Ectxt.get_top_wf et) (eterm_target' et);
    in eterm_target (get_eterm e) end;


(* consturctors for embeddings from atomic eterms *)
fun mk_const ectxt sty = 
    let val (wf,ectxt2) = Ectxt.next_wf ectxt in 
      (Embedding {eterm = eConst(sty, wf), ectxt = ectxt2}) end;

fun mk_srcvar ectxt (v_and_args,bnds,sunkt) = 
    let val (wf,ectxt2) = Ectxt.next_wf ectxt in 
      (Embedding {eterm = eSrcVar((v_and_args,bnds,sunkt),wf), 
                  ectxt = ectxt2}) end;
    
fun mk_destvar ectxt (srct,bnds,v_and_args) = 
    let val (wf,ectxt2) = Ectxt.next_wf ectxt in 
    (Embedding {eterm = eDestVar((srct,bnds,v_and_args), wf),
                ectxt = ectxt2}) end;

fun mk_relfree ectxt rel = 
    let val (wf,ectxt2) = Ectxt.next_wf ectxt in 
    (Embedding {eterm = eRelFree (rel, wf),
                ectxt = ectxt2}) end;

fun mk_bnd ectxt (bnds, i, j) = 
    let val (wf,ectxt2) = Ectxt.next_wf ectxt in 
    (Embedding {eterm = eBound ((i, bnds), wf),
                ectxt = ectxt2}) end;

(* embedding t into j; j is bound in target wf, therefore t is added
   to agenda to be found elsewhere in the wave front. *)
fun mk_bnd_with_agenda ectxt wfn (t,j) = 
    let (* val (curwf,ectxt2) = Ectxt.next_wf ectxt *)
        val (em,ectxt2) = Ectxt.add_to_agenda (wfn,t) ectxt
    in Embedding {eterm = eIntoBound ((em,j), SOME wfn),
                  ectxt = ectxt2 }
    end;


(* add an asbtraction to an embedding *)
fun add_abs (s,ty) wf e = update_eterm (fn et => eAbs ((s,ty,et),wf)) e;
(* add application to embedding *)
fun add_app e e2 = update_eterm (fn et => eApp (get_eterm e,et)) e2;


(* Embedding *) 

(* ISSUES: 
"?x" --> "?y" 
is this a eSrcVar or a eDestVar? it's actually both. 

"(f ?x)" --> "?y" 
is ?x represented as a sink? or is it hidden in the eDestVar? 
*)

exception embedding_exp of string;

(* embedding atomic terms (heads of head normal form) *)
(* (sbn,bnds,bTs) = number of source types, source bound vars and relationship 
   of abstraction embeddings, target bound types *)
fun head_embeddings ectxt ((_$_), _) = 
    raise embedding_exp "impossible1: term1 not in head normal form"
  | head_embeddings ectxt  (_, (_$_)) = 
    raise embedding_exp "impossible2: term2 not in head normal form"
  | head_embeddings ectxt (Var _, _) = 
    raise embedding_exp "impossible3: term1 is var, should be dealt with in multi-case"
  | head_embeddings ectxt (_, Var _) = 
    raise embedding_exp "impossible4: term2 is var, should be dealt with in multi-case"
  | head_embeddings ectxt (a as Abs(s1,ty1,t1), Abs(s2,ty2,t2)) =
    let 
      val sub_ectxt = Ectxt.add_bnd_in_wf (s2,ty2) ectxt
      val sub_embeddings = 
          app_embeddings sub_ectxt ((a,[]), Term.strip_comb t2)
      val (curwf,ectxt2) = Ectxt.next_wf ectxt
    in
      case TypUnify.try_unify (ty1, ty2) (Ectxt.get_ienv ectxt2)
       of NONE => sub_embeddings
        | SOME (_,ienv1) => 
          Seq.append 
           (Seq.map
              (add_abs (s1,ty1) curwf)
              (app_embeddings (ectxt2 |> Ectxt.add_bnd_in_skel (ty1,ty2)
                                      |> Ectxt.set_ienv ienv1)
                              (Term.strip_comb t1, Term.strip_comb t2)))
           sub_embeddings
    end
  | head_embeddings ectxt (a as Abs _, _) = Seq.empty
  | head_embeddings ectxt (t, Abs(s2,ty2,t2)) = 
    app_embeddings (Ectxt.add_bnd_in_wf (s2,ty2) ectxt)
                   ((t,[]), Term.strip_comb t2)
  | head_embeddings ectxt (Const(s1,ty1), Const(s2,ty2)) =  
    if s1 = s2 then 
      case TypUnify.try_unify (ty1, ty2) (Ectxt.get_ienv ectxt) of 
        NONE => Seq.empty
      | SOME (_,ienv1) => Seq.single (mk_const (Ectxt.set_ienv ienv1 ectxt) (s2,ty2))
    else Seq.empty
  | head_embeddings ectxt (Free(s1,ty1),Free(s2,ty2)) =
    (case TypUnify.try_unify (ty1, ty2) (Ectxt.get_ienv ectxt) of 
       NONE => Seq.empty
     | SOME (_,ienv1) => 
       (case Ectxt.related_frees ectxt s1 s2
         of NONE => Seq.empty
          | SOME reldiff => 
            Seq.single (mk_relfree (Ectxt.set_ienv ienv1 ectxt) 
                                   (((s1,ty1),(s2,ty2)),reldiff))))
  | head_embeddings ectxt (Bound i,Bound j) = 
    if Ectxt.binders_embed ectxt i j 
    then Seq.single (mk_bnd ectxt (Ectxt.get_bnds ectxt,i,j))
    else Seq.empty
  | head_embeddings ectxt (t,Bound j) = 
    (case Ectxt.lookup_bnd_wf ectxt j 
      of NONE => Seq.empty
       | SOME n => 
         (* if bound is in cur wf, then embedding will be found by
            other app choices, so consider as empty for now *)
         if Wf.name_eq (n, Ectxt.get_curwf_name ectxt) then Seq.empty 
         else 
           (* check is we are a subembedding from a wf *)
           case Ectxt.get_fromwf ectxt 
            of NONE => (* we are top-level embedding, explore subembedding *)
               Seq.single (mk_bnd_with_agenda ectxt n (t,j))
             | SOME n2 => 
               (* if bound is from wave front of this subembedding *)
               if Wf.name_eq (n, n2) then Seq.empty
               else Seq.single (mk_bnd_with_agenda ectxt n (t,j)))
  | head_embeddings ectxt (_,_) = Seq.empty

(* comb case, embedding of two head-normal terms - flattened out applications *)
and app_embeddings ectxt ((_ $ _, _), _) = 
    raise embedding_exp "impossible5"
  | app_embeddings ectxt (_, (_ $ _, _)) =
    raise embedding_exp "impossible6"
  | app_embeddings ectxt (t1 as (Var v,a1s), t2 as (h2,a2s)) =
    let val src = Term.list_comb t1
        val sunkt = TrmCtxt.apply (snd (Ectxt.get_curwf ectxt)) 
                                  (Term.list_comb t2)
        val ectxt2 = Ectxt.clear_curwf ectxt
    in
      Seq.single (mk_srcvar ectxt ((v,a1s),Ectxt.get_bnds ectxt,sunkt))
    end
    (* ((Seq.map 
           (fn ienv2 => mk_srcvar (Ectxt.set_ienv ienv2 ectxt2) ((v,a1s),sunkt))
           (MyUnify.unifiers (Ectxt.get_ienv ectxt2,[(src,sunkt)]))))
     *)  
  | app_embeddings ectxt (t1 as (h1,a1s), t2 as (Var v,a2s)) =
    let val srcterm = Term.list_comb t1
        val dest = Term.list_comb t2
    in
      Seq.single (mk_destvar ectxt (srcterm, Ectxt.get_bnds ectxt, (v,a2s)))
(* Seq.map 
         (fn ienv2 => mk_destvar (Ectxt.set_ienv ienv2 ectxt) (srcterm, (v,a2s)))
         (MyUnify.unifiers (Ectxt.get_ienv ectxt,[(srcterm,dest)])) *)
    end
  | app_embeddings ectxt ((h1,[]), (h2,[])) = head_embeddings ectxt (h1,h2)
  | app_embeddings ectxt (t1, (h2,[])) =
    (case h2 of 
       (Abs(s,ty,t2)) => 
       app_embeddings (Ectxt.add_bnd_in_wf (s,ty) ectxt) 
                      (t1, Term.strip_comb t2)
     | _ => Seq.empty)
  | app_embeddings ectxt (t1 as (h1,a1s), t2 as (h2,a2s)) =
    Seq.append 
      (* embeddings with no wave front here; 
         FIXME: should be checking types, missing args count as bound vars 
                = eta-expansion on the fly. *) 
      (if length a1s = length a2s 
       then 
         let 
           fun next_app (a1,a2) e = 
               Seq.map (add_app e)
                       (app_embeddings 
                          (get_ectxt e) 
                          (Term.strip_comb a1, Term.strip_comb a2))
         in
           fold (* for each pair of args, need to have an argument embedding *)
             (Seq.maps o next_app)
             (a1s ~~ a2s)
             (head_embeddings ectxt (h1,h2))
         end
       else Seq.empty)
      (embed_into_some_subpos ectxt (t1, t2)) (* embeddings with a wave front here *)
and embed_into_some_subpos ectxt (t1 as (h1,a1s), t2 as (h2,a2s)) =
    let
      (* given some context, zip to each (application) position in term *)
      fun zipto_comb c (t1$t2) = 
          (TrmCtxt.add_appl t1 c, Term.strip_comb t2) :: 
          (zipto_comb (TrmCtxt.add_appr t2 c) t1)
        | zipto_comb [] atomict = []
        | zipto_comb c atomict = [(c, Term.strip_comb atomict)]
      val wf_choices = Seq.of_list
                         (zipto_comb TrmCtxt.empty (Term.list_comb t2))
    in
      Seq.maps
        (fn (wf,t2') => 
            Seq.maps
              solve_bnd_embedding_agenda
              (app_embeddings (Ectxt.addto_curwf wf ectxt) (t1,t2')))
        wf_choices
    end
(* for all terms that embed into bnd vars in a wave front, search for
   an embedding of the term somewhere in the wave front. 
   Assumes embedding is complete (has empty curwf)
*)
and solve_bnd_embedding_agenda e = 
    let 
      (* note: clever extension of parents ectxt as subs ectxt, we then
      pull back the old eterm and just update the subs. *)
      (* n is sub embedding name, e is super-embedding, all possible
         ways to embed t1 into some part of the wave front wf *)
      fun mk_sube e n t1 wfn (t2,wf) =
          Seq.map
            (fn sube => sube |> update_subs (Em.NTab.update 
                                               (n,(wfn,wf,get_eterm sube)))
                             |> set_eterm (get_eterm e))
            (app_embeddings (get_ectxt e |> Ectxt.set_fromwf wfn)
                            (Term.strip_comb t1, Term.strip_comb t2));

      (* all subparts of a wave front (where we might embed
         something else), with it's wave front context *)
      fun term_subparts_of_wf [] = []
        | term_subparts_of_wf ((TrmCtxt.D.Abs _) :: morewf) = 
          term_subparts_of_wf morewf
        | term_subparts_of_wf ((TrmCtxt.D.AppR t) :: morewf) =
          (t,morewf)::(term_subparts_of_wf morewf)
        | term_subparts_of_wf ((TrmCtxt.D.AppL t) :: morewf) = 
          (t,morewf)::(term_subparts_of_wf morewf);
    in
      case Em.NTab.pull_elem (get_agenda e)
       of NONE => Seq.single e
        | SOME ((n,(wfn,t)), a2) => 
          let (* wave front contents for bound term to be searched within *)
            val wf = Wf.NTab.get (get_wfs e) wfn;
          in
            (Seq.of_list (term_subparts_of_wf wf))
              |> Seq.maps (mk_sube (e |> set_agenda a2) n t wfn)
              |> Seq.maps solve_bnd_embedding_agenda
          end
    end;

fun check e = 
    (Thm.cterm_of (get_theory e) (src e); 
     Thm.cterm_of (get_theory e) (tgt e); ());

exception embed_exp of Ectxt.T * Term.term * Term.term;

(* embed term s in t, preparing both before hand *)
fun embed ectxt s t = 
    let 
      val thry = Ectxt.get_theory ectxt 
      val ctxt = ProofContext.init_global thry 
 (*      val _ = Pretty.writeln 
                (Pretty.chunks [
                 Pretty.block [Pretty.str "embed: ",
                               Trm.pretty ctxt s],
                 Pretty.block [Pretty.str " -> ",
                               Trm.pretty ctxt t]
                ]); *)
    in
    (* Seq.map (fn e => (check e; e)
                handle *** _ => raise embed_exp (ectxt, s, t)) *)
      (app_embeddings ectxt (Term.strip_comb (Pattern.eta_long [] s), 
                             Term.strip_comb (Pattern.eta_long [] t)))
    end;
(*     handle *** _ => raise embed_exp (ectxt, s, t) *)

(*     handle Interrupt => Dbg.exp (); *)



(* some embedding term tools *)

(* fast type of src, may be have type vars instantiated *)


fun fastype_of_src e = 
    Ectxt.fastype_of_eterm_src (get_ectxt e) ([],get_eterm e);

fun fastype_of e = 
    InstEnv.inst_typ_tvars 
      (get_ienv e)
      (Ectxt.fastype_of_eterm_src (get_ectxt e) ([],get_eterm e));


(* Pretty printing code *)

(* these are constants in the theory RippleNotation *)
val notation_wf = "EmbeddingNotation.embWF";
(* Note: wave holes are not strictly needed, but save pulling out
   funny abstractions that make the pretty print look big and ugly *)
val notation_wh = "EmbeddingNotation.embWH";
val notation_svar = "EmbeddingNotation.embSVar";
val notation_dvar = "EmbeddingNotation.embDVar";
val notation_relfree = "EmbeddingNotation.embRFree";
val notation_inbnd = "EmbeddingNotation.embInBnd";
 

(* This can be used to change get a nice readable term-representation 
   of the embedding, with wave fronts, wave holes and sinks all annotated. *)
fun mk_prettyterm e = 
    let 
      val ectxt = get_ectxt e;

      (* make an annotated term (for pretty printing) from a ctxt and a term *)
      fun prettytermf_in_wf typs NONE = (typs,I)
        | prettytermf_in_wf typs (SOME wfn) =
          let 
            val wf = Ectxt.get_wf ectxt wfn
            val wf_typs = TrmCtxt.ty_ctxt wf
            val all_typs = wf_typs @ typs
          in 
            (all_typs,
             (fn t => 
                 let 
                   (* Note: Doesn't Abs Bound vars, but does *)
                   val tty = Term.type_of1 (all_typs,t);
                   val wft = TrmCtxt.apply 
                               wf (Const(notation_wh,tty --> tty) $ t)
                   val wfty = Term.type_of1 (typs, wft)
                 in InstEnv.inst_trm 
                      (Ectxt.get_ienv ectxt)
                      (Const(notation_wf,wfty --> wfty) $ wft) 
                 end))
          end;
 
      (* for hd, wave front already dealt with, only pretty wave-hole part *)
      fun pretty_eterm1_hd T (eApp _) = 
          raise embedding_exp "mk_prettyterm.pretty_eterm1_hd: eApp"
        | pretty_eterm1_hd T (eAbs((s,ty,t),wf)) = 
          let val ty' = InstEnv.inst_typ_tvars (get_ienv e) ty
          in Abs(s,ty',pretty_eterm1 (ty'::T) t) end
        | pretty_eterm1_hd T (eConst(rep,wf)) = 
          InstEnv.inst_trm_typs (get_ienv e) (Const rep)
        | pretty_eterm1_hd T (eBound((i,bnds),wf)) = 
          Bound (Ectxt.target_of_src_bound bnds i)
        | pretty_eterm1_hd T (eIntoBound((en,i),wf)) =  
          let val ty = (Term.type_of1 (T,Bound i))
          in (Const(notation_inbnd, ty --> ty)) $ (Bound i) end
          (* FIXME: what about bounds in the tlist? 
             increment indices by wfs, maybe need to keep 
             track of indicies? *) 
        | pretty_eterm1_hd T (eSrcVar(((nty,tlist),bnds,t2),wf)) =  
          let 
            val srcvar = 
                InstEnv.inst_trm_typs 
                  (get_ienv e) 
                  (Ectxt.inc_term_src_bounds bnds (Term.list_comb (Var nty,tlist)))
            val t2' = InstEnv.inst_trm_typs (get_ienv e) t2
            val ty2 = Term.type_of1 (T, t2') 
            val ty1 = Term.type_of1 (T, srcvar)
          in (Const (notation_svar, ty1 --> ty2 --> ty2)) $ srcvar $ t2' end
        | pretty_eterm1_hd T (eDestVar((t1,bnds,(nty,tlist)),wf)) =  
          let val destvar = InstEnv.inst_trm_typs 
                              (get_ienv e) 
                              (Term.list_comb (Var nty,tlist));
              val t1' = InstEnv.inst_trm_typs 
                              (get_ienv e) 
                        (Ectxt.inc_term_src_bounds bnds t1);
              val ty = Term.type_of1 (T, t1');
          in (Const (notation_dvar, 
                     ty --> (Term.type_of destvar) --> ty))
               $ t1' $ destvar
          end
        | pretty_eterm1_hd T (eRelFree((((n, ty),(n2, ty2)), relinfo),wf)) =  
          InstEnv.inst_trm_typs 
            (get_ienv e) 
            (if n = n2 then Free (n,ty) else 
             (Const(notation_relfree,ty --> ty2 --> ty2))
               $ (Free (n,ty)) 
               $ (Free (n2,ty2)))

      and pretty_eterm1 T (et as eApp _) = 
          let val (eth,ett) = Ectxt.dest_app et
              val wfopt = Ectxt.get_top_wf eth
              val (T2,f) = prettytermf_in_wf T wfopt
          in f (Term.list_comb (pretty_eterm1_hd T2 eth, 
                                map (pretty_eterm1 T2) ett))
          end
        | pretty_eterm1 T (eAbs((s,ty,t),wf)) = 
          let val (T2,f) = prettytermf_in_wf T wf
              val ty' = InstEnv.inst_typ_tvars (get_ienv e) ty;
          in f (Abs(s,ty',pretty_eterm1 (ty'::T2) t)) end
        | pretty_eterm1 T (et as eIntoBound _) = pretty_eterm1_hd T et
        | pretty_eterm1 T et = 
          let val wfopt = Ectxt.get_top_wf et
              val (T2,f) = prettytermf_in_wf T wfopt
          in f (pretty_eterm1_hd T2 et) end
    in pretty_eterm1 [] (get_eterm e)
    end;


fun pretty_wf ctxt wf = 
    Trm.pretty 
      ctxt
      (Abs("HOLE", Type("HOL.bool", []), 
           TrmCtxt.apply wf 
                         (Bound (length (TrmCtxt.ty_ctxt wf)))));

fun pretty_sub e (wfn,wf,et) = 
    let val e' = set_eterm et e  
        val ctxt = ProofContext.init_global (InstEnv.get_theory (get_ienv e))
    in 
      Pretty.chunks 
        [Pretty.block [Pretty.str "Wfn: ", 
                       Wf.pretty_name wfn],
         Pretty.block [Pretty.str "Wf: ", pretty_wf ctxt wf],
         Pretty.block [Pretty.str "Eterm: ",
                       Trm.pretty (get_ctxt e') (mk_prettyterm e')]
        ]
    end;

fun pretty_ectxt_of e = 
    Pretty.chunks 
    [
     Pretty.block [Pretty.str "InstEnv: ", InstEnv.pretty (get_ienv e)],
     Pretty.block [Pretty.str "Subs: ", 
                   Em.NTab.pretty (pretty_sub e) (get_subs e)],
     Pretty.block [Pretty.str "RelGraph: ", ParamRGraph.pretty (get_rels e)]
    ];

  val print_ectxt_of = Pretty.writeln o pretty_ectxt_of;

exception embed_pretty_exp of T;

(* pretty stuff *)
fun pretty e = Trm.pretty (get_ctxt e) (mk_prettyterm e)
    (* handle *** _ => raise embed_pretty_exp e; *)

val print = Pretty.writeln o pretty; 

end; (* struct *)


structure Embed : EMBED = DB_Embed;

(* PolyML.Compiler.debug := false; *)
