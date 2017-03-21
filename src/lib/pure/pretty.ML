(* a naive version of Pretty *)
signature PRETTY =
sig
  type T;
  val str: string -> T
  val block: T list -> T
  val writeln: T -> unit
  val string_of: T -> string
  val chunks: T list -> T
  val fbrk: T
  val list: string -> string -> T list -> T
  val enclose: string -> string -> T list -> T
  val indent : int -> T -> T
  val unformatted_string_of: T -> string
  val symbolic_string_of: T -> string
  val separate: string -> T list -> T list
  
end;

structure Pretty: PRETTY =
struct
local open Basics in 

 type T = string;
 
 val str = I;
 val fbrk = "" 
 

 fun block pl = fold (fn x => (fn y => x^y)) pl "";
 fun chunks pl = fold (fn x => (fn y => x^y^"\n")) pl "";
 fun list pre post pl = pre ^ (chunks pl) ^ post

 fun enclose lpar rpar par = block(lpar :: (par @ [rpar]))
 fun indent nspace par = " " ^ par;

 val string_of = I;
 val unformatted_string_of = I;
 val symbolic_string_of = I;

 fun separate sep l = 
  case l of [] => l
  | _ => 
    let val last = rev l |> hd in 
      rev l |> tl |> rev |> map (fn x => x ^ sep) |> (fn xs => xs @ [last]) end

 fun writeln pretty = print pretty;
end;(* end of local open *)
end;
