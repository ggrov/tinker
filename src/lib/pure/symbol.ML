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



fun is_ascii_letter c = #"A" <= c andalso c <= #"Z" orelse #"a" <= c andalso c <= #"z";
fun is_ascii_letdig c =
  is_ascii_letter c orelse #"0" <= c andalso c <= #"9" orelse c = #"_" orelse c = #"'";

fun is_utf8 c = c >= #"\128";
fun is_utf8_trailer c = #"\128" <= c andalso c < #"\192";
fun is_utf8_control c = #"\128" <= c andalso c < #"\160";

fun explode string =
  let
    fun char i = String.sub (string, i);
    fun string_range i j = String.substring (string, i, j - i);

    val n = size string;
    fun test pred i = i < n andalso pred (char i);
    fun many pred i = if test pred i then many pred (i + 1) else i;
    fun maybe pred i = if test pred i then i + 1 else i;
    fun maybe_char c = maybe (fn c' => c = c');
    fun maybe_ascii_id i = if test is_ascii_letter i then many is_ascii_letdig (i + 1) else i;

    fun scan i =
      if i < n then
        let val ch = char i in
          (*encoded newline*)
          if ch = #"\^M" then "\n" :: scan (maybe_char #"\n" (i + 1))
          (*pseudo utf8: encoded ascii control*)
          else if ch = #"\192" andalso
            test is_utf8_control (i + 1) andalso not (test is_utf8 (i + 2))
          then chr (Char.ord (char (i + 1)) - 128) :: scan (i + 2)
          (*utf8*)
          else if is_utf8 ch then
            let val j = many is_utf8_trailer (i + 1)
            in string_range i j :: scan j end
          (*named symbol*)
          else if ch = #"\\" andalso test (fn c => c = #"<") (i + 1) then
            let val j = (i + 2) |> maybe_char #"^" |> maybe_ascii_id |> maybe_char #">"
            in string_range i j :: scan j end
          (*single character*)
          else String.str ch :: scan (i + 1)
        end
      else [];
  in scan 0 end;
  
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


val is_letter = (fn x => is_ascii_lower x orelse is_ascii_upper x);
val is_digit = is_ascii_digit;
val is_quasi = is_ascii_quasi;
val is_blank = is_ascii_blank;
end