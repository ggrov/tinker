structure List = SML97BasisLibrary.List;
structure Char = SML97BasisLibrary.Char;
exception backdoor_Fail = Fail;
exception Fail = RunCall.Fail;
(*Template to deal with the val which has been defined in pp but are used accidentally as fresh variables in isap and quanto 
val backdoor_ = ;
val _ = PolyML.Compiler.forgetValue "";
val _ = PolyML.Compiler.forgetFixity "";

*)
(*dtd001 imp001*)
val backdoor_from = from;
val _ = PolyML.Compiler.forgetValue "from";
val _ = PolyML.Compiler.forgetFixity "from";
(*dtd001 imp001*)
val backdoor_to = to;
val _ = PolyML.Compiler.forgetValue "to";
val _ = PolyML.Compiler.forgetFixity "to";
(*dtd001 imp001*)
val backdoor_diff = diff;
val _ = PolyML.Compiler.forgetValue "diff";
val _ = PolyML.Compiler.forgetFixity "diff";
(*THEN and ORELSE are redefeined in isap. Hopefully no legacy problem*)
(*dtd009 imp009*)
val backdoor_THEN = THEN;
val _ = PolyML.Compiler.forgetValue "THEN";
val _ = PolyML.Compiler.forgetFixity "THEN";
(*dtd009 imp009*)
val backdoor_ORELSE = ORELSE;
val _ = PolyML.Compiler.forgetValue "ORELSE";
val _ = PolyML.Compiler.forgetFixity "ORELSE";

use "ROOT.ML";

(*restore functions*)
exception Fail  = backdoor_Fail;
val diff = backdoor_diff;
val THEN = backdoor_THEN;
val ORELSE = backdoor_ORELSE;
val from = backdoor_from;
val to = backdoor_to;

infix 4 diff;
infix 4 THEN;
infix 4 ORELSE;
infix 5 from;
infix 5 to;

(*Export all files to a heap file*)
PolyML.Project.ensure_at_latest_heap ();
PolyML.shareCommonData run; PolyML.fullGC ();
PolyML.SaveState.saveState "zed_psgraph.heap";

(*The next step is to use "PolyML.SaveState.loadState" the heap file, and then "save_and_exit" in pp interface so
* that the isaplib + quanto + psgraph heap will stored in pp*)
