(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      src/gproof/prf/rtree.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Updated:    21 Oct 2006
    Created:    21 Oct 2006
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* result tree: a way to move all the recursion of the proof graph
into a single nice datatype: we pull all the data into an RTree, do
our work on it, and then push it back. Used for making conjectures and
for introduccing new results and their assumptions. For example, we
can provide context renaming for a rtree easily. 

Idea is to have implicit contexts here, as this is the essence of much
of the resursion that is needed in modifying a proof environment. 

IMPROVE: Unclear that we need fixes, probably best to remove it and
get rid of data separation in record. 

*)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature RTREE 
= sig
  
  type gname

  (* a result/conjecture tree. 
     For conjectures names and ptab are just suggested namings,
     For results they are the real thing. *)
  datatype T = 
           RTree of {name : gname, (* proposed name *)
                     lfixes : Cx.ptab, (* params *)
                     trm : Trm.T, (* conclusion term *)
                     asms : T list} (* assumptions *)

  (* basic working with the rtrees *)
  val mk : gname -> Cx.ptab -> Trm.T -> T list -> T

  val get_asms : T -> T list
  val get_name : T -> gname
  val get_lfixes : T -> Cx.ptab
  val get_ctrm : T -> Trm.T (* result conclusion term *)

  val has_context : T -> bool

  val set_asms : T list -> T -> T
  val set_name : gname -> T -> T
  val set_lfixes : Cx.ptab -> T -> T
  val set_ctrm : Trm.T -> T -> T

  val update_asms : (T list -> T list) -> T -> T
  val update_lfixes : (Cx.ptab -> Cx.ptab) -> T -> T
  val update_name : (gname -> gname) -> T -> T
  val update_ctrm : (Trm.T -> Trm.T) -> T -> T

  (* final outputed Isabelle term *)
  val trm_of : T -> Trm.T

  (* renaming *)
  val rename : Cx.ptab * Cx.ptab_renaming -> T -> T
  (* special case of renaming: start with fixes of cx and no_renaming *)
  val put_under_fixes : Cx.ptab -> T -> T
  val put_in_cx : Cx.T -> T -> T
  val put_in_ncx : (Cx.cxname * Cx.T) -> T -> T

  (* useful functions! *)
  val foldmap_lfixestrm :
      ('a -> Cx.ptab * Trm.T -> 'a * (Cx.ptab * Trm.T)) -> 'a -> T -> T
  val map_lfixestrm : (Cx.ptab * Trm.T -> Cx.ptab * Trm.T) -> T -> T
  val map_lfixes : (Cx.ptab -> Cx.ptab) -> T -> T
  val map_trm : (Trm.T -> Trm.T) -> T -> T

  (* drops top level params *)
  val drop_lfixes : T -> T
  val drop_inner_lfixes : Cx.ptab -> T -> T
  val drop_outer_lfixes : Cx.ptab -> T -> T

  (* change outer params to fresh vars *)
  val varify_top_fixes : InstEnv.T -> T -> InstEnv.T * T

  (* selected and unselected from tree's direct assumptions *)
  exception no_such_assumptions of gname list;
  val select_asms : Goaln.NSet.T -> T -> T list * T list
  val drop_asms : Goaln.NSet.T -> T -> T list (* dropped these *)
                                     * T (* this left over *)
  val drop_asml : bool list -> T -> T list (* dropped these *)
                                    * T (* this left over *)
  (* pretty printing *)
  val pretty : Proof.context -> T -> Pretty.T;
  val print : Proof.context -> T -> unit

end;


structure DB_RTree
= struct

type gname = Goaln.NSet.name;

datatype T = RTree of 
         { name : gname, (* proposed name *)
           lfixes : Cx.ptab, (* params *)
           trm : Trm.T, (* goal *)
           asms : T list}; (* assumptions *)

fun mk name lfixes trm asms = 
    RTree{name=name,lfixes=lfixes,trm=trm,asms=asms};

fun get_name (RTree rep) = #name rep;
fun get_asms (RTree rep) = #asms rep;
fun get_lfixes (RTree rep) = #lfixes rep;
fun get_ctrm (RTree rep) = #trm rep;

(* we have some context if we have some assumptions or parameters *)
fun has_context rt = 
    not (null (get_asms rt) andalso Cx.isempty_ptab (get_lfixes rt));

(* update / set functions *)
fun update_name f (RTree rep) = 
    RTree {name= f(#name rep),lfixes= #lfixes rep,
           trm= #trm rep,asms= #asms rep};
fun update_asms f (RTree rep) = 
    RTree {name= #name rep,lfixes= #lfixes rep,
           trm= #trm rep,asms= f(#asms rep)};
fun update_lfixes f (RTree rep) = 
    RTree {name = #name rep, lfixes = f (#lfixes rep), 
          trm = #trm rep, asms = #asms rep };
fun update_ctrm f (RTree rep) =
    RTree {name = #name rep, lfixes = #lfixes rep, 
          trm = f(#trm rep), asms = #asms rep };

val set_name = update_name o K;
val set_asms = update_asms o K;
val set_lfixes = update_lfixes o K;
val set_ctrm = update_ctrm o K;

(* update fixes and trm together because trm is dependent on fixes *)
fun update_lfixestrm f (RTree rep) =
    let val (lfixes2,trm2) = f (#lfixes rep,#trm rep) in 
      RTree {name = #name rep, lfixes = lfixes2, 
             trm = trm2, asms = #asms rep }
    end;

fun applyto_lfixestrm f (RTree rep) =
    let val (x,(lfixes2,trm2)) = f (#lfixes rep,#trm rep) in 
      (x,RTree {name = #name rep, lfixes = lfixes2, 
                trm = trm2, asms = #asms rep })
    end;

(* fold a function down and over the tree to update data  *)
fun foldmap_lfixestrm f x0 rtree = 
    let 
      fun rtree_rec x rtree = 
          let val (x2,rtree2) = applyto_lfixestrm (f x) rtree
          in update_asms (map (rtree_rec x2)) rtree2 end;
    in rtree_rec x0 rtree end;

(* map to rtree stuff *)
fun map_lfixestrm f rtree = 
    rtree |> update_lfixestrm f 
          |> update_asms (map (map_lfixestrm f));

fun map_lfixes f rtree = 
    rtree |> update_lfixes f 
          |> update_asms (map (map_lfixes f));

fun map_trm f rtree = 
    rtree |> update_ctrm f 
          |> update_asms (map (map_trm f));

(* given an rtree rename params and update trms, recurse on asms. 
   We are given fixes to avoid and renaming so far. *)
(* implicit (fixes,renaming) rtree *)
val rename = foldmap_lfixestrm Cx.rename_trm_avoiding;

(* make a conjecture rtree from a ctree *)
(* implicit rtree *)
fun put_under_fixes fixes = rename (fixes, Cx.empty_renaming);
(* implicit cx, rtree *)
val put_in_cx = put_under_fixes o Cx.get_fixes;
(* implicit rtree *)
fun put_in_ncx (cxname,cx) = put_in_cx cx;

(* drop params: only valid if trm does not contain the params. *)
(* implicit ptab to drop that number of elements of, then rtree *)
val drop_lfixes = set_lfixes Cx.empty_ptab;
val drop_inner_lfixes = update_lfixes o Cx.drop_inner_nptab;
val drop_outer_lfixes = update_lfixes o Cx.drop_outer_nptab;

(* varify the given ptab, avoiding the ienv variables *) 
fun varify_top_fixes ienv rt = 
    let 
      val ps = Cx.get_trmps_of_ptab (get_lfixes rt)
      val (lifting,ienv2) = 
            Lifting.mk Trm.TrmParams.empty ps ienv
    in 
      (ienv2, rt |> set_lfixes Cx.empty_ptab
                 |> map_trm (Lifting.lift lifting))
    end; 

(* select asm names from tree's direct assumptions *)
exception no_such_assumptions of gname list;
fun select_asms anames rtree = 
    let 
      val (inn,out,leftover) = 
          fold_rev (fn rt => fn (inn,out,col) =>
                                let val n = (get_name rt) in 
                                  if Goaln.NSet.contains col n then 
                                    (rt::inn,out,Goaln.NSet.delete n col)
                                  else
                                    (inn,rt::out,col) end)
                   (get_asms rtree)
                   ([],[],anames);
    in
      if Goaln.NSet.is_empty leftover then 
        (inn,out)
      else
        raise no_such_assumptions (Goaln.NSet.list_of leftover)
    end;

fun drop_asms asms rtree =
    let val (drop,keep) = select_asms asms rtree
    in (drop, set_asms keep rtree) end;

fun drop_asml dropasmbools rtree =
    let 
      val rtreeasms = (get_asms rtree)
      fun partition [] [] (inns,outs) = (inns,outs)
        | partition (true::t) (h2::t2) (inns,outs) =
          partition t t2 (h2::inns,outs)
        | partition (false::t) (h2::t2) (inns,outs) =
          partition t t2 (inns,h2::outs)
        | partition _ [] (inns,outs) = (inns,outs)
        | partition [] l (inns,outs) = (inns,l @ outs);
      val (drop,keep) = partition dropasmbools rtreeasms ([],[])
    in (drop, set_asms keep rtree) end;

(* make final Isabelle term *)
fun trm_of rt = 
      let val ps = Cx.get_trmps_of_ptab (get_lfixes rt)
        val asmtrms = map trm_of (get_asms rt)
      in Trm.allify_params ps (Trm.list_implies asmtrms (get_ctrm rt)) end;

fun fixed_trm_of rt = 
      let val ps = Cx.get_trmps_of_ptab (get_lfixes rt)
        val asmtrms = map trm_of (get_asms rt)
      in Trm.list_implies asmtrms (get_ctrm rt) end;

(* pretty printing *)
fun pretty ctxt rt = 
    Pretty.chunks 
    [Pretty.block [Pretty.str "name:", Pretty.str (get_name rt)],
     Pretty.str "lfixes:",
     Cx.full_pretty_ptab ctxt (get_lfixes rt),
     Pretty.str "trm:",
     Trm.pretty ctxt (get_ctrm rt),
     Pretty.str "asms:",
     Pretty.block 
       [Pretty.str "{",
        (Pretty.indent 2 o Pretty.chunks)
          (map (pretty ctxt) (get_asms rt)),
        Pretty.str " }"]];

val print = 
    Pretty.writeln oo pretty;

end;

structure RTree : RTREE = DB_RTree;
