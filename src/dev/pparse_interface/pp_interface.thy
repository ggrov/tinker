theory pp_interface                             
imports      
  Main                  
begin

ML{*
val mythm = @{thm "impI"};
*}

(* for backward proofs -- similar for forward? *)
(* maybe we need a better representation of proof objects? *)
ML{*
(* Proof state *)
type fixes = string list;
type PS = fixes * (string * term) list * term; (* need to know about "used" assumptions etc. *)

datatype thm_name = Thm of string | Hyp of string;

datatype atac = 
   Auto of {simp : thm_name list,intro : thm_name list, dest : thm_name list}
 | Simp of thm_name list
 | Conj of term (* subgoal tac (and have statement?) *)
 | Blast of {dest : thm_name list, intro : thm_name list}
 | Force of {simp : thm_name list,intro : thm_name list, dest : thm_name list} 
 | Metis of thm_name list (* i.e. sledgehammer - so we don't care about args.. *)
 | Induction of thm_name * string (* not sure about args here *)
 | UnknownTac of string

datatype meth = 
   Rule of thm_name
 | Erule of thm_name * thm_name (* which assumption + thm *)
 | Frule of thm_name * thm_name (* which assumption + thm *)
 | Subst_thm of thm_name (* rule used *)
 | Subst_asm_thm of thm_name * thm_name  (* rule used *)
 | Subst_using_asm of thm_name (* which assumption in list *)
 | Case of term (* term which case is applied for *)
 | Tactic of atac
 | Using of thm_name list * meth 
 | Unknown of string;

type why = string * meth

datatype PT = Gap
            | Proof of why * PG list
            | Failure of {failures : PT list, valid : PT option} (* assume failed is ordered *)
and PG = Goal of {state : PS, cont : PT};
*}




ML{*
val tac1 = Auto {simp  = [],intro = [], dest = []};
val s0 = ([],[],@{term "x + x = 0"}) : PS;
val t1 = Goal {state = s0,cont = Gap};
val t2 = Goal {state = s0,cont = Proof (("",Tactic tac1),[])};
*}

ML{*
exception decode_exp of string * XML.tree;

val encode_term = Term_XML.Encode.term; 
val decode_term = Term_XML.Decode.term; 

fun encode_st_pair (s,t) = XML.Elem (("Pair",[("name",s)]),encode_term t);
fun decode_st_pair (XML.Elem (("Pair",[("name",s)]),ttree)) = (s,decode_term ttree)
 |  decode_st_pair tree  = raise decode_exp ("Pair  has wrong args",tree);;
 
fun encode_assocl als = XML.Elem (("AssocList",[]),map encode_st_pair als);
fun decode_assocl (XML.Elem (("AssocList",[]),als_tree)) = map decode_st_pair als_tree
 |  decode_assocl tree  = raise decode_exp ("Assoc list has wrong args",tree);

fun encode_ps (_,accls,g) = XML.Elem (("PS",[]),[encode_assocl accls] @ encode_term g);
fun decode_ps (XML.Elem (("PS",[]),[accls_tree,g_tree])) = 
     ([],decode_assocl accls_tree, decode_term [g_tree])
 |  decode_ps tree  = raise decode_exp ("PS has wrong args",tree);

fun encode_thm_name (Thm s) = XML.Elem (("Thm",[("name",s)]),[])
 |  encode_thm_name (Hyp s) = XML.Elem (("Hyp",[("name",s)]),[]);

fun decode_thm_name (XML.Elem (("Thm",[("name",s)]),[])) = Thm s
 |  decode_thm_name (XML.Elem (("Hyp",[("name",s)]),[])) = Hyp s
 |  decode_thm_name tree = raise decode_exp ("cannot decode thm_name",tree);

fun encode_tac (Auto {simp,intro,dest}) = XML.Elem (("Auto",[]),
         [XML.Elem (("Simp",[]),map encode_thm_name simp),
         XML.Elem (("Intro",[]),map encode_thm_name intro),
         XML.Elem (("Dest",[]),map encode_thm_name dest)])
 |  encode_tac (Simp thms) = (XML.Elem (("Simp",[]),map encode_thm_name thms))
 |  encode_tac (Conj trm) = (XML.Elem (("Conj",[]),encode_term trm))
 |  encode_tac (Blast {dest,intro}) = XML.Elem (("Blast",[]),
         [XML.Elem (("Intro",[]),map encode_thm_name intro),
         XML.Elem (("Dest",[]),map encode_thm_name dest)])
 |  encode_tac (Force {simp,intro,dest}) = XML.Elem (("Force",[]),
         [XML.Elem (("Simp",[]),map encode_thm_name simp),
         XML.Elem (("Intro",[]),map encode_thm_name intro),
         XML.Elem (("Dest",[]),map encode_thm_name dest)])
 |  encode_tac (Metis thms) = XML.Elem (("Metis",[]),map encode_thm_name thms)
 |  encode_tac (Induction (thm,s)) = XML.Elem (("Induction",[("desc",s)]),[encode_thm_name thm])
 |  encode_tac (UnknownTac s) = XML.Elem (("UnknownTac",[("val",s)]),[]);


fun decode_tac (XML.Elem (("Auto",[]),[XML.Elem (("Simp",[]),simp_trees),XML.Elem (("Intro",[]),intro_trees),XML.Elem (("Dest",[]),dest_trees)])) =
      Auto {simp = map decode_thm_name simp_trees,
            intro = map decode_thm_name intro_trees,
            dest = map decode_thm_name dest_trees}
 | decode_tac (XML.Elem (("Simp",[]),tree_els)) = Simp (map decode_thm_name tree_els)
 | decode_tac ((XML.Elem (("Conj",[]),trm_tree))) = Conj (decode_term trm_tree)
 | decode_tac (XML.Elem (("Blast",[]),[XML.Elem (("Intro",[]),intro_trees),XML.Elem (("Dest",[]),dest_trees)])) =
    Blast {intro = map decode_thm_name intro_trees,
          dest = map decode_thm_name dest_trees}
 | decode_tac (XML.Elem (("Force",[]),[XML.Elem (("Simp",[]),simp_trees),XML.Elem (("Intro",[]),intro_trees), XML.Elem (("Dest",[]),dest_trees)])) = 
      Force {simp = map decode_thm_name simp_trees,
            intro = map decode_thm_name intro_trees,
            dest = map decode_thm_name dest_trees}
 | decode_tac (XML.Elem (("Metis",[]),thm_trees)) = Metis (map decode_thm_name thm_trees)
 | decode_tac ( XML.Elem (("Induction",[("desc",s)]),[thm_tree])) = Induction (decode_thm_name thm_tree,s)
 | decode_tac (XML.Elem (("UnknownTac",[("val",s)]),[])) = UnknownTac s
 | decode_tac tree =  raise decode_exp ("cannot decode tactic",tree);

fun encode_meth (Rule thm) = XML.Elem (("Rule",[]),[encode_thm_name thm])
 |  encode_meth (Erule (asm,thm)) = 
       XML.Elem (("Erule",[]),
         [XML.Elem (("Assumption",[]),[encode_thm_name asm]),
         XML.Elem (("Theorem",[]),[encode_thm_name thm])])
 |  encode_meth (Frule (asm,thm)) = 
       XML.Elem (("Frule",[]),
         [XML.Elem (("Assumption",[]),[encode_thm_name asm]),
         XML.Elem (("Theorem",[]),[encode_thm_name thm])])
 |  encode_meth (Subst_thm thm) = XML.Elem (("Subst_thm",[]),[encode_thm_name thm])
 |  encode_meth (Subst_asm_thm (asm,thm)) = 
       XML.Elem (("Subst_asm_thm",[]),
         [XML.Elem (("Assumption",[]),[encode_thm_name asm]),
         XML.Elem (("Theorem",[]),[encode_thm_name thm])])
 |  encode_meth (Subst_using_asm thm) = XML.Elem (("Subst_using_asm",[]),[encode_thm_name thm])
 |  encode_meth (Case trm) = (XML.Elem (("Case",[]),encode_term trm))
 |  encode_meth (Tactic tac) = (XML.Elem (("Tactic",[]),[encode_tac tac]))
 |  encode_meth (Using (thms,meth)) =
       XML.Elem (("Using",[]),
         [XML.Elem (("Thms",[]),map encode_thm_name thms),
         XML.Elem (("Method",[]),[encode_meth meth])])
 |  encode_meth (Unknown str) = (XML.Elem (("Unknown",[("name",str)]),[]));


fun decode_meth (XML.Elem (("Rule",[]),[rule])) = (Rule (decode_thm_name rule))
 |  decode_meth (tree as XML.Elem (("Rule",[]),_)) = raise decode_exp ("rule has wrong args",tree)
 | decode_meth (XML.Elem (("Erule",[]),[XML.Elem (("Assumption",[]),[asm_tree]),XML.Elem (("Theorem",[]),[thm_tree])])) = 
     Erule (decode_thm_name asm_tree, decode_thm_name thm_tree)
 | decode_meth (XML.Elem (("Frule",[]),[XML.Elem (("Assumption",[]),[asm_tree]), XML.Elem (("Theorem",[]),[thm_tree])])) = 
      Frule (decode_thm_name asm_tree, decode_thm_name thm_tree)
 |  decode_meth (XML.Elem (("Subst_thm",[]),[thm_tree])) = Subst_thm (decode_thm_name thm_tree)
 |  decode_meth (XML.Elem (("Subst_asm_thm",[]),[XML.Elem (("Assumption",[]),[asm_tree]),XML.Elem (("Theorem",[]),[thm_tree])])) =
       Subst_asm_thm (decode_thm_name asm_tree ,decode_thm_name thm_tree)
 |  decode_meth (XML.Elem (("Subst_using_asm",[]),[thm_tree])) = Subst_using_asm (decode_thm_name thm_tree)
 |  decode_meth (XML.Elem (("Case",[]),trm_tree)) = Case (decode_term trm_tree)
 |  decode_meth (XML.Elem (("Tactic",[]),[tac_el])) = Tactic (decode_tac tac_el)
 |  decode_meth (tree as XML.Elem (("Tactic",[]),_)) = raise decode_exp ("tactic has wrong args",tree)
 |  decode_meth (XML.Elem (("Using",[]),[XML.Elem (("Thms",[]),thms_tree), XML.Elem (("Method",[]),[meth_tree])])) =
     Using (map decode_thm_name thms_tree,decode_meth meth_tree)
 |  decode_meth (XML.Elem (("Unknown",[("name",str)]),[])) = Unknown str
 |  decode_meth tree =  raise decode_exp ("cannot decode method",tree);


fun encode_why (s,m) = XML.Elem (("Why",[("why_info",s)]),[encode_meth m]);
fun decode_why (XML.Elem (("Why",[("why_info",s)]),[m])) = (s,decode_meth m)
 |  decode_why tree = raise decode_exp ("cannot decode why",tree);

fun encode_pt Gap = XML.Elem (("Gap",[]),[])
 |  encode_pt (Proof (w,xs)) = XML.Elem (("Proof",[]),[encode_why w] @ map encode_pg xs)
 |  encode_pt (Failure {failures,valid}) = XML.Elem (("Failure",[]),
     [XML.Elem (("Failures",[]),map encode_pt failures),
      XML.Elem (("Valid",[]),[encode_maybe_valid valid])])
and encode_pg (Goal {state,cont}) = XML.Elem (("Goal",[]),[encode_ps state,encode_pt cont])
and encode_maybe_valid NONE = XML.Elem (("NONE",[]),[])
 |  encode_maybe_valid (SOME v) = XML.Elem (("SOME",[]),[encode_pt v]);

fun decode_pt (XML.Elem (("Gap",[]),[])) = Gap
 |  decode_pt (XML.Elem (("Proof",[]),(w_tree::xs_trees)))  =
      Proof (decode_why w_tree,map decode_pg xs_trees)
 |  decode_pt (XML.Elem (("Failure",[]),[XML.Elem (("Failures",[]),failures_trees), XML.Elem (("Valid",[]),[valid_tree])])) =
       Failure {failures = map decode_pt failures_trees,valid = decode_maybe_valid valid_tree}
  | decode_pt tree = raise decode_exp ("cannot decode proof element",tree)
and decode_pg (XML.Elem (("Goal",[]),[state_tree,cont_tree])) =
      Goal {state = decode_ps state_tree,cont = decode_pt cont_tree}
  | decode_pg tree = raise decode_exp ("cannot decode proof goal",tree)
and decode_maybe_valid (XML.Elem (("NONE",[]),[])) = NONE
  | decode_maybe_valid (XML.Elem (("SOME",[]),[v_tree])) = SOME (decode_pt v_tree)
  | decode_maybe_valid tree = raise decode_exp ("cannot decode option type",tree);

encode_meth (Rule (Thm "a")) |> decode_meth;
encode_tac (Simp [Thm "a",Thm "a",Hyp "B"]);

*}
ML{*
XML.Text "test";
XML.Elem (("Unknown",[("arg","test")]),[]);
val t = XML.Elem (("Simp",[]),[XML.Elem (("dest",[("val","l1")]),[]),XML.Elem (("dest",[("val","l2")]),[])]);
val yt = YXML.string_of t;
val t' = YXML.parse yt;
*}


end;
