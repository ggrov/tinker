theory pp_interface 
imports
  Main
  "../build/RTechn"
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
 open ParseTree;
 structure FE = FeatureEnv;
 structure TF = TermFeatures;

*}
ML{*
val (Goal pg) = parse_file "/Users/ggrov/Stratlang/src/parse/examples/attempt_lem2.yxml" 
val (Proof p) = #cont pg;
val (_,_,StrTerm g) = #state pg;

fun cont_of_prf (Goal pg) = case #cont pg of Proof p => p |> snd;
fun meth_of_prf (Goal pg) = case #cont pg of Proof p => p |> fst |> snd; 
fun term_of_prf (Goal pg) = case #state pg of
     (_,_,StrTerm g) => g;

fun oterms_of_prf g = map term_of_prf (cont_of_prf g)

*}
(* lift term to features *)
ML{*
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

fun rtech_of_goal ctxt goal =
  RTechn.id
  |> RTechn.set_inputs (W.NSet.single (wire_of_str ctxt (term_of_prf goal)))
  |> RTechn.set_outputs (W.NSet.of_list (map (wire_of_str ctxt) (oterms_of_prf goal)))
*}


ML{*
val t = term_of_prf (Goal pg);
val t' = Syntax.read_prop @{context} "\<forall>x. PP x \<longrightarrow> PP x"
 |> Thm.cterm_of @{theory};
Goal.init;
val w = wire_of_str @{context} t;
Wire.get_goal w |> BWire.get_pos;
W.NSet.single w;
*}


ML{*
rtech_of_goal @{context}(Goal pg);

fun rtechns_of_proof ctxt g = 
 (rtech_of_goal ctxt g) :: (maps (rtechns_of_proof ctxt) (cont_of_prf g))
*}

ML{*
rtechns_of_proof @{context} (Goal pg);
*}

ML{*
val prs = parse_file "/Users/ggrov/Stratlang/src/parse/examples/attempt_lem1.yxml"; 
rtechns_of_proof @{context} prs;
*}

ML{*
val t = @{prop "! x y. P x \<and> P y --> P x \<and> P y"};
TF.constants t 
*}






ML{*
 open ParseTree;
*}

ML{*
val tac1 = Auto {simp = [],intro = [], dest = []};
val s0 = ([],[],IsaTerm @{term "x + x = 0"}) : PS;
(*val t1 = Goal {state = s0,cont = Gap};
val t2 = Goal {state = s0,cont = Proof (("",Tactic tac1),[])}*)
*}


ML{*
print_depth 100;
*}

ML{*
XML.Text "test";
XML.Elem (("Unknown",[("arg","test")]),[]);
val t = XML.Elem (("Simp",[]),[XML.Elem (("dest",[("val","l1")]),[]),XML.Elem (("dest",[("val","l2")]),[])]);
val yt = YXML.string_of t;
val t' = YXML.parse yt;
(YXML.parse o YXML.string_of);
val x = Print_Mode.setmp [] ((YXML.parse o YXML.string_of)) t;
*}

ML{*
val (Goal pg) = parse_file "/u1/staff/gg10/Stratlang/src/parse/examples/simple2.yxml" 
*}

(* todo - parse -> then map to features *)
ML{*
val (_,_,StrTerm g) = #state pg;
val x = "\<forall>i. zero i = 0 \<or> zero (- i) = 0";
String.explode g;
(String.explode x)=(String.explode g);
Syntax.parse_prop @{context} g;
*}

ML{*
Syntax.read_prop_global @{theory} g;
Syntax.parse_prop @{context} g;
*}





end;


