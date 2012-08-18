
signature DATATYPE_IND_SCHEMES =
sig
  type typename = string
  type T

  val default_ind_thm : T -> Thm.thm
  val ind_thms : T -> Thm.thm list

  val lookup :  Context.theory -> typename -> T option;
end;

signature INDUCT_TAC
= sig

end;

functor InductTacFUN(D : DATATYPE_IND_SCHEMES) = 
struct

(* find an element, but keep the rest also *)
fun pull_elem f l = 
    let fun recf [] L = NONE
          | recf (h :: t) L = 
            if f h then SOME (h, (rev L) @ t)
            else recf t (h :: L)
    in recf l [] end;

(* re-arranges things to induct on (indnames) into the correct format
for Isabelles induction tactic, also removed them from ithings, so
that we know what other frees to turn into sinks (univ quantifies in
the IH) *)
(* assumes: indnames <= ithings *)
fun mk_induct_insts ithings indnames = 
    let 
      fun faux ithings [] L = (ithings, rev L)
        | faux ithings (h :: t) L = 
          if h = "_" then (faux ithings t (NONE :: L))
          else 
            (case pull_elem (fn (n,ty) => n = h) ithings of 
               NONE => 
               raise ERROR ("No such variable to do induction on: " ^ h)
             | SOME (v, ithings') => (faux ithings' t ((SOME v) :: L)));
    in faux ithings indnames [] end;


(* get the frees in a term *)
val frees_of_term = map Term.dest_Free o Trm.term_frees;
(* take xs in !!xs. P xs. *)
val params_of_term = Term.strip_all_vars;

(* the free variables of a term that are of a datatype 
   (can have induction applied) *)
fun inductable_things_in_term thry t = 
    let 
      fun datatype_chk (Type(tn,_))  = 
           Basics.is_some (D.lookup thry tn)
        | datatype_chk _ = false;
    in 
      List.partition (datatype_chk o snd) 
                     ((frees_of_term t) @ 
                      (params_of_term t))
    end;


fun inductable_things_in_sg i th = 
    inductable_things_in_term 
      (Thm.theory_of_thm th) 
      (Library.nth (prems_of th) (i - 1));

(* underlying tactic *)
(* is_open : bool : if false will rename fixed vars in the
automatically generated isar context to "internal" fixed vars, ie
fixing the vasr with the name suffixed by a "_" char. True when
working in Isar. It can be set in the Isar method call by "induct
(open)..", ie "(open)" after the method name. 

InductMethod.induct_tac 
  ctxt is_open def_insts fixing taking opt_rule facts i th =
 *)
(* invarient: allfrees + params = non_ithings + inductfrees + otherfrees *)
(* invarient: ithings = otherfrees + inductfrees *)
(* invarient: vars <= ithings *)
fun induct_tac rule vars goalthm = 
    let
        (*Dummy context for the sake of Isar*)
      val ctxt = ProofContext.init_global (Thm.theory_of_thm goalthm);
      val (ithings, non_ithings) = inductable_things_in_sg 1 goalthm;
      val (otherfrees, inductfrees) = mk_induct_insts ithings vars;
      val insts = [map (fn NONE => NONE | SOME v => 
                                          (* FIXME: Each variable paired with false? *)
                                          SOME (NONE : Binding.binding option,(Free v,true)))
                         inductfrees];
         (* Throw away Isar related stuff and only take the Thm.thm seq *)
      val nw_thms = 
          Seq.map snd (Induct.induct_tac
                         ctxt false insts [non_ithings @ otherfrees] [] rule [] 1 goalthm)
      in
       (* the freezeT is a hack to correct a bug/feature in 
          InductTac that changes type frees into meta-type vars: 
          Talk to Markarius about this! *)
        Seq.single (Thm.legacy_freezeT (Seq.hd nw_thms))
      end;


(* the dtacs *)
(*
fun induct vars = 
    DTac.mk_from_isa_tac_local
      (K (Pretty.block [Pretty.str "Induction on:",
                     Pretty.list " " " " (map Pretty.str vars)]),
       induct_tac NONE vars);
    
fun induct_rule rule vars =
    DTac.mk_from_isa_tac_local
      (K (Pretty.block 
         ([Pretty.str "Induction on: ",
           (Pretty.list " " " " (map Pretty.str vars)), 
           Pretty.str "with rule: "]
          @
          (map (Pretty.str o Thm.get_name_hint) rule))),
       induct_tac (SOME rule) vars);
*)


end;

