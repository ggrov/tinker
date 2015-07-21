structure SimpleGT_Lib  = 
struct
  open RodinHelper Rodin RJP PredicateTag
 (******************************** 
 GT_top_symbol_is
 ********************************)

  fun get_pnode_goal_tag pnode_name =
    let val reply=(execute  ("GET_PNODE_GOAL_TAG",[("NODE",pnode_name)]));
      in toInt (getParam reply "TAG")
    end

  fun get_top_symbol term pnode = 
    let val reply=execute ("GET_TOP_SYMBOL",[("NODE",pnode),("TERM",term)])
    in
      getParam reply "SYMBOL"
    end;
  
  fun get_hyps pnode =
    let val reply=execute ("GET_HYPS",[("NODE",pnode)])
    in
      getParamValues reply
    end

  fun sub_terms term pnode =
    let val reply= execute ("SUB_TERMS",[("TERM",term),("NODE",pnode)]);
    in 
      getParamValues reply
    end

  fun get_hyps_with_subterm subterm pnode = 
    let val hyps= get_hyps pnode;
        fun g (hyp::xs) pnode = 
            let val subterms=sub_terms hyp pnode
                fun match_all (term::txs) = (match pnode (subterm,term)) :: (match_all txs)
                  | match_all          [] = [];
                val match_result=match_all subterms
            in
                if match_result=[] then 
                  g xs pnode
                else
                  hyp::(g xs pnode)
                  
            end
        |  g [] _ = []
     in
        g hyps pnode
     end;
                   

  fun GT_has_hyps_with_subterm subterm context _ _ _ =
    let val hyps=get_hyps_with_subterm subterm context;
        val result= case hyps of [] => false
                               | hyplist => true
     in result
     end

  fun GT_top_symbol_is symb context _ _ _ =
    let val reply= execute ("TOP_SYMBOL_IS", [("CONTEXT",context),("SYMBOL",symb)])
    in
        case getParam reply "RESULT" of "true" => true | _ => false
    end;

end
open SimpleGT_Lib;
