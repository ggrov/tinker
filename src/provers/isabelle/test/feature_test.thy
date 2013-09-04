(* simple test of combinators *)
theory feature_test                                              
imports               
 "../build/IsaP"                                                                  
begin

ML{* 
  exception feature_test_exp of term
  structure GTD = GoalTypData;  structure Prover = IsaProver;
  structure TF = TermFeatures;
  fun trm_to_thm thy trm = Thm.cterm_of thy trm |>  Thm.trivial
*}

-- "aux functions"
ML {*
fun gtd_to_string (GTD.String str) = str;
fun gtds_to_string xs = SOME (map gtd_to_string xs) handle _ => NONE;

fun gtd_to_term (GTD.Term trm) = trm;
fun gtds_to_terms xs = SOME (map gtd_to_term xs) handle _ => NONE;


*}

-- "has symbols"
ML{*
(* we accept non-well-formedness *)
fun has_symbols'   _ [] = true 
 |  has_symbols' (Prover.Fact thm) xs = 
     (case gtds_to_string xs of
       NONE => false
      | SOME xs' => TermFeatures.has_constants xs' (Thm.prop_of thm))
 | has_symbols' (Prover.Concl thm) xs = 
     (case gtds_to_string xs of
       NONE => false
      | SOME xs' => TermFeatures.has_constants xs' (Thm.prop_of thm));

        
fun has_symbols (_:Proof.context) _ [] = false
 |  has_symbols ctxt obj (x::xs) = 
     (has_symbols' obj x) orelse (has_symbols ctxt obj xs);


val test = has_symbols @{context} (Prover.Concl(trm_to_thm @{theory}  @{prop "a \<and> b \<longrightarrow> c"})) [[(GTD.String "HOL.implies"), (GTD.String "HOL.conj")]];
val test = has_symbols @{context} (Prover.Concl (trm_to_thm @{theory} @{prop "a \<longrightarrow> b"})) [[(GTD.String "HOL.implies"), (GTD.String "HOL.conj")]];
*}
setup {* IsaMatchParam.add_class_object_feature (F.mk "has_symbols",has_symbols) *}

(*
-- "top symbol"

ML{*

(* will it always be a prop? *)
fun top_symbol' (_:Proof.context)  (Atomic.Fact thm) xs = 
     (case gtds_to_string xs of
       NONE => false
      | SOME xs' => exists (fn str => TermFeatures.is_top_level str  ( (Thm.prop_of thm))) xs')
 |  top_symbol' (ctxt:Proof.context)  (Atomic.Concl thm) xs = 
    let val _ = Pretty.writeln (Syntax.pretty_term ctxt  ( (Thm.concl_of thm))) in
     (case gtds_to_string xs of
       NONE => ( writeln "no in topsym" ; false)
      | SOME xs' =>  exists (fn str => TermFeatures.is_top_level str (  (Thm.concl_of thm))) xs') end
 | top_symbol' (_:Proof.context)  _ _ = false (* or true *)

(*
fun top_symbols (_:Proof.context) _ [] = false
 |  top_symbols ctxt thm (x::xs) = 
     (top_symbol' thm x) orelse (top_symbols ctxt thm xs);
*)
val test = top_symbol' @{context} (Atomic.Concl ( trm_to_thm @{theory} @{prop "a --> b "})) [(GTD.String "HOL.implies"), (GTD.String "HOL.conj")];
val test = top_symbol' @{context} (Atomic.Concl ( trm_to_thm @{theory}@{prop "a \<longrightarrow> b"})) [(GTD.String "HOL.conj")];

*}
setup {* IsaMatchParam.add_class_feature (F.mk "top_symbols",top_symbol') *}

-- "shape: example where context is required"
ML {*
fun is_shape' ctxt (Atomic.Fact thm) xs = 
     (case gtds_to_terms xs of
       NONE => false
      | SOME xs' => forall (fn trm => TermFeatures.is_shape (Proof_Context.theory_of ctxt) trm (Thm.prop_of thm)) xs')
  | is_shape' ctxt (Atomic.Concl thm) xs = 
     (case gtds_to_terms xs of
       NONE => false
      | SOME xs' => forall (fn trm => TermFeatures.is_shape (Proof_Context.theory_of ctxt) trm (Thm.prop_of thm)) xs')
      | is_shape' _ _ _ = false (* or true *)
 
(* fun is_shape (_:Proof.context) _ [] = false
 |  is_shape ctxt thm (x::xs) = 
     (is_shape' ctxt thm x) orelse (is_shape ctxt thm xs); *)
*}
setup {* IsaMatchParam.add_class_feature (F.mk "is_shape",is_shape') *}
*)

(* test matching for some goal types *)
ML{*
  val gt = GoalTyp_I.default;
  (*val class_topsymb = GoalTyp.Class.add_item (F.mk "top_symbols") [[(GTD.String "HOL.conj")], [(GTD.String "HOL.conj"), (GTD.String "HOL.implies")]] Class.top;*)
  val class_hassymb = GoalTyp.Class.add_item (F.mk "has_symbols") [[(GTD.String "HOL.conj")]] Class.top;
(*  val class_hassymb_topsymb = GoalTyp.Class.add_item (F.mk "has_symbols") [[(GTD.String "HOL.implies")]] class_topsymb;*)

  val gt_demo = 
    GoalTyp.set_gclass class_hassymb gt
    |> GoalTyp.set_facts [ class_hassymb]
    |> GoalTyp.set_name (G.mk"hassymb");

  val auto = RTechn.id
            |> RTechn.set_name (RT.mk "auto")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "auto"));
  val auto_tac = fn x => ( Clasimp.auto_tac x);

  val psauto = PSComb.LIFT ([gt_demo],[gt]) (auto);
  val psgraph = psauto PSGraph.empty;

  val psgraph = 
    psauto PSGraph.empty 
    |> PSGraph.update_atomics (StrName.NTab.doadd ("auto", auto_tac));

*}
ML{*
  val (pn,pp) = Prover.init @{context} ( @{term "A \<and> A ==> A \<longrightarrow> A ==> A --> A"});
  val pnode_tab = 
       StrName.NTab.ins
         (Prover.get_pnode_name pn,pn)
         StrName.NTab.empty;
  val edata_0 = EData.init psgraph pp pnode_tab [];
*}

ML {*
 pn;
*}

ML{*
val (pp,g) = PPlan.init @{context} @{term "A \<and> A ==> A \<longrightarrow> A ==> A --> A"};
PNode.pretty pp |> Pretty.writeln;
*}

ML{*
  val edata0 = EVal.init psgraph @{context} @{prop "A \<and> A ==> A \<and> A"} |> hd;
  val edata1 = EVal.evaluate_any edata0 ;
*}


ML{*-
UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams (SOME edata0) (K edata0)
*}


-- "some previous codes"
(*

-- "storing data"
ML{*
 structure GTD = GoalTyp.Class.GoalTypData;
 structure CF_Data = Theory_Data(
  type T =  (Proof.context 
            -> thm  (* or term? *)
            -> GTD.data list list (* fixme: not sure current class is correct here*)
            -> bool) F.NTab.T
   val empty = F.NTab.empty
   val extend = I
   val merge = fst);

  val add_feature = CF_Data.map o F.NTab.ins;
  val get_features = CF_Data.get;
  val get_feature = F.NTab.lookup o get_features;
*}

-- "the class match function using this"
ML{*
  fun class_data_match fname ctxt obj data = 
    case get_feature (Proof_Context.theory_of ctxt) fname of
       NONE => false
     | SOME f => f ctxt obj data;
*}
*)

end



