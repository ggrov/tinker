theory method_test
imports Main
begin
(*  setup two methods for testing *)
ML{*
K;
SIMPLE_METHOD; 

Scan.succeed
      (K (SIMPLE_METHOD ((etac @{thm conjE} THEN' rtac @{thm conjI}) 1)));
Scan.lift (Scan.succeed (Method.succeed));
Scan.lift (Scan.succeed (fn ctxt => Method.cheating true ctxt));

fun case_tac ctxt a = res_inst_tac ctxt [(("P", 0), a)] @{thm case_split};
Args.goal_spec -- Scan.lift Args.name_source >>
    (fn (quant, s) => fn ctxt => SIMPLE_METHOD'' quant (case_tac ctxt s));
*}

method_setup dummyPrint =
{* Scan.lift (Scan.succeed ((fn x => (writeln "i'm dummy"; Method.succeed)))) *}
" dummyPrint do nothing but print a string "


lemma "a = a"
apply dummyPrint



print_methods;
end
