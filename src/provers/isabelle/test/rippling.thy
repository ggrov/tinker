theory rippling
imports "../build/basic/RTechn"
begin
(* wrapping trm with name structure *)
  ML_file "../../../rtechn/rippling/embedding/paramtab.ML" 
  ML_file "../../../rtechn/rippling/embedding/trm.ML"  
  ML_file "../../../rtechn/rippling/embedding/isa_trm.ML"
  ML_file "../../../rtechn/rippling/embedding/instenv.ML"
  ML_file "../../../rtechn/rippling/embedding/typ_unify.ML"   

(* embeddings *)
  ML_file "../../../rtechn/rippling/embedding/eterm.ML"  
  ML_file "../../../rtechn/rippling/embedding/ectxt.ML" 
  ML_file "../../../rtechn/rippling/embedding/embed.ML" 
  
(* measure and skeleton *)
  ML_file "../../../rtechn/rippling/measure_traces.ML"
  ML_file "../../../rtechn/rippling/measure.ML" 
  ML_file "../../../rtechn/rippling/flow_measure.ML"
  ML_file "../../../rtechn/rippling/dsum_measure.ML" 
  ML_file "../../../rtechn/rippling/skel.ML" 
  ML_file "../../../rtechn/rippling/skel_mes_traces.ML" 



(* Rippling wave rules DB from theory *)
  ML_file "../../../rtechn/rippling/wrulesdb.ML"  
  ML_file "../../../rtechn/rippling/wrules_gctxt.ML"

(* rippling technique *)
  ML_file "../../../rtechn/rippling/basic_cinfo.ML" 
  ML_file "../../../rtechn/rippling/basic_rtechn.ML"


ML{*
(* used to import embedding to psgraph, one question is how to port to pp, embedding is working now  *)
val tgt = @{term "(a \<union> e) \<union> b"};
val src = @{term "((a \<union> c) \<union> (e \<union> c))  \<union> (b \<inter> c)"};

val ienv = (InstEnv.init @{context});
val ectxt = Embed.Ectxt.init ienv ParamRGraph.empty;
val embeding = Embed.embed ectxt tgt src |> Seq.list_of |> hd;
Embed.print embeding;
*}
end
