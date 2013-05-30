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


  val data_to_json : data -> Json.json
  val data_from_json : Json.json -> data
  val data_ll_to_json : data list list -> Json.json
  val data_ll_from_json : Json.json -> data list list
  

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

(****************************
*  for json
******************************)
  exception EXP_PARSING_JSON of string
  fun get_el_from_list str strl = 
    List.filter (fn (x,_) => case (String.compare (str, x)) of EQUAL => true | _ => false) strl |> hd
  handle _ => raise EXP_PARSING_JSON ("Unknown type constructor \""^str^"\"")

  (* FIXME: term doesn't work*)
  fun data_to_json (Int i) = Json.mk_object [("Feature_Int", Json.Int i)]
    | data_to_json (String s) = Json.mk_object [("Feature_Str", Json.String s)]
    | data_to_json (Term t) = Prover.string_of_trm Prover.globe_ctxt t 
        |> (fn x => Json.mk_object [("Feature_Trm", Json.String x)])
    | data_to_json (Position p) = 
        Json.mk_object [("Feature_Pos", map Json.Int (Prover.intlist_of_pos p) |> Json.Array)]
    | data_to_json (Bool b) = Json.mk_object [("Feature_Bool", Json.Bool b)]
    | data_to_json (DVar d) = Json.mk_object [("Feature_DVar", Json.String (F.string_of_name d))]

  fun data_from_json (Json.Object jobj) = 
    let 
      val typStr = Json.properties jobj |> hd;
      val typList = [("Feature_Int", (1 : int)), ("Feature_Str", (2 : int)), 
                     ("Feature_Trm", (3 : int)), ("Feature_Pos", (4 : int)), 
                     ("Feature_Bool", (5 : int)), ("Feature_DVar", (6 : int))]
    in
      get_el_from_list typStr typList 
      |> snd
      |> (fn x => case x of 1 => let val (Json.Int i) = Json.get jobj typStr in Int i end
                           | 2 => let val (Json.String s) =  Json.get jobj typStr in String s end
                           | 3 => raise EXP_PARSING_JSON "Not support terom from json"(*let val (Json.String t) = Json.get jobj typStr in Term t end*)
                           | 4 => let val (Json.Array ary) = Json.get jobj typStr in 
                                    Prover.pos_of_intlist (map (fn (Json.Int i) => i) ary) |> Position end
                           | 5 => let val (Json.Bool b) = Json.get jobj typStr in Bool b end
                           | 6 => let val (Json.String s) =  Json.get jobj typStr in F.mk s |> DVar end
          )
    end
    | data_from_json _ = raise EXP_PARSING_JSON "Not a Json object type."


  fun data_ll_to_json dll =
  let 
    fun list_to_json dl = map (fn x => data_to_json x) dl |> Json.Array
  in
    map list_to_json dll |> Json.Array
  end
    
  fun data_ll_from_json  (Json.Array j) = map (fn (Json.Array x) => map (data_from_json) x) j
  | data_ll_from_json _ = raise EXP_PARSING_JSON "Not a Json array type."


    structure Sharing = 
    struct
      type data = data;
      structure Prover = Prover.Sharing;
    end

end (* structure *)


