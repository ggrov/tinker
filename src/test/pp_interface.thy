theory pp_interface
imports
  Main
uses
  "../parse/parsetree.ML"  
begin

(* lift term to features *)
ML{*

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
val is = parse_file "/u1/staff/gg10/Stratlang/src/parse/examples/simple1.yxml"
*}

(* todo - parse -> then map to features *)
ML{*
val (_,_,(StrTerm g)) = #state pg;
val x = "\<forall>i. zero i = 0 \<or> zero (- i) = 0";
x=g;
String.explode x;
String.explode g;
(String.explode x)=(String.explode g);
*}

ML{*
Syntax.read_prop_global @{theory} g;
Syntax.parse_prop @{context} g;
*}





end;


