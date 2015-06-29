theory LoadQuantoLib13
imports

    "~~/contrib/isaplib/isabelle/isaplib/isaplib"
    "~~/contrib/quantomatic/core/isabelle/QuantoCore"

begin 
(*ML_file "lib/raw_source.ML"*)
ML{* 
  structure RawSource = Source;
  val eval_text = ML_Context.eval_text true (Position.start);
*}
end
