(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      cinfo/rippling/skel_better.ML
    Author:     Lucas Dixon, University of Edinburgh
                
    Created: 8 Feb 2009 *) 
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*) 
(* Rippling state for a given skeleton: we hold the complete set of
   ripple traces - and return blocked measures ones for the
   skeleton. This corresponds exactly to searching independently with
   each measure, but avoid symmetries in rewriting space and measure
   space.
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
functor RippleSkelMesTracesFUN(RippleMeasure : BASIC_RIPPLE_MEASURE)
(* : RIPPLE_SKEL *)
= struct

structure RippleMeasure = RippleMeasure;
val name = "rippling skel: measure_traces: " ^ RippleMeasure.name; (* unique id to define rippling *)

type em = RippleMeasure.T
fun em_ord (m1, m2) = RippleMeasure.ord (m1,m2);

structure Traces = 
MeasureTracesFun(
  type measure = em 
  val ord = em_ord);

(* the ripple skeleton state for this branch of search *)
datatype T = RippleState of 
 {skelterm : Term.term, (* skeleton term *)
  skelname : string, (* skeleton result name *)
  embeddings : Embed.T list,
  (* current measures *)
  measures : RippleMeasure.Col.T,
  (* measures over all previous steps *)
  traces : Traces.T,
  (* information built up by measure function, e.g. possible flows *)
  (* mtdata : RippleMeasure.trace_data, *)
  (* names of blocked traces *)
  blocked : Traces.Nm.NSet.T};


 (* simple interface functions GET/SET *)
fun get_skelterm (RippleState rep) = #skelterm rep;
fun get_skelname (RippleState rep) = #skelname rep;
fun get_embeddings (RippleState rep) = #embeddings rep;
fun get_measure_col (RippleState rep) = #measures rep;
fun get_traces (RippleState rep) = #traces rep;
(* fun get_mtdata (RippleState rep) = #mtdata rep; *)
fun get_blocked (RippleState rep) = #blocked rep;
fun get_blocked_ms st = 
    Traces.get_measures (get_traces st) (get_blocked st);
val get_measures = Traces.get_cur_measures o get_traces

fun set_skel (skelt, skeln) (RippleState rep) = 
    RippleState {skelterm = skelt, 
                 skelname = skeln, 
                 embeddings = #embeddings rep,
                 measures = #measures rep,
                 traces = #traces rep,
                 blocked = #blocked rep 
                };

fun set_traces traces2 (RippleState rep) = 
    (RippleState {skelterm = #skelterm rep, skelname = #skelname rep, 
                  embeddings = #embeddings rep, measures = #measures rep,
                  traces = traces2, blocked = #blocked rep });

fun set_blocked blocked2 (RippleState rep) = 
    (RippleState {skelterm = #skelterm rep, skelname = #skelname rep, 
                  embeddings = #embeddings rep, measures = #measures rep,
                  traces = #traces rep, blocked = blocked2 });

fun set_measures ms2 (RippleState rep) = 
    (RippleState {skelterm = #skelterm rep, skelname = #skelname rep, 
                  embeddings = #embeddings rep, measures = ms2,
                  traces = #traces rep, blocked = #blocked rep});

fun set_embeddings es2 (RippleState rep) = 
    (RippleState {skelterm = #skelterm rep, skelname = #skelname rep, 
                  embeddings = es2, measures = #measures rep,
                  traces = #traces rep, blocked = #blocked rep});

(* get the named skeleton used during rippling *)
fun get_named_skel_term ripst = (get_skelname ripst, get_skelterm ripst);

fun success_chk ripst = 
    List.exists RippleMeasure.success_chk (get_measures ripst);

(* blocked. *)
fun blocked_chk st newsts = 
    (* blocked if all new states say they are blocked (non-empty blocked set) *)
    List.all (fn newst => 
                 not (Traces.Nm.NSet.is_empty (get_blocked newst)))
             newsts;

fun embeddings ectxt skel_trm target_trm = 
    (Embed.embed ectxt skel_trm target_trm)
      |> Seq.list_of;

(* *)
fun ord (m1,m2) = if Traces.has_cur_measures m2 then LESS else GREATER;

  (* choices to be searched over *)
fun init {ectxt    : Embed.Ectxt.T,
          skelname : string,
          skelterm : Term.term, 
          target   : Term.term} =
    let 
      val es = embeddings ectxt skelterm target
      val ms = RippleMeasure.init_measures es
    in 
      if null es then [] (* you have to at least have an embedding to start with *)
      else [RippleState {skelterm = skelterm, 
                     skelname = skelname, 
                     embeddings = es,
                     measures = ms,
                     traces = Traces.init (RippleMeasure.Col.list_of ms),
                     blocked = Traces.Nm.NSet.empty }]
    end;

(* Search though all possible improveing measures *)
fun mk_better_next ectxt newtrm oldst = 
    let 
      val es = embeddings ectxt (get_skelterm oldst) newtrm
      val ms = RippleMeasure.better_next_measures (get_measure_col oldst) es
      val (blocked,traces2) = Traces.next (RippleMeasure.Col.list_of ms)
                                          (get_traces oldst)
    in (* remark: if es is empty, then no cur measure *)
      if (Traces.has_cur_measures traces2)
      then [oldst |> set_traces traces2
                  |> set_embeddings es
                  |> set_measures ms
                  |> set_blocked blocked]
      else [] (* only have a new state if there is some better measure *)
    end;

(* Search though all possible measures; for best first rippling *)
fun mk_all_next ectxt newtrm oldst = 
  let 
    val es = embeddings ectxt (get_skelterm oldst) newtrm
    val ms = RippleMeasure.all_next_measures (get_measure_col oldst) es
    val (blocked,traces2) = Traces.next (RippleMeasure.Col.list_of ms) 
                                        (get_traces oldst)
  in  (* always have a result even if no better measure *)
    [oldst |> set_traces traces2
           |> set_embeddings es
           |> set_measures ms
           |> set_blocked blocked]
  end;

(* ------------------------------------------------------------ *)
(* Pretty printing *)
(* ------------------------------------------------------------ *)
(* IMPROVE: for best first, add in printing of all measures if no better measures... *)
fun pretty_measures skel_name [] = 
    Pretty.block [Pretty.str "no measures for skeleton: ", 
                  Pretty.str skel_name]
  | pretty_measures skel_name (ms as (mh::mt)) = 
    let 
      val (num_of_ms,biggest as (bn,bm),smallest as (sn,sm)) = 
          fold (fn (n,m) => 
                fn (count,(b as (bn,bm)),(s as (sn,sm))) => 
                   (count + 1, 
                    case RippleMeasure.ord (m,bm)
                     of GREATER => (n,m) | _ => b, 
                    case RippleMeasure.ord (m,sm)
                     of LESS => (n,m) | _ => s))
               mt
               (1, mh, mh);
    in
    Pretty.chunks
      [Pretty.block [Pretty.str ("(" ^ (Int.toString num_of_ms) ^ ") measures for skeleton: "),
                     Pretty.str skel_name,
                     Pretty.str ": {"
                     ],
       Pretty.block ([(if num_of_ms < 3 then 
                         Pretty.chunks 
                           (map (fn (n,m) => 
                                    Pretty.block [Pretty.str "(", 
                                                  Traces.Nm.pretty_name n,
                                                  Pretty.str ") ",
                                                  RippleMeasure.pretty m]) 
                                ms)
                       else 
                         Pretty.chunks
                           [Pretty.block [Pretty.str "(", 
                                          Traces.Nm.pretty_name bn,
                                          Pretty.str ") ", 
                                          RippleMeasure.pretty bm,
                                          Pretty.str " ..."],
                            Pretty.block [Pretty.str "(", 
                                          Traces.Nm.pretty_name sn,
                                          Pretty.str ") ", 
                                          RippleMeasure.pretty sm]])]),
       Pretty.str "}"
      ]
    end;
       (* Pretty.block 
         *)

fun pretty_embeddings es = 
      Pretty.block [Pretty.str "Embeddings: ", 
                    Pretty.list "{" "}" (map Embed.pretty es)];

fun pretty ctxt st = 
    Pretty.chunks 
      [pretty_measures 
         (get_skelname st)
         (Traces.get_cur_named_measures (get_traces st)),
       pretty_embeddings (get_embeddings st)
      ];

fun print ctxt = Pretty.writeln o pretty ctxt;

end;


structure DB_RippleSkel = RippleSkelMesTracesFUN(FlowMeasure);
structure RippleSkel : RIPPLE_SKEL = DB_RippleSkel;
