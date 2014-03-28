theory whym_gt
imports
  "../../build/isabelle/Eval"
  "../../provers/isabelle/basic/build/BIsaMeth"
begin

  section "variables"
  text {*

  *}

  ML{*
   datatype vardata = Term of term | Str of string;
   type env = vardata StrName.NTab.T;
 *}

  text {*
   [term(?x); term(?y); existential(?x); has_term(?y = ?x)]
     rule inst (?x,?y)
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
