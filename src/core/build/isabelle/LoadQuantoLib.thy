theory LoadQuantoLib
imports
  Main
  "~~/contrib/quantomatic/core/quanto"  

begin 
(* ML_file "inject.ML" *)

ML{*
   fun eval_text text = ML_Context.eval ML_Compiler.flags (Position.start) (ML_Lex.read (Position.start) text);
  (*  fun eval_text text =(
    writeln ("exec : "^ text);
    Secure.use_text ML_Env.local_context (1, "ML") (false) text  ) *)
 
  
*} 
end
