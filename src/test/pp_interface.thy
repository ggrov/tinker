theory pp_interface 
imports
  "../build/Parse"
  "../build/Eval"  
begin

ML{*
 val path = "/u1/staff/gg112/"
*}

lemma lem1: "! x y. P x \<and> P y --> P x \<and> P y"
 apply (rule allI)
 apply (rule allI)
 apply (rule impI)
 apply (rule conjI)
 apply (erule conjE)
  apply assumption
  apply (erule conjE)
 apply assumption
 done

lemma lem2: "! x. P x --> P x"
 apply (rule allI)
 apply (rule impI)
 apply assumption
 done

(* fixme change to Feature_Theory *)
(* fixme: add dynamically within feature lib *)

(*
setup {*
Feature_Ctxt.add ("top-level-const",FeatureEnv.fmatch_top_level);
*}
setup {*
Feature_Ctxt.add ("consts",FeatureEnv.fmatch_const);
*}
*) 


setup {*
Feature_Ctxt.add ("top-level-const",K (K (K true)));
*}
setup {*
Feature_Ctxt.add ("consts",K (K (K true)));
*} 


ML{*
val g1 =  ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml")
       |> GraphTransfer.graph_of_goal @{context};

Strategy_Dot.write_dot_to_file ( path ^ "/pp_test1.dot") g1;
*}

ML{*
val g2 =  ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem2.yxml")
       |> GraphTransfer.graph_of_goal @{context};

Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2.dot") g2;
*} 


(* eval graph *)
ML{*
 structure EData = EvalD_DF;
val edata0 = RTechnEval.init @{theory} [@{prop "! x. P x --> P x"}] (fn th => (g2,th));

Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_1.dot") (EData.get_graph edata0); 
*}


ML{*
val [r1,r2,r3] = GraphEnv.get_rtechns_of_graph (EData.get_graph edata0)
|> V.NSet.list_of
(* |> maps (EvalAtomic.mk_match_graph g1); *)
*}

ML{*
val edata1 = RTechnEval.one_step edata0 r2 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_2.dot") (EData.get_graph edata1); 
*}

ML{*
val [r1,r2,r3] = GraphEnv.get_rtechns_of_graph (EData.get_graph edata1)
|> V.NSet.list_of
(* |> maps (EvalAtomic.mk_match_graph g1); *)
*}

ML{*
val edata2 = RTechnEval.one_step edata1 r2 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_3.dot") (EData.get_graph edata2); 
*}

ML{*
val [r1,r2,r3] = GraphEnv.get_rtechns_of_graph (EData.get_graph edata2)
|> V.NSet.list_of
(* |> maps (EvalAtomic.mk_match_graph g1); *)
*}

(* gen_order *)


(* maybe the problem is no output wires *)
ML{*
val g = EvalAtomic.mk_match_graph (EData.get_graph edata2) r1 |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/mytest.dot") g;
val (lhs,rhs) = (g,g);
*}

ML{*
 open Strategy_Theory.Rule;
*}

ML{*
val lhsbndry : V.NSet.T = Graph.get_boundary lhs;
check_rule_consistency lhs rhs;
val ignorevnames = (* ignore boundary and also fresh rhs vnames *)
            V.NSet.union_merge 
              lhsbndry
              (V.NSet.subtract (Graph.get_vnames rhs)
                                    (Graph.get_vnames lhs)); 
        val ignoreenames = E.NSet.subtract (Graph.get_enames rhs)
                            (Graph.get_enames lhs);
        val vrn = V.mk_renaming ignorevnames 
                    (V.NSet.union_merge ignorevnames 
                      (Graph.get_vnames lhs))
                    V.NTab.empty

        val ern = E.mk_renaming ignoreenames 
                    (E.NSet.union_merge ignoreenames (Graph.get_enames lhs))
                    E.NTab.empty
        val xrn = X.Rnm.empty;
        val ((_,vrn,ern), rhs') = Graph.rename (xrn,vrn,ern) rhs
        val lhsauts = (Seq.list_of oo GraphIso.get) lhs lhs
        val rhsauts = (Seq.list_of oo GraphIso.get) rhs rhs'
        val lhsba = map (fn x => ((  VInjEndo.restrict_dom_to lhsbndry
                                   o GraphIso.get_vmap) x,GraphIso.get_subst x))
                        lhsauts
        val rhsba = map (fn x => ((  VInjEndo.restrict_dom_to lhsbndry
                                   o GraphIso.get_vmap) x,GraphIso.get_subst x))
                        rhsauts
        fun filterorbits (x::xs) os =
            let val orbit = map ((VInjEndo.compose (fst x)) o fst) rhsba 
                fun eq a b = ((V.NTab.fold 
                                      (fn (d,c) => VInjEndo.add d c)
                                      (VInjEndo.get_domtab a) b; true)
                             handle VInjEndo.add_exp _ => false)
                val xs' = filter_out
                            (fn a => exists (eq (fst a)) orbit)
                            xs
            in filterorbits xs' (x::os) end
          | filterorbits [] os = os;
filterorbits lhsba [];
*}

ML{*
val g = lhs;
val auts = lhsauts;
val done = V.NSet.empty;
val bound = V.NSet.empty;
*}

ML{*
fun maybe_box vn v = if Graph.is_bboxed g vn then
                               Boxed (Graph.get_bboxes_of g vn,v)
                             else v;
val aset = Graph.incident_vertices g done;
        val (root,vset)=if V.NSet.is_empty aset
                      then (NONE,Graph.get_vnames g
                                 |> V.NSet.remove_set done
                                 |> V.NSet.remove_set (Graph.get_boundary g))
                      else (SOME((the (* must be nonempty by adjacency *)
                                 o V.NSet.get_local_bot
                                oo V.NSet.intersect) done
                                     ((Graph.adj_vnames g
                                     o the
                                     o V.NSet.get_local_bot) aset))
                             ,aset);
V.NSet.is_empty vset;
root;

val vsetb = V.NSet.intersect vset bound
                                  val (vset,typ) = if V.NSet.is_empty vsetb
                                                 then (vset,Initial Arbitrary)
                                                 else (vsetb,Initial Constrained)
                                  val (v,orb,_) = take_orbit auts vset
                                  val auts' = fix v auts
                                  val bound' = V.NSet.union_merge bound orb;
 (maybe_box v typ,Tree(v,[]));
 :: gen_order g auts'
                                             (V.NSet.add v done) bound'
                                 
*}

(*
fun gen_order g auts done bound =
    let 
        

    in if V.NSet.is_empty vset then []
    else case root of NONE => let 
                              in  
                              end
                  | SOME x => let val (v,orb,_) = take_orbit auts vset
                                  val auts' = fix v auts
                                  val (auts'',subtr)
                                      = gen_order_sub g auts'
                                                      (V.NSet.delete v orb) 
                              in (maybe_box v 
                                   (if      V.NSet.contains bound v
                                  then Rooted (Constrained,x)
                                  else   if Graph.is_boundary g v
                                       then Boundary x
                                       else Rooted (Arbitrary,x)),
                                  Tree(v, subtr))::gen_order g auts''
                                         (V.NSet.union_merge done orb)
                                         bound
                              end
*)



(*
ML{*



      in (Rule { lhs = lhs, rhs = rhs',
                lhs_aut = lhsauts,
                selfapps = filterorbits lhsba [],
                order = gen_order lhs lhsauts
                                  V.NSet.empty V.NSet.empty },
          (vrn,ern))
      end
    else
      raise bad_rule_exp ("mk: Left and right hand side boundaries are different", lhs, rhs)
    end;
*}
*)
ML{*
val edata = edata2;
val graph_pat = g;
    val graph = EData.get_graph edata;
   (* match - FIXME: must be a better way than creating a dummy rule *)

(*
Strategy_Theory.Rule.mk (g,g);
*)
(*
    val subst = Strategy_Theory.RulesetRewriter.rule_matches 
                   (Strategy_Theory.Rule.mk (graph_pat,graph_pat))
                   graph
                |> snd
                |> Seq.map Strategy_Theory.Match.get_match_subst
    val gvars = GraphEnv.get_gvars_of_graph graph_pat;
*)
*}
(*
ML{*
EvalAtomic.eval_var_mk_rule_aux edata2 g
*}
*)



(* termination issue is with tactics!! *)
ML{*
val edata3 = RTechnEval.one_step edata2 r2  |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_3.dot") (EData.get_graph edata2); 
*}


ML{*
EData.get_pplan edata1
*}



ML{*

 EvalAtomic.eval_atomic edata0 r1
*}

ML{*
val pp = EvalAtomic.mk_match_graph (EData.get_graph edata0) r2 |> hd;
val (l,r) =  EvalAtomic.eval_var_mk_rule edata0 pp |> Seq.list_of |> hd |> snd |> hd;
*}
ML{*

EvalAtomic.eval_graph edata p1 |> Seq.list_of |> hd |> Seq.list_of |> hd;
*}

ML{*
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_l1.dot") r; 

*}




(* doesn't terminate!! *)
(* is it features or application ~ the latter by the looks of things... *)

(*
ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
*}
*)




ML{*
Context.theory_of;
Global_Theory.get_thm @{theory} "allI";

Facts.named "HOL.allI";

*}


ML{*

exists;
@{term "F"} = @{term "FG"}
*}

(* example similar lemmas *)







ML{*
 val t1 = @{term " P x \<and> P y \<Longrightarrow> P x"};
 val t2 = @{term "\<And>x y. P x \<and> P y \<Longrightarrow> P x"};
*}
ML{*
 GraphTransfer.get_missing_hyps @{context} ("\<And>x y. P x \<and> P y \<Longrightarrow> P x",["\<And>x y. P x \<and> P y \<Longrightarrow> P x"]);
*}

ML{*
val rtechn_l1 = GraphTransfer.rtechns_of_file @{context} (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml");
val rtechn_l2 = GraphTransfer.rtechns_of_file @{context} (path ^ "/Stratlang/src/parse/examples/attempt_lem2.yxml");
*}

(* next: start making graph! *)


ML{*
 val g2 = ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml");
 val graph = GraphTransfer.graph_of_goal @{context} g2;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test1adsf.dot") graph 
(*     dot -Tpdf pp_test1.dot -o pp_test1.pdf 
*)
*}

end;


