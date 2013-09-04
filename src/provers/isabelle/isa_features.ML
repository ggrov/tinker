structure IsaFeatures  =
struct 

  structure GTD = GoalTypData

  (* aux functions *)
  fun gtd_to_string (GTD.String str) = str;
  fun gtds_to_string xs = SOME (map gtd_to_string xs) handle _ => NONE;

  fun gtd_to_term (GTD.Term trm) = trm;
  fun gtds_to_terms xs = SOME (map gtd_to_term xs) handle _ => NONE;
 
  (* abstracts over or list of data - empty is what to do for empty data *)
  fun thmf empty f (_:Proof.context) _ [] = empty
   |  thmf empty f ctxt thm (x::xs) = 
        (f ctxt thm x) orelse (thmf empty f ctxt thm xs);

  (* has symbols *)

  (* we accept non-well-formedness *)
  fun has_symbols' _ _ [] = true 
   |  has_symbols' _ thm xs = 
        case gtds_to_string xs of
          NONE => false
        | SOME xs' => TermFeatures.has_constants xs' (Thm.prop_of thm);
        
  (* means fails for empty list *)
  val has_symbols = thmf false has_symbols';

 (* top symbol *)
 fun top_symbol' _ _ [] = false (* or true *)
  |  top_symbol' _ thm xs = 
        case gtds_to_string xs of 
         NONE => false
         (* will it always be a prop? *)
       | SOME xs' => exists (fn str => TermFeatures.is_top_level str (Thm.prop_of thm)) xs';
  
 val top_symbols = thmf false top_symbol';       


 (* shape: example where context is required *)

  fun is_shape' _ _ [] = false (* or true *)
   |  is_shape' ctxt thm xs = 
        case gtds_to_terms xs of
          NONE => false
       | SOME xs' => forall (fn trm => TermFeatures.is_shape (Proof_Context.theory_of ctxt) trm (Thm.prop_of thm)) xs';
 
  val is_shape = thmf false is_shape';

  (* register all features *)
  val default = 
     add_cfeature (F.mk "has_symbols",has_symbols)
     #> add_cfeature (F.mk "top_symbols",top_symbols)
     #> add_cfeature (F.mk "is_shape",is_shape);

end
