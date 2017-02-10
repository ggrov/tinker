theory LoadQuantoLib16
  imports
  Main                              
  "../../../../../quantomatic/core/quanto"  
  (* a lightweight version of the quantomatic lib, including isalib *)         
begin 

ML{*

  exception RunCallFail = Fail;
(*  fun eval_text text = ML_Context.eval ML_Compiler.flags (Position.start) (ML_Lex.read (Position.start) text); *)
 val eval_text = ML_Compiler0.ML  
  (ML_Compiler0.make_context ML_Name_Space.global)
  {debug = false, file = "", line = 1, verbose = true}
*}  

end
