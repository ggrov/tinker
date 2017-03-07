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
  

end;

structure Pretty: PRETTY =
struct
 type T = string;
 
 val str = I;
 val fbrk = "" 
 

 fun block pl = fold (fn x => (fn y => x^y)) pl "";
 fun chunks pl = fold (fn x => (fn y => x^y^"\n")) pl "";
 fun list pre post pl = pre ^ (chunks pl) ^ post

 val string_of = I;
 
 fun writeln pretty = print pretty;
 
end;
