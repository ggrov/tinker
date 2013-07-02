(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/ectxt.ML
    Authors:    Lucas Dixon, ldixon@inf.ed.ac.uk
                updated 1 Dec 2008
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Contexts for embedding 

PolyML.Compiler.debug := true;
*)   

signature ECTXT 
= sig

  include ETERM;

  (* embedding context for an eterm; captures partial embedding status *)        
  type T
       
  val init : InstEnv.T -> ParamRGraph.T -> T

  val add_bnd_in_skel : Term.typ * Term.typ -> T -> T
  val add_bnd_in_wf : string * Term.typ -> T -> T
  val add_to_agenda : Wf.name * Term.term (* add: embed this term into wf *)
                      -> T 
                      -> (Em.name * T) (* embedding name placeholder *)
  val addto_curwf : TrmCtxt.T -> T -> T
  val binders_embed : T -> int -> int -> bool
  val clear_curwf : T -> T

  val wfname_of_bnd : T -> int -> Wf.name

  val lookup_bnd_wf : T -> int -> Wf.name option
  val next_wf : T -> Wf.name option * T
  exception no_such_binder_exp of T * int
  val related_frees :
      T -> Free.name -> Free.name -> (Free.name * Free.name) list option

  val fastype_of_eterm_src : T -> Term.typ list * eterm -> Term.typ

  (* change a bound var in src to one in tgt given the binding context *)
  val target_of_src_bound : bnd list -> int -> int
  (* incremenet binders in src appropriately for binding context *)
  val inc_term_src_bounds : bnd list -> Term.term -> Term.term

  (* gets *)
  val get_agenda : T -> (Wf.name * Term.term) Em.NTab.T
  val get_bnds : T -> bnd list
  val get_curwf : T -> Wf.name * TrmCtxt.T
  val get_curwf_name : T -> Wf.name
  val get_ienv : T -> InstEnv.T
  val get_theory : T -> theory
  val get_rels : T -> ParamRGraph.T
  val get_subs : T -> (Wf.name * TrmCtxt.T * eterm) Em.NTab.T
  val get_wfs : T -> TrmCtxt.T Wf.NTab.T

  val get_sub : T -> Em.name -> Wf.name * TrmCtxt.T * eterm
  val get_wf : T -> Wf.name -> TrmCtxt.T

  (* sets *)  
  val set_curwf : Wf.name * TrmCtxt.T -> T -> T
  val set_ienv : InstEnv.T -> T -> T
  val set_subs : (Wf.name * TrmCtxt.T * eterm) Em.NTab.T -> T -> T
  val set_wfs : TrmCtxt.T Wf.NTab.T -> T -> T

  (* fromwf is name of wave front we are a sub-embedding in *)
  val get_fromwf : T -> Wf.name option (* if subembedding, wfname *)
  val set_fromwf : Wf.name -> T -> T 
  val clear_fromwf : T -> T

  (* updates *)
  val update_agenda :
      ((Wf.name * Term.term) Em.NTab.T ->
       (Wf.name * Term.term) Em.NTab.T) -> T -> T
  val update_bnds : (bnd list -> bnd list) -> T -> T
  val update_curwf : (Wf.name * TrmCtxt.T -> Wf.name * TrmCtxt.T) -> T -> T
  val update_ienv : (InstEnv.T -> InstEnv.T) -> T -> T
  val update_rels : (ParamRGraph.T -> ParamRGraph.T) -> T -> T
  val update_subs : ((Wf.name * TrmCtxt.T * eterm) Em.NTab.T -> 
                     (Wf.name * TrmCtxt.T * eterm) Em.NTab.T) -> T -> T
  val update_wfs : (TrmCtxt.T Wf.NTab.T -> TrmCtxt.T Wf.NTab.T) -> T -> T

end;


structure DB_Ectxt
= struct

(* defines eterm data types *)
open DB_ETerm;

datatype T = Ectxt of
         { ienv : InstEnv.T, (* instantiations *)
           subs : (Wf.name 
                   * TrmCtxt.T (* the part of the wave front we are under *)
                   * eterm) Em.NTab.T, (* to sub eterms, with wf name it occurs in *)
           wfs : TrmCtxt.T Wf.NTab.T, (* wave front names -> trm ctxts *)
           rels : ParamRGraph.T, (* related frees/params *)
           (* temp info: used only for construction - ? make into a temp datatype? *)
           agenda : (Wf.name * term) Em.NTab.T, (* agenda of things needing to be embedded somewhere, 
                                      name space shared with subs *)
           bnds : bnd list, (* info about current binding context *)
           curwf : (Wf.name * TrmCtxt.T), (* next wf name and (maybe partial) content *)
           fromwf : Wf.name option (* SOME wfn, if subembedding is from within wfn *)
         };


fun init ienv rels = 
    Ectxt {ienv = ienv, 
           subs = Em.NTab.empty, 
           wfs = Wf.NTab.empty, 
           rels = rels, 
           bnds = [],
           curwf = (Wf.default_name, TrmCtxt.empty),
           agenda = Em.NTab.empty,
           fromwf = NONE};

fun get_ienv (Ectxt rep) = #ienv rep;
fun get_subs (Ectxt rep) = #subs rep;
fun get_wfs (Ectxt rep) = #wfs rep;
fun get_rels (Ectxt rep) = #rels rep;
fun get_bnds (Ectxt rep) = #bnds rep;
fun get_curwf (Ectxt rep) = #curwf rep;
fun get_fromwf (Ectxt rep) = #fromwf rep;
fun get_agenda (Ectxt rep) = #agenda rep;

val get_theory = InstEnv.get_theory o get_ienv;

val get_sub = Em.NTab.get o get_subs;
val get_wf = Wf.NTab.get o get_wfs ;

val get_curwf_name = fst o get_curwf;

fun update_ienv f (Ectxt rep) = 
    Ectxt {ienv = f (#ienv rep), subs = #subs rep, wfs = #wfs rep, 
           rels = #rels rep, curwf = #curwf rep, bnds = #bnds rep,
           agenda = #agenda rep, fromwf = #fromwf rep};
fun update_subs f (Ectxt rep) = 
    Ectxt {ienv = #ienv rep, subs = f(#subs rep), wfs = #wfs rep, 
           rels = #rels rep, curwf = #curwf rep, bnds = #bnds rep,
           agenda = #agenda rep, fromwf = #fromwf rep};
fun update_wfs f (Ectxt rep) = 
    Ectxt {ienv = #ienv rep, subs = #subs rep, wfs = f(#wfs rep), 
           rels = #rels rep, curwf = #curwf rep, bnds = #bnds rep,
           agenda = #agenda rep, fromwf = #fromwf rep};
fun update_rels f (Ectxt rep) = 
    Ectxt {ienv = #ienv rep, subs = #subs rep, wfs = #wfs rep, 
           rels = f(#rels rep), curwf = #curwf rep, bnds = #bnds rep,
           agenda = #agenda rep, fromwf = #fromwf rep};
fun update_curwf f (Ectxt rep) = 
    Ectxt {ienv = #ienv rep, subs = #subs rep, wfs = #wfs rep, 
           rels = #rels rep, curwf = f(#curwf rep), bnds = #bnds rep,
           agenda = #agenda rep, fromwf = #fromwf rep};
fun update_fromwf f (Ectxt rep) = 
    Ectxt {ienv = #ienv rep, subs = #subs rep, wfs = #wfs rep, 
           rels = #rels rep, curwf = #curwf rep, bnds = #bnds rep,
           agenda = #agenda rep, fromwf = f(#fromwf rep)};
fun update_bnds f (Ectxt rep) = 
    Ectxt {ienv = #ienv rep, subs = #subs rep, wfs = #wfs rep, 
           rels = #rels rep, curwf = #curwf rep, bnds = f(#bnds rep),
           agenda = #agenda rep, fromwf = #fromwf rep};
fun update_agenda f (Ectxt rep) = 
    Ectxt {ienv = #ienv rep, subs = #subs rep, wfs = #wfs rep, 
           rels = #rels rep, curwf = #curwf rep, bnds = #bnds rep,
           agenda = f (#agenda rep), fromwf = #fromwf rep};

(* sets *)
val set_ienv = update_ienv o K;
val set_curwf = update_curwf o K;
val set_subs = update_subs o K;
val set_wfs = update_wfs o K;

val set_fromwf = update_fromwf o K o SOME;
val clear_fromwf = update_fromwf (K NONE);

(* j is bound in some wf of ec, t is src term, add needing to find t
   in wfname to agenda *)
fun add_to_agenda wfn_and_t ec =
    let val (n, subs2) = Em.NTab.new_name Em.default_name (get_subs ec)
    in (n, ec |> update_agenda (Em.NTab.update_new (n,wfn_and_t))
              |> set_subs subs2)
    end;

exception no_such_binder_exp of T * int;

(* SOME wfname if i is bound in a wave front *)
fun lookup_bnd_wf ec i = 
    let 
      fun aux_chk 0 ((WfBinder (wfn,ty))::_) = SOME wfn 
        | aux_chk 0 ((SrcBinder ty1ty2)::_) = NONE
        | aux_chk i (_ :: bnds) = aux_chk (i - 1) bnds
        | aux_chk _ _ = raise no_such_binder_exp (ec,i)
    in aux_chk i (get_bnds ec) end;    

(* i is bound within a wave front, give back the wave front name *)
fun wfname_of_bnd ec i = 
    (case lookup_bnd_wf ec i
     of NONE => raise no_such_binder_exp (ec,i)
      | SOME wfn => wfn);

(* check if two free names are related by some relation in a
   param/relation graph. Given an embedding, check if two names are
   related by the relation context *)
fun related_frees ec s1 s2 = 
    if Free.name_eq (s1, s2) then SOME [] 
    else 
      case (ParamRGraph.shortest_path (get_rels ec) (ParamRGraph.VNm.mk s1) 
                                      (ParamRGraph.VNm.mk s2)) 
       of NONE => NONE
        | SOME l => 
          SOME (map (fn (x,y) => (ParamRGraph.ENm.dest x, 
                                  ParamRGraph.VNm.dest y))
                    l);

(* enter the term context of this wave front into the wave front table
   and generate a new fresh name for a new wave front which is initially
   the empty context. *)
fun next_wf ec = 
    (case get_curwf ec 
      of (n,[]) => (NONE,ec)
       | (n,wf as (_::_)) => 
         let val (n2, wfs) = (get_wfs ec) |> Wf.NTab.update_new (get_curwf ec) 
                                          |> Wf.NTab.new_name n
         in (SOME n, ec |> set_wfs wfs
                        |> set_curwf (n2,[]))
         end);

(* add stuff to inside of wave front i.e. add g "%x. f x" => "% x. f (g x)" *)
fun addto_curwf more_wf = 
    update_curwf (fn (n,wf) => (n, more_wf @ wf));
(* remove content of current wave front *)
val clear_curwf = update_curwf (fn (n,wf) => (n,[]));

(* check if Bound i emebeds into Bound j w.r.t. embedding context *)
fun binders_embed ec i j = 
    let 
      (* check is the source bound var i1 is embedded in the destination bound var i2 *)
      fun aux_chk (i1,i2) [] = false
        | aux_chk (0,0) ((SrcBinder _) :: bnds) = true
        | aux_chk (i1,0) ((WfBinder _):: bnds) = false
        | aux_chk (i1,i2) ((SrcBinder _) :: bnds) = aux_chk (i1 - 1,i2 - 1) bnds
        | aux_chk (i1,i2) ((WfBinder _) :: bnds) = aux_chk (i1,i2 - 1) bnds 
    in aux_chk (i,j) (get_bnds ec) end;

fun target_of_src_bound ((SrcBinder _) :: bnds) 0 = 0
  | target_of_src_bound ((SrcBinder _) :: bnds) i = 
    1 + (target_of_src_bound bnds (i - 1))
  | target_of_src_bound ((WfBinder _) :: bnds) i = 
    1 + (target_of_src_bound bnds i)
  (* consider improving this: maybe a bit too liberal - 
     we assume unbound contexts and give back values - 
     used in: id_eterm_of_term *)
  | target_of_src_bound [] i = i; 

fun inc_term_src_bounds bnds (Abs(s,ty,t)) = 
    Abs(s,ty, inc_term_src_bounds ((SrcBinder (ty,ty))::bnds) t)
  | inc_term_src_bounds bnds (t1 $ t2) = 
    (inc_term_src_bounds bnds t1) $ (inc_term_src_bounds bnds t2)
  | inc_term_src_bounds bnds (Bound i) = 
    Bound (target_of_src_bound bnds i)
  | inc_term_src_bounds bnds t = t;


(* *)
fun add_bnd_in_skel ty1ty2 ec = 
    update_bnds (fn bnds => (SrcBinder ty1ty2) :: bnds) ec;

fun add_bnd_in_wf (n,ty) ec = 
    ec |> update_bnds (fn bnds => (WfBinder (get_curwf_name ec,ty)) :: bnds)
       |> addto_curwf [TrmCtxt.D.Abs(n,ty)];

(* quickly get the src type of the embedding term given its context *) 
fun fastype_of_eterm_src ec (Ts, eApp(f,u)) =
    (case fastype_of_eterm_src ec (Ts,f) of
       Type("fun",[_,T]) => T
     | _ => raise eterm_exp("fastype_of: expected function type", 
                                  [eApp(f,u)]))
  | fastype_of_eterm_src ec (_, eConst ((_,T),_)) = T
  | fastype_of_eterm_src ec (_, eRelFree ((((_,T),_),_),_)) = T
  | fastype_of_eterm_src ec (Ts, et as eBound ((i,_),_)) = 
    (List.nth(Ts,i)
     handle General.Subscript => 
            raise eterm_exp("fastype_of: Bound", [et]))
  | fastype_of_eterm_src ec (Ts, eIntoBound ((en,i),_)) = 
    (let val (wfn,c,et) = get_sub ec en
     in fastype_of_eterm_src ec ((TrmCtxt.ty_ctxt c) @ Ts, et) end)
  | fastype_of_eterm_src ec (Ts, eSrcVar ((((ix,T),args),bnds,t2),_)) = 
    Term.fastype_of1 (Ts, Term.list_comb (Var(ix,T), args))  
  | fastype_of_eterm_src ec (Ts, eDestVar ((t1,bnds,(ix,T)),_)) = 
    Term.fastype_of1 (Ts, t1)
  | fastype_of_eterm_src ec (Ts, eAbs ((_,T,u),_)) = 
    T --> fastype_of_eterm_src ec (T::Ts, u);

(* 
fun pretty_trmdpos ctxt (Zipper.C.D.Abs (n,ty)) = 
    Pretty.block
      [Pretty.str "Abs ",
       Pretty.str n,
       Pretty.str " :: ",
       Trm.Var.pretty_typ ctxt ty]
  | pretty_trmdpos ctxt (Zipper.C.D.AppL t) = 
    [Pretty.str "AppL ", Trm.pretty ctxt t]
  | pretty_trmdpos ctxt (Zipper.C.D.AppR t) = 
    [Pretty.str "AppR ", Trm.pretty ctxt t];

fun pretty_trmctxt ctxt tc = 
    Pretty.list "[" "]" (map (pretty_trmdpos ctxt) tc);

fun pretty_sub ec (wfn,tc,eterm) = 
    Pretty.block 
    [Pretty.str "sub: ",
     Pretty.chunks 
     [Pretty.block 
        [Pretty.str "wfn: ",
         Em.pretty_name wfn],
      Pretty.block 
        [Pretty.str ": ",
         TrmCtxt.pretty (get_ctxt ec) tc],

      

fun pretty (Ectxt rep) = 
    Pretty.chunks 
      [Pretty.block 
         [Pretty.str "ienv: ",
          InstEnv.pretty (#ienv rep)],
       Pretty.block 
         [Pretty.str "subs: ",
          Em.NTab.pretty 

     ienv : InstEnv.T, (* instantiations *)
           subs : (Wf.name 
                   * TrmCtxt.T (* the part of the wave front we are under *)
                   * eterm) Em.NTab.T, (* to sub eterms, with wf name it occurs in *)
           wfs : TrmCtxt.T Wf.NTab.T, (* wave front names -> trm ctxts *)
           rels : ParamRGraph.T, (* related frees/params *)
           (* temp info: used only for construction - ? make into a temp datatype? *)
           agenda : (Wf.name * term) Em.NTab.T, (* agenda of things needing to be embedded somewhere, 
                                      name space shared with subs *)
           bnds : bnd list, (* info about current binding context *)
           curwf : (Wf.name * TrmCtxt.T) (* next wf name and (maybe partial) content *)
*)


end;


structure Ectxt : ECTXT = DB_Ectxt;

(* PolyML.Compiler.debug := false; *)
