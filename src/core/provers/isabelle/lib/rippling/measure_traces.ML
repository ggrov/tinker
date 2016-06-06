(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/rippling/measure_traces.ML
    Author:     Lucas Dixon, University of Edinburgh
                
    Created: 7 Feb 2009 *) 
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*) 
(* 
   Ripple traces - a sequence of ripples that is measure decreasing;
   store all measures that are valid between two steps
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature MEASURE_TRACES
= sig

(* measures *)
type measure

(* names for measures *)
structure Nm : SSTR_NAME

(* trace data *)
type data
(* measure traces *)
type T

(* creating and making the next set of measure traces *)
val init : measure list -> T
val next : measure list -> T 
           -> Nm.NSet.T (* do not decrease on any previous measure *)
              * T

val get_measure : T -> Nm.name -> measure
val get_measures : T -> Nm.NSet.T -> measure list
val get_named_measures : T -> Nm.NSet.T -> (Nm.name * measure) list
val get_mtab : T -> measure Nm.NTab.T
val get_cur_measures : T -> measure list
val get_cur_named_measures : T -> (Nm.name * measure) list
val has_cur_measures : T -> bool (* true iff get_cur_measures != [] *)
val get_cur : T -> Nm.NSet.T

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
functor MeasureTracesFun(
  type measure
  val ord : measure * measure -> General.order)
(* : MEASURE_TRACES *)
= struct

type measure = measure;

structure Nm :> SSTR_NAME = SStrName;
structure LessRel = NameBRelFun(structure Dom = Nm and Cod = Nm); 

datatype T = Trace of 
         { cur : Nm.NSet.T,
           dropped : Nm.NSet.T,
           lessrel : LessRel.T,
           mtab : measure Nm.NTab.T
         };

fun get_mtab (Trace rep) = #mtab rep;
fun get_cur (Trace rep) = #cur rep;
fun get_dropped (Trace rep) = #dropped rep; (* current ones that don't improve on any previous *)
fun get_lessrel (Trace rep) = #lessrel rep;

val get_measure = Nm.NTab.get o get_mtab;
fun get_measures t ns = map (get_measure t) (Nm.NSet.list_of ns);
fun get_named_measures t ns = map (fn n => (n, get_measure t n)) (Nm.NSet.list_of ns);
fun get_cur_measures t = get_measures t (get_cur t);
fun get_cur_named_measures t = get_named_measures t (get_cur t);
fun has_cur_measures t = not (Nm.NSet.is_empty (get_cur t));

fun init measures = 
    let 
      val mtab = fold (fn x => Nm.NTab.doadd (Nm.default_name, x))
                      measures Nm.NTab.empty
    in
      Trace 
        { cur = Nm.NTab.get_nameset mtab,
          dropped = Nm.NSet.empty,
          lessrel = LessRel.empty,
          mtab = mtab }
    end;

(* Note: if new_mesures is empty, everything gets blocked *)
fun next new_mesures t = 
    let 
      val cur = (get_cur t)

      (* names for embeddings and measures *)
      val (newns,mtab) = 
          fold (fn x => fn (newns, measures) =>
                let 
                  val (newn, measures2) = 
                      Nm.NTab.add (Nm.default_name, x) measures
                  val newns = Nm.NSet.add newn newns
                in (newns, measures2) end)
               new_mesures (Nm.NSet.empty, get_mtab t)

      (* update rels *)
      (* dropset are those measure that don't improve on any previous measure *)
      val (dropset, rels) = 
        Nm.NSet.fold 
        (fn newn => fn (dropset, rels) => 
          let val newm = Nm.NTab.get mtab newn
              val rels2 = 
                Nm.NSet.fold 
                  (fn curn => fn rels => 
                    let val curm = Nm.NTab.get mtab curn
                    in case ord (newm,curm) 
                        of LESS => LessRel.add1 newn curn rels
                         (* if exists old mes not improved by some new one, 
                            then there is a path where old mes is blocked *)
                         | _ => rels
                    end)
                  cur rels
              val dropset2 = 
                  if (Nm.NSet.is_empty (LessRel.domf rels2 newn))
                  then Nm.NSet.add newn dropset
                  else dropset
          in (dropset2, rels2) end)
        newns (Nm.NSet.empty, get_lessrel t)

      val newns2 = Nm.NSet.subtract newns dropset
      (* blocked: exists an old measure for which no new 
         measure imprves. *)
      val blocked = 
          Nm.NSet.fold 
            (fn n => fn blockedset => 
                case LessRel.lookup_codf rels n
                 of NONE => Nm.NSet.add n blockedset
                  | SOME _ => blockedset)
            cur Nm.NSet.empty
    in (blocked, 
        Trace 
          { cur = newns2,
            dropped = dropset,
            lessrel = rels,
            mtab = mtab})
    end;

end;
