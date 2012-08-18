(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rstate/cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Contextual Information about the reasoning state. This is a
    polymorphic table of the information that is available to use when
    reasoning. This is global in the sense that there is one instance
    of the data for all goals. See lcinfo for contextual info that
    local to a result in proof planning.

    To create a new structure that will hold contextual information,
    see inftools.ML

    Note: this is not the same as Isabelle theory context, or Isabelle's Proof
    context, this is specifically for holding info for proof
    planning; it lives as an element in the Isabelle contexts. 

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature CINFO =
sig
  type T = PolymTable.T
  structure Thy : THEORY_DATA where type T = PolymTable.T;
  structure Ctxt : PROOF_DATA where type T = PolymTable.T;
end;

structure CInfo 
: CINFO 
= struct
  type T = PolymTable.T;

  structure Thy = Theory_Data(struct
    type T = PolymTable.T
    val empty = PolymTable.empty
    val extend = I
    fun merge (t1,t2) = PolymTable.merge t1 t2
  end);

  structure Ctxt = Proof_Data(struct 
    type T = PolymTable.T;
    val init = Thy.get;
  end);
end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
