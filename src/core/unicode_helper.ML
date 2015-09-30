functor UnicodeHelperFUN (val symb_tab : (string * string) list) =
struct
(* symbols and unicodes, as a intermidiate coding to avoid parsing those non-ascii symbols in Json
  this is a translation between PSGraph and GUI *)
  val gui_uni : (string * string) list = [
     ("¬", "_uni_symb_lnot_"),
     ("∧", "<_uni_symb_land_>"),
     ("⟶", "<_uni_symb_implies_>"),
     ("∀", "<_uni_symb_forall_>"),
     ("∃", "<_uni_symb_exists_>"),
     ("≠", "<_uni_symb_neq_>"),
     
     ("∈", "<_uni_symb_in_>"),
     ("·","<_uni_symb_blackdot_>"),
     ("⟨", "<_uni_symb_l_angle_brk_>"),
     ("⟩", "<_uni_symb_r_angle_brk_>"),
     ("×", "<_uni_symb_cross_>"),
     ("→", "<_uni_symb_fun_>"),
     ("𝕌", "<_uni_symb_bbU_>"),
     ("Z", "<_uni_symb_bbZ_>"),
     
     ("σ", "<_uni_symb_sigma_>"),
     ("γ", "<_uni_symb_gammar_>"),
     ("η", "<_uni_symb_eta_>"),
     
     ("⋎", "<_uni_symb_down_corner_>"),
     ("⌜","<_uni_symb_left_corner_>"),
     ("⌝", "<_uni_symb_right_corner_>"),

     ("ⓩ", "<_uni_symb_left_z_corner_>"),
     ("≜", "<_uni_symb_left_z_assign_>")
    ]
  val prover_uni = symb_tab

  fun toUnEscape tab str = 
   case StrName.NTab.lookup (StrName.NTab.of_list tab) str of
    (SOME x) => x
   | NONE => str
  
  fun toEscape tab str = 
    case StrName.NTab.lookup (StrName.NTab.of_list (map (fn (x,y)=> (y,x)) tab)) str of
    (SOME x) => x
   | NONE => str
  
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
  
  fun findUC tab str =filterf  ( map ( index str) (map fst tab))
  fun findEUC tab str=filterf  ( map ( index str) (map snd tab)) 
  (* To Escape *)
  fun encode tab str = let
    val k = findUC tab str;
    val (start, len, uc) = case k of (NONE, _,_ ) => (0, 0, "")
                        |  (SOME i, j, unichar) => (i, j, unichar);
    val head= String.substring(str, 0, start);
    val mid = toUnEscape tab uc;
    val tail = String.extract(str, start+len, NONE); 
    val result= String.concat [head, mid, tail];
    val hasmore = case findUC tab result of (NONE,_,_) => false | _ => true
  in
    if hasmore then
     encode tab result
    else
     result
  end;
  
  (* To Unescape *)
  fun decode tab str = let
    val k = findEUC tab str;
    val (start, len, uc) = case k of (NONE, _,_ ) => (0, 0, "")
                        |  (SOME i, j, unichar) => (i, j, unichar);
    val head= String.substring(str, 0, start);
    val mid = toEscape tab uc;
    val tail = String.extract(str, start+len, NONE); 
    val result= String.concat [head, mid, tail];
    val hasmore = case findEUC tab result of (NONE,_,_) => false | _ => true
  in
    if hasmore then
     (* replaceEUC result *)
     decode tab result
    else
     (* result *)
     result
  end;

  val encode_gui_json = encode gui_uni (* encode gui symbol to unicode string*)
  val decode_gui_json = decode gui_uni (* decode unicode string to gui symbol *)

  val encode_prover_json = encode prover_uni (* encode prover symbol to unicode string*)
  val decode_prover_json = decode prover_uni (* decode unicode string to prover symbol *)
end
