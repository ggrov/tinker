(* authors: Gudmund Grov and Andrius Velykis *)
structure WhyMTree =
struct
  (* structure XML = IsaXML;*)

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

  (* know methods *)
  datatype tac = Tac of string * (string list list)
 
  (* user provided annotations [will need a richer datatype] *)
  type why = string * tac

  datatype PT = Gap
    | Proof of why * PG list
    | Failure of {failures : PT list, valid : PG list (*PT option *)} (* assume failed is ordered *)
  and PG = Goal of {state : PS, cont : PT};

 (* datatype Theory = Th of PG StrName.NTab.T;*)

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

  fun encode_opts NONE = XML.Elem (("NONE",[]),[])
   | encode_opts (SOME v) = XML.Elem (("SOME",[]),v);

  fun encode_opt v = encode_opts(Option.map (fn e => [e]) v);

  fun decode_opts (XML.Elem (("NONE",[]),[])) = NONE
    | decode_opts (XML.Elem (("SOME",[]),v)) = SOME(v)
    | decode_opts tree = raise decode_exp ("cannot decode option type",tree);

  fun decode_opt e = Option.map hd (decode_opts e);


  fun encode_tag_args arg = XML.Elem (("Arg",[]),map XML.Text arg)

  fun encode_tac (Tac (name,args)) = 
      XML.Elem (("Tac",[("val",name)]),
       map encode_tag_args args);

  fun decode_tac_single_arg (XML.Text x) = x
  fun decode_tac_arg (XML.Elem (("Arg",[]),arg)) = map decode_tac_single_arg arg;
  fun decode_tac_args (XML.Elem (("Args",_),args)) = maps decode_tac_arg args;

  fun decode_tac (XML.Elem (("Tac",[("val",name)]),args)) = Tac (name,map decode_tac_args args)
   | decode_tac (xml) = Tac (XML.string_of xml,[]); (* dummy *)

  fun encode_why (s,m) = XML.Elem (("Why",[("why_info",s)]),[encode_tac m]);
  fun decode_why (XML.Elem (("Why",[("why_info",s)]),[m])) = (s,decode_tac m)
   | decode_why tree = raise decode_exp ("cannot decode why",tree);

  fun encode_pt Gap = XML.Elem (("Gap",[]),[])
   | encode_pt (Proof(w, goals)) = XML.Elem (("Proof",[]),[encode_why w, XML.Elem (("Goals",[]), map encode_pg goals)])
   (* FIXME: not working *)
   | encode_pt (Failure {failures,valid}) = XML.Elem (("Failure",[]),
       [XML.Elem (("Failures",[]),map encode_pt failures),
        XML.Elem (("Valid",[]),[] (* encode_opt (Option.map encode_pt valid)] *) )])
  and encode_pg (Goal {state,cont}) = XML.Elem (("Goal",[]),[encode_ps state,encode_pt cont]);

  fun decode_pt (XML.Elem (("Gap",[]),[])) = Gap
   | decode_pt (XML.Elem (("Proof",[]),(w_tree :: XML.Elem (("Goals",[]), goals_trees) :: _))) =
        Proof (decode_why w_tree, map decode_pg goals_trees)
   | decode_pt (XML.Elem (("Failure",[]),[XML.Elem (("Failures",[]),failures_trees), XML.Elem (("Valid",[]),[valid_tree])])) = 
        Failure {failures = map decode_pt failures_trees,valid = decode_goals valid_tree (* Option.map decode_pt (decode_opt valid_tree) *)}
   | decode_pt tree = raise decode_exp ("cannot decode proof element",tree)
  and decode_pg (XML.Elem (("Goal",[]),[state_tree,cont_tree])) =
        Goal {state = decode_ps state_tree,cont = decode_pt cont_tree}
   | decode_pg tree = raise decode_exp ("cannot decode proof goal",tree)
  and decode_goals (XML.Elem (("Goals",[]),goals)) = map decode_pg goals;

 fun decode_lemma (XML.Elem (("Lemma",[("name",s)]),[m])) = (s,decode_pg m);

 fun decode_theory (XML.Elem (("Theory",_),lemmas)) = 
   lemmas
   |> map decode_lemma 
(*   |> StrName.NTab.of_list
   |> Th *) ;

 fun parse_only_file filename = 
   let
     val is = TextIO.openIn filename
     val inp = TextIO.inputAll is;
     val _ = TextIO.closeIn is;
   in
     inp 
   end;

 fun parse_file filename = 
   let
     val is = TextIO.openIn filename
     val inp = TextIO.inputAll is;
     val _ = TextIO.closeIn is;
   in
     inp |> YXML.parse_body 
         |> hd (* not sure what's in the rest of the list *)
         |> decode_theory (* should be decode_theory *)
   end;

(*
  fun path th = Path.implode (Thy_Load.master_directory th) ^ "/";
  fun fname' th = (Context.theory_name th) ^ ".pp";
  fun filename th = (path th) ^ (fname' th);

  val parse_theory = parse_file o filename;
*)

end;


