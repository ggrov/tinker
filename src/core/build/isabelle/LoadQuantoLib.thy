theory LoadQuantoLib
imports
  Main
  "~~/contrib/quantomatic/core/quanto"  

begin 
(* ML_file "inject.ML" *)

ML{*

val eval_name_space = ML_Env.name_space {SML=false, exchange=false};
val eval_context: use_context =
 {tune_source = #tune_source  ML_Env.local_context,
  name_space = eval_name_space,
  str_of_pos = #str_of_pos  ML_Env.local_context,
  print = #print  ML_Env.local_context,
  error = #error  ML_Env.local_context};

  (*  fun eval_text text = ML_Context.eval ML_Compiler.flags (Position.start) (ML_Lex.read (Position.start) text); *)
    fun eval_text text =(
      (*writeln ("exec : "^ text);*)
      Secure.use_text eval_context (*ML_Env.local_context*) (1, "ML") (false) text  
    ) handle exn => raise exn;
  
*}  

end
