(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./theory/HOL/isar_attr.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Created:    14 Oct 2004
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    Isar Attributes for HOL
*)

structure IsarAttr = 
struct 

open IsarAttr;

structure Argcong = 
struct
  val name = "OF_argcong"
  val arg_cong_th = (@{thm "HOL.arg_cong"});
  val prettyf : unit -> Pretty.T = K (Pretty.str ("OF argcong"));
  fun attrf () th = th RS arg_cong_th;
  structure I = 
    DThmAttrInstFUN(
      structure K = 
      struct
        type T = unit;
        val name = name;
        fun eq x y = true; (* no data thus always true *)
        val prettyf = prettyf;
        val attrf = attrf;
      end)
  val dattr = I.dattr ();
end; (* Argcong *)


end;
