functor UnicodeHelperFUN (val unicode_symb : (string * string) list) =
struct

  fun toUnEscape str = 
   case StrName.NTab.lookup (StrName.NTab.of_list unicode_symb) str of
    (SOME x) => x
   | NONE => str
  
  fun toEscape str = 
    case StrName.NTab.lookup (StrName.NTab.of_list (map (fn (x,y)=> (y,x)) unicode_symb)) str of
    (SOME x) => x
   | NONE => str
  
  val unilist = map fst unicode_symb
  val codlist = map snd unicode_symb
  
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
