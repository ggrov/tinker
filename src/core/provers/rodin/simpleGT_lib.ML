structure SimpleGT_Lib  = 
struct
  open RodinHelper RJP
 (******************************** 
 GT_top_symbol
 ********************************)
 fun GT_top_symbol symb context _ _ _ = 
 let val reply = execute ("GET_PNODE_GOAL_TYPE",[("GOAL_TYPE","TOP_SYMBOL"),("CONTEXT",context),("SYMBOL",symb)])
     val result= getParam reply "RESULT"
 in
    case result of "true" => true
                  | _    => false
 end

end
open SimpleGT_Lib;
