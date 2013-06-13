structure PTParse =
struct

fun step prf = (case prf of
    PAxm (x,_,_) => [x]
  | prf % _ => step prf
  | prf %% prf' => (step prf) @ (step prf')
  | Abst (_, _, prf) => step prf
  | AbsP (_, _, prf) => step prf
  | PThm (_,((s,_,_),_)) => [s]
  | _ => []);


fun step prf = (case prf of
    PAxm ("Pure.transitive", _, _) %
      SOME @{term "f 0 = 1 | f 0 = 0"} %
      SOME @{term "False | True"} %
      SOME @{term "True"} => SOME prf
  | prf % _ => find_subproof prf
  | prf %% prf' => (case find_subproof prf of
      NONE => find_subproof prf'
    | r => r)
  | Abst (_, _, prf) => find_subproof prf
  | AbsP (_, _, prf) => find_subproof prf
  | _ => NONE);

fun find_subproof prf = (case prf of
    PAxm ("Pure.transitive", _, _) %
      SOME @{term "f 0 = 1 | f 0 = 0"} %
      SOME @{term "False | True"} %
      SOME @{term "True"} => SOME prf
  | prf % _ => find_subproof prf
  | prf %% prf' => (case find_subproof prf of
      NONE => find_subproof prf'
    | r => r)
  | Abst (_, _, prf) => find_subproof prf
  | AbsP (_, _, prf) => find_subproof prf
  | _ => NONE);


 fun prf thm = Proofterm.proof_of (Proofterm.strip_thm (Thm.proof_body_of thm));

end
