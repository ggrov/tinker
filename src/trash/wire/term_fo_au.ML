(* implementation of variant of Plotkin's FO AU  *)
(* TO DO: - binders are not handled (need to ensure only the same is captured)
         - types are not handled. Need to also generalise type and update "parent"
           in function call 
         - get_one (find match): Plotkin requires that "at least one of them is a variable" 
           I couldn't really understand this point so I ignored it
*) 
structure FirstOrderAU =
struct

 (* generation of fresh variable name *)

 fun insert name v = StrName.NSet.ins_fresh name v handle _ => v;

 fun names_of' nset (Const (a, _)) = insert a nset
  | names_of' nset (Free (a, _)) = insert a nset
  | names_of' nset (Var ((a,_), _)) = insert a nset
  | names_of' nset (Bound _) = nset
  | names_of' nset (Abs (_, _, t)) = names_of' nset t
  | names_of' nset (t $ u) = names_of' (names_of' nset t) u;

 val names_of = names_of' StrName.NSet.empty;
 fun names_of2 (t1,t2) = names_of' (names_of t1) t2;
 fun fresh_of2 t name = StrName.NSet.new (names_of2 t) name;

 (* step 2 of Plotkin's alg: try to find one two terms to generalise
      NONE indicates termination *)

  (* special case for binders *)
  fun get_one (Abs (_, _, ta), Abs (_, _, tb)) = get_one (ta,tb)
  (* general case *)
  |  get_one (a,b) = 
        case (Term.strip_comb a,Term.strip_comb b) of
          ((na,[]),(nb,[])) => if (na=nb) then NONE else SOME (a,b)
        | ((_,[]),(_,_)) => SOME (a,b) (* different arity of args *)
        | ((_,_),(_,[])) => SOME (a,b) (* different arity of args *)
        | ((na,ta),(nb,tb)) => if not (na=nb) then SOME (a,b) else get_first_of (ta,tb)
  and get_first_of (x::xs,y::ys) = (case get_one (x,y) of
        SOME v => SOME v
      | NONE => get_first_of (xs,ys))
   |  get_first_of _ = NONE;

 (* (part of) step 4: replace all occurences where term occurs at the same place *)

 (* to do: handle binders and type gen *)
 fun replace v (ma,ra) (mb,rb) =
   if ma=ra andalso mb=rb then (v,v) else
   case (ma,mb) of
     (Abs (na, tya, ta),Abs (nb, tyb, tb)) => 
       let val (new_a,new_b) = replace v (ta,ra) (tb,rb)
       in (Abs (na, tya, new_a),Abs (nb, tyb, new_b))
       end
   | (la $ rra,lb $ rrb) =>
       let val (new_la,new_lb) = replace v (la,ra) (lb,rb)
           val (new_ra,new_rb) = replace v (rra,ra) (rrb,rb) 
       in (new_la $ new_ra,new_lb $ new_rb)
       end
   | _ => (ma,mb);

  (* main algorithm (fixme: type hardcoded) *)

  fun generalise (t1,t2) = 
    let
      val vname = fresh_of2 (t1,t2) "v"
      fun vtyp t1' t2' = Term.type_of t1' handle _ => Term.type_of t2' handle _ => @{typ "nat"}
      fun newvar v1 v2 = Free (vname,vtyp v1 v2)
    in case get_one (t1,t2) of
        NONE => t1 (* could be either really *)
     | (SOME (v1,v2)) => generalise (replace (newvar v1 v2) (t1,v1) (t2,v2))
   end

end















(* OLD STUFF -- delete *)

(*

(* extracts and checks properties of single terms *)

structure StrTable = Table(struct type key = string; val ord = String.compare end);

signature FO_AU =
sig
  
end (* sig *)

structure FirstOrderAU =
struct

 fun trepl (Type (_,[])) = true
  |  trepl _ = false;

 (* has to be "atomic" - and not function type *)
 fun repl (Bound _) = true (* fixme: should really check with binder too! *)
  |  repl (Var (_,t)) = trepl t (* have to be careful with this - make sure that two vars are not fixed *)
  |  repl (Free (_,t)) = trepl t
  |  repl (Const (_,t)) = trepl t
  |  repl _ = false;

 exception anti_unify_exp of term * term;
 val name_num = Unsynchronized.ref 1;

(* fix: type issue *)
 fun fresh_var () = (* name_num := !name_num + 1; *) Var (("V" ^ string_of_int (!name_num),0),@{typ "'a"});
 fun fresh_var_of_typ t = (* name_num := !name_num + 1; *) Var (("V" ^ string_of_int (!name_num),0),Term.type_of t);

 fun add_sub _ b = b;

(* assume well-formed so can ignore type, i.e. same symbols will have same type *)
 fun fau (a1 $ a2,sub1) (b1 $ b2,sub2) = 
      let
         val (a1',b1',sub1',sub2') = fau (a1,sub1) (b1,sub2)
         val (a2',b2',sub1'',sub2'') = fau (a2,sub1') (b2,sub2')
      in
         (a1' $ a2', b1' $ b2',sub1'',sub2'')
      end 
 |  fau (Abs (s1,ty1,te1),sub1) (Abs (s2,ty2,te2),sub2) = 
      let
         val (te1',te2',sub1',sub2') = fau (te1,sub1) (te2,sub2)
      in
         (Abs (s1,ty1,te1'),Abs (s2,ty2,te2'),sub1',sub2')
      end 
      
 |  fau (t1,sub1) (t2,sub2) = 
       if t1 = t2 then (t1,t2,sub1,sub2)
       else if repl t1 andalso repl t2 
       then
         let (* fixme: uses theory *)
             val newval = if Sign.typ_equiv @{theory} (Term.type_of t1,Term.type_of t2)
                           then fresh_var_of_typ t1 else fresh_var ();
         in 
              (newval,newval,add_sub (fresh_var,t1) sub1,add_sub (fresh_var,t2) sub2)
         end
       else raise anti_unify_exp (t1,t2);

 fun just_gen t1 t2 = fau (t1,[]) (t2,[]) |> (fn (a,_,_,_) => a);

 fun smatch (Abs (s1,ty1,te1)) (Abs (s2,ty2,te2)) = smatch te1 te2
  |  smatch (a1 $ a2) (b1 $ b2) = smatch a1 b1 andalso smatch a2 b2
  |  smatch (Var _) t = repl t
  |  smatch patt t = (patt = t);

end (* struct *)
*)




