(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/rippling/skel.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Created:    14 April 2003
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Code to manage the skeleton state during rippling, ie holds the skeleton,
    embeddings etc.

    Note that a ripple skel is w.r.t a single skeleton. The ripple
    cinfo is responsible for managing multiple skeletons.

*)  
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature RIPPLE_SKEL = 
sig

  type T

  structure RippleMeasure : BASIC_RIPPLE_MEASURE

  val name : string

  (* choices to be searched over *)
  val init : {ectxt : Embed.Ectxt.T,
              skelname: string,
              skelterm: Term.term, 
              target: Term.term} -> T list

  val mk_better_next : Embed.Ectxt.T -> Term.term -> T -> T list
  val mk_all_next : Embed.Ectxt.T -> Term.term -> T -> T list

(* 
  val mk_thld_next : Embed.Ectxt.T -> Term.term 
                     -> (Embed.T * RippleMeasure.T) -> T -> T list
*)
  (* val mk_midout_next : Embed.Ectxt.T -> Term.term list -> T -> T list *)


  (* *)
  val get_measures : T -> RippleMeasure.T list
  val get_embeddings : T -> Embed.T list

  (* this ripple state is a final one -- ie apply critics etc 
     (although we may also have next states) *)
  val success_chk : T -> bool

  val get_named_skel_term : T -> (string * Term.term)

  (* true if this state is blocked given the list of possible 
     future states *)
  val blocked_chk : T -> T list -> bool

  val pretty : Proof.context -> T -> Pretty.T
  val print : Proof.context -> T -> unit

end;
