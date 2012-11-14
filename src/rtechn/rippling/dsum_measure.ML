(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      dsum_measure.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Modified:   19 Sep 2008
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    sum of distances measure
*)

structure DB_DSumMeasure
= struct 

val name = "DSumMeasure";

structure Mes = SStrName;

datatype dir = Up | Down

val default_dir = Up;

type mes = (int (* wave front size *)
           * dir) (* direction *)
             option;

val no_wf_measure = NONE;

fun mk_default_mes 0 = NONE
  | mk_default_mes n = SOME (n,default_dir);

fun mk_both_mes NONE = [NONE]
  | mk_both_mes (SOME (n,_)) = [SOME (n,Up), SOME (n,Down)];


(* head-normal form trees with difference measures for pretty printing *)
datatype mes_tree = 
         MesTrLeaf of mes * Mes.name * bool (* bool = is sink or not *)
       | MesTrAbs of mes * Mes.name * mes_tree
       | MesTrApp of mes * Mes.name * (mes_tree list);

(* for size-weighted measures, change: "topdist + ..." to: "topdist * m + ..." *)
fun add_to_mes NONE topdist sink_dist dsum = dsum
  | add_to_mes (SOME (m,Up)) topdist sink_dist_opt dsum = 
    topdist + dsum
  | add_to_mes (SOME (m,Down)) topdist  (SOME sink_dist) dsum = 
    sink_dist + dsum
  | add_to_mes (SOME (m,Down)) topdist NONE dsum = 
    raise ERROR "add_to_mes: down wf without sink distance under it";

(* maximal distance to sinks *)
fun compose_sink_dist NONE NONE = NONE
  | compose_sink_dist (SOME d1) (SOME d2) = SOME (Int.max (d1,d2))
  | compose_sink_dist NONE d2 = d2
  | compose_sink_dist d1 NONE = d1;

fun add_one_to_sinkd NONE = NONE
  | add_one_to_sinkd (SOME x) = SOME (x + 1);

(* go through measure tree *)
fun dsum_of_mestree topdist (MesTrApp (m,_,l)) = 
    let 
      val topdist' = topdist + 1;
      val (sinkd, dsum2) = 
          fold (fn t => fn (sinkd1,dsum1) => 
                   let val (sinkd2, dsum2) = dsum_of_mestree topdist' t
                   in (compose_sink_dist sinkd2 sinkd1, dsum2 + dsum1)
                   end)
               l (NONE, 0)
      val sinkd2 = add_one_to_sinkd sinkd;
    in (sinkd2, add_to_mes m topdist sinkd2 dsum2) end

  | dsum_of_mestree topdist (MesTrAbs (m,_,t)) = 
    let val (sinkd, dsum2) = dsum_of_mestree (topdist + 1) t
      val sinkd2 = add_one_to_sinkd sinkd;
    in (sinkd2, add_to_mes m topdist sinkd2 dsum2) end

  | dsum_of_mestree topdist (MesTrLeaf(m,_,is_sink)) = 
    let val sinkd = (if is_sink then (SOME 1) else NONE)
    in (sinkd, add_to_mes m topdist sinkd 0) end;

fun has_sink (MesTrApp (_,_,l)) = List.exists has_sink l
  | has_sink (MesTrAbs (_,_,t)) = has_sink t
  | has_sink (MesTrLeaf(_,_,s)) = s;

(* lists with one of each list of list of lists *)
fun one_of_each [] = []
  | one_of_each [[]] = []
  | one_of_each [(h::t)] = [h] :: (one_of_each [t])
  | one_of_each ([] :: xs) = []
  | one_of_each ((h :: t) :: xs) = 
    (map (fn z => h :: z) (one_of_each xs)) 
    @ (one_of_each (t :: xs));

(* IMPROVE: should be a generic way to wrap/cache the has_sink info... *)
(* given a tree, make a tree of all possible directions; assumes input
   tree has all Up annotations. *)
fun all_dir_of_mestree (MesTrApp (m,n,l)) = 
    let 
      val l2s = one_of_each (map all_dir_of_mestree l)
      val ms = if List.exists has_sink l then mk_both_mes m else [m]
    in maps (fn l2 => map (fn m => MesTrApp (m,n,l2)) ms) l2s end
  | all_dir_of_mestree (MesTrAbs (m,n,t)) = 
    let val ts = all_dir_of_mestree t
        val ms = if has_sink t then mk_both_mes m else [m]
    in maps (fn t => map (fn m => MesTrAbs (m,n,t)) ms) ts end
  | all_dir_of_mestree (t as MesTrLeaf(m,n,is_sink)) = 
    (if is_sink then map (fn m => MesTrLeaf(m,n,is_sink))
                         (mk_both_mes m)
     else [t]);


(* int names for skeleton term positions, by depth-first traversal,
ignores application nodes. Application nodes wave fronts are
represented by the wave front on the head symbol. *)
datatype T = Mes of 
         {emb : Embed.T, (* embedding *)
          mestr : mes_tree,
          dsum : int (* sum of distances to nearest sink *)
         };


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
    in (names3,MesTrApp(no_wf_measure,n,rev mtL)) end
  | zero_mes_tree_of_term (Abs (s,ty,t)) names = 
    let val (n,names2) = new_name names 
        val (names3,mt) = zero_mes_tree_of_term t names2
    in (names3,MesTrAbs (no_wf_measure,n,mt)) end
  | zero_mes_tree_of_term t names = 
    let val (n,names2) = new_name names
    in (names2,MesTrLeaf (no_wf_measure,n,false)) end;

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
              MesTrApp (mk_default_mes (sum_wf_sizes e ((Ectxt.get_top_wf h)::extrawfs)), 
                        n, rev mtL)) 
          end

        | recf extrawfs (Ectxt.eAbs((_,_,et),wf)) names = 
          let val (n,names2) = new_name names 
              val (names3,mt) = recf [] et names2
          in (names3, MesTrAbs (mk_default_mes (sum_wf_sizes e (wf::extrawfs)), n, mt)) end
          
        | recf extrawfs (Ectxt.eSrcVar (_,wf)) names = 
          let val (n,names2) = new_name names
          in (names2,MesTrLeaf (mk_default_mes (sum_wf_sizes e (wf::extrawfs)),n,true)) end
          
        | recf extrawfs (Ectxt.eDestVar ((t,_,_),wf)) names = 
          zero_mes_tree_of_term t names
          
        | recf extrawfs (Ectxt.eIntoBound ((en,i),wf)) names = 
          recf (wf::extrawfs) (#3 (Embed.get_sub e en)) names
          
        | recf extrawfs lf names = 
          let val (n,names2) = new_name names
          in (names2,
              MesTrLeaf (mk_default_mes 
                           (sum_wf_sizes e ((Ectxt.get_top_wf lf)::extrawfs)),
                         n,false)) end;

    in recf [] (Embed.get_eterm e) Mes.NSet.empty end;


fun get_emb (Mes rep) = #emb rep;
fun get_mestr (Mes rep) = #mestr rep;
fun get_dsum (Mes rep) = #dsum rep;
(* implicit: mes p *)

(* LESS = m1 is better; *)
fun ord (m1,m2) = Int.compare (get_dsum m1,get_dsum m2);

structure Col = CollectionFUN(type key = T val ord = ord);


(* *)
fun init e = 
    let val (names,mestr) = mes_tree_of_embed e
        val mestrees = all_dir_of_mestree mestr;
    in map (fn t => 
               let val (sinkd,dsum) = dsum_of_mestree 1 t in 
                 Mes {emb = e, dsum = dsum, mestr = t}
               end)
           mestrees
    end;

(* initialise a new measure *)
fun init_measures es = Col.of_list (maps init es);

(* given: old measure, new embedding, give back all possible new measures *)
(* FIXME: only make different new states when measure flow is different. *)
fun all_next_measures oldms es = init_measures es;

(* given: old measures, new embedding, gives back new measures which made progress *)
(*  *)
fun better_next_measures oldms es = init_measures es;

(* *)
fun success_chk mes = (get_dsum mes = 0)


fun pretty_term_pos_and_wf n wfopt = 
    Pretty.block 
      ([Mes.pretty_name n]
       @ (case wfopt of SOME (sz,dir) => 
                        [Pretty.str "*", 
                         (case dir of Up => Pretty.str "^"
                                    | Down => Pretty.str "_"),
                         Pretty.str (Int.toString sz)]
                      | NONE => [Pretty.str ""]));

fun pretty_mestr (MesTrLeaf(sz,n,is_sink)) = 
    Pretty.block 
      ((if is_sink then [Pretty.str "?"] else []) @ 
       [pretty_term_pos_and_wf n sz])
  | pretty_mestr (MesTrAbs(sz,n,mestr)) = 
    Pretty.block 
      [Pretty.str "Abs",
       pretty_term_pos_and_wf n sz,
       Pretty.str "[", pretty_mestr mestr, Pretty.str "]"]
  | pretty_mestr (MesTrApp(sz,n,mestrL)) = 
    Pretty.block 
      [pretty_term_pos_and_wf n sz,
       Pretty.list "[" "]" (map pretty_mestr mestrL)];


fun pretty_full (m as Mes rep) = 
    Pretty.chunks 
       [Pretty.block [Pretty.str "Embed: ", 
                      Embed.pretty (#emb rep)],
        Pretty.block [Pretty.str "dsum: ", 
                      Pretty.str (Int.toString (#dsum rep))],
        Pretty.block [Pretty.str "MesTree: ", 
                      pretty_mestr (#mestr rep)]
        ];

val print_full = Pretty.writeln o pretty_full;


fun pretty_short (m as Mes rep) = 
    Pretty.block 
      [Pretty.block [Pretty.str "", 
                     Pretty.str (Int.toString (#dsum rep))],
       Pretty.block [Pretty.str ": ", 
                     pretty_mestr (#mestr rep)]];

val pretty = pretty_short;

val print = Pretty.writeln o pretty;

end;


structure DSumMeasure : BASIC_RIPPLE_MEASURE = DB_DSumMeasure;
structure RippleMeasure = DSumMeasure;
(* 
 structure DSumRippleMeasure : BASIC_RIPPLE_MEASURE = 
  IntRippleMeasureFUN(val embed_measure = DB_DSumMeasure.measure);
*)
