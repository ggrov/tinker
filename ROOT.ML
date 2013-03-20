(*
  ROOT.ml file to compile all dependent libraray The stack is shown as below
  
  -----------------
  |    psgraph    |
  -----------------
  |  quantomatic  |
  -----------------
  |    isaplib    |
  -----------------
  |   proof power |
  -----------------
  

*)

  
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*                  Compile quantomatic including isaplib                  *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

val psgraphDir = OS.FileSys.getDir();


OS.FileSys.chDir psgraphDir;
(* Include quantomatic and isaplib *)
OS.FileSys.chDir (psgraphDir ^ "/../quantomatic/core/");
use "ROOT.ML";
OS.FileSys.chDir psgraphDir;

(*Descripe dependent files*)
PolyML.Project.depend_on_files
  [
   (*psgraphDir ^ "/../isaplib/ROOT.ML", for isaplib, for structure Project*)
   psgraphDir ^ "/../quantomatic/core/ROOT.ML", 
   psgraphDir ^ "/ROOT.ML" (*psgraph*)
  ];
 
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*                        psgraph                                          *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
  
(*
  Prf 
  
  PolyML.Project.make "src/proof/pnode.ML";                                                                                                                                                        
  PolyML.Project.make "src/proof/pplan.ML";
  PolyML.Project.make "src/proof/export_thm.ML";                          
  PolyML.Project.make "src/proof/export_isar.ML";      
*)


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*                               Update heaps                              *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

PolyML.Project.Log.log 2 "checking if heap is newer than edits...";

if PolyML.Project.heap_is_newer_than_edits "heaps/psgraph_child.heap"
then PolyML.Project.Log.log 2 "NO"
else 
 (PolyML.Project.Log.log 2 "YES...building child heap...";
  PolyML.Project.ensure_at_latest_heap ();
  PolyML.Project.save_project_child_state "heaps/psgraph_child.heap");
  
PolyML.Project.Log.log 2 "done.";

