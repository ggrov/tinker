(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/conj/conjecturedb_lib.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Created:    17 Aug 2002 - lucasd
    Updated:    7 Jan 2003 - lucasd
                11 sept 2006 - moa. changes to fit new proof env.
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Code to hold a database of conjectured things so that we don't
    reconjecture the same things.


    Modified varant that will also have a lemmastatus of
 'in progress', to be used by bf-rippling.

*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(*

Essentially we use a term descrimination net to hold the term of the
conjecture as the key and a proof plan option for that
conjecture. NONE represnets that it was not possible to prove it, and
a SOME proof plan represents how it was proved.

Maybe we should make a destinction between things that we found to be
false, those that we can prove and those that we can. Although false
and "can't prove" both result in abandoning that branch of search. It
maybe useful to give results back to the user in case they beleive
that an "unproven but possible true conjecture" can be proved. 

[7 Jan 2003]
More importantly if we later find that we can prove some new lemma it
may change teh state of all unkown conjectures, but obviously it won't
affect the known to be false conjectures.

*)

signature CONJECTUREDB_LIB = 
sig

  type  T

  (* previous result/status of a conjecture 
     IMRPOVE: add witness for false things *) 

datatype conj_status = 
         ConjStatus_false of Term.term 
       | ConjStatus_failed 
       | ConjStatus_in_progress
       | ConjStatus_unknown;

  val empty : T
  val lookup : T -> Term.term 
               -> (string (* absolute name *)
                   * (Thm.thm * (Prf.gname * Prf.T))) list (* maybe proofs *)
                  * conj_status (* status *)

  val insert_proved : string  (* proposed name for conjDB *)
                      -> (Thm.thm * (Prf.gname * Prf.T)) (* proved theorem *)
                      -> T 
                      -> (string * T) (* given name + new conj DB *)
  val insert_false : Term.term -> T -> T
  val insert_failed :  Term.term -> T -> T

  (* IMPROVE?  manage by unique gnames to identify proof attempts? *)
  val insert_inprogress : Term.term -> T -> T 
  val delete_inprogress : Term.term -> T -> T


  val pretty_stats :  T -> Pretty.T

  val get_proved : T -> (Thm.thm * (Prf.gname * Prf.T)) Goaln.NTab.T
  val get_truenet : T -> (Prf.gname * (Thm.thm * (Prf.gname * Prf.T))) Net.net
  val get_falsenet :  T -> (Term.term) Net.net
  val get_failednet : T -> (Term.term) Net.net
  val get_inprogressnet : T -> Term.term Net.net

  val lemmas_inprogress_of : T -> Term.term list

end;



structure ConjecturedbLib : CONJECTUREDB_LIB = 
struct


  (* type conj_thingT = proofstateS.proofstateT option; *)
datatype T = ConjDB of 
         { truenet : (string * (Thm.thm * (Prf.gname * Prf.T))) Net.net,
           proved : (Thm.thm * (Prf.gname * Prf.T)) Goaln.NTab.T,
           (* IMRPOVE: add witness for counter-examples *)
           falsenet : Term.term Net.net,
           failednet : Term.term Net.net,
           inprogressnet : Term.term Net.net
         };

datatype conj_status = 
         ConjStatus_false of Term.term 
       | ConjStatus_failed 
       | ConjStatus_in_progress
       | ConjStatus_unknown;

(* empty *)
val empty = 
    ConjDB { 
    truenet = Net.empty,
    proved = Goaln.NTab.empty,
    falsenet = Net.empty,
    failednet = Net.empty,
    inprogressnet = Net.empty};

fun get_proved (ConjDB rep) = #proved rep;
fun get_truenet (ConjDB rep) = #truenet rep;
fun get_falsenet (ConjDB rep) = #falsenet rep;
fun get_failednet (ConjDB rep) = #failednet rep;
fun get_inprogressnet (ConjDB rep) = #inprogressnet rep;

val lemmas_inprogress_of = Net.entries o get_inprogressnet;

fun update_proved f cdb = 
    (ConjDB {
     truenet = get_truenet cdb, 
     proved = f (get_proved cdb),
     falsenet = get_falsenet cdb, 
     failednet = get_failednet cdb, 
     inprogressnet = get_inprogressnet cdb});
val set_proved = update_proved o K;

fun update_truenet f cdb = 
    (ConjDB {
     truenet = f (get_truenet cdb), 
     proved = get_proved cdb,
     falsenet = get_falsenet cdb, 
     failednet = get_failednet cdb, 
     inprogressnet = get_inprogressnet cdb});
    
fun update_falsenet f cdb = 
    (ConjDB {
     truenet = get_truenet cdb, 
     proved = get_proved cdb,
     falsenet = f (get_falsenet cdb), 
     failednet = get_failednet cdb,
     inprogressnet = get_inprogressnet cdb });
    
fun update_failednet f cdb = 
    (ConjDB {
     truenet = get_truenet cdb, 
     proved = get_proved cdb,
     falsenet = get_falsenet cdb, 
     failednet = f (get_failednet cdb),
     inprogressnet = get_inprogressnet cdb});
    
fun update_inprogressnet f cdb = 
    (ConjDB {
     truenet = get_truenet cdb, 
     proved = get_proved cdb,
     falsenet = get_falsenet cdb, 
     failednet = get_failednet cdb,
     inprogressnet = f (get_inprogressnet cdb)});
    
    (* pretty stats of conjecture DB *)
fun pretty_stats db =
    let fun netsize net = Int.toString (length (Net.entries net));
    in
      Pretty.chunks
        [Pretty.str ("lemmas proved: " ^ (netsize (get_truenet db))),
         Pretty.str ("lemmas disproved: " ^ (netsize (get_falsenet db))),
         Pretty.str ("lemmas unknown: " ^ (netsize (get_failednet db))),
         Pretty.str ("lemmas in progress: " 
                     ^ (netsize (get_inprogressnet db)))]
    end;


(* filter out to get only really matching things *)
(* 
  |> List.filter 
    (fn (n,(lemmaps,lemmat)) =>
        let 
          val (lifting,ienv2) = 
              Lifting.mk Trm.TrmParams.empty 
                         lemmaps (PPlan.get_ienv ppl)
          val lemmat2 = Lifting.lift lifting lemmat
        in MyUnify.unifies (PPlan.get_thoery ppl) 
                           (ienv2,[(lemmat2,t)]) end)
*)

(* lookup term "tin" in the conjecture DB and return what we know about it. *)
fun lookup db tin = 
    let  (* note: we eta-contract the term so that (%x. f x) matches "f",
         as terms are eta-contracted when inseted into the DB of terms *)
      val t = (Envir.beta_eta_contract tin)

      val tnet = get_truenet db

      fun net_contains_t net = 
          List.find (Trm.trm_name_eq t) (Net.unify_term net t)
    in
      (Net.unify_term tnet t, (* possible proofs... *)    
       (* other stuff we know about the given term *)
       (* FIXME: use unification for false stuff, not net_contains_t! *)
       (case net_contains_t (get_falsenet db) (* false matches *)
         of SOME false_t => ConjStatus_false false_t
          | NONE => 
          (* previous attempt failed - conjecture is unknown *)
            (case net_contains_t (get_failednet db)
              of SOME _ => ConjStatus_failed
               | NONE => 
               (* conjecture is in progress somewhere else *)
                 (case net_contains_t (get_inprogressnet db)
                   of SOME _ => ConjStatus_in_progress
                    | NONE => ConjStatus_unknown))))
    end;

(* terms are the same upto free-var renaming *)
val net_eq_check = uncurry Trm.trm_name_eq;

(* implicit args: cdb *)
(* IMRPOVE: more general(w.r.t. Unification) false things should
   subsume simpler ones. *)
fun insert_false t = 
    let val vt = Envir.beta_eta_contract t
    in update_falsenet (Net.insert_term net_eq_check (vt,vt))
    end;

(* IMRPOVE: more general(w.r.t. Unification) true things should
   subsume simpler ones. *)
(* Note this can happen if we find two proofs for the same theorem. 
e.g. Simp OR ind AND simp, might give two proofs *)
fun insert_proved n (x as (thm,prfstuff)) db = 
    let 
      val vt = Envir.beta_eta_contract (Thm.prop_of thm)
      val thm2 = Thm.put_name_hint n thm
      val (n2,proved2) = Goaln.NTab.add (n,(thm2,prfstuff)) (get_proved db)
    in (n2, db |> update_truenet (Net.insert_term 
                                    (fn ((x,_),(y,_)) => x = y)
                                    (vt,(n2,(thm2,prfstuff))))
               |> set_proved proved2)
    end;

fun insert_failed t = 
    let val vt = Envir.beta_eta_contract t
    in update_failednet (Net.insert_term net_eq_check (vt,vt)) end;

(* IMRPOVE: more general(w.r.t. Unification) true things should
   subsume simpler ones - more complex for stuff in progress. *)
fun insert_inprogress t  = 
    let val vt = Envir.beta_eta_contract t
    in update_inprogressnet (Net.insert_term net_eq_check (vt,vt)) end;
fun delete_inprogress t = 
    let val vt = Envir.beta_eta_contract t
    in update_inprogressnet (Net.delete_term net_eq_check (vt,vt)) end;


end;
