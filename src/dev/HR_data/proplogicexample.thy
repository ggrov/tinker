theory proplogicexample
imports 
  Main
   "../../provers/isabelle/full/build/Parse" 
begin

ML_val{* proofs := 2 *}
ML{*print_depth 20*}
 
ML_file "clausegenerator.ML"

ML{*
val path = "/home/colin/Documents/MIL/MIL/proof_terms/"
*}


(* Test dataset for use with MIL learning*)

(* Datatypes from proof_term_parse.ML - copied for reference*)
ML{*
  datatype tmp_prftree = TmpPrf of proof * (tmp_prftree list)
  datatype prftree = Prf of (string * term option) * (prftree list)
*}

(* Functions from proof_term_parse.ML - copied for reference*)
ML{*
  fun prf thm = Proofterm.proof_of (Proofterm.strip_thm (Thm.proof_body_of thm));

 
  fun stripp (A %% B) = (stripp A) %% (stripp B)
   | stripp (A % _) = stripp A
   | stripp (Abst (_, _, A)) = stripp A
   | stripp (AbsP (_,_,A)) = stripp A
   | stripp A = A;

  fun app_list (A %% B) = app_list A @ [B]
   |  app_list (A % _) = app_list A
   |  app_list (Abst (_,_,X)) = app_list X
   |  app_list (AbsP (_,_,X)) = app_list X
   |  app_list X = [X];

 
  fun 
    pair_trm_tac (A % _) = pair_trm_tac A
   |  pair_trm_tac (PAxm (x,t,_)) = (x,SOME t)
   |  pair_trm_tac (PThm (_,((s,t,_),_))) = (s,SOME t)
   |  pair_trm_tac (Abst (_,_,X)) = pair_trm_tac X
   |  pair_trm_tac (AbsP (_,_,X)) = pair_trm_tac X
   |  pair_trm_tac (PBound 0) = ("assumption",NONE)
   |  pair_trm_tac (PBound _) = ("",NONE)

 
  fun project_trm_tac (TmpPrf (x,xs)) =  Prf (pair_trm_tac x,map project_trm_tac xs);


  fun simple_tree' prf = 
    case app_list prf of
      [x] => TmpPrf (x,[])
    | (x::xs) => TmpPrf (x,map simple_tree' xs);

  val simple_tree = simple_tree' o stripp;


  val build_tree = project_trm_tac o simple_tree;
*}


(*Attempting to translate strings (tactics) and terms (goals) into a readable form 
for MIL. Trying to keep the same tree structure.*)
ML{*
fun prune_terms prf =
  case build_tree prf of
  Prf ((s,SOME t),[]) => (((clausegen.trans_tacs s),(clausegen.term_trans t)),[])
| Prf ((s,NONE),[]) => (((clausegen.trans_tacs s),(clausegen.term_trans Term.dummy)),[])
| Prf ((s,SOME t),[x]) => (((clausegen.trans_tacs s),(clausegen.term_trans t)),[x])
*}


(*Different version of the same function in different notation*)
ML{*
fun prune_terms_alt (Prf ((s,SOME t),[])) = (((clausegen.trans_tacs s),(clausegen.term_trans t)),[])
  | prune_terms_alt (Prf ((s,NONE), [])) = (((clausegen.trans_tacs s),(clausegen.term_trans Term.dummy)),[])
  | prune_terms_alt (Prf ((s,SOME t),[x::xs])) = (((clausegen.trans_tacs s),(clausegen.term_trans t)),[prune_terms_alt x]@[prune_terms_alt xs])
*}


(*Extracting tactic labels from proofs. Works, but only provides a list of tactics
used. *)

ML{*
fun find_tacs (A %% B) = (find_tacs A) ^ " " ^ (find_tacs B)
  | find_tacs (A % _) = find_tacs A
  | find_tacs (Abst (_, _, A)) = find_tacs A
  | find_tacs (AbsP (_,_,A)) = find_tacs A
  | find_tacs (PThm (_,((A,_,_),_))) = A
  | find_tacs (PBound _) = "";
*}


lemma a: "A \<longrightarrow> A"
  apply (rule impI)
  apply assumption
done

full_prf a


ML{*
val prfa = PTParse.prf @{thm a};
*}
ML{*
val term_a = clausegen.term_trans @{term "A \<longrightarrow> A"};
val MIL_a = clausegen.pt_trans prfa;
*}



lemma b: "A \<and> B \<longrightarrow> B \<and> A"
  apply (rule impI)
  apply (erule conjE)
  apply (rule conjI)
  apply assumption
  apply assumption
done

full_prf b

ML{*
val prfb = PTParse.prf @{thm b};
val MIL_b = clausegen.pt_trans prfb;
*}


lemma c: "(A \<and> B) \<longrightarrow> (A \<or> B)"
  apply (rule impI)
  apply (erule conjE)
  apply (rule disjI1)
  apply assumption
done

full_prf c

ML{*
val prfc = PTParse.prf @{thm c};
val MIL_c = clausegen.pt_trans prfc;
*}


lemma d: "((A \<or> B) \<or> C) \<longrightarrow> A \<or> (B \<or> C)"
  apply (rule impI)
  apply (erule disjE)
  apply (erule disjE)
  apply (rule disjI1)
  apply assumption
  apply (rule disjI2)
  apply (rule disjI1)
  apply assumption
  apply (rule disjI2)
  apply (rule disjI2)
  apply assumption
done

full_prf d

ML{*
val prfd = PTParse.prf @{thm d};
val MIL_d = clausegen.pt_trans prfd;
*}


lemma e: "A \<longrightarrow> B \<longrightarrow> A"
  apply (rule impI)
  apply (rule impI)
  apply assumption
done

full_prf e

ML{*
val prfe = PTParse.prf @{thm e};
val MIL_e = clausegen.pt_trans prfe;
*}


lemma f: "(A \<or> A) = (A \<and> A)"
  apply (rule iffI)
  apply (erule disjE)
  apply (rule conjI)
  apply assumption
  apply assumption
  apply (rule conjI)
  apply assumption
  apply assumption
  apply (erule conjE)
  apply (rule disjI1)
  apply assumption
done

full_prf f

ML{*
val prff = PTParse.prf @{thm f};
val MIL_f = clausegen.pt_trans prff;
*}


lemma g: "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"
  apply (rule impI)
  apply (rule impI)
  apply (rule impI)
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply assumption
done

full_prf g


ML{*
val prfg = PTParse.prf @{thm g};
val MIL_g = clausegen.pt_trans prfg;
*}


lemma h: "(A \<longrightarrow> B) \<longrightarrow> (B \<longrightarrow> C) \<longrightarrow> A \<longrightarrow> C"
  apply (rule impI)
  apply (rule impI)
  apply (rule impI)
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply assumption
done

full_prf h

ML{*
val prfh = PTParse.prf @{thm h};
val MIL_h = clausegen.pt_trans prfh;
*}



lemma i: "\<not>\<not>A \<longrightarrow> A"
  apply (rule impI)
  apply (rule classical)
  apply (erule notE)
  apply assumption
done

full_prf i

ML{*
val prfi = PTParse.prf @{thm i};
val MIL_i = clausegen.pt_trans prfi;
*}


lemma j: "A \<longrightarrow> \<not>\<not>A"
  apply (rule impI)
  apply (rule notI)
  apply (erule notE)
  apply assumption
done

full_prf j

ML{*
val prfj = PTParse.prf @{thm j};
val MIL_j = clausegen.pt_trans prfj
*}


lemma k: "(\<not>A \<longrightarrow> B) \<longrightarrow> (\<not>B \<longrightarrow> A)"
  apply (rule impI)
  apply (rule impI)
  apply (rule classical)
  apply (erule impE)
  apply assumption
  apply (erule notE)
  apply assumption
done

full_prf k

ML{*
val prfk = PTParse.prf @{thm k};
val MIL_k = clausegen.pt_trans prfk;
*}


lemma l: "((A \<longrightarrow> B) \<longrightarrow> A) \<longrightarrow> A"
  apply (rule impI)
  apply (rule classical)
  apply (erule impE)
  apply (rule impI)
  apply (erule notE)
  apply assumption
  apply (erule notE)
  apply assumption
done

full_prf l

ML{*
val prfl = PTParse.prf @{thm l};
val MIL_l = clausegen.pt_trans prfl;
*}


lemma m: "A \<or> \<not>A"
  apply (rule classical)
  apply (rule disjI2)
  apply (rule notI)
  apply (erule notE)
  apply (rule disjI1)
  apply assumption
done

full_prf m

ML{*
val prfm = PTParse.prf @{thm m};
val MIL_m = clausegen.pt_trans prfm;
*}


lemma n: "A \<or> B  \<longrightarrow> B \<or> A"
  apply (rule impI)
  apply metis
done

full_prf n

ML{*
val prfn = PTParse.prf @{thm n};
val MIL_n = clausegen.pt_trans prfn;
*}


lemma o: "(\<not>(A \<and> B)) = (\<not>A \<or> \<not>B)"
  apply (rule iffI)
  apply (rule classical)
  apply (erule notE)
  apply (rule conjI)
  apply (rule classical)
  apply (erule notE)
  apply (rule disjI1)
  apply assumption
  apply (rule classical)
  apply (erule notE)
  apply (rule disjI2)
  apply assumption
  apply (rule notI)
  apply (erule conjE)
  apply (erule disjE)
  apply (erule notE)
  apply assumption
  apply (erule notE)
  apply assumption
  done

ML{*
val prfo = PTParse.prf @{thm o};
val MIL_o = clausegen.pt_trans prfo;
*}



end
