signature TYPE_SET =
sig
  type T
  val compare : T * T -> order option
end

functor NaiveSetFun (t : TYPE_SET) = 
struct
  type T = t.T  
  type set = T list
  
  val compare = t.compare
  val (id : set) = []
  fun is_empty s = case s of [] => true | _ => false
  fun member e s = List.filter (fn x => case compare (e,x) of (SOME EQUAL) => true | _ => false) s 
                   |> List.length |> (fn x => if x > 0 then true else false)

  fun insert e s = if member e s then s else e :: s

  fun remove e (m :: s) = (case compare (e,m) of (SOME EQUAL) => (remove e s) | _ => [m] @ (remove e s))
    | remove _ [] = []

  fun union (a, s) = fold insert s a
  fun inter (a, (m::b)) = if member m a then [m] @ (inter (a, b)) else inter (a, b)
    | inter (_, []) = []

  fun size (m :: a) = (1 : int) + size(remove m a) 
    | size [] = 0

  (* use union to remove redundences *)
  fun to_list (data : set) = union (id, data)
  fun from_list (l : T list) = union (id, l)
  val from_single_list = fn x => from_list [x] 
end
