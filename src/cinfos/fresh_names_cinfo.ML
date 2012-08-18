(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfos/fresh_names_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Contextual Information for unique names to be used during proof
    planning for things like assumptions and haves...

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature FRESH_NAMES_CINFO = 
sig
  
  structure I : INFO_ITEM

(*  val init : CInfo.T -> CInfo.T *)
  val new_name_in_cinfo : CInfo.T -> string -> (CInfo.T * string)
  val new_name_in_rst : RState.T -> string -> (RState.T * string)

end;


(* Meta information for reasoning state descriptions *)
structure FreshNamesCInfo : FRESH_NAMES_CINFO = 
struct

  (* we use a name and an integer to state which version of the name
  we are at, for example, under the key: ind_hyp, if the int is 7,
  then the next name for ind_hyp, is "ind_hyp8" *)
  type namesT = int Symtab.table;

  fun pretty tab = 
      Pretty.chunks
        [Pretty.str "Used result names: ",
         Pretty.chunks 
           (map (fn (s,i) => Pretty.str (s ^ (string_of_int i))) 
                (Symtab.dest tab))
        ];

  structure I = 
  InfoFUN( 
    struct
      type T = namesT;
      val name = "names";
      val init = Symtab.empty;
      val copy = I; (* copy is just identy as no references *)
      val pretty = K o pretty
    end
  );
  
  fun new_name_in_cinfo cinfo s =
      let 
        val mynamesTab = I.get cinfo
      in
        case (Symtab.lookup mynamesTab s) of 
          NONE => (I.put (Symtab.update_new (s, 0) mynamesTab) cinfo, 
                   s)
        | (SOME i) => (I.put (Symtab.update (s, i + 1) mynamesTab) cinfo, 
                       s ^ string_of_int (i + 1))
      end;

  fun new_name_in_rst rst s = 
      let 
        val cinfo = RState.get_cinfo rst 
        val (cinfo2, s2) = new_name_in_cinfo cinfo s
      in
        (RState.set_cinfo cinfo2 rst, s2)
      end;

(* 
  fun init cinfo = I.init_with Symtab.empty cinfo;
*)

end;
