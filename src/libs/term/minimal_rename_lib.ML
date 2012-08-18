(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/minimal_rename_lib.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Rename Free's in a term so that the names are as short as
    possible, based on the type names. Note this also provides a
    normal form for names in term. However this normal form is *not*
    stable over beta reduction as it is based on the left-to-right
    ordering of frees in the term. 

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

structure MinimalRenameLib = 
struct

fun type_name (Type(s,_)) = s
  | type_name (TFree(s,_)) = s
  | type_name (TVar((s,i),_)) = s;

(* choose a new minimal and basic name for an instance of this type *)
fun type_base_name ty = 
    let 
      val tyname = type_name ty
      val chars = String.explode ((*NameSpace.base*) tyname)
    in
      case List.find (Char.isAlpha) chars 
       of NONE => "a"
        | SOME h => Char.toString (Char.toLower h)
    end;

(* next and previous names, we skip the "o" character *)
fun name_suc s = 
    String.implode (rev
      (case rev (String.explode s) of 
      [] => [#"a"]
    | (l as h::t) => 
      if h = #"n" then (#"p"::t)
      else if Char.compare (h, #"z") = GREATER then (#"a"::l) 
      else Char.succ h :: t));

fun name_pred s = 
    String.implode (rev
      (case rev (String.explode s) of 
      [] => []
    | (l as h::t) => 
      if h = #"p" then (#"n"::t)
      else if Char.compare (h, #"a") = LESS then (t) 
      else Char.pred h :: t));


fun rename_abs n ty ATab = (ATab, n);

fun rename_free ty n (tab as (rntab,ftab)) = 
    let fun doadd n2 =
          case Symtab.lookup ftab n2
           of NONE => ((Symtab.update_new (n,n2) rntab, 
                        Symtab.update_new (n2,()) ftab), n2)
            | SOME _ => doadd (name_suc n2)
    in
      case Symtab.lookup rntab n of 
        NONE => doadd (type_base_name ty)
      | SOME n2 => (tab, n2)
    end;

fun rename_term_aux FTab ATab (a $ b) = 
    let 
      val (FTab2, a2) = rename_term_aux FTab ATab a 
      val (FTab3, b2) = rename_term_aux FTab2 ATab b
    in (FTab3, a2 $ b2) end
  | rename_term_aux FTab ATab (Abs (n,ty,t)) = 
    let 
      val (ATab2, n2) = rename_abs n ty ATab
      val (FTab2, t2) = rename_term_aux FTab ATab2 t
    in (FTab2, Abs(n2, ty, t2)) end
  | rename_term_aux FTab ATab (Free (n,ty)) = 
    let 
      val (FTab2, n2) = rename_free ty n FTab
    in (FTab2, Free (n2, ty)) end
  | rename_term_aux FTab ATab x = (FTab, x);

fun rename_term t = 
    let 
      val (tab, t2) = 
          rename_term_aux (Symtab.empty,Symtab.empty) Symtab.empty t;
 (*      val _ = writeln "\n --- \n Conj Term: ";
      val _ = writeln (TermLib.string_of_term t2);
      val _ = writeln "--- ";  *)
    in
      t2
    end;


end;
