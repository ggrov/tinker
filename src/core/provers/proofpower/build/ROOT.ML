(*
  ROOT.ml file to compile all dependent libraray The stack is shown as below
  
  note that psgraph and supertac are installed on demanded
  
  |    psgraph    |
  -----------------
  |    supertac   |
  -----------------
  |  quantomatic  |
  -----------------
  |   proof power |
  -----------------
  

*)

  
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*                  Compile quantomatic                                    *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

val psgraphDir = OS.FileSys.getDir();
val psgraphSrc = psgraphDir ^ "/../../../../../";

OS.FileSys.chDir psgraphSrc;
(* Include quantomatic *)
OS.FileSys.chDir (psgraphSrc ^ "/../quantomatic/core/");
use "ROOT.ML";
OS.FileSys.chDir psgraphSrc;






