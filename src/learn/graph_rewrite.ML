structure GraphRewrite = 
struct

  (* functions to rewrite and return the hierarchical rule *)
  val rewrite = EvalAtomic.rewrite;

  fun REPEAT_MAX' rule gs = 
    let
      val gs' = maps (rewrite rule) gs
    in
     case gs' of
       [] => gs
      | gs' => REPEAT_MAX' rule gs'
    end;

  fun REPEAT_MAX rule g = REPEAT_MAX' rule [g];

   
end;



