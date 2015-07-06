(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      flow_measure.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Modified:   19 Sep 2008
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

Measure based on identifying changes in wave front size and
considering it a vector to the sinks and top of term tree.
                                                         
Wave front movement between points in term tree defines a "flow" on
the tree. We allow flow in the direction of wave fronts/top of term
tree, but never allow back-flow on a path.

*)

(* 
signature FLOW_MEASURE 
= sig
  include BASIC_RIPPLE_MEASURE

  structure Mes : SSTR_NAMES

end;
*)

(* flow are just mappings on names; they form a function on a single
space, but the closure of any value must be finite. The order is based
on the names. A function "f" is GREATER than "g" when it conatins the
first element not contained in "g".  *)

functor FlowFun(Nm : SNAME) 
= struct

(* IMPROVE: to allow composition of flows, replace with NameMap; 
   then renaming etc can happen. *)
type T = Nm.NSet.T Nm.NTab.T; (* from(wf starts) -> to(wf ends) set *)

(* flow comparison - check what distinct flow the two flows have. *)
fun flow_compare (f1,f2) = 
    let 
      (* remove all stuff in both *)
      val (f1',f2') = 
          Nm.NTab.fold 
            (fn (tof2,fromf2s) => fn (f1',f2') => 
             case Nm.NTab.lookup f1' tof2 of 
               NONE => (f1',f2')
             | SOME fromf1s => 
               if Nm.NSet.eq fromf2s fromf1s then 
                 (Nm.NTab.delete tof2 f1', Nm.NTab.delete tof2 f2')
               else (f1',f2'))
            f2 (f1,f2)
    in (Nm.NTab.is_name_empty f1',Nm.NTab.is_name_empty f2') end;

(* flow ordering, more flow entries = smaller in order. A flow ord
   value is larger than another if it is contained by the other, i.e. 
   has all the same flow directions and the other also has more 
   flow directions. *)
fun simply_better_flow_ord (f1, f2) =
    (case flow_compare (f1,f2)
      of (false, true) => LESS
       | (true, false) => GREATER
       | (_, _) => EQUAL (* both empty or both have different stuff *))


(* total ordering on flow: GREATER if fst contains elements not conatined by the other. 
   one with smallest name that is not contained in the other is bigger: strict refinement of
   better_flow_ord. (refines EQUAL case only - LESS and GREATER are still
   respected) *)
fun total_flow_ord (f1, f2) =
    (case Nm.NTab.pull_smallest f1 
      of NONE => if Nm.NTab.is_element_empty f2 then EQUAL
                 else LESS
       | SOME ((fromn1,ns1),f1') => 
         (case Nm.NTab.pull_smallest f2 
           of NONE => GREATER
            | SOME ((fromn2,ns2),f2') => 
              (case Nm.name_ord (fromn1,fromn2) 
                of LESS => GREATER
                 | GREATER => LESS
                 | EQUAL => 
                   (case Nm.NSet.ord (ns1, ns2)
                     of LESS => LESS
                      | GREATER => GREATER
                      | EQUAL => total_flow_ord (f1',f2')))));
 
val ord = total_flow_ord;

fun add_1flow_to ton fromn flow = 
    Nm.NTab.update 
      (fromn,
       Nm.NSet.add ton (case Nm.NTab.lookup flow fromn 
                          of NONE => Nm.NSet.empty | SOME toset => toset))
      flow;

fun add_1flow fromn ton flow = 
    add_1flow_to ton fromn flow;

fun pretty_flow flow = 
    Pretty.block [Pretty.str "Flow: ", 
                  Nm.NTab.pretty_as_list Nm.NSet.pretty flow];

(* a collection of flows (a set) *)
(* structure Col = CollectionFUN(type key = T val ord = total_flow_ord); *)

val empty = Nm.NTab.empty;

end;



(* measures for embeddings based on flows *)
structure DB_FlowMeasure
= struct 

val name = "FlowMeasure";

structure Mes = SStrName;

structure Flow = FlowFun(Mes);

(* head-normal form trees with difference measures for pretty printing *)
datatype mes_tree = 
         MesTrLeaf of int * Mes.name * bool (* bool = is sink or not *)
       | MesTrAbs of int * Mes.name * mes_tree
       | MesTrApp of int * Mes.name * (mes_tree list);


(* int names for skeleton term positions, by depth-first traversal,
ignores application nodes. Application nodes wave fronts are
represented by the wave front on the head symbol. *)
datatype T = Mes of 
         {emb : Embed.T, (* embedding *)
          sinks : Mes.NSet.T, (* name of sink positions *)
          mestr : mes_tree,
          pressure : int, (* preasure w.r.t. some flow *)
          flow : Flow.T,
          avgflow : int, (* averge wave front flow, lower is better *)
          wfps : int (* wave front size *)
                  Mes.NTab.T};

(* lookup wave fronts and find the sum of the sizes *)
fun sum_wf_sizes e wfns = 
    let fun merge_wf_sizes [] size = size
          | merge_wf_sizes ((SOME wfn)::wfns) size = 
            let val wf_size = List.length (Embed.get_wf e wfn)
            in merge_wf_sizes wfns (wf_size + size) end
          | merge_wf_sizes (NONE::wfns) size = merge_wf_sizes wfns size;
    in merge_wf_sizes wfns 0 end;

fun new_name names = Mes.NSet.add_new Mes.default_name names;

(* make a measure tree with no wave fronts from a term *)
fun zero_mes_tree_of_term (t as _ $ _) names = 
    let val (h,ts) = strip_comb t
        val (n,names2) = new_name names
        val (names3,mtL) = 
            fold (fn t => fn (names',mtL) => 
                                 let val (names2',mt) = zero_mes_tree_of_term t names'
                                 in (names2',(mt::mtL)) end)
                     ts (names2,[])
    in (names3,MesTrApp(0,n,rev mtL)) end
  | zero_mes_tree_of_term (Abs (s,ty,t)) names = 
    let val (n,names2) = new_name names 
        val (names3,mt) = zero_mes_tree_of_term t names2
    in (names3,MesTrAbs (0,n,mt)) end
  | zero_mes_tree_of_term t names = 
    let val (n,names2) = new_name names
    in (names2,MesTrLeaf (0,n,false)) end;

(* assumes terms are beta-short form *)
fun mes_tree_of_embed e = 
    let 
      (* exrawf is the carried wave front from the outer-part of a
         sub-embeding, consider: "f (g a))" --> "wf1 (%x. f (wf2 x))
         (wf3 a)"; The wave front's on "a" are wf2@wf3, the extrawf
         when considering eterm for "wf3 a" is wf2. *)
      fun recf extrawfs (et as Ectxt.eApp (_, _)) names = 
          let val (h,ets) = Ectxt.dest_app et (* measure by head & list style term shape *)
              val (n,names2) = new_name names
              val (names3,mtL) = 
                  fold (fn et' => fn (names',mtL) => 
                                       let val (names2',mt) = recf [] et' names'
                                       in (names2',(mt::mtL)) end)
                           ets (names2,[])
          in (names3,
              MesTrApp (sum_wf_sizes e ((Ectxt.get_top_wf h)::extrawfs), n, rev mtL)) 
          end

        | recf extrawfs (Ectxt.eAbs((_,_,et),wf)) names = 
          let val (n,names2) = new_name names 
              val (names3,mt) = recf [] et names2
          in (names3, MesTrAbs (sum_wf_sizes e (wf::extrawfs), n, mt)) end
          
        | recf extrawfs (Ectxt.eSrcVar (_,wf)) names = 
          let val (n,names2) = new_name names
          in (names2,MesTrLeaf (sum_wf_sizes e (wf::extrawfs),n,true)) end
          
        | recf extrawfs (Ectxt.eDestVar ((t,_,_),wf)) names = 
          zero_mes_tree_of_term t names
          
        | recf extrawfs (Ectxt.eIntoBound ((en,i),wf)) names = 
          recf (wf::extrawfs) (#3 (Embed.get_sub e en)) names
          
        | recf extrawfs lf names = 
          let val (n,names2) = new_name names
          in (names2,
              MesTrLeaf (sum_wf_sizes e ((Ectxt.get_top_wf lf)::extrawfs),
                         n,false)) end;

    in recf [] (Embed.get_eterm e) Mes.NSet.empty end;


fun get_emb (Mes rep) = #emb rep;
fun get_wfps (Mes rep) = #wfps rep;
(* implicit: mes p *)
val get_wf_size = Mes.NTab.get o get_wfps;


fun get_pressure (Mes rep) = #pressure rep;
fun update_pressure f (Mes rep) = 
    Mes {emb = #emb rep, avgflow = #avgflow rep,
         pressure = f (#pressure rep),
         flow = #flow rep,
         mestr = #mestr rep, sinks = #sinks rep, 
         wfps = #wfps rep};
val set_pressure = update_pressure o K;

fun get_flow (Mes rep) = #flow rep;
fun update_flow f (Mes rep) = 
    Mes {emb = #emb rep, flow = f (#flow rep), avgflow = #avgflow rep,
         pressure = #pressure rep,
         mestr = #mestr rep, sinks = #sinks rep, wfps = #wfps rep};
val set_flow = update_flow o K;

fun get_avgflow (Mes rep) = #avgflow rep;
fun update_avgflow f (Mes rep) = 
    Mes {emb = #emb rep, avgflow = f (#avgflow rep), flow = #flow rep,
         pressure = #pressure rep,
         mestr = #mestr rep, sinks = #sinks rep, wfps = #wfps rep};
val set_avgflow = update_avgflow o K;

(* LESS = m1 is better; m1 is new  *)
fun ord (m1,m2) =
    (case Int.compare (get_pressure m1, get_pressure m2) 
      of EQUAL => Flow.ord (get_flow m2, get_flow m1) (* more flow is better; swapped *)
       | LESS => LESS
       | GREATER => GREATER);

(* collections of measures *)
structure Col = CollectionFUN(type key = T val ord = ord);


(* IMPROVE: take account of pressure * size: lex order on pressure the
sizes.  size * pressure not good, as small increase in size is bad,
even if it ripple out.
*)
(* IMPROVE: does wfps have zero entries for zero sizes? better for it 
   to be empty? *)
fun pressure_of_wfps flow wfps =
    Mes.NTab.fold 
      (fn (n,sz) => 
       fn pressure => 
          if sz > 0 then 
            (case Mes.NTab.lookup flow n of 
               NONE => 1 + pressure
             | SOME nset => 1 
                            + ((length (Mes.NSet.list_of nset))) 
                            + pressure)
          else pressure
      ) wfps 0;

(* ASSUMES: consistent ordering of names w.r.t. choosing names *)
(* traverse a term to make the term position names *)
(* returns: 
   (sink_below, upflow set),
   (wfps, sinks, initial flow = rippling-out) *)
fun init_from_mestr (MesTrLeaf (wfsize,n,is_sink)) (wfps,sinks,flow) = 
    let val wfps2 = Mes.NTab.update (n, wfsize) wfps
    in ((is_sink, 
         if is_sink then Mes.NSet.empty else Mes.NSet.add n Mes.NSet.empty),
        (wfps2, 
         if is_sink then Mes.NSet.ins_fresh n sinks else sinks,
         flow)) end
  | init_from_mestr (MesTrAbs(wfsize,n,mestr)) (wfps,sinks,flow) =
    let val wfps2 = Mes.NTab.update (n, wfsize) wfps
        val ((has_sink,upflows),(wfps3,sinks3,flow3)) = 
            init_from_mestr mestr (wfps2,sinks,flow)
    in
      ((has_sink,if has_sink then upflows else Mes.NSet.add n upflows),
       (wfps3,sinks3, Mes.NSet.fold (Flow.add_1flow_to n) upflows flow3))
    end
  | init_from_mestr (MesTrApp (wfsize,n,mestrL)) (wfps,sinks,flow) = 
    let val wfps2 = Mes.NTab.update (n, wfsize) wfps
        val ((has_sink,upflows),(wfps3,sinks3,flow3)) = 
            fold (fn mestr => fn ((has_sink2,upflow2),wfs) => 
                  let val ((has_sink_here,upflow_here),wfs2) = 
                          init_from_mestr mestr wfs
                  in ((has_sink2 orelse has_sink_here,
                       Mes.NSet.union_merge upflow_here upflow2),
                      wfs2) end)
                 mestrL ((false,Mes.NSet.empty),(wfps2,sinks,flow))
    in
      ((has_sink,if has_sink then upflows else Mes.NSet.add n upflows),
       (wfps3, sinks3, Mes.NSet.fold (Flow.add_1flow_to n) upflows flow3))
    end;

(* *)
fun init e = 
    let 
      val (names,mestr) = (mes_tree_of_embed e)
      val ((has_sink,upflows),(wfps,sinks,flow)) = 
            init_from_mestr mestr (Mes.NTab.empty,Mes.NSet.empty,Flow.empty)
    in (Mes {emb = e, avgflow = 1, (* intially avg flow is good *)
             flow = flow, pressure = pressure_of_wfps flow wfps,
             mestr = mestr, sinks = sinks, wfps = wfps}) end;

(* initialise a new measure *)
fun init_measures es = Col.of_list (map init es);

(* temporary datatype to hold wave front sizes at points in the term tree *)
datatype flowqty = 
         FlowQty of 
         {less_wfs : int Mes.NTab.T, (* positions that get better (how much) *)
          more_wfs : int Mes.NTab.T (* positions that got worse (how much) *)
         }

(* no flow *)
val empty_flowqty = (FlowQty {less_wfs = Mes.NTab.empty, 
                              more_wfs = Mes.NTab.empty});

(* *)
fun add_good_flowqty p sz (FlowQty rep) = 
    FlowQty {less_wfs = Mes.NTab.ins (p,sz) (#less_wfs rep),
             more_wfs = #more_wfs rep};

fun add_bad_flowqty p sz (FlowQty rep) = 
    FlowQty {less_wfs = #less_wfs rep,
             more_wfs = Mes.NTab.ins (p,sz) (#more_wfs rep)};

(* Assumes measures are of the same skeleton. *)
(* computes amount of wave front change at each position *)
(* CHANGE TO wfps ********************* *)
fun compute_flowqty oldwfps newwfps = 
    Mes.NTab.fold 
      (fn (p,sz) => fn flow =>
                       let val oldsize = Mes.NTab.get oldwfps p
                       in case Int.compare (oldsize,sz)
                           of LESS => add_bad_flowqty p (sz - oldsize) flow
                            | EQUAL => flow
                            | GREATER => add_good_flowqty p (oldsize - sz) flow
                       end)
      newwfps empty_flowqty;

(* IMPROVE: use sz instead of 1 ? *)
(* updates flow direction graph for new flows, returns avg flow *)
fun recompute_mes_flow (FlowQty rep) old_flow = 
    let 
      fun update_1flow fromn sz ton (total,flow,changed) = 
          (case Mes.NTab.lookup flow ton
            of NONE => (* no previous flow from ton to fromn; so add from->ton as good flow *)
               (total + 1, Flow.add_1flow fromn ton flow, true)
             | SOME ton_froms => (* previous flow from ton *)
               (if Mes.NSet.contains ton_froms fromn 
                then (total - 1, flow,changed) (* bad flow direction *)
                else (* else good flow *) 
                  (total + 1, Flow.add_1flow fromn ton flow, true)));

      val (avgflow, flow2,changed) = 
          Mes.NTab.fold 
            (fn (ton,sz) =>
                Mes.NTab.fold (fn (fromn,sz2) => 
                                  update_1flow fromn (1 + sz2) ton)
                              (#less_wfs rep))
            (#more_wfs rep)
            (0,old_flow,false)
    (* (if changed then SOME flow2 else NONE) -- in case we need it opt? *)
    in (avgflow, flow2) end;


(* ASSUMES: consistent ordering of names w.r.t. choosing names *)
(* traverse a term to make the term position names *)
fun wfps_and_sinks_of_mestr (MesTrLeaf (wfsize,n,is_sink)) (wfps,sinks) = 
    let val wfps2 = Mes.NTab.update (n, wfsize) wfps
    in (wfps2,if is_sink then Mes.NSet.ins_fresh n sinks else sinks) end
  | wfps_and_sinks_of_mestr (MesTrAbs(wfsize,n,mestr)) (wfps,sinks) =
    let val wfps2 = Mes.NTab.update (n, wfsize) wfps
    in wfps_and_sinks_of_mestr mestr (wfps2,sinks) end
  | wfps_and_sinks_of_mestr (MesTrApp (wfsize,n,mestrL)) (wfps,sinks) = 
    let val wfps2 = Mes.NTab.update (n, wfsize) wfps
    in fold wfps_and_sinks_of_mestr mestrL (wfps2,sinks) end;

(* given: old measure, new embedding, give back all possible new measures *)
fun all_next_measures oldms es = 
    fold 
      (fn e => 
       let 
         val (names,mestr) = mes_tree_of_embed e
         val (wfps,sinks) = wfps_and_sinks_of_mestr mestr (Mes.NTab.empty,Mes.NSet.empty)
       in 
         Col.fold
           (fn oldm => 
            let
              val (avgflow,flow2) = 
                  recompute_mes_flow (compute_flowqty (get_wfps oldm) wfps)
                                     (get_flow oldm)
              val m = (Mes {emb = e, avgflow = avgflow, flow = flow2,
                            pressure = pressure_of_wfps flow2 wfps,
                            mestr = mestr, sinks = sinks, wfps = wfps})
            in Col.union1 m end)
           oldms
       end)
      es
      Col.empty;

fun wfm_less (m,oldm) = 
    Mes.NTab.fold (fn (_,wfsize) => fn sum => wfsize + sum)
                  (get_wfps m) 0
    < 
    Mes.NTab.fold (fn (_,wfsize) => fn sum => wfsize + sum)
                  (get_wfps oldm) 0;

(* given: old measures, new embedding, gives back new measures which made progress *)
fun better_next_measures oldms es = 
    fold 
      (fn e => 
       let 
         val (names,mestr) = mes_tree_of_embed e
         val (wfps,sinks) = wfps_and_sinks_of_mestr mestr (Mes.NTab.empty,Mes.NSet.empty)
       in 
         Col.fold
           (fn oldm => 
            let
              val (avgflow,flow2) = 
                  recompute_mes_flow (compute_flowqty (get_wfps oldm) wfps)
                                     (get_flow oldm)
              val m = (Mes {emb = e, avgflow = avgflow, flow = flow2,
                            pressure = pressure_of_wfps flow2 wfps,
                            mestr = mestr, sinks = sinks, wfps = wfps})
            in case ord(m,oldm) of LESS => Col.union1 m | _ => I end)
           oldms
       end)
      es
      Col.empty;

(* *)
fun success_chk mes = Mes.NTab.forall (fn (_,wfsize) => (wfsize = 0))
                                      (get_wfps mes);

fun pretty_term_pos_and_wf flow n sz = 
    Pretty.block 
      ([Mes.pretty_name n]
       @ (if sz <> 0 then [Pretty.str "*", Pretty.str (Int.toString sz)] else [Pretty.str ""])
       @ [Pretty.str "",
          (* (case Mes.NTab.lookup flow n of NONE => Pretty.str "{}"
                                           | SOME ns => Mes.NSet.pretty ns), *)
          Pretty.str ""
      ]);
    
fun pretty_mestr flow (MesTrLeaf(sz,n,is_sink)) = 
    Pretty.block 
      ((if is_sink then [Pretty.str "?"] else []) @ 
       [pretty_term_pos_and_wf flow n sz])
  | pretty_mestr flow (MesTrAbs(sz,n,mestr)) = 
    Pretty.block 
      [Pretty.str "Abs",
       pretty_term_pos_and_wf flow n sz,
       Pretty.str "[", pretty_mestr flow mestr, Pretty.str "]"]
  | pretty_mestr flow (MesTrApp(sz,n,mestrL)) = 
    Pretty.block 
      [pretty_term_pos_and_wf flow n sz,
       Pretty.list "[" "]" (map (pretty_mestr flow) mestrL)];


fun pretty_full (m as Mes rep) = 
    Pretty.block 
    [Pretty.chunks 
       [Pretty.block [Pretty.str "Pressure: ", Pretty.str (Int.toString (get_pressure m))],
        Pretty.block [Pretty.str "Embed: ", 
                      Embed.pretty (#emb rep)],
        Pretty.block [Pretty.str "Avgflow: ", Pretty.str (Int.toString (#avgflow rep))],       
        Pretty.block [Pretty.str "Sinks: ", 
                      Mes.NSet.pretty (#sinks rep)],
        Pretty.block [Pretty.str "MesTree: ", 
                      pretty_mestr (#flow rep) (#mestr rep)],
        Pretty.block [Pretty.str "Wf Positions: ", 
                      Mes.NTab.pretty (Pretty.str o Int.toString) 
                                      (#wfps rep)]
    ]];

val print_full = Pretty.writeln o pretty_full;


fun pretty_short (m as Mes rep) = 
    Pretty.block 
      [Pretty.str "Pressure: ", Pretty.str (Int.toString (get_pressure m)), Pretty.str ";  ",
       Pretty.str "Avgflow: ", Pretty.str (Int.toString (#avgflow rep))];
    
fun pretty_long (m as Mes rep) = 
    Pretty.block 
    [Pretty.chunks 
       [Pretty.block [Pretty.str "Pressure: ", Pretty.str (Int.toString (get_pressure m))],
        Pretty.block [Pretty.str "Avgflow: ", Pretty.str (Int.toString (#avgflow rep))],
        Pretty.block [Pretty.str "Flow: ", 
                      Mes.NTab.pretty_as_list Mes.NSet.pretty (#flow rep)],
        Pretty.block [Pretty.str "MesTree: ", 
                      pretty_mestr (#flow rep) (#mestr rep)]
    ]];

val pretty = pretty_short;

val print = Pretty.writeln o pretty;


end;


structure FlowMeasure : BASIC_RIPPLE_MEASURE = DB_FlowMeasure;
structure RippleMeasure = FlowMeasure;
(* 
 structure DSumRippleMeasure : BASIC_RIPPLE_MEASURE = 
  IntRippleMeasureFUN(val embed_measure = DB_DSumMeasure.measure);
*)
