theory TinkeringRodin
imports       
  "../../build/isabelle/Tinker"                                                                               
begin 

(* TODO: move rodin prover here *)

ML{*
  structure SimpleGoalType : BASIC_GOALTYPE = SimpleGoalType_Fun(structure Prover = RodinProver val struct_name = "SimpleGoalType");
  structure Data = PSGraphDataFun(SimpleGoalType);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = SimpleGoalType  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory)
  structure PSGraph = PSGraphFun(structure Theory_IO = Theory_IO);
  structure PSComb = PSCombFun (structure PSGraph = PSGraph)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (IEVal);
  structure Env_Tac_Lib = EnvTacLibFunc (Theory);
*}

ML{*  open Env_Tac_Lib  *}
