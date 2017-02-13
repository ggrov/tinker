theory LoadQuantoLib
  imports
  Main                              
  (*"../../../../../quantomatic/core/quanto"*)
  "~~/contrib/quantomatic/core/quanto"
begin 

ML{*
Induct.induct_tac;
  exception RunCallFail = Fail;
(*  fun eval_text text = ML_Context.eval ML_Compiler.flags (Position.start) (ML_Lex.read (Position.start) text); *)
 val eval_text = ML_Compiler0.ML ML_Env.context
  {debug = false, file = "", line = 0, verbose = false}
*}  
  
 
ML{*
(* a quick test for the use of the top level context for eval ML code *)
  eval_text "eval_text";
*}

end
