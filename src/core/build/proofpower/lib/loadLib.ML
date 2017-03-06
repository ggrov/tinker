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

val backdoor_use_file = use_file;

(* some useful combinators from isabelle *)
infix 1 |> |>> |-> ||> ||>>;
fun I x = x;
fun K x = fn _ => x;
fun x |> f = f x;
fun (x, y) |>> f = (f x, y);
fun (x, y) |-> f = f x y;
fun (x, y) ||> f = (x, f y);
fun (x, y) ||>> f = let val (z, y') = f y in ((x, z), y') end;

infix 1 #> #-> #>> ##> ##>>
(*composition and structured results*)
fun (f #> g) x   = x |> f |> g;
fun (f #-> g) x  = x |> f |-> g;
fun (f #>> g) x  = x |> f |>> g;
fun (f ##> g) x  = x |> f ||> g;
fun (f ##>> g) x = x |> f ||>> g;

(* a pretedned Unsynchronized.ref*)
structure Unsynchronized = struct datatype ref = datatype ref end;
(* load libraries *)
OS.FileSys.chDir (tinkerhome ^ "/src/lib");
(* some libraries from Isabelle/Pure *)
use "pure/lib.ML";
use "pure/exn.ML";
use "pure/table.ML";
use "pure/scan.ML";
use "pure/symbol.ML";
(*use "pure/pretty.ML";*)
structure Library = PureLib;
open PureLib;
use "isalib.ML" ;
OS.FileSys.chDir (build_path);


(*restore functions*)
exception Fail  = backdoor_Fail;
val diff = backdoor_diff;
val THEN = backdoor_THEN;
val ORELSE = backdoor_ORELSE;
val from = backdoor_from;
val to = backdoor_to;
val use_file = backdoor_use_file;

(*val EQUAL = E%Q%UAL;*)

infix 4 diff;
infix 4 THEN;
infix 4 ORELSE;
infix 5 from;
infix 5 to;
