theory rodin_main

imports "../../../../core/build/isabelle/BasicGoalTyp"
begin   
ML_file "../../../../core/logging_handler.ML"
ML_file "../../../../core/interface/text_socket.ML"
ML_file "./interface/unicode_helper.ML"
ML_file "./interface/rodin_socket.ml"
ML_file "./interface/raw_source.ML"
ML_file "./interface/json.ML"
ML_file "./interface/io.ML"
ML_file "./interface/json_io.ML" 
ML_file "./interface/interface.ML" 
ML_file "./interface/rodin_prover.ML"
ML_file "./interface/rodin_extra.ML"

ML
{*
  
  fun simple_tag_tac tag =
  let open PredicateTag;
    val result=
       if tag= PredicateTag.LAND then "conjI" else
       if tag= PredicateTag.LIMP then "impI" else
       if tag= PredicateTag.FORALL then "allI" else 
       "hyp"
       
  (* raise error "UNHANDLED TAG" *)
  in 
    result 
  end

   fun prove (node::xs) limit = 
     (if limit>0 then
        let
            val tag=RodinProverExtra.get_pnode_goal_tag node;
            val tactic=simple_tag_tac tag;
            val tag_result =RodinProver.apply_tactic tactic (node,"");
            val (nodes,_) = Seq.hd tag_result;
            val new_open_nodes= List.concat [nodes , xs]
        in
           prove new_open_nodes (limit-1)
        end
     else
        raise error "Failed to prove within limit steps") 
    | prove [] _ = ("Proof Done"; Rodin.close "")
  
  (* start will always be a singleton list with only one node in it,   
   * for this is the case when user select one node in Rodin *)         
   val start =  ( RodinProver.get_open_pnodes "");  
  prove start 50;     
*}

end

