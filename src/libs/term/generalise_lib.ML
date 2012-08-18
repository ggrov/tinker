(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/generalise_lib.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Code to perform generalisation of terms, creating and naviagting 
    a generalisation tree.
   
    USES: TermTreeHandlerLib (for focus terms)
    USES: TermLib (for pretty printing terms, and checking fun type)

    FIXME: use name tables for new generalised var names. 
*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature GENERALISE_LIB =
sig
  type T

(*   exception gen_from_zippers_exp of (Zipper.T list); *)

  exception generalise_exp of string

  val gent_of_gen : T -> Trm.T
  val is_prim_type_gen : T -> bool
  val occs_of_gen : T -> int
  val repl_of_gen : T -> Trm.T
  val subt_of_gen : T -> Trm.T

  (* val mk_more_gen : T -> T Seq.seq *)
  val gen_term : Trm.TrmParams.T -> Trm.T
                 -> (Trm.TrmParams.T * Trm.T) list
  
  val pretty_gen : Context.theory -> T -> Pretty.T
end;



(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure GeneraliseLibDB = 
struct

datatype T = 
         Gen of {
           params : Trm.TrmParams.T, (* the param names - to make new gen vars *)
         (* focus terms to generalise the focus of *)
           ftlist : Zipper.T list, (* terms focused somewhere special - at the appropriate generalisation presumably. *)
           subt : Trm.T, (* the subterm that has been generalised *)
           occs : int,  (* Num of subterm occurances *)
           repl : Trm.T, (* subterm replacement - ie free var *)
         (* Generalised term, ie replaced subterm by repl in fcterm *)
           gent : Trm.T,
           gapart : string list, (* the frees vars generalised apart *)
           prev : T option (* optional previous generalisation *)
  };


(* exception for when we try to generalise the empty list. *)
exception generalise_exp of string;

(* basic gets for generalisations *)
fun params_of_gen (Gen rep) = #params rep;
fun ftlist_of_gen (Gen rep) = #ftlist rep;
fun repl_of_gen (Gen rep) = #repl rep;
fun subt_of_gen (Gen rep) = #subt rep;
fun gent_of_gen (Gen rep) = #gent rep;
fun occs_of_gen (Gen rep) = #occs rep;
fun gapartvs_of_gen (Gen rep) = #gapart rep;
fun prev_of_gen (Gen rep) = #prev rep;
fun set_prev_gen p (Gen rep) = 
    Gen {params = #params rep,
         ftlist = #ftlist rep, 
         subt = #subt rep,
         occs = #occs rep,
         repl = #repl rep,
         gent = #gent rep,
         gapart = #gapart rep,
         prev = p};

(* true if we have generalised vars apart - ie gen apart list is not null *)
val genapart_of_gen = not o null o gapartvs_of_gen;

(* we can use the Term.fastype_of as the replacement will already have
been given a good type, ie it'll be a free varaible, and not contain a
bound var *)

fun is_fun_typ (Type(s, l)) = if s = "fun" then true else false
  | is_fun_typ _ = false;
val is_prim_typ = not o is_fun_typ;

val gen_is_prim_type = is_prim_typ o Term.fastype_of o Zipper.trm;

fun is_prim_type_gen g = 
    is_prim_typ (Term.fastype_of (repl_of_gen g));

(* for debugging... *)
fun pretty_gen thry g = 
    let 
      val prettytf = Syntax.pretty_term_global thry;
      val gt = prettytf (gent_of_gen g)
      val r = prettytf (repl_of_gen g)
      val s = prettytf (subt_of_gen g)
      val oc = Pretty.str (string_of_int (occs_of_gen g))
      val a = Pretty.str_list "[" "]" (gapartvs_of_gen g)
    in
      Pretty.chunks 
        [ Pretty.block [Pretty.str "Gen: '", gt , Pretty.str "'"],
          Pretty.block [Pretty.str "with '", r, Pretty.str "'"],
          Pretty.block [Pretty.str " = '", s, Pretty.str "'"],
          Pretty.block [Pretty.str "occs: ", oc],
          Pretty.block [Pretty.str "generalising apart: ", a] ]
    end;


fun generalised_frees ft1 fts =
    let 
      fun frees_of_ft ft = 
          (map (fst o Term.dest_Free) 
               (Trm.term_frees (Zipper.trm ft)))
      fun ff (ft, vs) = 
          Library.union (op =) (frees_of_ft ft) vs
    in List.foldr ff (frees_of_ft ft1) fts end;

(* make a new free variable with the same type as the focus *)
fun new_free_var_for_zipper ptab ft =
    let val ty = Term.fastype_of (Zipper.trm ft);
        val (n,ptab2) = Trm.TrmParams.add1 ("G_",ty) ptab
    in (ptab2, Trm.mk_free (n, ty)) end;

(* exception gen_from_zippers_exp of (Zipper.T list); *)

(* Make a common-subterm generalisation for a groups of focuses - ie
replace location of the the focues with a fresh free variable. Note
this assumes that: all the focuses are of the same term and are
disjoint. *)
fun mk_gen_from_zippers ptab ft fts = 
    let val (ptab2, fv) = new_free_var_for_zipper ptab ft 
      fun merge_foc_gen locft ft' = 
          Zipper.set_trm 
            fv (Zipper.zipto (Zipper.ctxt locft) (Zipper.goto_top ft'))
    in
      (ptab2, fold merge_foc_gen fts (Zipper.set_trm fv ft))
    end;
    (* handle Zipper.move _ => raise gen_from_zippers_exp (ft :: fts); *)


(* regroup the common fcterms with common focuses, 
   after having moved up or right, note we use aeconv not equality *)
fun group_focuses partf L =
    let fun recf [] = []
          | recf (ft1 :: ls) = 
            let val (same, diffs) = List.partition (partf ft1) ls
            in (ft1 :: same) :: (recf diffs) end
    in recf L end;


(* given two focus terms make sure they are both leaes, and check equality *)
fun leaf_partf z1 z2 = 
    let val t1 = Zipper.trm z1 val t2 = Zipper.trm z2
    in case (t1,t2) of 
         (_ $ _ , _) => 
         raise generalise_exp "leaf_partf: app1: this can't be happening!"
       | (_, _ $ _) => 
         raise generalise_exp "leaf_partf: app2: this can't be happening!"
       | (Abs _, _) => 
         raise generalise_exp "leaf_partf: abs1: this can't be happening!"
       | (_, Abs _) => 
         raise generalise_exp "leaf_partf: abs2: this can't be happening!"
       | (lf, lf2) => (lf = lf2)
    end;


(* The update partition function, for checking if the rhs or new
   abstraction preserve the aeconv of the focuses *)
fun update_partf z1 z2 = 
    let val t1 = Zipper.trm z1 val t2 = Zipper.trm z2
    in case (t1,t2) of 
         (Abs(_,ty,t), Abs(_,ty2,t2)) => (ty = ty2)
       | (Abs(_,ty,t),_) => false 
       | (a $ b, a2 $ b2) => Pattern.aeconv (b,b2)
       | (a $ b, _) => false 
       | (_, _) =>  
         raise generalise_exp "update_partf: this can't be happening!"
    end;

(* generalise given a group of fcterms (assumed to have aeconv
focuses). This will return a list of lists: a list of new
generalisation groups, ie having a larger common aeconv focuses. *)
fun genstep els = 
    let 
      val gs = group_focuses update_partf
                             (Library.map_filter 
                                (fn x => SOME (Zipper.move_up_right_or_abs  x)
                                    handle Zipper.move _ => NONE) els);
(*      val _ = writeln "-- Next Groups --"
      val _ = print_gengroups gs
      val _ = writeln "\n-- " *)
    in
      gs
    end;

fun apply_genfilter gfilter gs = 
    List.foldr (fn (g, (gens,gs2)) => 
              let val (genopt, keep) = gfilter g in
                (case genopt of NONE => gens
                              | SOME gen => gen :: gens, 
                 if keep then g :: gs2 else gs2) end)
          ([],[]) gs;

val left_leaves_of_fcterm = 
    Library.filter (fn z => case Zipper.ctxt z 
                            of (Zipper.C.D.AppR x::_) => true 
                             | _ => false)
    o Seq.list_of o ZipperSearch.leaves_lr;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Generalisation filters *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* These are functions that take a focus group and give back a pair:
generalisation option * bool The bool is true if we should continue
searching up the tree for generalisations.  *)


(* generalise using "genfilter" which creates the valid
generalisations from the focus groups and also filters the
groups. Give the most generalised first. Note: this is a very
interesting example of a specification goes far beyond type
information, for example, this will terminate, and the snd element of
the result is always the empty list. *)

fun generalise_maxfirst ingenfilter ft =
    let val initgroups = 
            group_focuses leaf_partf (left_leaves_of_fcterm ft)  
(*      val _ = writeln "-- Init Groups --"
      val _ = print_gengroups initgroups
      val _ = writeln "\n-- " *)
        val genfilter = apply_genfilter ingenfilter
        fun recf [] Gs = Gs
          | recf (groups as (_ :: _)) Gs = 
            let val (gens, continues) = genfilter groups 
              val upgroups = Library.flat (map genstep continues)
            in recf upgroups (gens @ Gs) end
    in recf initgroups [] end;

(* generalise using "genfilter" which creates the valid
generalisations from the focus groups and also filters the
groups. Give the least generalised first. *)
fun generalise_minfirst ingenfilter ft =
    let val initgroups = 
            group_focuses leaf_partf (left_leaves_of_fcterm ft)          
        val genfilter = apply_genfilter ingenfilter
        fun recf [] = []
          | recf (groups as (_ :: _)) = 
            let val (gens, continues) = genfilter groups 
                val upgroups = Library.flat (map genstep continues)
            in gens @ (recf upgroups) end
    in recf initgroups end;



(* A filter that requires 2 occurances of the common-subterm for
continuing and additionally requires the gen to be of primitive type
(non-function), and must *not* generalise variables apart. *)
fun genfilter_2o_nf ptab [] = (NONE, false)
  | genfilter_2o_nf ptab (ftss as ft::fts) = 
    if 0 < length fts then
      if gen_is_prim_type ft then 
        let val (ptab2, newgenft) = mk_gen_from_zippers ptab ft fts
          val genoverfrees = generalised_frees ft fts 
          val left_over_frees = map (fst o Term.dest_Free) 
                                    (Trm.term_frees (Zipper.trm newgenft))
          val gapart = Library.inter (op =) genoverfrees left_over_frees
          val gen = Gen { params = ptab2,
                          ftlist = ftss,
                          subt = Zipper.trm ft,
                          occs = length ftss,
                          repl = Zipper.trm newgenft,
                          gent = Zipper.top_trm newgenft,
                          gapart = gapart,
                          prev = NONE}
        in (SOME gen, true)  end
      else
        (NONE, true)
    else
      (NONE, false);


(* generalise a term *)
(* test with:
GeneraliseLib.gen_term (read "a * b + a * c + z = a * b + (a * c + z)");
*)
fun gen_once ptab = generalise_maxfirst (genfilter_2o_nf ptab) o Zipper.mktop;

(* Code to search for the first maximal generalisation *)
fun gen_more g = 
  let val ft = Zipper.mktop (gent_of_gen g) 
    val g2s = (generalise_maxfirst (genfilter_2o_nf (params_of_gen g)) ft)
  in case g2s of [] => NONE
               | (g2 :: _) => SOME ((set_prev_gen (SOME g)) g2)
  end;

(* FIXME: allow some search for other gens that don't gen-vars apart *)
fun gen_term ptab t = 
    let val gs = (gen_once ptab t) 
      fun recf g = 
          case gen_more g of NONE => g
                           | SOME g' => recf g'
    in 
      case gs of [] => [] 
               | (g1 :: _) => 
                 let val maxg = recf g1 in
                   (*if genapart_of_gen maxg then []
                   else *) [(params_of_gen maxg, gent_of_gen maxg)] 
                 end
    end;

end; (* struct *)

structure GeneraliseLib : GENERALISE_LIB = GeneraliseLibDB;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)



(*
open GenTreeS;


terms to compare:

read "(x *o* y +o+ x *o* ordinal) +o+ x = 
      x *o* y +o+ (x *o* ordinal +o+ x)";

want:
read "a +o+ b +o+ c = a +o+ (b +o+ c)";

--
Goal "a + b = c";
writeterm (term_of_thm (Seq.hd (instantiate_tac [("a1", "a"), ("b1","b")] (forall_elim_vars 1 (forall_intr_frees (topthm()))))));

(Free("a", Type... ))

TermTreeHandlerS.generalise (read "k g h") (read "f g h");
*)




(* generalise extensionality: (f x = f y), if generalised to (x = y) *)
(* can simply be done by: *)

(*

(* generalise from (f x = f y) to (x = y) *)
(rtac arg_cong 1)


Seq.hd ((instantiate_tac [("P", "% z. R z = T z")]) (allI RS spec));
Gives:
"(!!x. R x = T x) ==> R ?x = T ?x"

and

Seq.hd ((instantiate_tac [("P", "% z. ?R z = ?T z")]) (allI RS spec));
Gives:
"(!!x. ?R x = ?T x) ==> ?R ?x = ?T ?x"

(allI RS spec)
Gives:
"(!!x. ?P x) ==> ?P ?x"


*)
