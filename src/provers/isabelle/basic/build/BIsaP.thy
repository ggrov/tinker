(* simple test of proof representation *)
theory BIsaP                                             
imports       
  "../../../../build/isabelle/BasicIsaPS"                                                                               
begin 
 
 ML_file "../isa_prover.ML"               

ML{*
  val rtechn_tracing = (*tracing*) (fn _ => ());
*}
(* rippling *) 
 ML_file "../../termlib/rippling/basic_ripple.ML" 
(* induction *)
 ML_file "../../termlib/induct.ML"

 ML_file "../simple_goaltyp.ML"  
                            

ML{*
   structure GT : BASIC_GOALTYPE = SimpleGoalTyp;
   structure Data = PSGraphDataFun(GT);
*}

ML{*
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
*}
ML{*
structure Theory = PSGraph_TheoryFun(SimpleGoalTyp);
*}
ML{*
structure PSGraph = PSGraphFun(Theory);
*}     
          
ML{*
 PSGraph.empty;
*}

ML{*
structure EData =  EDataFun( PSGraph);
structure EVal = EValFun(EData);

*}
end



