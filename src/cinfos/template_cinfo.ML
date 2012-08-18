(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfos/template_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Date:       2 Jan 2005
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Template for Contextual Information. This adds 
    strings to the cinfo. 

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature TEMPLATE_CINFO = 
sig
  
  (* This is the sturtcure that provides the common interface for 
     cinfo kinds *)
  structure I : INFO_ITEM

  (* pretty printing code -- use this for debugging! *)
  val pretty : I.T -> Pretty.T 
  (* note extra RState.T as we always allow printing relative to a state *)
  val pretty_of_cinfo : CInfo.T -> Pretty.T
  val pretty_of_rst : RState.T -> Pretty.T 

  (* now the code to actually manage the cinfo and to provide common
     tools for its use. *)
  val of_str : string -> I.T 
  (* the following are helpers for more convinient use *)
  val set_cinfo : string -> CInfo.T -> CInfo.T
 
end;


(* Template structure for cinfo *)
structure TemplateCInfo : TEMPLATE_CINFO = 
struct

  (* this is the type of our contextual info - which is an abriviation 
     for I.T *)
  type T = string

  (* we now define our generic data for contextual information *)
  structure I = 
  InfoFUN( 
    struct
      type T = T; (* This sets the type *)
      val name = "userpoint"; (* a unique name for this kind of cinfo *)
      val init = "empty!"; (* an initial default value *)
      val copy = I; (* copying is only non-identity when we use references *)
      fun pretty d rst = Pretty.str d; (* function to prettify *)
    end
  );

  val pretty = Pretty.str;
  (* implicit cinfo *)
  val pretty_of_cinfo = pretty o I.get;
  (* implicit rst *)
  fun pretty_of_rst rst = I.pretty (I.get_from_rst rst) rst;

  (* because input and output type are the same this is trivial *)
  fun of_str s = s;
  (* implicit cinfo *)
  val set_cinfo = I.update_cinfo o K of_str;
  (* implicit rst *)
  val set_rst = I.update_rst o K of_str;

  (* define other functions/tools for techniques to work with 
     you kind of cinfo here *)

end;
