(* a lightweight version of Symbol from Pure *)
structure Symbol = 
struct

type symbol = string;

val STX = chr 2;
val DEL = chr 127;

val space = chr 32;

fun is_char s = size s = 1;

fun is_utf8 s = size s > 0 andalso PureLib.forall_string (fn c => ord c >= 128) s;


val eof = "";
fun is_eof s = s = eof;
fun not_eof s = s <> eof;
val stopper = Scan.stopper (K eof) is_eof;


(* ASCII symbols *)

fun is_ascii s = is_char s andalso ord s < 128;

fun is_ascii_letter s =
  is_char s andalso
   (ord "A" <= ord s andalso ord s <= ord "Z" orelse
    ord "a" <= ord s andalso ord s <= ord "z");

fun is_ascii_digit s =
  is_char s andalso ord "0" <= ord s andalso ord s <= ord "9";

fun is_ascii_hex s =
  is_char s andalso
   (ord "0" <= ord s andalso ord s <= ord "9" orelse
    ord "A" <= ord s andalso ord s <= ord "F" orelse
    ord "a" <= ord s andalso ord s <= ord "f");

fun is_ascii_quasi "_" = true
  | is_ascii_quasi "'" = true
  | is_ascii_quasi _ = false;

val is_ascii_blank =
  fn " " => true | "\t" => true | "\n" => true | "\^K" => true | "\f" => true | "\^M" => true
    | _ => false;

fun is_ascii_control s = is_char s andalso ord s < 32 andalso not (is_ascii_blank s);

fun is_ascii_letdig s = is_ascii_letter s orelse is_ascii_digit s orelse is_ascii_quasi s;

fun is_ascii_lower s = is_char s andalso (ord "a" <= ord s andalso ord s <= ord "z");
fun is_ascii_upper s = is_char s andalso (ord "A" <= ord s andalso ord s <= ord "Z");

fun to_ascii_lower s = if is_ascii_upper s then chr (ord s + ord "a" - ord "A") else s;
fun to_ascii_upper s = if is_ascii_lower s then chr (ord s + ord "A" - ord "a") else s;

fun is_ascii_identifier s =
  size s > 0 andalso is_ascii_letter (String.substring (s, 0, 1)) andalso
  PureLib.forall_string is_ascii_letdig s;

val scan_ascii_id = Scan.one is_ascii_letter ^^ (Scan.many is_ascii_letdig >> implode);



end