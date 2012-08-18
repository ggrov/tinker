theory ienv
imports IsaP Main
begin

-- "Example of how to use Instantiation Environments"
ML {*

(* construct a context which lets us read schematic terms *)
val context = 
    ProofContext.set_mode (ProofContext.mode_schematic) @{context};

(* read in two terms *)
val t1 = Syntax.read_term context "(?a :: nat) + ?b * ?c";
val t2 = Syntax.read_term context "(?a :: nat) + (?e + ?f) * ?c";

(* make instantiation environment *)
val ienv = InstEnv.init (ProofContext.theory_of context);
 structure foo2 = struct open InstEnv; end;
*}

ML {* 
(* do matching, instantiate t1: matches *)
val (SOME ienv') = MyUnify.match [(t1,t2)] ienv;
InstEnv.print ienv';
*}

ML {* 
(* do matching, instantiate t2: doesn't match *)
val NONE = MyUnify.match [(t2,t1)] ienv;


*}

end;