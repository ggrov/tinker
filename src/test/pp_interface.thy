theory pp_interface 
imports
  Main
  "../build/Wire"
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
*}
ML{*
val (Goal pg) = parse_file "/u1/staff/gg10/Stratlang/src/parse/examples/attempt_lem2.yxml" 
val (Proof p) = #cont pg;
val (_,_,StrTerm g) = #state pg;
*}
(* lift term to features *)
ML{*
structure TF = TermFeatures;
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


