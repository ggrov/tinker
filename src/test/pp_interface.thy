theory pp_interface 
imports
  Main
  "../build/Graph"
uses
  "../parse/parsetree.ML"   
begin

text "Similar proofs with small difference, 
      similar cases in a proof"


(* From Isabelle list:
   John Wickerson <jpw48@cam.ac.uk>  Subject: [isabelle] "and similarly..."
   Date: 31 January 2012 15:57:25 GMT 

 next
    assume "opt1 fN o HeadMap g1 = HeadMap g2o fA"
      and "opt1 fN'o HeadMap g2 = HeadMap g3o fA'"
    hence "opt1 fN'o opt1 fNo HeadMap g1 = HeadMap g3o fA'o fA"
      using o_assoc[of "opt1 fN'" "opt1 fN" "HeadMap g1"]
        and o_assoc[of "opt1 fN'" "HeadMap g2" "fA"] by auto
    thus "opt1 (fN'o fN)o HeadMap g1 = HeadMap g3o (fA'o fA)"
      using opt1_o[of "fN'" "fN"] by auto
  next
    assume "opt1 fN o TailMap g1 = TailMap g2 o fA"
      and "opt1 fN' o TailMap g2 = TailMap g3 o fA'"
    hence "opt1 fN' o opt1 fNo TailMap g1 = TailMap g3o fA'o fA"
      using o_assoc[of "opt1 fN'" "opt1 fN" "TailMap g1"]
        and o_assoc[of "opt1 fN'" "TailMap g2" "fA"] by auto
    thus "opt1 (fN' o fN)o TailMap g1 = TailMap g3 o (fA'o fA)"
      using opt1_o[of "fN'" "fN"] by auto
  qed
*)

(* example similar lemmas *)

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

ML{*
 val path = "/u1/staff/gg10/"
*}

ML{*
local open ParseTree; in
 structure FE = FeatureEnv;
 structure TF = TermFeatures;

  fun cont_of_prf (Goal pg) = case #cont pg of Proof p => p |> snd;
  fun meth_of_prf (Goal pg) = case #cont pg of Proof p => p |> fst |> snd; 
  fun term_of_prf (Goal pg) = case #state pg of (_,_,StrTerm g) => g;
  fun oterms_of_prf g = map term_of_prf (cont_of_prf g)

fun wire_of_str ctxt str =
  let 
    val t = Syntax.read_prop ctxt str;
    val fs = FE.get_features t 
    val gwire = BWire.default_wire
              |> BWire.set_pos fs;
  in
   Wire.default_wire 
   |> Wire.set_goal gwire
  end;

fun name_of_thm_name (Thm s) = s
 |  name_of_thm_name (Hyp s) = s;

fun meth_name (Rule thn) = "rule: " ^ name_of_thm_name thn
 | meth_name (Erule (a,th)) = "erule: " ^ name_of_thm_name th (* which assumption + thm *)
 | meth_name (Frule (a,th)) = "frule" (* which assumption + thm *)
 | meth_name (Subst_thm th) = "subst_thm" (* rule used *)
 | meth_name (Subst_asm_thm (th1,th2)) = "subst_asm" (* rule used *)
 | meth_name (Subst_using_asm t) = "subst_using_asm" (* which assumption in list *)
 | meth_name (Case t) = "cases" (* term which case is applied for *)
 | meth_name (Tactic at) = "tactic"
 | meth_name (Using (th,m)) =  "erule: "
 | meth_name (Unknown s) = s;

fun rtech_of_goal ctxt goal =
  RTechn.id
  |> RTechn.set_atomic_appf (goal |> meth_of_prf |> meth_name)
  |> RTechn.set_inputs (W.NSet.single (wire_of_str ctxt (term_of_prf goal)))
  |> RTechn.set_outputs (W.NSet.of_list (map (wire_of_str ctxt) (oterms_of_prf goal)))

fun rtechns_of_proof ctxt g = 
 (rtech_of_goal ctxt g) :: (maps (rtechns_of_proof ctxt) (cont_of_prf g))


fun rtechns_of_file ctxt fname = 
  parse_file fname
  |> rtechns_of_proof ctxt;

end;
*}


ML{*
val rtechn_l1 = rtechns_of_file @{context} (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml");
val rtechn_l2 = rtechns_of_file @{context} (path ^ "/Stratlang/src/parse/examples/attempt_lem2.yxml");
*}

(* next: start making graph! *)

(* for each: previous node (if any), input wire, current graph, ProofNode to be parsed,
    returns updated graph *)
ML{*

fun graph_of_goal' prev ctxt goal g0 = 
  let 
      val rt = rtech_of_goal ctxt goal
      val (SOME wire) = (W.NSet.tryget_singleton o RTechn.get_inputs) rt
      val (l,g1) = Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rt)) g0
      val g2 = Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W wire) prev l g1
             |> snd
 
  in
     fold (graph_of_goal' l ctxt) (cont_of_prf goal) g2
  end;

 fun graph_of_goal ctxt goal =
  let 
      val rt = rtech_of_goal ctxt goal
      val (SOME wire) = (W.NSet.tryget_singleton o RTechn.get_inputs) rt
      val (l,g0) = Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rt)) Strategy_Theory.Graph.empty
      val (prev,g1) = Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert g0
      val g2 = Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W wire) prev l g1
             |> snd
  in
     fold (graph_of_goal' l ctxt) (cont_of_prf goal) g2
  end;
*}

ML{*
 val g2 = ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml");
 val graph = graph_of_goal @{context} g2;
 val str = Strategy_OutputGraphDot.output graph;
 writeln str;
*}

(*
     val is = TextIO.openIn filename
     val inp = TextIO.inputAll is;
     val _ = TextIO.closeIn is;

*)
ML{*
val filename = "/u1/staff/gg10/test.dot";
val outs = TextIO.openOut filename;
val _ = TextIO.output (outs,str);
TextIO.closeOut outs;
(* then do 
     edit strange formatting and
     dot -Tpdf test.dot -o test.pdf 
    would be nicer if data rather V/E names are printed
*)
*}


end;


