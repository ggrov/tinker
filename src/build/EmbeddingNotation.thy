header {* IsaPlanner Embedding Notation *}

theory EmbeddingNotation
imports Pure
begin

section {* Rippling Notation *}

consts embWF :: "'a => 'a" -- "extra dest stuff => dest T"
consts embSVar :: "'a => 'b => 'b" -- "src Var => dest stuff => dest T"
consts embDVar :: "'a => 'b => 'b" -- "src stuff => dest Var => dest T"
consts embInBnd :: "'a => 'a" -- "dest bnd => dest T"
consts embRFree :: "'a => 'b => 'b" -- "src Free => dest Free => dest T"

(* Note: wave holes are not strictly needed, but save pulling out
   funny abstractions that make the pretty print look big and ugly *)
consts embWH :: "'a => 'a" -- "src stuff again => dest T"


(* Only works in interactive mode ...

text {* ML code to allow the 'term' command to read in terms with
schematic vars. Largely a copy of code from Isabelle. *}

-- {* A hacked $term$ outer command that allows meta-variables *}
ML {* 
structure P = OuterParse and K = OuterKeyword;

val opt_modes = 
  Scan.optional (P.$$$ "(" |-- P.!!! (Scan.repeat1 P.xname --| P.$$$ ")")) [];

fun string_of_term state s =
  let
    val ctxt = (ProofContext.set_mode ProofContext.mode_schematic 
                                      (Proof.context_of state));
    val t = Syntax.read_term ctxt s;
    val T = Term.type_of t;
  in
    Pretty.string_of
      (Pretty.block [Pretty.quote (Syntax.pretty_term ctxt t), Pretty.fbrk,
        Pretty.str "::", Pretty.brk 1, Pretty.quote (Syntax.pretty_typ ctxt T)])
  end;

fun print_term string_of (modes,arg) = 
  Toplevel.keep (fn state =>
    PrintMode.with_modes modes (fn () =>
      writeln (string_of (Toplevel.enter_proof_body state) arg)) ());

val _ =
  OuterSyntax.improper_command "term" "read and print term" OuterKeyword.diag
    (opt_modes -- P.term >> (Toplevel.no_timing oo (print_term string_of_term)));
*}

term "f a ?b c" -- "src"
term "f (Suc a) x ?y" -- "dest unannotated"
term "f (embWF Suc a) (embSVar ?b x) (embDVar c ?y)" -- "dest annotated"

term "r a b"; -- "relation0"
term "r b c"; -- "relation1"
term "r a x"; -- "src"
term "r c (f x)"; -- "dest unannotated"
term "r (embRFree a c) (embWF f x)"; -- "dest annotated"

(* possible infix notation... tends to clash with other theories 
("[< _ >]")
("[> _ <]")
("'\ _ '/")
("[R _ _ ]")
*)
*)

end;
