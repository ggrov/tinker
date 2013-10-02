theory GroupStratGraphs
imports 
  "../../provers/basic_isabelle/build/BIsaMeth" 
begin

ML{*
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
  val op LOOP_WITH = PSComb.LOOP_WITH;
  val gt_induct = "inductable";
  val gt_base = "base case";
  val gt_step = "step case";
  val gt_sub = "substitution";
  val gt_simp = "simplification"
  val gt_id = "contains identity"
*}

ML{*
  val auto =  RTechn.id
            |> RTechn.set_name (RT.mk "auto")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "auto"));

  val simp = RTechn.id
            |> RTechn.set_name (RT.mk "simp")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simp"));

  val simp_only = RTechn.id
                 |> RTechn.set_name (RT.mk "simp only <rule>")
                 |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simp only"));

  val induct = RTechn.id
              |> RTechn.set_name (RT.mk "induct")
              |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "induct"));

  val sub = RTechn.id
           |> RTechn.set_name (RT.mk "axiom substitution")
           |> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["subst ax2"]));

  val id = RTechn.id
          |> RTechn.set_name (RT.mk "removing identity term")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["ax1","id_rev"]));
*}

ML{*
(* strategy for proofs of basic group theory properties *)

val psinduct = PSComb.LIFT ([gt_induct],[gt_base, gt_step]) (induct);
val psauto1 = PSComb.LIFT ([gt_base], [gt_id]) (auto);
val psauto2 = PSComb.LIFT ([gt_step], [gt_id, gt_simp, gt_sub]) (auto);
val psid = PSComb.LIFT ([gt_id, gt_id],[]) (id);
val pssub = PSComb.LIFT ([gt_sub], [gt_simp]) (sub);
val pssimp1 = PSComb.LIFT ([gt_simp], []) (simp);
val pssimp2 = PSComb.LIFT ([gt_simp], [gt_simp]) (simp_only);

val psf = psinduct THENG psauto1 THENG psauto2 THENG psid THENG pssub 
              THENG pssimp1 THENG pssimp2;

val psgraph_group = psf PSGraph.empty  |> PSGraph.load_atomics [("assumption",K atac)];
*}

setup {* PSGraphMethod.add_graph ("group",psgraph_group) *}

end
