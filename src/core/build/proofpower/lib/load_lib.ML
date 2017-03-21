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
fun curry f x y = f (x, y);
fun uncurry f (x, y) = f x y;

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

infix 2 ?
infix 3 o oo ooo oooo
(*conditional application*)
fun b ? f = fn x => if b then f x else x;
(*composition with multiple args*)
fun (f oo g) x y = f (g x y);
fun (f ooo g) x y z = f (g x y z);
fun (f oooo g) x y z w = f (g x y z w);


(* a pretedned Unsynchronized.ref*)
(* load libraries *)
OS.FileSys.chDir (tinkerhome ^ "/src/lib");
(* some libraries from Isabelle/Pure *)
(* exception and multi-threading *)
use "pure/exn.ML";

(* utils *)
use "pure/lib.ML";
use "pure/table.ML";
use "pure/scan.ML";
use "pure/symbol.ML";
use "pure/pretty.ML";
use "pure/seq.ML";

structure Library = PureLib;
open Basics PureLib Thread;

fun print_exception_trace (_: exn -> string) = PolyML.exception_trace;
val seconds = Time.fromReal;
use "pure/multithreading.ML";
use "pure/multithreading_polyml.ML";
use "pure/unsynchronized.ML";
use "pure/simple_thread.ML";
use "pure/synchronized.ML";
(* isalib *)
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
