structure Subterms =
struct

 (* subterm *)
  fun fold_aterms f (t $ u) = f (t $ u) #> fold_aterms f t #> fold_aterms f u
    | fold_aterms f (Abs (_, _, t)) = fold_aterms f t
    | fold_aterms f a = f a;

  fun naive_subterms t =  fold_aterms (curry (op ::)) t [];

  (* filter out stuff we don't want - could instead be integrated with subterms for effiency? *)
  val filter_silly =
    let val silly_consts = ["EB_Rel.funimage","Orderings.ord_class.less","HOL.Trueprop","==>"] (* think B.O is bound *)
        fun check (Const (v,_)) = not (List.exists (fn x => x = v) silly_consts)
         |  check _ = true
    in
     filter check
    end;

  val filter_loose_bound = filter (fn t => not(Term.loose_bvar(t,0)))
  fun filter_type (xs:term list) = map I xs;
  val naive_filter = filter_silly #> filter_loose_bound #> filter_type;

  val filtered_subterms = naive_filter o naive_subterms;

end (* struct *)
