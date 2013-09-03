(* simple test of combinators *)
theory feature_test                                              
imports               
 "../build/IsaP"                                                                  
begin

-- "storing data"
ML{*
 structure GTD = GoalTyp.Class.GoalTypData;
 structure CF_Data = Theory_Data(
  type T =  (Proof.context 
            -> thm  (* or term? *)
            -> GTD.data list list (* fixme: not sure current class is correct here*)
            -> bool) F.NTab.T
   val empty = F.NTab.empty
   val extend = I
   val merge = fst);

  val add_feature = CF_Data.map o F.NTab.ins;
  val get_features = CF_Data.get;
  val get_feature = F.NTab.lookup o get_features;
*}

 -- "the class match function using this"
ML{*
  fun class_data_match fname ctxt obj data = 
    case get_feature (Proof_Context.theory_of ctxt) fname of
       NONE => false
     | SOME f => f ctxt obj data;
*}

-- "aux functions"
ML {*
fun gtd_to_string (GTD.String str) = str;
fun gtds_to_string xs = SOME (map gtd_to_string xs) handle _ => NONE;

fun gtd_to_term (GTD.Term trm) = trm;
fun gtds_to_terms xs = SOME (map gtd_to_term xs) handle _ => NONE;


*}

-- "has symbols"
ML{*
(* we accept non-well-formedness *)
fun has_symbols' _ [] = true 
 |  has_symbols' thm xs = 
     case gtds_to_string xs of
       NONE => false
      | SOME xs' => TermFeatures.has_constants xs' (Thm.prop_of thm);
        

fun has_symbols (_:Proof.context) _ [] = false
 |  has_symbols ctxt thm (x::xs) = 
     (has_symbols' thm x) orelse (has_symbols ctxt thm xs);
*}
setup {* add_feature (F.mk "has_symbols",has_symbols) *}

-- "top symbol"
ML{*
TermFeatures.is_top_level;

(* will it always be a prop? *)
fun top_symbol' _ [] = false (* or true *)
 |  top_symbol' thm xs = 
     case gtds_to_string xs of
       NONE => false
      | SOME xs' => exists (fn str => TermFeatures.is_top_level str (Thm.prop_of thm)) xs';
        

fun top_symbols (_:Proof.context) _ [] = false
 |  top_symbols ctxt thm (x::xs) = 
     (top_symbol' thm x) orelse (top_symbols ctxt thm xs);
*}
setup {* add_feature (F.mk "top_symbols",top_symbols) *}

-- "shape: example where context is required"
ML {*
fun is_shape' _ _ [] = false (* or true *)
 |  is_shape' ctxt thm xs = 
     case gtds_to_terms xs of
       NONE => false
      | SOME xs' => forall (fn trm => TermFeatures.is_shape (Proof_Context.theory_of ctxt) trm (Thm.prop_of thm)) xs';
 
fun is_shape (_:Proof.context) _ [] = false
 |  is_shape ctxt thm (x::xs) = 
     (is_shape' ctxt thm x) orelse (is_shape ctxt thm xs); 
*}
setup {* add_feature (F.mk "is_shape",is_shape) *}


(* TO DO : test matching for some goal types *)


end



