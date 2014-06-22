theory test
imports
  "../../build/isabelle/Eval"
  "../../provers/isabelle/basic/build/BIsaMeth"
begin

ML_file "goaltype.ML"        

(* TO DO FOR ISABELLE (before completing implementation):
    - instantiation env in isabelle
       -> how to add
       -> how to reset
       -> how to check if exists (name only!)
    - apply an instantion to a term + thm
*)

(*
  For simplicitiy 
   - each hierarchy have a separate instantiation env?
   - or, somehow to fresh things up?
*)

(* close to how it is handled in Isabelle! *)
ML{*
  type tenv = Type.tyenv * Envir.tenv;
  val empty_tenv : tenv = (Vartab.empty, Vartab.empty);
*}

-- "isabelle matching test"
ML{*

val P = Proof_Context.read_term_pattern @{context} "?F \<and> ?G = (0::nat)";
Thm.cterm_of @{theory} P;
val P = Proof_Context.read_term_pattern @{context} "?F \<and> ?G = (0::nat)";
val P' = @{term "True \<and> 1 = (0::nat)"};
val P'' = @{term "True \<and> 1 = (0::nat)"};

val t1 = Pattern.match @{theory} (P,P') empty_tenv;
val t2 = Pattern.match @{theory} (P,P'') t1;

Envir.lookup;
*}

(* exists x. ?P such that subterm(?Y = x,?P) *)
ML{*
val t = @{term "\<exists> x. x = 0 \<and> (\<exists> x. 0 = x)"};
t;
*}

-- "term instantiation"
ML{*
Envir.subst_term;
t1;
Envir.subst_term t1 P;
*}

consts
 a :: "nat"
(* TO DO: instantiated variables in thms *)
ML{*
@{thm exI};
val patt = Proof_Context.read_term_pattern @{context} "?x::nat" |> Thm.cterm_of @{theory};
val x = @{cterm "a"};

Thm.instantiate ([],[(patt,x)]) @{thm exI};

Drule.instantiate_normalize ([],[(patt,x)]) @{thm exI};
(* this is only for bound variables *)
Drule.rename_bvars [("x","a")] @{thm exI};

*}
thm exI
thm exI[where x = a]

ML{*
Drule.instantiate_normalize;
*}
ML{*
fun read_instantiate_mixed ctxt mixed_insts thm =
  let
    val ctxt' = ctxt
      |> Variable.declare_thm thm
      |> fold (fn a => Variable.declare_names (Logic.mk_type (TFree (a, dummyS)))) (add_used thm []);  (* FIXME !? *)
    val tvars = Thm.fold_terms Term.add_tvars thm [];
    val vars = Thm.fold_terms Term.add_vars thm [];
    val insts = Rule_Insts.read_insts ctxt' mixed_insts (tvars, vars);
  in
    Drule.instantiate_normalize insts thm
    |> Rule_Cases.save thm
  end;
*}

(* to do: how to look up given variable? or is this actually required? 
   type is the problem (need to look into indexes for the variables *)
ML{*
Envir.lookup ;
*}


ML{*
type tenv = (typ * term) Vartab.table
*}

-- "get_subterm"
ML{*
fun match (patt,trm) env = Pattern.match @{theory} (patt,trm) env;
fun some_match pt env = [match pt env] handle Pattern.MATCH  => []; 

fun matching_subterm env patt term =
   some_match (patt,term) env 
  @ (case term of
         t $ u => matching_subterm env patt t @ matching_subterm env patt u
       | Abs (_, _, t) => matching_subterm env patt t
       | _ => []);
*}

ML{*
 val empt = (Vartab.empty, Vartab.empty);
 val p = Proof_Context.read_term_pattern @{context} "_ = ?G";
 matching_subterm empt p @{term "A = ([]::nat list) \<and> (B::nat) = (44::nat)"};
*}
-- "test"
ML{*
 Scan.repeat ($$ "x") ["x"," "];
 val t =  "has_shape(\"?A \<or> ?B\")." 
       |> Clause_GT.explode;
 Clause_GT.scan_program "has_shape(\"?A || ?B\").  has_test(). sym(X) :- A(X),B(y).";
*}

-- "instantiate new goaltype"
ML{*
type T = Clause_GT.Args list; (* should be clause list *)
type gnode = string;
  type Env = string Vartab.table; 

  type pnode = { pname : string, pctxt : Proof.context, ptrm : Term.term, env : Env } 
    (* could also hold the thm? *)
  type pplan = { goal : Thm.thm, opengs : pnode list, usedgs : StrName.NSet.T }

*}


-- "simple rtechn"
ML{*
  (* name and arguments *)
  (* examples
      rule(exI,X) or rule exI((P,[A]),(x,[X]))
  *)

  type arg =  string * (string * string list) list ;
  datatype EvalProp = Or | Orelse (* to be extended with search strategy etc *)
  datatype appfn = Appf of arg list (* to allow multiple here *)
                 | Nested of EvalProp (* or or orelse *)
                 | Identity

 datatype T =
   RTechn of {
  		name : string,
  		appf: appfn}
*}

-- "new rtechn"
ML{*

  (* name and arguments *)
  type arg =  string * string list ;
  datatype atomic = Rule | ERule | FRule | Subst | SubstAsm | Tactic
  datatype EvalProp = Or | Orelse
  datatype appfn = Appf of (atomic * arg) list (* to allow multiple here *)
                 | Nested of EvalProp (* or or orelse *)
                 | Identity

 datatype T =
   RTechn of {
  		name : string,
  		appf: appfn}
*}

(*
examples:
  allI (= Rule,(allI,[]))
  exI(?x) (= Rule,exI,[?x]) ~> exI with ?x as witness

*)



ML{*
   (* for whym: all variables are terms \<section>*)
   datatype vardata = Term of term | Str of string | VL of vardata list;
   type env = vardata StrName.NTab.T;
 *}

(*
  mygt(A,B) :- feat(g(A,B)); feat(B). 
*)

text {*
   [term(?x); term(?y); existential(?x); has_term(?y = ?x)]
     rule-inst(?x,?y)
   [term(?x); term(?y); existential(?x); has_term(?y = ?x)] [other]

   - environment will need to live in goal node
   - need to support arguments for rules etc.
   - type of ?x
        term? name? number?
        give type, e.g. term(?x); name(?x)?
   - where is instantiation_env kept?
   - can we choose local/global scope for vars? 
       - e.g. local(?x);global(?y); 
       - or just re-introduce? -> stays until next type decl:  term(?x)  -> but only single for each goal type 
       - semantics: to keep -> either keep for each pre-post or declare as global
            - what about hierarchies?
              -> need a lot of matching for 
 *}

section "general ideas"
  text {*
    - formalise notion of depedent types - what we called links really
    - e.g. pi x : reduce (x): or will it always just be one so we can e.g. 
      just use prev and this?
      - composition of dependent types 
        -> can we make goal type depend fully on 
   - link to type of variables of_type(x)
   - link to binders is_ex(x)

  eval:
   - better exception handling - can this be included in features?
  *}
  

end
