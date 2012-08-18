(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/induct_HOL.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    created:    30 Jun 2005
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

   Induction scheme tools for HOL, and creation of induction technique.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 


structure HOLDatatypeIndScheme 
: DATATYPE_IND_SCHEMES
= struct

  type typename = string;
  datatype T = scheme of {default_ind_thm : Thm.thm,
                          all_ind_thms : Thm.thm list};

  fun default_ind_thm (scheme rep) = #default_ind_thm rep;
  fun ind_thms (scheme rep) = #all_ind_thms rep;

  fun lookup thy s = 
      (case (Datatype.get_info thy s) of
        NONE => NONE
      | SOME di => SOME (scheme {default_ind_thm = #induct di,
                                 all_ind_thms = [#induct di]}));

end;

structure InductTac = InductTacFUN(HOLDatatypeIndScheme);
