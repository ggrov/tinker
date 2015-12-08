  (* name of class *)
  structure C = 
   struct 
     open SStrName;
     val default_name = mk "Ca"; 
   end;

  (* name of class feature *)
  structure F = 
   struct 
     open SStrName;
     val default_name = mk "Fa"; 
   end;
 
   (* name of links *)
  structure L = 
   struct 
     open SStrName;
     val default_name = mk "La"; 
   end; 

  (* name of goal type *)
  structure G = 
   struct 
     open SStrName;
     val default_name = mk "Ga"; 
   end;

 fun str_chunks l = 
  let fun c (a,b) = a ^ "\n" ^ b; val l' = rev l in 
  case l of [] => "" | _ =>
  List.foldl c (hd l') (tl l') end;
 fun str_blocks comb l = 
  let fun c (a,b) = a ^ comb ^ b; val l' = rev l in
  case l of [] => "" | _ => 
  List.foldl c (hd l') (tl l') end;
 
 val gui_version = "0.4"

