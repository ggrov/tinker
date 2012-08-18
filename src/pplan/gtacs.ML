(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gtacs.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Updated:    March 2007 - Lucas Dixon
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  

    tacticals for working with tactics that derive new results and
    produce named goals. 

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature GTACS = 
sig

type gname;
type rname;
type prf;
type state = ((rname list * gname list) * prf);

type fwd_gtac = rname -> prf -> state Seq.seq
type bck_gtac = gname -> prf -> state Seq.seq

type gtac = state -> state Seq.seq

val mk_map_fwd : fwd_gtac -> gtac
val mk_map_bck : bck_gtac -> gtac
val of_bckf : (gname -> prf -> (gname list * prf) Seq.seq) -> gtac;
val of_fwd1f : (rname -> prf -> (rname * prf) Seq.seq) -> gtac;

val fail : gtac;
val id : gtac;

val or : gtac list -> gtac
val thenl : gtac list -> gtac
val try : gtac -> gtac
val repeat : gtac -> gtac
val prove_or_fail : gtac -> gtac

val then_f : gtac -> (state -> state) -> gtac
val f_then : (state -> state) -> gtac -> gtac
val then_select : (state -> bool) -> gtac -> gtac

(* internal *)
(* also apply the list of functions gathering the results *)
val also : (prf -> state Seq.seq) list -> prf -> state Seq.seq

(* add results to each thing in a sequence *)
val addseq_listpair : 
    (rname list * gname list) 
    -> state Seq.seq 
    -> state Seq.seq 
val addseq_list : 
    (gname list) 
    -> (gname list * prf) Seq.seq 
    -> (gname list * prf) Seq.seq 

end;


functor GTacsFun(type gname type rname type prf)
: GTACS
= struct

type gname = gname;
type rname = rname;
type prf = prf;
type state = ((rname list * gname list) * prf);

type fwd_gtac = rname -> prf -> state Seq.seq
type bck_gtac = gname -> prf -> state Seq.seq

type gtac = state -> state Seq.seq

(* add results to each thing in a sequence *)
fun addseq_list gs = 
    Seq.map (fn (gs2,p) => (gs @ gs2,p));

(* add results to each thing in a sequence *)
fun addseq_listpair (rs,gs) = 
    Seq.map (fn ((rs2,gs2),p) => ((rs @ rs2, gs @ gs2),p));

(* also apply the list of state transitions gathering the results *)
fun also' gather [] p = Seq.single (([],[]),p)
  | also' gather (hf::tfs) p = 
    (hf p) |> Seq.maps (fn (ns,p2) => gather ns (also' gather tfs p2));

(* also apply the list of state transitions gathering the results *)
val also : (prf -> state Seq.seq) list -> prf -> state Seq.seq
 = also' addseq_listpair;

(* make gtacs from function that take a result to work forwards from,
   or a goal to work backwards from *)
fun mk_map_fwd f ((rs,gs), p) = 
    addseq_listpair ([],gs) ((also (map (fn r => (f r)) rs)) p);

fun mk_map_bck f ((rs,gs), p) = 
    addseq_listpair (rs,[]) ((also (map (fn g => (f g)) gs)) p);

fun of_bckf f = 
    mk_map_bck (fn g => fn p => 
                Seq.map (fn (gs2,p2) => (([],gs2),p2)) 
                        (f g p));

fun of_fwd1f f = 
    mk_map_fwd (fn r => fn p => 
                Seq.map (fn (r2,p2) => (([r2],[]),p2))
                        (f r p));


(* depth and breadth first search of then applications - the
difference is the order in which they treat intermediate goals, depth
first treating new goals first and breadth first treating all the old
goals first. *)
fun thenl [] st = Seq.single st
  | thenl (lfs as hf::tfs) st = (hf st) |> Seq.maps (thenl tfs);

(* fail *)
fun fail st = Seq.empty
fun id st = Seq.single st;

(* or = seq of f1's, f2's *)
fun or fs st = 
    Basics.fold (fn f => (fn seq => Seq.append (f st) seq)) fs Seq.empty;

(* try applying f, if we fail, we give back a the state without change  *)
fun try f st = 
    (case Seq.pull (f st) of 
       NONE => Seq.single st
     | SOME (h,t) => Seq.cons h t);

(* apply state function before or after *)
fun then_f f afterf = Seq.map afterf o f;
fun f_then beforef f = f o beforef;

(* apply f then filter results (select the ones you want to keep) *)
fun then_select selectf f = Seq.filter selectf o f;

(* leave no goals or fail *)
val prove_or_fail : gtac -> gtac
 = then_select (fn ((_,[]),_) => true | _ => false);

(* repeated application *)
fun repeat f st = (f st) |> Seq.maps (repeat f);

end;


structure GTacs = 
GTacsFun(
  type gname = Prf.gname 
  type rname = Prf.gname 
  type prf = Prf.T);
