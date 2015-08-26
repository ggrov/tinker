(* simple test of proof representation *)
theory eval_test                                           
imports        
  "../build/BIsaP"    
begin

ML{*
local open Env_Tac_Utils in 
  
end
*}
ML{*
Scan.catch ($$ "x") (Symbol.explode "x := this is a term @{term a + b} and another term @{term \<not> ?y}")
handle RunCall.Fail msg => (writeln msg; raise Fail "hello");
*}

ML{*

scan_antiquto (Symbol.explode "@{term \"some term\"} ab");
(($$ "?" || $$ "!") --| (Scan.many (Symbol.is_blank)))  (Symbol.explode "!xyz_t :=");
Symbol.explode "term l"
|> (Scan.this_string "term" || Scan.this_string "thm")  --| (Scan.many (Symbol.is_blank));
scan_var (Symbol.explode "?xyz_t :=");
scan_type  (Symbol.explode "term  list  list");
scan_env_tac  (Symbol.explode "?xyz_t : term list list :=");

*}

ML{*
val scan_antiquto = Scan.this_string "@{" |-- ($$ "\"") --> 
val scan_def = Scan.repeat (Scan.until)

*}
ML{*
structure Prover = IsaProver; 
Prover.trm_of_string;
val scan_antiqu = (Scan.repeat (Scan.unless ( Scan.this_string "@{") (Scan.one Symbol.not_eof)));

scan_def (Symbol.explode "?x := this is a term @{term a + b} and another term @{term \<not> ?y}");

Symbol.explode "x @ \" y";
($$ "?" -- $$ "x" -- $$ "y" -- $$ " ") (Symbol.explode "?xy := this is a term @{term \"a + b\"} and another term @{term \<not> ?y}");
Scan.unless;

$$ "?" -- (Scan.repeat (Scan.unless ( $$ ":=") (Scan.one Symbol.not_eof)));
(Symbol.explode " @{term \<not> ?y}");
Scan.catch ($$ "?x") (Symbol.explode "?x := this is a term @{term a + b} and another term @{term \<not> ?y}")
handle RunCall.Fail msg => (writeln msg; raise Fail "hello")

*}
end



