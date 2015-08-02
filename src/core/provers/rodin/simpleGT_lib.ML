structure SimpleGT_Lib  = 
struct
  open RodinHelper Rodin RJP PredicateTag
 (******************************** 
 GT_top_symbol_is
 ********************************)

           (*         

  fun GT_has_hyps_with_subterm subterm context _ _ _ =
    let val hyps=get_hyps_with_subterm subterm context;
        val result= case hyps of [] => false
                               | hyplist => true
     in result
     end *)

  

end
open SimpleGT_Lib;
