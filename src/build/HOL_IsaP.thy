theory HOL_IsaP                                                                                                                 
imports                  
  Complex_Main         
  (* Generic parts of IsaPlanner*)               
  "RTechn"    
  "EmbeddingNotation"      

  (* Higher Order parts of IsaPlanner*)
  "IsaPHOLUtils"   
uses

(* counter examples *)
  "../cinfos/counterex_cinfo.ML"
 

(* rulesets   *)
 "../rtechn/rulesets/substs.ML"
 "../rtechn/rulesets/bckimps.ML"
 "../rtechn/rulesets/fwdimps.ML"

(* was dtacs : now tactics *)
(*  "../rtechn/basic/isa_dtacs.ML" *)
  "../rtechn/induct/induct_tac.ML"
  "../build/induct_HOL.ML"

(* techn *)
(*
  "../rtechn/basic/dtac_rtechn.ML"
*)
  "../rtechn/induct/induct_rtechn.ML"
  "../build/isar_attr.ML"

(* GG: removed for graphdev version
  "../rtechn/split/split_rtechn.ML"
*)

  (* Lemma conjecturing *)


  "../rtechn/conj/conj_stack_cinfo.ML"
  "../rtechn/conj/conjecturedb_lib.ML"
  "../rtechn/conj/conjdb_cinfo.ML"
  "../rtechn/conj/lemma_conj_lib.ML"
  "../build/lemma_conj_HOL_data.ML"
(* GG: remove for graphdev version
  "../rtechn/conj/conj_rtechn.ML"
*)

 (* basic conjecturing *)
  "../rtechn/conj/basic_conj_rtechn.ML"

(* Counter example (quickcheck) and auto *)
(* GG: removed for graphdev version
  "../rtechn/quickcheck_auto.ML"
*)

(* Simplification based proof technique (CADE'03) *)

(* FIXME: do later *)
(*
  "../rtechn/induct_and_simp.ML"
*)

(* Rippling wave rules DB from theory *)
  "../rtechn/rippling/wrules_gctxt.ML"

(* rippling critic libs *)
(* fixme later -- need to look into part_wrule *)

(*
  "../critics/middleout_rw.ML"
  "../critics/lemma_speculation.ML"
*)

(* rippling techniques *)
  "../rtechn/rippling/basic_cinfo.ML"
  "../rtechn/rippling/basic_rtechn.ML"

(* GG: removed for graphdev version
  "../rtechn/rippling/lemcalc.ML"  
*)


(* FIX ME LATER - get basic rippling stuff to work first *)
(*
  "../rtechn/rippling/midout_cinfo.ML"
  "../rtechn/rippling/casesplit.ML"
  "../rtechn/rippling/casesplit_calc.ML"
  "../rtechn/rippling/postripple_casesplit.ML"
  "../rtechn/rippling/lemcalc.ML"
  "../rtechn/rippling/lemspec.ML"
*)
(*
  "../rtechn/rippling/ripple_bf_techn.ML" 
*)

(* Relational Rippling *)
(*   "../rtechn/rrippling/rr_wrulesdb.ML" *)
(*  *** 
  "../rtechn/rrippling/rr_table.ML" (* Contains the definition of the rtable. Solves order-of-inclusion problem. *)
  "../rtechn/rrippling/rr_linkinfo.ML" (* Perhaps move these functions into rr_cinfo? May cause problems with order-of-inclusion! *)
  "../rtechn/rrippling/rr_embeddinglib.ML"
  "../rtechn/rrippling/rr_aterms.ML"
  "../rtechn/rrippling/rr_trmutil.ML" (* Functions that don't really belong anywhere else. Debug output for terms and eterms, etc. *)
  "../rtechn/rrippling/rr_measure.ML" (* Relational measure: (functional wave-fronts * relational wave-fronts). *)
  "../rtechn/rrippling/rr_measure_tabs.ML" (* The tables for type and positions of wave-fronts. *)
  "../rtechn/rrippling/rr_skel.ML"
(*   "../rtechn/rrippling/rr_thyinfo.ML" *)
  "../rtechn/rrippling/rr_cinfo.ML"
  "../rtechn/rrippling/rr_techn.ML" (* Relational rippling reasoning technique implementation proper. *)
*)

(* interface *)
  (* "../interface/interface.ML" *)

  (* "../rtechn/rippling/basic_rtechn_test.ML"  *)
begin

section {* Generic Theory Information for Rippling *}

(* the wave rule addtributes *)
(* syntax works as follows:
   [attr_name]  --  adds the thms to the attr_name set
   [attr_name add] -- as above
   [attr_name del] -- removes thsm from the attr_name set

   [wrule]  --  the wave rules set
   [all_wrule] -- wave rules without filtering bad rules

   [impwrule] -- adds implication for reasoning backwards (unsafe rewriting) 
 
   [fwd_impwrule] -- adds implications for reasoning forward
*)
attribute_setup wrule =
{* Attrib.add_del (Thm.declaration_attribute WRulesGCtxt.add_wrule_thm)
                  (Thm.declaration_attribute WRulesGCtxt.del_wrule_thm) *}
"add wave rules (filtering silly thing)"

attribute_setup all_wrule = 
(* was addall_wrule_thm *)
{* Attrib.add_del (Thm.declaration_attribute WRulesGCtxt.add_wrule_thm) 
                  (Thm.declaration_attribute WRulesGCtxt.del_wrule_thm) *}
"add all wave rules (no filtering)"

attribute_setup impwrule =
{* Attrib.add_del (Thm.declaration_attribute WRulesGCtxt.add_impwrule_thm) 
                  (Thm.declaration_attribute WRulesGCtxt.del_impwrule_thm) *}
"add implication wave rule (reasoning backward)"

attribute_setup fwd_impwrule = 
{* Attrib.add_del 
     (Thm.declaration_attribute WRulesGCtxt.add_fwd_impwrule_thm)
     (Thm.declaration_attribute WRulesGCtxt.del_fwd_impwrule_thm) *}
"add implication wacve rule (reasoning forward)"

    
(** outer syntax for print_wrules
val () =
  OuterSyntax.improper_command "print_wrules" "print the currently used wave rules."
    OuterKeyword.diag
    (Scan.succeed (Toplevel.no_timing o Toplevel.unknown_context o 
                   (Toplevel.keep
      ((*Toplevel.node_case 
         (print)*)
         (WRules.print o get_from_ctxt o Proof.context_of o Toplevel.proof_of)
    ))));
**)

section {* Rippling Implementations *}

-- "Ripple states with measures based on grouped flow"
ML {*
structure RippleSkel_flow = RippleSkelMesTracesFUN(FlowMeasure);
structure RippleSkel_flow = RippleSkelMesTracesFUN(FlowMeasure); 
*}
-- "Rippling contextual information"
ML {*
structure RippleCInfo_flow = BasicRippleCInfoFUN(RippleSkel_flow);
*}
-- "Middle-out rippling contextual information"
(* ML {*
structure MidOutCInfo_flow = MidOutRippleCInfoFUN(RippleCInfo_flow);
*} *)

-- "Rippling Reasoning Techniques "
ML {*
(* NOTE: change to basic conj rtechn *)
structure RippleRTechn_flow = BasicRippleRTechnFUN(
  structure RippleCInfo = RippleCInfo_flow 
  structure ConjRTechn = BasicConjRTechn);


(*
 structure RippleCaseSplit_flow = RippleCaseSplitRTechnFUN(
                            structure BasicRipple = RippleRTechn_flow);
structure RippleCasePostSplit_flow = RippleCasePostSplitFUN(
                            structure BasicRipple = RippleRTechn_flow); *)

*}  

-- "Rippling techniques with Lemma-calculationa and Case Analysis"
ML {*
(* structure RippleLemCalc_flow = RippleLemCalcFUN(
                          structure BasicRipple = RippleCaseSplit_flow); 
structure RippleLemCalc_flow2 = RippleLemCalcFUN(
                          structure BasicRipple = RippleCasePostSplit_flow);
structure RippleLemSpec_flow =  RippleLemSpecFUN(
                           structure RippleLemCalc = RippleLemCalc_flow
                           structure MidOutRCInfo = MidOutCInfo_flow); *)
*} 

-- "All Flow-Rippling under one structure"
ML {* 
structure FlowRippler = struct
  structure Measure = FlowMeasure;
  structure Skel = RippleSkel_flow;
  structure CInfo = RippleCInfo_flow;
(*  structure MidOutCInfo = MidOutCInfo_flow; *)
  structure RTechn = struct 
    structure Basic = RippleRTechn_flow;
(*    structure LemCalc = RippleLemCalc_flow;
    structure LemSpec = RippleLemSpec_flow; *)
   end;
end;

(* IMPROVE: add again the best first rippler... ? structure Ripple_BF = Ripple_BFRTechn; *)
*}
 
-- "Sum of Distances measure (approx hamming distance, see DixonFLeuriot at TPHOLs'04)" 
ML {*
structure RippleSkel_dsum = RippleSkelMesTracesFUN(DSumMeasure);
structure RippleCInfo_dsum = BasicRippleCInfoFUN(RippleSkel_dsum);
(* structure MidOutCInfo_dsum = MidOutRippleCInfoFUN(RippleCInfo_dsum); *)
structure RippleRTechn_dsum = BasicRippleRTechnFUN(
  structure RippleCInfo = RippleCInfo_dsum 
  structure ConjRTechn = BasicConjRTechn);

(*
structure RippleLemCalc_dsum = RippleLemCalcFUN( 
                          structure BasicRipple = RippleRTechn_dsum);
*)

(*structure RippleCaseSplit_dsum = RippleCaseSplitRTechnFUN(
                            structure BasicRipple = RippleRTechn_dsum);
structure RippleLemCalc_dsum = RippleLemCalcFUN( 
                          structure BasicRipple = RippleCaseSplit_dsum); *)
(* structure RippleLemSpec_dsum =  RippleLemSpecFUN(
                           structure RippleLemCalc = RippleLemCalc_dsum
                           structure MidOutRCInfo = MidOutCInfo_dsum); *)
*} 

-- "Set Rippling defaults"
ML {*
structure Rippler = FlowRippler;
structure RippleMeasure = Rippler.Measure;
structure RippleSkel = Rippler.Skel;
structure RippleCInfo = Rippler.CInfo;
(* structure MidOutCInfo = Rippler.MidOutCInfo; *)
structure RippleRTechn = Rippler.RTechn.Basic;
(* structure RippleLemCalc = Rippler.RTechn.LemCalc;
structure RippleLemSpec = Rippler.RTechn.LemSpec; *)
*} 


(* adding atomic techniques to the Isabelle context *)
(*
setup{* RTabData.merge RippleRTechn.rtechn_tab *}
setup{* RTabData.add_rtechn InductRTechn.induct_rtechn *}
*)

-- "Simplification based inductive prover (see DixonFleuriot at CADE'03)"


setup RippleCInfo_flow.I.init_in_thy
setup RippleCInfo_dsum.I.init_in_thy

(*
ML {*
  structure InductAndSimp = InductAndSimpRTechnFUN(ConjRTechn);
*}


-- {* Setup calls add entries to IsaPlanner's contextual info table (updates the initially 
      empty table in the theory) *}

-- "setup for different kinds of rippling"

setup RippleCInfo_flow.I.init_in_thy
setup RippleCInfo_dsum.I.init_in_thy
setup MidOutCInfo_flow.MidOutI.init_in_thy
setup MidOutCInfo_dsum.MidOutI.init_in_thy

-- "setup other inductive proof technique tools"

setup ConjStackCInfo.I.init_in_thy
setup CounterExCInfo.I.init_in_thy
*)

end;
