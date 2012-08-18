(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./base/Isar/isar_attr.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Created:    14 Oct 2004
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    the basic Isar language Attributes, in a declarative form
*)

structure IsarAttr = 
struct 

(* rule format attribute for theorems... *)
structure RuleFormat : DTHM_ATTR_INST = 
DThmAttrInstFUN(
  structure K = struct
  (* trick: put context as data and thus get attribute out of context *)
  type T = Context.generic; 
  val name = "rule_format"
  fun prettyf gctxt = Pretty.str ("rule_format");
  fun attrf gctxt th = 
      snd (Attrib.attribute (Context.theory_of gctxt)
                            (Args.src (("rule_format", []), 
                                       Position.none))
                            (gctxt,th));
  fun eq x y = true; (* dummy: just say yes for all data - no real data to check *)
  end);


  (* need to be given outer theory so thay new kinds of symmetry can
  be used simply by examining the theory symmetries, e.g. == is
  defined before it's symmmetry argument, so any theorems defined
  early on must use a newer theory to get symmrtty attribute *)
structure Symmetric : DTHM_ATTR_INST = 
DThmAttrInstFUN(
  structure K = struct
  type T = Context.generic;
  val name = "symmetric";
  fun eq x y = true; (* dummy: just say yes for all data - no real data to check *)
  fun prettyf gctxt = Pretty.str ("symmetric");
  fun attrf gctxt th = 
      snd (Attrib.attribute (Context.theory_of gctxt)
                            (Args.src (("symmetric", []), 
                                       Position.none)) 
                            (gctxt,th))
  end);

end; (* IsarAttr *)
