(* authors: Gudmund Grov and Andrius Velykis *)
structure WhyMTree =
struct
  structure XML = IsaXML;

  (* String-based term for when Isabelle term cannot be determined *)
  datatype term_ref = IsaTerm of term | StrTerm of string

  (* Proof state *)
  type fixes = string list;
  (* to do: add features,
      syntax:
         type: e.g. g_feature
         name: string e.g. top_level
         args list: e.g. <arg>forall</arg><arg>exists</arg>
       (note: disjunction is pushed into feature)
       <feature type=g_feature name=has_symbol>
         <arg>forall</arg>
         <arg>exists</arg>
       </feature>  
       <negfeature type=g_feature name=has_symbol>
         <arg>and</arg>
         <arg>or</arg>
       </negfeature>  
      *)
  type PS = fixes * (string * term_ref) list * term_ref; (* need to know about "used" assumptions etc. *)
  (* thm - can either be hyp or global thm *)
  datatype thm_name = Thm of string | Hyp of string;

  (* known tactics *)
  datatype atac =
     Auto of {simp : thm_name list,intro : thm_name list, dest : thm_name list}
   | Simp of {add: thm_name list, del: thm_name list, only: (thm_name list) option}
   | Conj of term_ref (* subgoal tac (and have statement?) *)
   | Blast of {dest : thm_name list, intro : thm_name list}
   | Force of {simp : thm_name list,intro : thm_name list, dest : thm_name list}
   | Metis of thm_name list (* i.e. sledgehammer - so we don't care about args.. *)
   | Induction of (thm_name option) * (term_ref option) (* not sure about args here *)
   | UnknownTac of string

  (* know methods *)
  datatype meth =
   Rule of thm_name
   | Erule of (thm_name option) * thm_name (* which assumption + thm *)
   | Frule of (thm_name option) * thm_name (* which assumption + thm *)
   | Subst_thm of thm_name (* rule used *)
   | Subst_asm_thm of thm_name * thm_name (* rule used *)
   | Subst_using_asm of thm_name (* which assumption in list *)
   | Case of term_ref (* term which case is applied for *)
   | Tactic of atac
   | Using of thm_name list * meth
   | Unknown of string;
   (* from a b c have g:"p x" becomes Have ([Thm "a", Thm "b", Hyp "c"],"g",StrTerm "p x") *)
   (* | Have of thm_name list * string * term_ref *)
 
  (* user provided annotations [will need a richer datatype] *)
  type why = string * meth

  datatype PT = Gap
    | Proof of why * PG list
    | Failure of {failures : PT list, valid : PT option} (* assume failed is ordered *)
  and PG = Goal of {state : PS, cont : PT};

 datatype Theory = Th of PG StrName.NTab.T;

  (* encoding and decoding of xml representation *)
  exception decode_exp of string * XML.tree;

  fun encode_term (IsaTerm(t)) = XML.Elem (("IsaTerm",[]), Term_XML.Encode.term t)
   | encode_term (StrTerm(s)) = XML.Elem (("StrTerm",[("val", s)]), []);
  fun decode_term (XML.Elem (("IsaTerm",[]), term_tree)) = IsaTerm (Term_XML.Decode.term term_tree)
   | decode_term (XML.Elem (("StrTerm",[("val", s)]), [])) = StrTerm s
   | decode_term tree = raise decode_exp ("Term has wrong args",tree);

  fun encode_st_pair (s,t) = XML.Elem (("Pair",[("name",s)]),[encode_term t]);
  fun decode_st_pair (XML.Elem (("Pair",[("name",s)]),[ttree])) = (s,decode_term ttree)
   | decode_st_pair tree = raise decode_exp ("Pair has wrong args",tree);;
 
  fun encode_assocl als = XML.Elem (("AssocList",[]),map encode_st_pair als);
  fun decode_assocl (XML.Elem (("AssocList",[]),als_tree)) = map decode_st_pair als_tree
   | decode_assocl tree = raise decode_exp ("Assoc list has wrong args",tree);

  fun encode_ps (_,accls,g) = XML.Elem (("PS",[]),[encode_assocl accls, encode_term g]);
  fun decode_ps (XML.Elem (("PS",[]),[accls_tree,g_tree])) =
       ([],decode_assocl accls_tree, decode_term g_tree)
   | decode_ps tree = raise decode_exp ("PS has wrong args",tree);

  fun encode_thm_name (Thm s) = XML.Elem (("Thm",[("name",s)]),[])
    | encode_thm_name (Hyp s) = XML.Elem (("Hyp",[("name",s)]),[]);

  fun decode_thm_name (XML.Elem (("Thm",[("name",s)]),[])) = Thm s
   | decode_thm_name (XML.Elem (("Hyp",[("name",s)]),[])) = Hyp s
   | decode_thm_name tree = raise decode_exp ("cannot decode thm_name",tree);

  fun encode_opts NONE = XML.Elem (("NONE",[]),[])
   | encode_opts (SOME v) = XML.Elem (("SOME",[]),v);

  fun encode_opt v = encode_opts(Option.map (fn e => [e]) v);

  fun decode_opts (XML.Elem (("NONE",[]),[])) = NONE
    | decode_opts (XML.Elem (("SOME",[]),v)) = SOME(v)
    | decode_opts tree = raise decode_exp ("cannot decode option type",tree);

  fun decode_opt e = Option.map hd (decode_opts e);

  fun thm_elem name thm = XML.Elem ((name,[]),[encode_thm_name thm])
  fun thms_elem name thms = XML.Elem ((name,[]),map encode_thm_name thms)
  fun opt_thm_elem name thm = XML.Elem ((name,[]),[encode_opt(Option.map encode_thm_name thm)])
  fun opt_thms_elem name thms = XML.Elem ((name,[]),[encode_opts(Option.map (map encode_thm_name) thms)])

  fun encode_tac (Auto {simp,intro,dest}) = XML.Elem (("Auto",[]),
         [thms_elem "Simp" simp,
         thms_elem "Intro" intro,
         thms_elem "Dest" dest])
   | encode_tac (Simp {add,del,only}) = XML.Elem (("Simp",[]),
         [thms_elem "Add" add,
         thms_elem "Del" del,
         opt_thms_elem "Only" only])
   | encode_tac (Conj trm) = (XML.Elem (("Conj",[]),[encode_term trm]))
   | encode_tac (Blast {dest,intro}) = XML.Elem (("Blast",[]),
         [thms_elem "Intro" intro,
         thms_elem "Dest" dest])
   | encode_tac (Force {simp,intro,dest}) = XML.Elem (("Force",[]),
         [thms_elem "Simp" simp,
         thms_elem "Intro" intro,
         thms_elem "Dest" dest])
   | encode_tac (Metis thms) = thms_elem "Metis" thms
   | encode_tac (Induction (rule,arg)) = XML.Elem (("Induction",[]),
         [opt_thm_elem "Rule" rule,
         XML.Elem (("Arg",[]),[encode_opt(Option.map encode_term arg)])])
   | encode_tac (UnknownTac s) = XML.Elem (("UnknownTac",[("val",s)]),[]);

  fun decode_tac (XML.Elem (("Auto",[]),[XML.Elem (("Simp",[]),simp_trees),XML.Elem (("Intro",[]),intro_trees),XML.Elem (("Dest",[]),dest_trees)])) =
       Auto {simp = map decode_thm_name simp_trees,
            intro = map decode_thm_name intro_trees,
            dest = map decode_thm_name dest_trees}
   | decode_tac (XML.Elem (("Simp",[]),[XML.Elem (("Add",[]),add_trees),XML.Elem (("Del",[]),del_trees),XML.Elem (("Only",[]),[only_trees])])) =
        Simp {add = (map decode_thm_name add_trees),
              del = (map decode_thm_name del_trees),
              only = Option.map (map decode_thm_name) (decode_opts only_trees) }
   | decode_tac ((XML.Elem (("Conj",[]),[trm_tree]))) = Conj (decode_term trm_tree)
   | decode_tac (XML.Elem (("Blast",[]),[XML.Elem (("Intro",[]),intro_trees),XML.Elem (("Dest",[]),dest_trees)])) =
      Blast {intro = map decode_thm_name intro_trees,
            dest = map decode_thm_name dest_trees}
   | decode_tac (XML.Elem (("Force",[]),[XML.Elem (("Simp",[]),simp_trees),XML.Elem (("Intro",[]),intro_trees), XML.Elem (("Dest",[]),dest_trees)])) =
        Force {simp = map decode_thm_name simp_trees,
              intro = map decode_thm_name intro_trees,
              dest = map decode_thm_name dest_trees}
   | decode_tac (XML.Elem (("Metis",[]),thm_trees)) = Metis (map decode_thm_name thm_trees)
   | decode_tac ( XML.Elem (("Induction",[]),[XML.Elem (("Rule",[]),[rule_tree]), XML.Elem (("Arg",[]),[arg_tree])])) =
        Induction (Option.map decode_thm_name (decode_opt rule_tree),
                   Option.map decode_term (decode_opt arg_tree))
   | decode_tac (XML.Elem (("UnknownTac",[("val",s)]),[])) = UnknownTac s
   | decode_tac tree = raise decode_exp ("cannot decode tactic",tree);

  fun encode_meth (Rule thm) = thm_elem "Rule" thm
   | encode_meth (Erule (asm,thm)) =
         XML.Elem (("Erule",[]),
           [opt_thm_elem "Assumption" asm,
            thm_elem "Theorem" thm])
   | encode_meth (Frule (asm,thm)) =
         XML.Elem (("Frule",[]),
           [opt_thm_elem "Assumption" asm,
            thm_elem "Theorem" thm])
   | encode_meth (Subst_thm thm) = thm_elem "Subst_thm" thm
   | encode_meth (Subst_asm_thm (asm,thm)) =
         XML.Elem (("Subst_asm_thm",[]),
           [thm_elem "Assumption" asm,
           thm_elem "Theorem" thm])
   | encode_meth (Subst_using_asm thm) = thm_elem "Subst_using_asm" thm
   | encode_meth (Case trm) = (XML.Elem (("Case",[]),[encode_term trm]))
   | encode_meth (Tactic tac) = (XML.Elem (("Tactic",[]),[encode_tac tac]))
   | encode_meth (Using (thms,meth)) =
         XML.Elem (("Using",[]),
           [thms_elem "Thms" thms,
           XML.Elem (("Method",[]),[encode_meth meth])])
   | encode_meth (Unknown str) = (XML.Elem (("Unknown",[("name",str)]),[]));

  fun decode_meth (XML.Elem (("Rule",[]),[rule])) = (Rule (decode_thm_name rule))
   | decode_meth (tree as XML.Elem (("Rule",[]),_)) = raise decode_exp ("rule has wrong args",tree)
   | decode_meth (XML.Elem (("Erule",[]),[XML.Elem (("Assumption",[]),[asm_tree]), XML.Elem (("Theorem",[]),[thm_tree])])) =
       Erule (Option.map decode_thm_name (decode_opt asm_tree),
              decode_thm_name thm_tree)
   | decode_meth (XML.Elem (("Frule",[]),[XML.Elem (("Assumption",[]),[asm_tree]), XML.Elem (("Theorem",[]),[thm_tree])])) =
       Frule (Option.map decode_thm_name (decode_opt asm_tree),
              decode_thm_name thm_tree)
   | decode_meth (XML.Elem (("Subst_thm",[]),[thm_tree])) = Subst_thm (decode_thm_name thm_tree)
   | decode_meth (XML.Elem (("Subst_asm_thm",[]),[XML.Elem (("Assumption",[]),[asm_tree]),XML.Elem (("Theorem",[]),[thm_tree])])) =
         Subst_asm_thm (decode_thm_name asm_tree ,decode_thm_name thm_tree)
   | decode_meth (XML.Elem (("Subst_using_asm",[]),[thm_tree])) = Subst_using_asm (decode_thm_name thm_tree)
   | decode_meth (XML.Elem (("Case",[]),[trm_tree])) = Case (decode_term trm_tree)
   | decode_meth (XML.Elem (("Tactic",[]),[tac_el])) = Tactic (decode_tac tac_el)
   | decode_meth (tree as XML.Elem (("Tactic",[]),_)) = raise decode_exp ("tactic has wrong args",tree)
   | decode_meth (XML.Elem (("Using",[]),[XML.Elem (("Thms",[]),thms_tree), XML.Elem (("Method",[]),[meth_tree])])) =
       Using (map decode_thm_name thms_tree,decode_meth meth_tree)
   | decode_meth (XML.Elem (("Unknown",[("name",str)]),[])) = Unknown str
   | decode_meth tree = raise decode_exp ("cannot decode method",tree);

  fun encode_why (s,m) = XML.Elem (("Why",[("why_info",s)]),[encode_meth m]);
  fun decode_why (XML.Elem (("Why",[("why_info",s)]),[m])) = (s,decode_meth m)
   | decode_why tree = raise decode_exp ("cannot decode why",tree);

  fun encode_pt Gap = XML.Elem (("Gap",[]),[])
   | encode_pt (Proof(w, goals)) = XML.Elem (("Proof",[]),[encode_why w, XML.Elem (("Goals",[]), map encode_pg goals)])
   | encode_pt (Failure {failures,valid}) = XML.Elem (("Failure",[]),
       [XML.Elem (("Failures",[]),map encode_pt failures),
        XML.Elem (("Valid",[]),[encode_opt (Option.map encode_pt valid)])])
  and encode_pg (Goal {state,cont}) = XML.Elem (("Goal",[]),[encode_ps state,encode_pt cont]);

  fun decode_pt (XML.Elem (("Gap",[]),[])) = Gap
   | decode_pt (XML.Elem (("Proof",[]),(w_tree :: XML.Elem (("Goals",[]), goals_trees) :: _))) =
        Proof (decode_why w_tree, map decode_pg goals_trees)
   | decode_pt (XML.Elem (("Failure",[]),[XML.Elem (("Failures",[]),failures_trees), XML.Elem (("Valid",[]),[valid_tree])])) =
         Failure {failures = map decode_pt failures_trees,valid = Option.map decode_pt (decode_opt valid_tree)}
   | decode_pt tree = raise decode_exp ("cannot decode proof element",tree)
  and decode_pg (XML.Elem (("Goal",[]),[state_tree,cont_tree])) =
        Goal {state = decode_ps state_tree,cont = decode_pt cont_tree}
   | decode_pg tree = raise decode_exp ("cannot decode proof goal",tree);

 fun decode_lemma (XML.Elem (("Lemma",[("name",s)]),[m])) = (s,decode_pg m);

 fun decode_theory (XML.Elem (("Theory",_),_),lemmas) = 
   lemmas
   |> map decode_lemma 
   |> StrName.NTab.of_list
   |> Th;

 fun parse_file filename = 
   let
     val is = TextIO.openIn filename
     val inp = TextIO.inputAll is;
     val _ = TextIO.closeIn is;
   in
     inp |> YXML.parse_body 
         |> hd (* not sure what's in the rest of the list *)
         |> decode_pg (* should be decode_theory *)
   end;

  fun path th = Path.implode (Thy_Load.master_directory th) ^ "/";
  fun fname' th = (Context.theory_name th) ^ ".pp";
  fun filename th = (path th) ^ (fname' th);

  val parse_theory = parse_file o filename;


end;


