(* some useful combinators in isabelle *)
fun I x = x;
fun K x = fn _ => x;
fun x |> f = f x;

use "../../prover";
use "../pp_prover.ML";
