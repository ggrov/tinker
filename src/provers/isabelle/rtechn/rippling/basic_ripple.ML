signature BASIC_RIPPLE = 
sig
end

structure BasicRipple = 
struct
  exception ripple_exp of string;
   
  val db_wrules : Substset.T Unsynchronized.ref =  Unsynchronized.ref Substset.empty 

  fun init_wrule_db () = db_wrules := Substset.empty 

  fun add_wrules named_thms = 
    let val rules = map (fn m => Substset.rule_of_thm m |> (fn SOME x => x)) named_thms  in
     db_wrules := fold (Substset.add) rules (!db_wrules) end

  fun get_matched_wrules thy trm = Substset.match thy (!db_wrules) trm;
  
  fun ripple_tac ctxt i thm = 
    let 
      val params = TermFeatures.Data.get_subst_params ();
      fun pre_ripple_tac (occ, rule) =  
        EqSubst.eqsubst_tac ctxt occ [(Substset.thm_of_rule rule)] i thm |> Seq.hd |> Seq.single
    in 
      Seq.maps pre_ripple_tac (Seq.of_list params)
    end;

end;
