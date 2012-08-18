(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/conj/conjdb_ctxt_info.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Created:    17 Aug 2002
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Code to hold a database of conjectured things so that we don't
    reconjecture the same things.

*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* load the conjecure DB library
use "conjecturedb_lib.ML"; *)


signature CONJDB_CTXT_INFO = 
sig

  type T
 
  structure Ctxt : PROOF_DATA where type T = T

  val discard_all_in_ctxt : Proof.context -> Proof.context

  type conj_status = ConjecturedbLib.conj_status

  val lookup : T -> Term.term 
               -> (string * (Thm.thm * (Prf.gname * Prf.T))) list 
                  * conj_status

  val lookup_rst :  RState.T -> Term.term
                    -> (string * (Thm.thm * (Prf.gname * Prf.T))) list 
                       * conj_status

  val get_conj_by_name_rst 
      : RState.T -> string -> (Thm.thm * (Prf.gname * Prf.T))

  val insert_false : Term.term -> T -> T
  val insert_false_rst : Term.term -> RState.T -> RState.T

  val insert_proved 
      : Prf.gname  (* proposed name for conjDB *)
        -> (Thm.thm * (Prf.gname * Prf.T)) (* proved theorem *)
        -> T 
        -> (Prf.gname * T) (* given name + new conj DB *)
  val insert_proved_rst 
      : Prf.gname 
        -> (Thm.thm * (Prf.gname * Prf.T)) 
        -> RState.T 
        -> (Prf.gname * RState.T)

  val insert_failed : Term.term -> T -> T
  val insert_failed_rst : Term.term -> RState.T -> RState.T

  val insert_inprogress : Term.term  -> T -> T
  val insert_inprogress_rst : Term.term  -> RState.T -> RState.T

  val delete_inprogress : Term.term -> T -> T
  val delete_inprogress_rst : Term.term -> RState.T -> RState.T

  val pretty_stats : T -> Pretty.T
  val pretty_stats_rst : RState.T -> Pretty.T

  val pretty_i : Proof.context -> T -> Pretty.T
  val pretty_rst : RState.T -> Pretty.T
  val print_rst : RState.T -> unit

  val lemmas_in : T -> (Thm.thm * (Prf.gname * Prf.T)) Goaln.NTab.T
  val lemmas_in_ctxt : Proof.context -> (Thm.thm * (Prf.gname * Prf.T)) Goaln.NTab.T
  val lemmas_in_rst : RState.T -> (Thm.thm * (Prf.gname * Prf.T)) Goaln.NTab.T

  val lemmas_inprog_rst : RState.T -> Term.term list

end;

(* Contextual information for the conjecture database in a reasoning state
Was: ConjdbCInfo
*)
structure Conjdb_CtxtInfo : CONJDB_CTXT_INFO = 
struct

  type T = ConjecturedbLib.T Unsynchronized.ref;

  structure Ctxt = Proof_Data(struct 
    type T = ConjecturedbLib.T Unsynchronized.ref
    fun init thy = Unsynchronized.ref ConjecturedbLib.empty;
  end);

  structure Rst = struct 
    val get = Ctxt.get o RState.get_ctxt;
    val put = RState.update_ctxt o Ctxt.put;
    val map = RState.update_ctxt o Ctxt.map;
  end;

  fun discard_all_in_ctxt ctxt = Ctxt.put (Unsynchronized.ref ConjecturedbLib.empty) ctxt;

  type conj_status = ConjecturedbLib.conj_status;

  fun pretty_unproveables ctxt d = 
      let val ts = Net.entries (ConjecturedbLib.get_failednet d)
      in
        Pretty.chunks 
          [Pretty.str "Unprovable conjectures: ",
           Pretty.indent 2 (Pretty.chunks (map (Syntax.pretty_term ctxt) ts))]
      end;

  fun pretty_lemmas ctxt d = 
      let val ts = Net.entries (ConjecturedbLib.get_truenet d)
        fun pretty_lemma (n,(th,_)) = 
            Pretty.block [Goaln.NTab.pretty_name n,
                          Pretty.str ": ", 
                          Display.pretty_thm ctxt th]
      in
        Pretty.chunks 
          [Pretty.str "Proved Lemmas: ",
           Pretty.indent 2 (Pretty.chunks (map pretty_lemma ts))]
      end;

  fun pretty_nontheorems ctxt d = 
      let val ts = Net.entries (ConjecturedbLib.get_falsenet d)
      in
        Pretty.chunks 
          [Pretty.str "Non-theorems (false conjectures): ",
           Pretty.indent 2 (Pretty.chunks (map (Syntax.pretty_term ctxt) ts))]
      end;

  fun pretty_nontheorems ctxt d = 
      let val ts = Net.entries (ConjecturedbLib.get_inprogressnet d)
      in
        Pretty.chunks 
          [Pretty.str "In progress conjectures: ",
           Pretty.indent 2 (Pretty.chunks (map (Syntax.pretty_term ctxt) ts))]
      end;

  fun pretty_i ctxt (dref : T) = 
      let val d = !dref in
      Pretty.chunks [pretty_lemmas ctxt d, 
                     Pretty.brk 1, 
                     pretty_unproveables ctxt d, 
                     Pretty.brk 1, 
                     pretty_nontheorems ctxt d]
      end;

  fun pretty_rst rst = pretty_i (RState.get_ctxt rst) (Rst.get rst);
  val print_rst = Pretty.writeln o pretty_rst;

  fun pretty_stats dbref = ConjecturedbLib.pretty_stats (!dbref);
  val pretty_stats_rst = pretty_stats o Rst.get;

  fun lookup dbref t = ConjecturedbLib.lookup (!dbref) t;
  val lookup_rst = lookup o Rst.get;

  fun get_conj_by_name dbref s = 
      Goaln.NTab.get (ConjecturedbLib.get_proved (! dbref)) s;
  val get_conj_by_name_rst = get_conj_by_name o Rst.get;


  (* update using references, means that all other states with this
     conjecture database will also be updated. *)
  fun insert_false t dbref = 
      (dbref := (ConjecturedbLib.insert_false t (!dbref)); dbref)
  val insert_false_rst = Rst.map o insert_false;

  fun insert_proved n thmprf dbref = 
      let val (n2,db2) = ConjecturedbLib.insert_proved n thmprf (!dbref) 
      in (dbref := db2; (n2,dbref)) end;
  fun insert_proved_rst n thmprf rst = 
      let val (n2,db2) = insert_proved n thmprf (Rst.get rst)
      in (n2,rst) end;

  fun insert_failed t dbref = 
      (dbref := (ConjecturedbLib.insert_failed t (!dbref)); dbref);
  fun insert_failed_rst t rst = (insert_failed t (Rst.get rst); rst);

  fun insert_inprogress t dbref = 
      (dbref := (ConjecturedbLib.insert_inprogress t (!dbref)); dbref);
  fun insert_inprogress_rst t rst = (insert_inprogress t (Rst.get rst); rst);

  fun delete_inprogress x dbref = 
      (dbref := (ConjecturedbLib.delete_inprogress x (!dbref)); dbref);
  fun delete_inprogress_rst x rst = (delete_inprogress x (Rst.get rst); rst);

  fun lemmas_in dbref = ConjecturedbLib.get_proved (! dbref);
  val lemmas_in_ctxt = lemmas_in o Ctxt.get;
  val lemmas_in_rst = lemmas_in o Rst.get;

  fun lemmas_inprog_rst rst = (ConjecturedbLib.lemmas_inprogress_of (!(Rst.get rst)));

  (* note: again, we don't actually have to change the rst as the info 
     being updated is global *)
  (* fun new_name_from_rst s rst = 
      let 
        val dbref = (I.get_from_rst rst) 
        val (db2, nm) = (ConjecturedbLib.new_name s (!dbref))
      in
        (dbref := db2; (rst,nm))
      end;
   *)

end;

