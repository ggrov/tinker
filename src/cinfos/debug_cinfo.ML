(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfos/debug_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Contextual Information for Debugging, basically a list of strings that
    can be added to, to see what's going on. 

    We use a cunning trick whereby each state has a unique id (see
    rstate.ML), and we hold with the last debug info the rstate id
    that it was added for. Then, on display we can check the id and
    only show if its for the current state.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature DEBUG_CINFO = 
sig
  
  structure I : INFO_ITEM

  val last_debug_string_of_cinfo : CInfo.T -> string
  val current_debug_string_of_rst : RState.T -> string

  val add_dbgstr_to_rst : string -> RState.T -> RState.T

end;


(* Meta information for reasoning state descriptions  *)
structure DebugCInfo : DEBUG_CINFO = 
struct

  fun pretty (i,ss) = 
      Pretty.block 
      [Pretty.str ("infoid: " ^ (string_of_int i)),
       Pretty.str ("; debug info: " ^ 
                   (IsaPLib.string_of_list I ss))];

  structure I = 
  InfoFUN( 
    struct
      type T = (int * string list); (* int is state id that strings are for *)
      val name = "debug";
      val init = (~1, []);
      val copy = I; (* copy if Id as no refs *)
      val pretty = K o pretty
    end
  );

  (* Note: string of meta-info is not same as string of rstate, cinfo
  gives last debug info, where string of state gives only debug info
  for this state. *)

  fun last_debug_string_of_cinfo c = Pretty.string_of (pretty (I.get_from_cinfo c));

  fun current_debug_string_of_rst rst = 
      let 
        val (oldid, l) = (I.get_from_rst rst)
        val id = RState.get_id rst
      in
        "infoid: " ^ (string_of_int oldid) ^
        "; stateid: " ^ (string_of_int id) ^ "; " ^
        (IsaPLib.string_of_list (fn x => x) l)
        (* if oldid = id then 
        else
          "No debug info for this state." *)
      end;


  (* add new information to debug info, dropping old info if its for a
  different state *)

  fun add_dbgstr_to_rst s rst = 
      let 
        val (oldid, l) = (I.get_from_rst rst)
        val id = RState.get_id rst
      in
        if oldid = id then 
          (I.put_in_rst (id,s::l) rst)
        else
          (I.put_in_rst (id,[s]) rst)
      end;

end;
