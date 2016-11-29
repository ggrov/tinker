
structure StrTable = Table(struct type key = string; val ord = String.compare end);
structure TermFeatures =
struct
  local open PPTermLib in

  fun get_const_str t = 
    case dest_simple_term t of Const(a,_) => SOME a
    | _ => NONE


  fun top_level_const t = 
    let  val t' = dest_simple_term t in
      case t' of Var(_,_) => NONE
      | App(a,_) => top_level_const a
      | Const(a,_) => SOME t
      (*| Simple%lambda% (_,b) => top_level_const b*)
    end

  fun top_level_str t = 
    let  val t' = dest_simple_term t in
      case t' of Var(_,_) => NONE
      | App(a,_) => top_level_str a
      | Const(a,_) => SOME a
      (*| Simple%lambda% (_,b) => top_level_str b*)
    end
     
  fun const_pred str (Const (s,_)) = (str = s)
  |  const_pred _ _ = false;

  fun has_constant_by_str str t = 
    term_any (fn x => const_pred str (dest_simple_term x) ) t;

  fun has_constant subtrm t = term_any (fn x => subtrm ~=$ x) t;
  fun has_constants ss t = forall (fn s => has_constant s t) ss;
  

  end
end
