signature GOALTYP_DATA_SHARING =
sig
  type data
  structure Prover : PROVER_SHARING
end

signature GOALTYP_DATA =
sig
 
  structure Prover : PROVER
 
  datatype data = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of Prover.term (*Prover.term*)
    | Position of Prover.pos
    | Bool of bool
    | DVar of F.name (* variable: not used at the moment but may be required *)

  val match_data : (data * data) -> bool
  val match_data_ll : (data list list * data list list) -> bool

  structure Sharing : GOALTYP_DATA_SHARING
    sharing type Sharing.data = data
    sharing Sharing.Prover = Prover.Sharing
      
end (* signature *)

functor GoalTypDataFun (Prover: PROVER)  : GOALTYP_DATA =
struct

  structure Prover = Prover

  datatype data = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of Prover.term (* must be generalised beyond TP system *) 
    | Position of Prover.pos
    | Bool of bool
    | DVar of F.name (* variable: not used at the moment but may be required *)

  fun match_data ((Int a), (Int b)) = (a = b)
    | match_data ((String a), (String b)) = (case String.compare (a,b) of EQUAL => true | _ => false)
    | match_data ((Term a), (Term b)) =  Prover.match Prover.globe_ctxt (a,b) (*(case String.compare (a,b) of EQUAL => true | _ => false)*)
    | match_data ((Position a), (Position b)) = Prover.eq_pos (a,b)
    | match_data ((Bool a), (Bool b)) =  (a = b)
    | match_data ((DVar a), (DVar b)) = (case F.name_ord (a,b) of EQUAL => true | _ => false)
    | match_data (_,_) = false

  fun match_data_ll ((a : data list list),b) =
    let 
      fun zip [] [] = []
        | zip (x :: xs) (y :: ys) = (x,y) :: (zip xs ys);
      fun match_flist ((l1 : data list),l2) = 
        (if (List.length l1 = List.length l2)
        then
           not (List.exists (fn (x,y) => if match_data (x,y) then false else true) (zip l1 l2))
        else false);
      fun member e s = List.filter (fn x => match_flist (e,x)) s |> List.length |> (fn x => (x > 0))
      fun insert e s = (if member e s then s else e :: s)
      fun remove e (m :: s) = (if match_flist (e,m) then remove e s else [m] @ (remove e s))
        | remove _ [] = []
      fun union (a, s) = fold insert s a
      fun inter (a, (m::b)) = if member m a then [m] @ (inter (a, b)) else inter (a, b)
        | inter (_, []) = []
      fun size (m :: a) = (1 : int) + size(remove m a) 
        | size [] = 0
    in
      size (union (a,b)) = size (inter (a,b))
    end

    structure Sharing = 
    struct
      type data = data;
      structure Prover = Prover.Sharing;
    end

end (* structure *)


