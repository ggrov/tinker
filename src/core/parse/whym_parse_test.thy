theory whym_parse_test
imports Main 
begin

  ML_file "whym_tree.ML"       

ML{*

local open WhyMTree in

  exception prftree_exp of string;

  datatype prftree = Node of (string*string list list) * term * (prftree list);

 (* note: this is a hack! E.g. constants may be classified as free and we are not dealing properly with binders.*)
  fun term_of_term_ref (IsaTerm t) = t
   |  term_of_term_ref (StrTerm s) = Syntax.parse_term @{context} s handle _ => @{term "dummy"};

 fun term_of_ps (_,hyps,conc) = Logic.list_implies (map (term_of_term_ref o snd) hyps,term_of_term_ref conc);
   
  (* String-based term for when Isabelle term cannot be determined *)

  fun string_ps (_,_,r) = "term";
  
  fun string_tac (Tac (n,args)) = n;
  fun string_why (_,tac) = string_tac tac;

  fun str_list [] = ""
   |  str_list (s::ss) = s ^ str_list ss;

  fun string_pt Gap = "GAP"
   |  string_pt (Proof (why,gls)) = "Proof " ^ string_why why ^ (str_list (map string_pg gls))
   |  string_pt (Failure {failures,valid}) = "Failures " ^ (str_list (map string_pg valid))
 and string_pg (Goal {state,cont}) = "Goal " ^ (string_ps state)  ^ "\n" ^ string_pt cont; 

  fun trans_ps r = term_of_ps r;
  fun trans_tac (Tac (n,args)) = (n,args);
  fun trans_why (_,tac) = trans_tac tac;
  fun trans_pt Gap goal = raise prftree_exp "partial proof"
   |  trans_pt (Proof (why,gls)) goal = [Node (trans_why why,goal, maps trans_pg gls)]
   | trans_pt (Failure {valid,...}) goal = maps trans_pg valid
 and trans_pg (Goal {state,cont}) = trans_pt cont (trans_ps state); 

end;

*}

  ML{*
  val file = "/home/ggrov/GIT/Tinker/src/parse/examples/proplogicexample_2.yxml";
  val parse_and_trans = 
   WhyMTree.parse_file
   #> map (fn (n,t) => (n,trans_pg t));

  val res = parse_and_trans file
           
  val res0 = WhyMTree.parse_file file |> map fst;

  val res = WhyMTree.parse_file file |> map snd;
  val res1 = trans_pg (nth res 0); 
  val res1 = trans_pg (nth res 1);
  (* 11,13 and 14 does not work *)
  val x = nth res 11;
  val y = nth res0 12;
  trans_pg x; 
  val res1 = trans_pg (nth res 10); 
  *}

end
