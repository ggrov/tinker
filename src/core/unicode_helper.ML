structure UnicodeHelper=
struct

fun toUnEscape char  = case char of
  "\<nat>" => "\\u2115"
 |"\<nat>1" => "\\u2115\\u0031"
 |"\<int>" => "\\u2124"
 |"ℙ" => "\\u2119"
 |"ℙ1" => "\\u2119\\u0031"
 |"(" => "\\u0028"
 |")" => "\\u0029"
 |"\<Leftrightarrow>" => "\\u21D4"
 |"\<Rightarrow>" => "\\u21D2"
 |"\<and>" => "\\u2227"
 |"\<or>" => "\\u2228"
 |"\<not>" => "\\u00AC"
 |"\<top>" => "\\u22A4"
 |"\<bottom>" => "\\u22A5"
 |"\<forall>" => "\\u2200"
 |"\<exists>" => "\\u2203"
 |"·" => "\\u00B7"
 |"=" => "\\u003D"
 |"\<noteq>" => "\\u2260"
 |"<" => "\\u003C"
 |"\<le>" => "\\u2264"
 |">" => "\\u003E"
 |"\<ge>" => "\\u2265"
 |"\<in>" => "\\u2208"
 |"\<notin>" => "\\u2209"
 |"\<subset>" => "\\u2282"
 |"⊄" => "\\u2284"
 |"\<subseteq>" => "\\u2286"
 |"⊈" => "\\u2288"
 |"\<leftrightarrow>" => "\\u2194"
 |"" => "\\uE100"
 |"" => "\\uE101"
 |"" => "\\uE102"
 |"⇸" => "\\u21F8"
 |"\<rightarrow>" => "\\u2192"
 |"⤔" => "\\u2914"
 |"↣" => "\\u21A3"
 |"⤀" => "\\u2900"
 |"↠" => "\\u21A0"
 |"⤖" => "\\u2916"
 |"{" => "\\u007B"
 |"}" => "\\u007D"
 |"\<mapsto>" => "\\u21A6"
 |"\<emptyset>" => "\\u2205"
 |"\<inter>" => "\\u2229"
 |"\<union>" => "\\u222A"
 |"\<setminus>" => "\\u2216"
 |"\<times>" => "\\u00D7"
 |"[" => "\\u005B"
 |"]" => "\\u005D"
 |"" => "\\uE103"
 |"\<circ>" => "\\u2218"
 |";" => "\\u003B"
 |"\<otimes>" => "\\u2297"
 |"\<parallel>" => "\\u2225"
 |"\<sim>" => "\\u223C"
 |"◁" => "\\u25C1"
 |"⩤" => "\\u2A64"
 |"▷" => "\\u25B7"
 |"⩥" => "\\u2A65"
 |"\<lambda>" => "\\u03BB"
 |"\<Inter>" => "\\u22C2"
 |"\<Union>" => "\\u22C3"
 |"∣" => "\\u2223"
 |"‥" => "\\u2025"
 |"+" => "\\u002B"
 |"−" => "\\u2212"
 |"∗" => "\\u2217"
 |"\<div>" => "\\u00F7"
 |"^" => "\\u005E"
 |"⦂" => "\\u2982"
 |"≔" => "\\u2254"
 |":\<in>" => "\\u003A\\u2208"
 |":∣" => "\\u003A\\u2223"
 | a => a

fun toEscape str = case str of
"\\u2115" => "\<nat>"
| "\\u21151" => "\<nat>1"
| "\\u2124" => "\<int>"
| "\\u2119" => "ℙ"
| "\\u21191" => "ℙ1"
| "\\u0028" => "("
| "\\u0029" => ")"
| "\\u21D4" => "\<Leftrightarrow>"
| "\\u21D2" => "\<Rightarrow>"
| "\\u2227" => "\<and>"
| "\\u2228" => "\<or>"
| "\\u00AC" => "\<not>"
| "\\u22A4" => "\<top>"
| "\\u22A5" => "\<bottom>"
| "\\u2200" => "\<forall>"
| "\\u2203" => "\<exists>"
| "\\u00B7" => "·"
| "\\u003D" => "="
| "\\u2260" => "\<noteq>"
| "\\u003C" => "<"
| "\\u2264" => "\<le>"
| "\\u003E" => ">"
| "\\u2265" => "\<ge>"
| "\\u2208" => "\<in>"
| "\\u2209" => "\<notin>"
| "\\u2282" => "\<subset>"
| "\\u2284" => "⊄"
| "\\u2286" => "\<subseteq>"
| "\\u2288" => "⊈"
| "\\u2194" => "\<leftrightarrow>"
| "\\uE100" => ""
| "\\uE101" => ""
| "\\uE102" => ""
| "\\u21F8" => "⇸"
| "\\u2192" => "\<rightarrow>"
| "\\u2914" => "⤔"
| "\\u21A3" => "↣"
| "\\u2900" => "⤀"
| "\\u21A0" => "↠"
| "\\u2916" => "⤖"
| "\\u007B" => "{"
| "\\u007D" => "}"
| "\\u21A6" => "\<mapsto>"
| "\\u2205" => "\<emptyset>"
| "\\u2229" => "\<inter>"
| "\\u222A" => "\<union>"
| "\\u2216" => "\<setminus>"
| "\\u00D7" => "\<times>"
| "\\u005B" => "["
| "\\u005D" => "]"
| "\\uE103" => ""
| "\\u2218" => "\<circ>"
| "\\u003B" => ";"
| "\\u2297" => "\<otimes>"
| "\\u2225" => "\<parallel>"
| "\\u223C" => "\<sim>"
| "\\u25C1" => "◁"
| "\\u2A64" => "⩤"
| "\\u25B7" => "▷"
| "\\u2A65" => "⩥"
| "\\u03BB" => "\<lambda>"
| "\\u22C2" => "\<Inter>"
| "\\u22C3" => "\<Union>"
| "\\u2223" => "∣"
| "\\u2025" => "‥"
| "\\u002B" => "+"
| "\\u2212" => "−"
| "\\u2217" => "∗"
| "\\u00F7" => "\<div>"
| "\\u005E" => "^"
| "\\u2982" => "⦂"
| "\\u2254" => "≔"
| "\\u003A\\u2208" => ":\<in>"
| "\\u003A\\u2223" => ":∣" 
| a => a

val unilist=["\<nat>","\<nat>1","\<int>","ℙ","ℙ1","(",")","\<Leftrightarrow>","\<Rightarrow>","\<and>","\<or>","\<not>","\<top>","\<bottom>","\<forall>","\<exists>","·","=","\<noteq>","\<ge>","\<in>","\<notin>","\<subset>","⊄","\<subseteq>","⊈","\<leftrightarrow>","","","","⇸","⤔","↣","⤀","↠","⤖","{","}","\<mapsto>","\<mapsto>","\<emptyset>","\<inter>","\<union>","\<setminus>","\<times>","[","]","","\<circ>",";","\<otimes>","\<parallel>","\<sim>","◁","⩤","▷","⩥","\<lambda>","\<Inter>","\<Union>","∣","‥","+","−","∗","\<div>","^","⦂","≔",":\<in>","\<rightarrow>",":∣","\<le>","<",">"]
val codlist=["\\u2115","\\u2115\\u0031","\\u2124","\\u2119","\\u2119\\u0031","\\u0028","\\u0029","\\u21D4","\\u21D2","\\u2227","\\u2228","\\u00AC","\\u22A4","\\u22A5","\\u2200","\\u2203","\\u002C","\\u00B7","\\u003D","\\u2260","\\u003C","\\u2264","\\u003E","\\u2265","\\u2208","\\u2209","\\u2282","\\u2284","\\u2286","\\u2288","\\u2194","\\uE100","\\uE101","\\uE102","\\u21F8","\\u2192","\\u2914","\\u21A3","\\u2900","\\u21A0","\\u2916","\\u007B","\\u007D","\\u21A6","\\u21A6","\\u2205","\\u2229","\\u222A","\\u2216","\\u00D7","\\u005B","\\u005D","\\uE103","\\u2218","\\u003B","\\u2297","\\u2225","\\u223C","\\u25C1","\\u2A64","\\u25B7","\\u2A65","\\u03BB","\\u22C2","\\u22C3","\\u2223","\\u2025","\\u002B","\\u2212","\\u2217","\\u00F7","\\u005E","\\u2982","\\u2254","\\u003A\\u2208","\\u003A\\u2223"];

fun index str substr = let
  val (pref, suff) = Substring.position substr (Substring.full str)
  val (s, i, n) = Substring.base suff
in
  if i = size str then
    (NONE, size substr, substr)
  else
    (SOME i, size substr, substr)
end;

fun filterf ((SOME i, size, s)::xs)=(SOME i,size, s) |
    filterf ((NONE,_,_)::xs)=filterf xs |
    filterf [] = (NONE, 0,"")

fun findUC str =filterf  ( map ( index str) unilist)
fun findEUC str=filterf  ( map ( index str) codlist) 
(* To Escape *)
fun encode str = let
  val k = findUC str;
  val (start, len, uc) = case k of (NONE, _,_ ) => (0, 0, "")
                      |  (SOME i, j, unichar) => (i, j, unichar);
  val head= String.substring(str, 0, start);
  val mid = toUnEscape uc;
  val tail = String.extract(str, start+len, NONE); 
  val result= String.concat [head, mid, tail];
  val hasmore = case findUC result of (NONE,_,_) => false | _ => true
in
  if hasmore then
   encode result
  else
   result
end;

(* To Unescape *)
fun decode str = let
  val k = findEUC str;
  val (start, len, uc) = case k of (NONE, _,_ ) => (0, 0, "")
                      |  (SOME i, j, unichar) => (i, j, unichar);
  val head= String.substring(str, 0, start);
  val mid = toEscape uc;
  val tail = String.extract(str, start+len, NONE); 
  val result= String.concat [head, mid, tail];
  val hasmore = case findEUC result of (NONE,_,_) => false | _ => true
in
  if hasmore then
   (* replaceEUC result *)
   decode result
  else
   (* result *)
   result
end;

end
(*
val a = "a \\u2227 b \\u2227 c \\u21D2 c \\u2227 b \\u2227 a"

val b = UnicodeHelper.decode a;
val c = UnicodeHelper.encode b;

val cb=UnicodeHelper.findEUC a;
*)
