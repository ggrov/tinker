(* File containing proof attempts.
Rename this file before editing because any changes will be overwritten when exporting next time. *)
theory "MemMchR3_interactive"                               
imports  
  "../../../build/HOL_IsaP"    
  "MemMchR32"                                                                                                                     
uses  
 "../../../eval/basic_eval.ML"  
 "../../../eval/eval_atomic.ML"                               
 "../../../eval/rtechn_eval.ML" 
 "../init.ML"
 "../inst.ML"   
 "../subterms.ML"
 "../../../rtechn/basic/rtechn_prj.ML" 
begin

ML{*
 open RTechnPrj;
*}

(*
  Fixme: would be good to try on one of the Abrial proofs where the same strategy
   is applied 
*)
(* 
change to project everything, and then apply technique
*)

ML{*

fun pp graph name  = graph
  |> RTechn_Theory.IO_Xml.Output.Graph.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".graph");

fun pp_rule rule name  = rule
  |> RTechn_Theory.IO_Xml.Output.Rule.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".rule");

fun pp_ruleset ruleset name  = ruleset
  |> RTechn_Theory.IO_Xml.Output.Ruleset.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".ruleset");
*}

(* tactic doesn't work in this context *)
ML{*
  val assume = 
     let 
         val iw = RTechnEnv.mk_default_goal RTechnEnv.default_goal
         val ow = RTechnEnv.mk_default_goal RTechnEnv.auto_goal
         fun f _ new_goal = GNode.mk_goal_no_facts RTechnEnv.auto_goal new_goal
     in 
        RTechnEnv.apply_allasms_tac_to_each_goal_rtechn iw ow ("assume","assume") f (K (assume_tac 1))
     end;
*}


(* fixme: this shouldn't be done since we are working in different context
    -> instead look up name! *)
ML{*
val impIthm = @{thm "impI"};
val conjIthm = @{thm "conjI"};
val allIthm = @{thm "allI"};
val impI_rtechn = RTechnEnv.rule_wire WireNode.default_wire WireNode.default_wire impIthm;
*}

(* erule 1 *)
ML{*
val prem_wire = BWire.of_string "hyp_and";
val prem_out_wire = BWire.of_string "hyp_not_and";
val econjE_dthm = DThm.mk @{thm "conjE"};
val conjE_erule = RTechnEnv.erule_dthm_wire (prem_wire,WireNode.default_wire) (prem_out_wire,WireNode.default_wire) econjE_dthm;
*}

ML{*
val filter1 = (contains_symb' "op1Data");
val filter2 = gfilter_and
fun filter_and_symb rst t _ = ((contains_symb' "op1Data") t) andalso (gfilter_and rst t);
val project_and_rtechn = project_prem_rtechn filter_and_symb prem_wire WireNode.default_wire WireNode.default_wire;
*}

(* subst *)
ML{*
val pat =  @{term "HOL.Trueprop (op1Data = regArrayDataLong ' op1Index)"};
fun subst_filter rst gt _ = (gfilter_patt pat) rst gt;
val eqwire = BWire.of_string "res.eq";
val (thewire as (m,g)) = WireNode.default_wire;
val condwire = (BWire.of_string "cond",g);

val project_subst_rtechn = project_prem_rtechn subst_filter eqwire WireNode.default_wire WireNode.default_wire;
val sub = RTechnEnv.subst_eq_from_wire "subst" eqwire thewire thewire condwire false;
*}

(* forall quantifier *)
ML{*
val allwire = BWire.of_string "res.forall";
val doneallwire = BWire.of_string "res.forall.strip";
fun the_filter rst gt _ = gfilter_forall rst gt;
val project_forall_rtechn = project_prem_rtechn the_filter allwire WireNode.default_wire WireNode.default_wire;
val forall_rtechn = RTechnEnv.frule_dthm_wire allwire doneallwire WireNode.default_wire WireNode.default_wire (DThm.mk @{thm "spec"})
*}

ML{*
fun lift_elist_str f x = ([],f x);
fun lift_elist_term f x = (f x,([]:string list));
fun ft pplan = lift_elist_term (Subterms.filtered_subterms o PPlan.get_varified_ltrm pplan o GNode.get_goal);
val forall_rtechn = Insts.frule_rtechn "spec" ft "allI" (allwire,WireNode.default_wire) (doneallwire,WireNode.default_wire);
*}

(* filter imps *)
ML{*
val impwire = BWire.of_string "res.imp";
fun the_filter rst gt _ = gfilter_imp rst gt;
val filter_imp1 = filter_prem_rtechn the_filter doneallwire impwire WireNode.default_wire WireNode.default_wire;
*}

(* mp on imp *)
ML{*
val prem_wire = impwire;
val impE_dthm = DThm.mk @{thm "impE"};
val mp_frule = RTechnEnv.frule_dthm_wire prem_wire prem_wire WireNode.default_wire WireNode.default_wire (DThm.mk @{thm "mp"})
*}

(* filter and *)
ML{*
val prem_wire = impwire;
fun the_filter rst gt _ = gfilter_and rst gt;
val filter_and1 = filter_prem_rtechn the_filter prem_wire prem_wire WireNode.default_wire WireNode.default_wire;
*}

(* project out 2nd conjunct *)
ML{*
val prem_wire = impwire;
val conj2_dthm = DThm.mk @{thm "conjunct2"};
val conj2_rtechn = RTechnEnv.frule_dthm_wire prem_wire prem_wire WireNode.default_wire WireNode.default_wire conj2_dthm
*}

(* filter eq *)
ML{*
val prem_wire = impwire;
fun the_filter rst gt _ = gfilter_eq rst gt;
val filter_eq1 = filter_prem_rtechn the_filter prem_wire prem_wire WireNode.default_wire WireNode.default_wire;
*}

(* apply symmetry *)
ML{*
val prem_wire = impwire;
val sym_dthm = DThm.mk @{thm "sym"};
val sym_rtechn = RTechnEnv.frule_dthm_wire prem_wire prem_wire WireNode.default_wire WireNode.default_wire sym_dthm
*}


(* apply rule *)

ML{*
val resolve_asms = RTechnEnv.bck_res_wire prem_wire WireNode.default_wire WireNode.default_wire;
*}

(* next impI
   then elim on created goals *)
(* then refl *)
(* then assumption *)
ML{*
val gf = 
  lift impI_rtechn compose 
  lift project_and_rtechn compose 
  lift conjE_erule compose
  lift project_subst_rtechn compose
  lift sub compose 
  lift project_forall_rtechn compose
  lift forall_rtechn compose
  lift filter_imp1 compose
  lift mp_frule compose 
  lift filter_and1 compose
  lift conj2_rtechn compose
  lift filter_eq1 compose
  lift sym_rtechn compose
  lift resolve_asms compose
  lift assume;
*}

ML{*
val (t as (g,rst,es)) =
EB_Init.init_rst_from_locale
 [@{thm "MemMchR32.DualOpOk_grd9_GRD_goal_def"},@{thm "MemMchR32.DualOpOk_grd9_GRD_hyps_def"}]
 "MemMchR32.DualOpOk_grd9_GRD"
 @{theory} 
 (WireNode.default_wire,gf);
*}

ML{*

val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}

ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

(* note 4 works -- seems to be the same.. .strange??? *)
ML{*
val (t as (g,rst,en)) =
RTechnEval.step_df t |> Seq.list_of |> hd;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}

(* 
should apply:
  {(g1dh): "op1Index \<in> RegArrayDom"}
*)

(* hmmm. assume tac fails??? *)
(*
ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
PPlan.print (RState.get_pplan rst);
*}
*)

ML{*
val pplan = RState.get_pplan rst;
(* apply_frule_thm : Thm.thm -> gname -> T -> (gname * T) Seq.seq *)

fun test x = PPlan.apply_frule_thm @{thm "conjunct2"} x pplan |> Seq.list_of |> hd |> K (1,x)
             handle _ => (0,x);
fun app x pp = PPlan.apply_frule_thm @{thm "conjunct2"} x pp |> Seq.list_of |> hd |> snd;
*}



ML{*
RTechnComb.get_gnodes rst g |> tl |> hd |> snd |> GNode.GoalSet.list_of |> hd
*}

ML{*
val gs = 
RTechnComb.get_gnodes rst g |> tl |> hd |> snd |> GNode.GoalSet.list_of |> hd
|> GNode.lookup_facts prem_wire |> Goaln.NSet.list_of;

val writeterm = (Pretty.writeln oo Syntax.pretty_term);
Pretty.writeln;
 (RState.get_ctxt rst);

val gfilter_imp1 = gfilter_patt (Logic.varify_global @{term "HOL.Trueprop (A \<and> B)"});

val g = hd gs;

val ex = PPlan.get_varified_ltrm (RState.get_pplan rst) g;
val ex2 = Prf.get_ndname_varified_ltrm (RState.get_pplan rst) g;
val ex3 = (g,Logic.strip_imp_concl ex2);

gfilter_imp1 rst ex3;

*}


(* get_ndname_varified_ltrm p gname *)
ML{*
val writeterm = (Pretty.writeln oo Syntax.pretty_term);
Pretty.writeln;
 (RState.get_ctxt rst);
val gfilter_imp1 = gfilter_patt (Logic.varify_global @{term "HOL.Trueprop (A \<and> B)"});

val g =  get_gnodes rst g |> tl |> hd |> snd |> GNode.GoalSet.list_of |> hd
|> GNode.lookup_facts doneallwire |> Goaln.NSet.list_of
|> rev
|> hd;

val ex = PPlan.get_varified_ltrm (RState.get_pplan rst) g;
val ex2 = Prf.get_ndname_varified_ltrm (RState.get_pplan rst) g;
val ex3 = Logic.strip_imp_concl ex2;

 (writeterm (RState.get_ctxt rst)) ex3;
*}



(* am and an are the correct one -- but why these duplications?? *)
ML{*
val e =
GraphComb.get_goalnodes_of_graph g |> V.NSet.list_of
|> map (GraphComb.v_to_goalnode g)
|> map snd
|> map StrIntName.NSet.list_of
|> tl |> hd |> hd;

GNode_Ctxt.get e rst;
*}

ML{*
Subst.apply "l" false "n" (RState.get_pplan rst) |> Seq.list_of |> hd;
*}




(* DualOpOk_grd9_GRD *)
sublocale "DualOpOk_grd9_GRD_hyps" < "DualOpOk_grd9_GRD_goal"
apply (insert DualOpOk_grd9_GRD_hyps_axioms)
unfolding "DualOpOk_grd9_GRD_goal_def" "DualOpOk_grd9_GRD_hyps_def"
apply ebsimp'
apply (intro impI, elim conjE)

(* apply subst *)
thm HOL.ssubst[where t = "op1Data" and s="regArrayDataLong ' op1Index"]

(* here we can generalise - but how do we know that? *)
apply (rule HOL.ssubst[where t = "op1Data" and s="regArrayDataLong ' op1Index"])
apply (assumption)
(* or:
apply (rule_tac t = "op1Data" and s="regArrayDataLong ' op1Index" in HOL.ssubst,assumption)
*)
(* simple instantiation -- however Matthias' tactic can prove it!! *)

(* instantiate *)
apply (drule_tac x="op1Index" in spec)+

apply (drule mp,assumption)+
apply (elim conjE)
apply (rule sym)
apply assumption
done

section "setup"

(* should try to learn this! 
     - need to know the link between Eb_Simp.tactic' and the method name
        -> maybe this info is available?
     - rule rulename, frule, drule etc...
 *)
ML{*
fun setup ctxt = 
Eb_Simp.tactic' ctxt 1
THEN
((REPEAT o FIRST) [rtac @{thm "impI"} 1,rtac @{thm "allI"} 1])
THEN
(REPEAT (etac @{thm "conjE"} 1));
*}

section "substitution"

ML{*

val x = Unsynchronized.ref  @{term "t"};
Syntax.read_term;
fun p str = Parse.term (Outer_Syntax.scan Position.none str);
val tstr = "op1Data = regArrayDataLong ' op1Index";
val pat = @{term "op1Data = regArrayDataLong ' op1Index"};
val pat1 = Syntax.read_term @{context} tstr |> Logic.varify_global; 
Pattern.matches @{theory} (pat1,pat);

Syntax.string_of_term;
fun prj_match_assms str ctxt thm =
  let
    val thy = Proof_Context.theory_of ctxt
    val pat = Syntax.read_prop ctxt str |> Logic.varify_global
    fun check_match t = Pattern.matches thy (pat,t)
    val prems = Thm.prems_of thm |> maps Logic.strip_imp_prems
    val matching_prems = filter check_match prems
  in
    matching_prems
     (* map (Syntax.string_of_term ctxt) matching_prems |> map writeln; writeln "\n hello"; Seq.single thm *)
  end

fun prj_match_assm_print_tac str ctxt thm =
  (map (Syntax.string_of_term ctxt) (prj_match_assms str ctxt thm) |> map writeln; writeln "\n hello"; Seq.single thm);

val test_tac = prj_match_assm_print_tac "\<forall> x. P x";
 

datatype Place = Wire | AllHyp | All | LocalHyp
datatype Query = Select | DeSelect

*}

consts f :: "nat => nat"

(* instantiation -- see subterm in EventB isaP *)
ML{*

fun mk_spec str =
 read_instantiate @{context} [(("x",0),str)] @{thm spec} (* @{thm allE} *);
fun mk_exI str =
 read_instantiate @{context} [(("x",0),str)] @{thm exI} (* @{thm allE} *);

mk_spec "f x";
mk_exI "g (a x)";

(* must be a better way to get rid of forall *)
op RS;
val dummy = Skip_Proof.make_thm @{theory} @{prop "\<forall> x. PP x"};
dummy RS @{thm spec};
*}

(*
- select goals with universal binders
- apply frule spec to them (to varify)
- get conclusion and split all conjectures
*)

lemma "A ==> B ==> C"
apply (tactic "test_tac @{context}")
oops

ML{*
!x
*}
sublocale "DualOpOk_grd9_GRD_hyps" < "DualOpOk_grd9_GRD_goal"
apply (insert DualOpOk_grd9_GRD_hyps_axioms)
unfolding "DualOpOk_grd9_GRD_goal_def" "DualOpOk_grd9_GRD_hyps_def"
apply (tactic "setup @{context}")
apply (tactic "test_tac @{context}")


(* apply subst *)
thm HOL.ssubst[where t = "op1Data" and s="regArrayDataLong ' op1Index"]
(* *)
apply (rule_tac t = "op1Data" and s="regArrayDataLong ' op1Index" in HOL.ssubst,assumption)
(* simple instantiation -- however Matthias' tactic can prove it!! *)

(* instantiate *)
apply (drule_tac x="op1Index" in spec)+

apply (drule mp,assumption)+
apply (elim conjE)
apply (rule sym)
apply assumption
done



(*
  datatype term =
    Const of string * typ |
    Free of string * typ |
    Var of indexname * typ |
    Bound of int |
    Abs of string * typ * term |
    $ of term * term

*)
(*
  datatype typ =
    Type  of string * typ list |
    TFree of string * sort |
    TVar  of indexname * sort
*)
(* allowed to replace *)

(* DualOpOk_grd9_GRD *)
sublocale "DualOpOk_grd9_GRD_hyps" < "DualOpOk_grd9_GRD_goal"
apply (insert DualOpOk_grd9_GRD_hyps_axioms)
unfolding "DualOpOk_grd9_GRD_goal_def" "DualOpOk_grd9_GRD_hyps_def"
apply ebsimp'
apply (intro impI, elim conjE)

(* apply subst *)
thm HOL.ssubst[where t = "op1Data" and s="regArrayDataLong ' op1Index"]
(* *)
apply (rule_tac t = "op1Data" and s="regArrayDataLong ' op1Index" in HOL.ssubst,assumption)
(* simple instantiation -- however Matthias' tactic can prove it!! *)

(* instantiate *)
apply (drule_tac x="op1Index" in spec)+
ML_prf{*
val x = just_gen @{term "regArrayDataLong ' op1Index"} @{term "regArrayDataLong ' op2Index"};
smatch x @{term "regArray ' op1Index"};
*}
apply (drule mp,assumption)+
apply (elim conjE)
apply (rule sym)
apply assumption
done

section "deriving tactics"

subsection "subst goal"
(* 
 features: is a definition
   - is_atom(lhs) - what about polymorphic? or does it have to have a 
      type not polymorphic, not pair and not function type
   - lhs = rhs
   - not_atom(rhs)
   - unfold_def

 project_defs:
   -  x = e
*)

(* EXAMPLE 4 - evaluation test *)

(* from empty buffer to empty buffer *)
ML{*
fun mk_simple_eval_rule v g =
  let val vd = RTechn_Theory.Graph.get_vertex_data g v;
      val (v',g1) = RTechn_Theory.Graph.add_named_vertex v vd  RTechn_Theory.Graph.empty;
      val ins = map (fn (_,a,_) => a) (GraphComb.get_boundary_inputs g);
      val outs = map (fn (_,a,_) => a) (GraphComb.get_boundary_outputs g);
      fun add_input (ename,edata) g =      
                g |> RTechn_Theory.Graph.add_vertex GraphComb.boundary_vertex
                  |> (fn (v,g') => RTechn_Theory.Graph.add_named_edge ename (RTechn_Theory.Graph.Directed, edata) v v' g')
                  |> snd;
      fun add_output (ename,edata) g =      
                g |> RTechn_Theory.Graph.add_vertex GraphComb.boundary_vertex
                  |> (fn (v,g') => RTechn_Theory.Graph.add_named_edge ename (RTechn_Theory.Graph.Directed, edata) v' v g')
                  |> snd;
      val g2 = g1 |> fold add_input ins
                  |> fold add_output outs;
      val lhs = GraphComb.get_boundary_inputs g2 
              |> map (fn (_,(ename,_),_) => ename)
              |> (fn es => fold (fn e => fn g => GraphComb.insert_goalnode (e,g)) es g2);
      val rhs = GraphComb.get_boundary_outputs g2 
              |> map (fn (_,(ename,_),_) => ename)
              |> (fn es => fold (fn e => fn g => GraphComb.insert_goalnode (e,g)) es g2);
   in
    RTechn_Theory.Rule.mk(lhs,rhs)
   end;
*}

ML{*
val rule = mk_simple_eval_rule (V.mk "id") g;
val [m1,m2,m3] = RTechn_Theory.RulesetRewrites.rule_matches rule g |> snd |> Seq.list_of
*}
ML{*
 val g1 = RTechn_Theory.GraphSubst.rewrite g (RTechn_Theory.Rule.get_lhs rule) m1 (RTechn_Theory.Rule.get_rhs rule);
*}

(* EXAMPLE 3 - remove empty link *)

ML{*
fun empty_link_rule wire =
 let val (v1,g1) = RTechn_Theory.Graph.empty
                |> RTechn_Theory.Graph.add_vertex GraphComb.boundary_vertex
     val (v2,g2) = g1
                |> RTechn_Theory.Graph.add_vertex GraphComb.boundary_vertex
     val (e,dest) =  g2 |> RTechn_Theory.Graph.add_named_edge (E.mk (RState.Wire.string_of wire)) (RTechn_Theory.Graph.Directed, wire) v1 v2
     val src = GraphComb.insert_goalnode (e,dest)
  in 
    RTechn_Theory.Rule.mk (src,dest)
  end;
*}

(* 4 matches *)
ML{*
 val myrule = (RState.Wire.of_string "goal") |> empty_link_rule
 val [m1,m2,m3,m4] = RTechn_Theory.RulesetRewrites.rule_matches myrule g |> snd |> Seq.list_of
*}

ML{*
 val g1 = RTechn_Theory.GraphSubst.rewrite g (RTechn_Theory.Rule.get_lhs rule) m1 (RTechn_Theory.Rule.get_rhs rule);
*}

end
