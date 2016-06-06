structure InductRTechn = 
struct
  val atomic_tracing = LoggingHandler.logging "GOALTYPE"

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
  
  (* the free variables of a term that are of a datatype 
     (can have induction applied) *)
  fun inductable_things_in_term thry t = 
      let 
        fun lookup thy s = 
         (case (Datatype.get_info thy s) of
          NONE => NONE
          | SOME di => SOME ( {default_ind_thm = #induct di,
                                   all_ind_thms = [#induct di]}));
  
        fun datatype_chk (Type(tn,_))  = 
             Basics.is_some (lookup thry tn)
          | datatype_chk _ = false;
      in 
        List.partition (datatype_chk o snd) 
                       ((Trm.frees_of t) @ 
                        (Term.strip_all_vars t))
      end;
  
  fun has_inductable_var thy t = 
    let val (vars, _) = inductable_things_in_term thy t in
    case vars of [] => false 
    | _ => true end;
  
  fun inductable_things_in_sg i th = 
      inductable_things_in_term 
        (Thm.theory_of_thm th) 
        (Library.nth (prems_of th) (i - 1));
  
  fun induct_tac' rule vars ith goalthm ifArbitrary= 
      let
        val _ = atomic_tracing ("apply induction on: " ^ (hd vars))
          (*Dummy context for the sake of Isar*)
        val ctxt = Proof_Context.init_global (Thm.theory_of_thm goalthm);
        val (ithings, non_ithings) = inductable_things_in_sg ith goalthm;
        val (otherfrees, inductfrees) = mk_induct_insts ithings vars;
        val insts = [map (fn NONE => NONE | SOME v => 
                                            (* FIXME: Each variable paired with false? *)
                                            SOME (NONE : Binding.binding option,(Free v,true)))
                           inductfrees];
        val otherVars = if ifArbitrary then [non_ithings @ otherfrees] else []
           (* Throw away Isar related stuff and only take the Thm.thm seq *)
        val nw_thms = 
            Seq.map snd (Induct.induct_tac
                           ctxt false insts otherVars [] rule [] 1 goalthm)
        in
         (* the freezeT is a hack to correct a bug/feature in 
            InductTac that changes type frees into meta-type vars: 
            Talk to Markarius about this! *)
          Seq.single (Thm.legacy_freezeT (Seq.hd nw_thms))
        end;
  
  (* only apply induction on the first applicable vars *)
  fun induct_on_first_var_tac i thm = 
    let 
      val (vars, _) = inductable_things_in_sg i thm;
      val var = (fst o hd) vars
    in 
      induct_tac' NONE  [var] i thm 
    end
  
  fun induct_on_nth_var_tac n i thm = 
    let 
      val (vars, _) = inductable_things_in_sg i thm;
      val var = fst (nth vars n)
    in 
      induct_tac' NONE  [var] i thm 
    end

  (* apply induction on the all applicable vars *)
  fun induct_tac i thm = 
    let 
      val _ = atomic_tracing "call induct_tac";
      val (vars, _) = inductable_things_in_sg i thm 
      val ivars = map (fn (x, _) => [x]) vars |> Seq.of_list
    in 
      (* only consider the case with all arbitrary vars *)
      Seq.maps 
        (fn var => induct_tac' NONE var i thm true) ivars 
      (*Seq.append
      (Seq.maps 
        (fn var => induct_tac' NONE var i thm true) ivars)
      (Seq.maps 
        (fn var => induct_tac' NONE var i thm false) ivars)*)
    end
end (*end of struct induct *)
