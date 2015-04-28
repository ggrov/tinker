theory LoadQuantoLib
imports
  Main
  "~~/contrib/quantomatic/core/quanto"  

begin 
ML{*
  fun eval_text text = ML_Context.eval ML_Compiler.flags (Position.start) (ML_Lex.read (Position.start) text)
*} 
end
