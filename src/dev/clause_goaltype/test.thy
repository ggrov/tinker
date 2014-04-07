theory test
imports
  "../../build/isabelle/Eval"
  "../../provers/isabelle/basic/build/BIsaMeth"
begin

ML_file "goaltype.ML"        

-- "isabelle matching test"
ML{*

val P = Proof_Context.read_term_pattern @{context} "?F \<and> ?G = (0::nat)";
val P' = @{term "True \<and> 1 = (0::nat)"};
val P'' = @{term "False \<and> 1 = (0::nat)"};

val (ty,t) = Pattern.match @{theory} (P,P') (Vartab.empty, Vartab.empty);
val t = Pattern.match @{theory} (P,P') (ty,t);

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
