(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfos/user_points_cinfo.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Date:       22 June 2004
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Contextual Information for user choice points.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature USERPOINTS_CINFO = 
sig
  
  structure I : INFO_ITEM

  val pretty_of_cinfo : CInfo.T -> RState.T -> Pretty.T
  val pretty_of_rst : RState.T -> Pretty.T 

  val add_upoints_to_cinfo : RState.T list -> CInfo.T ->  CInfo.T
  val add_upoints_to_rst : RState.T list -> RState.T ->  RState.T

  val upoints_of_cinfo : CInfo.T -> RState.T list
  val upoints_of_rst : RState.T -> RState.T list

end;


(* Meta information for reasoning state descriptions *)
structure UserPointsCInfo : USERPOINTS_CINFO = 
struct
  type T = RState.T list

  structure I = 
  InfoFUN( 
    struct
      type T = T;
      val name = "userpoint";
      val init = [];
      val copy = I; (* copy is just identy as no references *)
      val pretty = K o (Pretty.chunks o (map DescripCInfo.pretty_rst));
    end
  );

  (* implicit cinfo *)
  val pretty_of_cinfo = I.pretty o I.get;
  (* implicit rst *)
  fun pretty_of_rst rst = I.pretty (I.get_from_rst rst) rst;


  fun add_upoints newcps oldcps = newcps @ oldcps;
  (* implicit cinfo *)
  fun add_upoints_to_cinfo cps = 
      I.update_cinfo (add_upoints cps);
  (* implicit rst *)
  fun add_upoints_to_rst cps = 
      I.update_rst (add_upoints cps);

  val upoints_of_cinfo = I.get;
  val upoints_of_rst = I.get_from_rst;
end;
