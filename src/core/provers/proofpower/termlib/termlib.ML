structure PPTermLib =
struct

(* op ~~ : is a zipper-like op for two list*)
  type pos = int list
  
  fun eq_pos (pos1, pos2) = 
    let 
      fun if_eq pos1 (x :: xs) = if ( hd pos1 = x) then if_eq (tl pos1) xs else false
        | if_eq _ [] = true
    in 
      if List.length pos1 = List.length pos2 then if_eq pos1 pos2 else false
    end
  
  fun strip_comb u  =
    let fun stripc (t, tl) = 
      let val (a,b) = (dest_app t) in
      	stripc (a, (b :: tl))
      handle _ => (a, b::tl) end;
    in  stripc(u,[]) end
    handle _ => (u, []);
    
  fun root_of_trm trm = fst (strip_comb trm)
  fun subtrm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(strip_comb t), x))) pos trm
  fun trm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(strip_comb t), x))) pos trm 
                           |> fst o strip_comb
                           
                       
end (* end of struck TermLib *)
