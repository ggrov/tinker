structure PpProver : PROVER =
struct

  type pos = int list
  type typ = TYPE
  type term = TERM
  type thm = THM
  type tactic = TACTIC
  type context = string list * string (* context string list * theory string *)
  (* get_current_pc () open_theory, set_pc *)

  exception gterm_exp
  
  val current_ctxt = get_current_pc (); (* used in those place need context in general *)
  val typ_of = type_of
  fun match ctxt = (op ~=$) 

  fun eq_pos (pos1, pos2) = 
    let 
      fun if_eq pos1 (x :: xs) = if ( hd pos1 = x) then if_eq (tl pos1) xs else false
        | if_eq _ [] = true
    in 
      if List.length pos1 = List.length pos2 then if_eq pos1 pos2 else false
    end
    
  fun intlist_of_pos pos = pos
  fun pos_of_intlist il = il
  
    fun strip_comb u  =
    let fun stripc (t, tl)= 
	 let val (a,b) = (dest_app t) in
           stripc (a, (b :: tl))
	handle _ => (a, b::tl) end;
    in  stripc(u,[])  end;
    

  fun root_of_trm trm = fst (strip_comb trm)
  fun subtrm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(strip_comb t), x))) pos trm
  fun trm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(strip_comb t), x))) pos trm 
                           |> strip_comb 
                           |> fst;
  val concl_of_thm = concl
  val asms_of_thm =  asms
  (* get asm of thm - asms*)
  fun trm_of_string _ = mk_string 

  
(* TODO: how to print those fancy symbols in proofpower ?*)
  fun string_of_trm _ = fn trm => PrettyPrinter.format_term true trm |> String.concat
  fun pretty_trm dummy t = string_of_term t |> Pretty.str

 
  
  structure Sharing = 
  struct
    type pos = pos
    type typ = typ
    type term = term
    type thm = thm
    type context = context
    type tactic = tactic
  end
end
