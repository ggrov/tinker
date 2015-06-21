(* simple test of proof representation *)
theory PSGraph                                                                               
imports         
  Graph                 
begin 

ML{*
*}

  ML_file "../../psgraph/psgraph.sig.ML"        
  ML_file "../../psgraph/psgraph.ML"      
  ML_file "../../psgraph/psgraph_comb.ML" 

ML{*


 fun build_tac_code_with_arg tac_code tac_args = 
  let
    fun concat a b = b ^ " "  ^ a;
    val tac_args' = 
      (* there should not be empty list *)
      map (fn l => case l of [x] => [x] | (x :: xs) => (x :: ":" :: xs)) tac_args;
    val args = 
      case tac_args' of [] => ""
      | _ => map (fn x => "(" ^ (fold concat x "") ^ " )" ) tac_args'
            |> (fn y => fold concat y "")
  in
     tac_code ^ args
  end;

build_tac_code_with_arg "a_tac" [["arg1"], ["arg2", "int", "list"], ["a", "int"]];
*}
end                                



