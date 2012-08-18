theory RTechn                                                                                                       
imports  
   "~~/contrib/quantomatic/core/isabelle/QuantoCore"                                                                                                                                                    
   IsapLib                                                                                  
   "PPlan"              
uses              

(* Basic Generic Framework *)
"../rstate/cinfo.ML"
"../rstate/lcinfo.ML"


"../rstate/rstate.ML"
"../rstate/inftools.ML"
 "../rstate/rst_pp.ML"  

(* Reasoning Technique Language *)
 
 
 "../rtechn/basic/basic_rtechn.ML"
 


(* lemma conjecturing *)
(* "rtechn/conj/conjecturedb_lib.ML"
"rtechn/conj/conjdb_cinfo.ML"
"rtechn/conj/conj_stack_cinfo.ML" *)


(* FIXME: add back in *) (*"../rtechn/basic/subspace.ML" *)
 "../rtechn/basic/rtechn_cx.ML"
 "../rtechn/basic/rtechn_rs.ML"       
 "../rtechn/basic/graph_comb.ML"    
  "../rtechn/basic/rtechn_comb.ML"

  "../critics/metavar_lib.ML" 
  (* "../rtechn/basic/res.ML" *)
  "../rtechn/basic/rtechn_env.ML"

(* Interface *)
(* FIXME: add back in *) (*"../interface/searchtree.ML"*)
begin

ML{* Toplevel.debug := true; *}

ML {* 
fun print_count_list s l = 
    (Pretty.writeln (Pretty.str (s ^ " " ^ (Int.toString (length l)))); l);
fun print_count_seq s sq = 
    Seq.of_list (print_count_list s (Seq.list_of sq));
*}

end;