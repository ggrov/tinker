(*** Basics *)
val raw_explode = SML90.explode;
val implode = String.concat;
val pointer_eq = PolyML.pointerEq;

structure Basics =
struct
(* List *)
fun fold _ [] y = y
  | fold f (x :: xs) y = fold f xs (f x y);

fun fold_rev _ [] y = y
  | fold_rev f (x :: xs) y = f x (fold_rev f xs y);

val exists = List.exists;
fun cons x xs = x :: xs;
fun append xs ys = xs @ ys;
fun take (0: int) xs = []
  | take _ [] = []
  | take n (x :: xs) = x :: take (n - 1) xs;

fun chop (0: int) xs = ([], xs)
  | chop _ [] = ([], [])
  | chop n (x :: xs) = chop (n - 1) xs |>> cons x;

val forall = List.all;
end
(*** more utils *)
structure PureLib = 
struct
local open Basics in 
(*** option *)
fun is_some (SOME _) = true
  | is_some NONE = false;

fun is_none (SOME _) = false
  | is_none NONE = true;

fun the (SOME x) = x
  | the NONE = raise Option.Option;

fun these (SOME x) = x
  | these NONE = [];

fun the_list (SOME x) = [x]
  | the_list NONE = []

fun the_default x (SOME y) = y
  | the_default x NONE = x;

fun perhaps f x = the_default x (f x);

fun merge_options (x, y) = if is_some x then x else y;

fun eq_option eq (SOME x, SOME y) = eq (x, y)
  | eq_option _ (NONE, NONE) = true
  | eq_option _ _ = false;

(*** Pair *)
fun pair x y = (x, y);

fun eq_fst eq ((x1, _), (x2, _)) = eq (x1, x2);
fun eq_snd eq ((_, y1), (_, y2)) = eq (y1, y2);
fun eq_pair eqx eqy ((x1, y1), (x2, y2)) = eqx (x1, x2) andalso eqy (y1, y2);

fun swap (x, y) = (y, x);

fun apfst f (x, y) = (f x, y);
fun apsnd f (x, y) = (x, f y);
fun apply2 f (x, y) = (f x, f y);

(*rear decomposition*)
fun split_last [] = raise List.Empty
  | split_last [x] = ([], x)
  | split_last (x :: xs) = apfst (cons x) (split_last xs);

(*** more about list *)

fun single x = [x];

fun the_single [x] = x
  | the_single _ = raise List.Empty;

fun singleton f x = the_single (f [x]);

fun yield_singleton f x = f [x] #>> the_single;

fun perhaps_apply funs arg =
  let
    fun app [] res = res
      | app (f :: fs) (changed, x) =
          (case f x of
            NONE => app fs (changed, x)
          | SOME x' => app fs (true, x'));
  in (case app funs (false, arg) of (false, _) => NONE | (true, arg') => SOME arg') end;

fun perhaps_loop f arg =
  let
    fun loop (changed, x) =
      (case f x of
        NONE => (changed, x)
      | SOME x' => loop (true, x'));
  in (case loop (false, arg) of (false, _) => NONE | (true, arg') => SOME arg') end;

fun maps f [] = []
  | maps f (x :: xs) = f x @ maps f xs;

(*separate s [x1, x2, ..., xn]  ===>  [x1, s, x2, s, ..., s, xn]*)
fun separate s (x :: (xs as _ :: _)) = x :: s :: separate s xs
  | separate _ xs = xs;

val map_filter = List.mapPartial;


(*** sort *)
fun bool_ord (false, true) = LESS
  | bool_ord (true, false) = GREATER
  | bool_ord _ = EQUAL;

val int_ord = Int.compare;
val string_ord = String.compare;

fun fast_string_ord (s1, s2) =
  if pointer_eq (s1, s2) then EQUAL
  else (case int_ord (size s1, size s2) of EQUAL => string_ord (s1, s2) | ord => ord);

fun prod_ord a_ord b_ord ((x, y), (x', y')) =
  (case a_ord (x, x') of EQUAL => b_ord (y, y') | ord => ord);

fun mergesort unique ord =
  let
    fun merge (xs as x :: xs') (ys as y :: ys') =
          (case ord (x, y) of
            LESS => x :: merge xs' ys
          | EQUAL =>
              if unique then merge xs ys'
              else x :: merge xs' ys
          | GREATER => y :: merge xs ys')
      | merge [] ys = ys
      | merge xs [] = xs;

    fun merge_all [xs] = xs
      | merge_all xss = merge_all (merge_pairs xss)
    and merge_pairs (xs :: ys :: xss) = merge xs ys :: merge_pairs xss
      | merge_pairs xss = xss;

    fun runs (x :: y :: xs) =
          (case ord (x, y) of
             LESS => ascending y [x] xs
           | EQUAL =>
               if unique then runs (x :: xs)
               else ascending y [x] xs
           | GREATER => descending y [x] xs)
      | runs xs = [xs]

    and ascending x xs (zs as y :: ys) =
          (case ord (x, y) of
             LESS => ascending y (x :: xs) ys
           | EQUAL =>
               if unique then ascending x xs ys
               else ascending y (x :: xs) ys
           | GREATER => rev (x :: xs) :: runs zs)
      | ascending x xs [] = [rev (x :: xs)]

    and descending x xs (zs as y :: ys) =
          (case ord (x, y) of
             GREATER => descending y (x :: xs) ys
           | EQUAL =>
               if unique then descending x xs ys
               else (x :: xs) :: runs zs
           | LESS => (x :: xs) :: runs zs)
      | descending x xs [] = [x :: xs];

  in merge_all o runs end;

fun sort ord = mergesort false ord;
val sort_strings = sort string_ord;


(*** List as set *)
fun filter_out f = filter (not o f);
fun member eq list x =
  let
    fun memb [] = false
      | memb (y :: ys) = eq (x, y) orelse memb ys;
  in memb list end;


fun insert eq x xs = if member eq xs x then xs else x :: xs;
fun remove eq x xs = if member eq xs x then filter_out (fn y => eq (x, y)) xs else xs;
fun update eq x xs = cons x (remove eq x xs);

fun inter eq xs = filter (member eq xs);

fun union eq = fold (insert eq);
fun subtract eq = fold (remove eq);

fun merge eq (xs, ys) =
  if pointer_eq (xs, ys) then xs
  else if null xs then ys
  else fold_rev (insert eq) ys xs;

 (*** string *)
 
fun exists_string pred str =
  let
    val n = size str;
    fun ex i = i < n andalso (pred (String.substring (str, i, 1)) orelse ex (i + 1));
  in ex 0 end;

fun forall_string pred = not o exists_string (not o pred);


(*** items tagged by integer index *)



(*insert tags*)
fun tag_list k [] = []
  | tag_list k (x :: xs) = (k:int, x) :: tag_list (k + 1) xs;

(*remove tags and suppress duplicates -- list is assumed sorted!*)
fun untag_list [] = []
  | untag_list [(k: int, x)] = [x]
  | untag_list ((k, x) :: (rest as (k', x') :: _)) =
      if k = k' then untag_list rest
      else x :: untag_list rest;

(*return list elements in original order*)
fun order_list list = untag_list (sort (int_ord o apply2 fst) list);


(* partiality *)
fun try f x = SOME (f x)
  handle exn => if Exn.is_interrupt exn then Exn.reraise exn else NONE;

fun can f x = is_some (try f x);


(* others *)
val writeln = print;
val tracing = print;
val warning = print;

end (* nend of open local BAsics*)
end