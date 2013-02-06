header "Implementation of the Introduction Tactic from ITP'13 paper"

theory intro  
imports
  "../../build/Parse"                        
begin

text "set path to current directory [used to parse in drawn graphs]"
ML{*
  val path = "<path to installation>/psgraph/src/examples/ITP13/";
*}

text "An auxiliary function to make the goal type"

ML{*
 fun mk_goal_typ name is_pos feature =
   Wire.default_wire
   |> Wire.set_name (SStrName.mk name)
   |> Wire.set_goal 
      (BWire.default_wire 
      |> (if is_pos then BWire.set_pos (F.NSet.single feature) 
                    else BWire.set_neg (F.NSet.single feature)));
*}

section "First Version"

text "The Isabelle Symbols"
ML{*
 val imp = "HOL.implies";
 val conj = "HOL.conj";
 val all = "HOL.All";
*}

text "The goal-types"
ML{*
 val comb_feature = Feature.Strings (StrName.NSet.of_list [imp,conj,all],"top-level-const");
 val imp_feature = Feature.Strings (StrName.NSet.single imp,"top-level-const");
 val conj_feature = Feature.Strings (StrName.NSet.single conj,"top-level-const");

 val none = mk_goal_typ "none" false comb_feature;
 val imp = mk_goal_typ "imp" true imp_feature;
 val conj = mk_goal_typ "conj" true conj_feature;
 val any = Wire.default_wire;
*}

text "Registering the goal-types in the Isabelle theory"

setup {* StringTransfer.add_wire ("none",none) 
     #>  StringTransfer.add_wire ("imp",imp) 
     #>  StringTransfer.add_wire ("conj",conj) 
     #>  StringTransfer.add_wire ("any",any) 
*} 

text "Wrapping the Atomic Tactics"

ML{*
val split = 
 RTechn.id |> RTechn.set_name "split" ;

val impI = 
 RTechn.id
 |> RTechn.set_name "impI"
 |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.impI"));

val conjI = 
 RTechn.id
 |> RTechn.set_name "conjI"
 |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.conjI"));
*}

text "registering the reasoning techniques"
setup {* StringTransfer.add_rtechn ("split",split) 
       #> StringTransfer.add_rtechn ("impI",impI) 
       #>  StringTransfer.add_rtechn ("conjI",conjI) *} 

text "parse drawn graph"
(* FIXME: what is "current" dir? *)
setup {* StringTransfer.register_graph (path ^ "intro_version1.qgraph") *}  

text "running the strategy"

text "I order to run the interactive verions, you'll need to change the 
  proof_strategy method into interactive_proof_strategy"

declare [[strategy=intro_version1]] 

lemma "A \<and> B"
 apply proof_strategy
 oops

lemma "A --> B"
 apply proof_strategy
 oops

text "error since the output does not match"
lemma "A \<and> B \<and> C"
 apply proof_strategy
 oops

section "Second Version"

text "parse drawn graph"
(* FIXME: what is "current" dir? *)
setup {* StringTransfer.register_graph (path ^ "intro_version2.qgraph") *} 

declare [[strategy=intro_version2]] 

text "now works"
lemma "A \<and> B \<and> C"
 apply proof_strategy
 oops

lemma "A \<longrightarrow> B \<and> C"
 apply proof_strategy
 oops

section "Third Version"

text "register all gaol-type and allI atomic tactic"
ML{* 
 val all_feature = Feature.Strings (StrName.NSet.single all,"top-level-const"); 
 val all = mk_goal_typ "conj" true all_feature;

 val allI = 
  RTechn.id
  |> RTechn.set_name "allI"
  |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.allI"));
*}
setup {* StringTransfer.add_wire ("all",all)
       #> StringTransfer.add_rtechn ("allI",allI) *}

text "parse drawn graph"
(* FIXME: what is "current" dir? *)
setup {* StringTransfer.register_graph (path ^ "intro_version3.qgraph") *}  

declare [[strategy=intro_version3]] 

lemma "! x. P x \<longrightarrow> Q x \<and> (! y. R y)"
 apply proof_strategy
 oops

end
