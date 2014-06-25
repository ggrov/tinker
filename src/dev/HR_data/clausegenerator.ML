(* Generates Prolog clauses from Isabelle terms and proof terms for use with Metagol*)

structure clausegen = struct


datatype tmp_tree = TmpPrf of term * (tmp_tree list)
datatype tree = Prf of (string * term option) * (tree list)

(*Translations from Isabelle's notation to Metagol notation*)

fun trans_consts "HOL.implies" = "imp"
   |  trans_consts "HOL.conj" = "conj"
   |  trans_consts "HOL.disj" = "disj"
   |  trans_consts "==>" = "turn"
   |  trans_consts "dummy_pattern" = ""
   |  trans_consts s = s;

(*Translation from Isabelle notation to easily readable tactic names*)

fun trans_tacs "HOL.impI" = "impI"
  | trans_tacs "HOL.impE" = "impE"
  | trans_tacs "HOL.conjI" = "conjI"
  | trans_tacs "HOL.conjE" = "conjE"
  | trans_tacs s = s;


(*Generating clauses as strings from Isabelle terms*)

fun term_trans (Const (a, _)) = trans_consts a 
    | term_trans (Free (a, _)) = a
    | term_trans (Var ((v,_), _)) = v
    | term_trans (Bound _) = ""
    | term_trans (Abs (_, _, t)) = term_trans t
    | term_trans (Const ("HOL.Trueprop",_) $ u) = term_trans u
    | term_trans (t $ u) = "app(" ^ term_trans t ^ "," ^ term_trans u ^ ")" ;


(*Extracting terms from proof term representation*)

fun get_terms (A %% B) = (get_terms A) $ (get_terms B)
    | get_terms (A % SOME B) = (get_terms A) $ B
    | get_terms (A % NONE) = get_terms A
    | get_terms (Abst (_, _, A)) = get_terms A
    | get_terms (AbsP (_,SOME A,B)) =  A $ (get_terms B)
    | get_terms (AbsP (_,NONE,A)) = get_terms A
    | get_terms (Hyp A) = A
    | get_terms (PAxm (_,A,_)) = A
    | get_terms (Oracle (_,A,_)) = A
    | get_terms (Promise (_,A,_)) = A
    | get_terms (PThm (_,((_,A,_),_))) = A
    | get_terms (PBound _) = Term.dummy;


fun mk_term_list (A %% B) = mk_term_list A @ [get_terms B]
   |  mk_term_list (A % _) = mk_term_list A
   |  mk_term_list (Abst (_,_,X)) = mk_term_list X
   |  mk_term_list (AbsP (_,_,X)) = mk_term_list X
   |  mk_term_list (PThm (_,((_,A,_),_))) = [A]
   |  mk_term_list (PBound _) = [];





(*Generating clauses direct from proof terms*)

fun pt_trans prf = term_trans (get_terms prf);



end
