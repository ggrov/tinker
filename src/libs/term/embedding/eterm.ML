(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/eterm.ML
    Authors:    Lucas Dixon, ldixon@inf.ed.ac.uk
                updated 30 Dec 2008
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    Embedding terms
*)   
signature ETERM = sig

  (* (sub)embedding names *)
  structure Em : SINT_NAME;

  (* wave front names *)
  structure Wf : SINT_NAME;

  (* binder embeddings in context *)
  datatype bnd = SrcBinder of Term.typ (* skeleton type *)
                              * Term.typ (* target type *)
               | WfBinder of Wf.name (* wf name bound inside of *)
                             * Term.typ; (* type of binder in wf *)

  (* relational difference (relation/goalnames) *)
  type relinfo = (string * string) list 

  (* datatype for embeddings of terms 

     eApp has no wave front: "f a" -e-> "g f a" is done by
     eta-expanded form with bound var and an eIntoBound.
     "wf1 g (wh (%x. f (wfbnd x a wf1))) (bwh a)"
     

     Wave fronts on an application are on the head symbol: 
     "f a" -e-> "g (f a)" is "wf g (wh (f a))"
     
  *)
datatype eterm = 
         eApp of (eterm * eterm)
       | eAbs of ((string * Term.typ * eterm) 
                  * Wf.name option) (* wave front ... *)
       | eConst of ((string * Term.typ) * Wf.name option)
       | eBound of ((int (* src binder *)
                     * bnd list) (* binding context *)
                    * Wf.name option)
       | eIntoBound of ((Em.name (* sub embedding name *)
                         * int)
                        * Wf.name option) (* embedding ename into bound i *)
       | eSrcVar of ((((Var.name * Term.typ) (* var of head normal term in src *)
                       * Term.term list (* args of var in src *)
                      ) 
                      * bnd list (* binding context *)
                      * Term.term) (* term in target *)
                     * Wf.name option) 
       | eDestVar of ((Term.term * (* term in src *)
                       bnd list * (* binding context *)
                       ((Var.name * Term.typ) * Term.term list)) (* target meta-var * args *)
                      * Wf.name option) 
       | eRelFree of ((((Free.name * Term.typ) (* Free Var in Given *)
                       * (Free.name * Term.typ)) (* Free Var in Goal/Fact *)
                      * relinfo)
                      * Wf.name option) (* func wave front *)

  exception eterm_exp of string * (eterm list);

val dest_app : eterm -> eterm * eterm list
val get_top_wf : eterm -> Wf.name option
val set_top_wf : Wf.name option -> eterm -> eterm

end;


structure DB_ETerm 
= struct

structure Em :> SINT_NAME = SIntName;
structure Wf :> SINT_NAME = SIntName;

(* relational difference (relation/goalnames) *)
type relinfo = (string * string) list 

(* bound var context, each binder is either a binder in the src (and
   dest) - we hold the types of both and make sure they unify; or a
   binder within a wave front - then we hold the wave front name and
   the tgt binder's type. *)
datatype bnd = SrcBinder of Term.typ * Term.typ
             | WfBinder of Wf.name * Term.typ

(* datatype for embeddedings of terms *)
datatype eterm = 
         eApp of (eterm * eterm)
       | eAbs of ((string * Term.typ * eterm) 
                  * Wf.name option) (* wave front ... *)
       | eConst of ((string * Term.typ) * Wf.name option)
       | eBound of ((int (* src binder *)
                     * bnd list) (* binding context *)
                    * Wf.name option)
       | eIntoBound of ((Em.name (* sub embedding name *)
                         * int)
                        * Wf.name option) (* embedding ename into bound i *)
       | eSrcVar of ((((Var.name * Term.typ) (* var of head normal term in src *)
                       * Term.term list (* args of var in src *)
                      ) 
                      * bnd list (* binding context *)
                      * Term.term) (* term in target *)
                     * Wf.name option) 
       | eDestVar of ((Term.term * (* term in src *)
                       bnd list * (* binding context *)
                       ((Var.name * Term.typ) * Term.term list)) (* target meta-var * args *)
                      * Wf.name option) 
       | eRelFree of ((((Free.name * Term.typ) (* Free Var in Given *)
                       * (Free.name * Term.typ)) (* Free Var in Goal/Fact *)
                      * relinfo)
                      * Wf.name option) (* func wave front *)


(* Global stuff that you need to know about as your traverse term for
   embedding. Invarients: agenda <= Names(subs); bnd var embedding
   only refer to wave fronts higher up term tree; *)

fun dest_app' ts (eApp (t1,t2)) = dest_app' (t2::ts) t1 
  | dest_app' ts et = (et,ts);
val dest_app = dest_app' [];

fun get_top_wf (eApp _) = NONE
  | get_top_wf (eAbs (_,wf)) = wf
  | get_top_wf (eConst (_,wf)) = wf
  | get_top_wf (eBound (_,wf)) = wf
  | get_top_wf (eIntoBound (_,wf)) = wf
  | get_top_wf (eSrcVar (_,wf)) = wf
  | get_top_wf (eDestVar (_,wf)) = wf
  | get_top_wf (eRelFree (_,wf)) = wf;

exception eterm_exp of string * (eterm list);

fun set_top_wf wfopt et = 
    let 
      fun set' (eApp (t1,t2)) = eApp (set' t1, t2)
        | set' (eAbs (a,_)) = (eAbs (a,wfopt))
        | set' (eConst (a,_)) = (eConst (a,wfopt))
        | set' (eBound (a,_)) = (eBound (a,wfopt))
        | set' (eIntoBound (a,_)) = (eIntoBound (a,wfopt))
        | set' (eSrcVar (a,_)) = (eSrcVar (a,wfopt))
        | set' (eDestVar (a,_)) = (eDestVar (a,wfopt))
        | set' (eRelFree (a,_)) = (eRelFree (a,wfopt));
    in set' et end;

end;


structure ETerm : ETERM = DB_ETerm;

(*install_pp (make_pp ["ETerm", "Em", "T"] 
                    (Pretty.pprint o ETerm.Em.pretty_name));
install_pp (make_pp ["ETerm", "Wf", "T"] 
                    (Pretty.pprint o ETerm.Wf.pretty_name));

install_pp (make_pp ["ETerm", "Em", "NSet", "T"] 
                    (Pretty.pprint o ETerm.Em.NSet.pretty));
install_pp (make_pp ["ETerm", "Wf", "NSet", "T"] 
                    (Pretty.pprint o ETerm.Wf.NSet.pretty));*)
