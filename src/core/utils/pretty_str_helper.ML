structure PrettyStrHelper = 
struct 
 fun tab i = if i < 1 then "" else ("  " (* two space*) ^ tab (i-1));

 fun str_chunks_tab i l  = 
  let fun c (a,b) = (tab i) ^ a ^ "\n" ^ (tab i) ^ b; val l' = rev l in 
  case l of [] => "" | [x] => (tab i) ^ x | _ =>
  List.foldl c (hd l') (tl l') end;

 fun str_chunks l = str_chunks_tab 0 l ;
 
 fun str_blocks comb l = 
  let fun c (a,b) = a ^ comb ^ b; val l' = rev l in
  case l of [] => "" | _ => 
  List.foldl c (hd l') (tl l') end;

 fun str_subst0 str (tab: (string*string) list) (tab0: (string*string) list) = 
  let fun substr (s,i,j) = if (i = j ) then "" else String.substring (s,i,j-i) in 
   if String.size str = 0 then ""
   else (
    if tab0 = [] 
    then String.substring (str, 0, 1) ^ 
     str_subst0 (substr(str, 1, String.size str)) tab tab
    else ( 
     if String.isPrefix (fst(hd tab0)) str 
     then snd(hd tab0) ^ str_subst0 (substr(str, String.size (fst(hd tab0)), String.size str)) tab tab
     else str_subst0 str tab (tl tab0)))
  end;
  
 fun str_subst tab str = str_subst0 str tab tab;
end

open PrettyStrHelper