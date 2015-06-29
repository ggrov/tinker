(* simple test of proof representation *)
theory CIsaP                                             
imports       
  "../../../build/isabelle/BasicIsaPS"                                                                               
begin     
 -- "the goaltype"
 ML_file "../../../goaltype/clause/goaltype.ML"                                                                                                                        

 -- "the prover"  
 ML_file "../basic/isa_prover.ML"   

 -- "setting up PSGraph"
 ML{*
   structure GT : BASIC_GOALTYPE  = ClauseGTFun(IsaProver); 
   structure Data = PSGraphDataFun(GT);   
   structure PSDataIO = PSGraphIOFun(structure Data = Data);
   structure Theory = PSGraph_TheoryFun(GT);
   structure PSGraph = PSGraphFun(Theory);
 *}     
 
 -- "setting up Evaluation"
 ML{*
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
 *}

end



