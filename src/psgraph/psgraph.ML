(* contains the data structure for a proof strategy graph *)
signature PS_GRAPH =
sig
  type psgraph
  val mk_psgraph : PS_Theory.Graph.T -> psgraph
end

structure PSGraph =
struct
   type rule = PS_Theory.Rule.T

   (* no longer uses underlying storage of data in isabelle? *)
   datatype psgraph = PSGraph of {
        graph : PS_Theory.Graph.T,
        g_tacs : rule StrName.NTab.T, (* only name of parent *)
        or_tacs : (rule list) StrName.NTab.T,
        orelse_tacs : (rule * rule) StrName.NTab.T, (* (try,orelse) *)
        (* fixme: should depend on underlying theorem prover *)
        atomics : (Thm.thm list -> Proof.context -> tactic) StrName.NTab.T
    }

   fun mk_psgraph graph =
     PSGraph { graph = graph,
               g_tacs = StrName.NTab.empty,
               or_tacs = StrName.NTab.empty,
               orelse_tacs = StrName.NTab.empty,
               atomics = StrName.NTab.empty };

   fun combine ps1 ps2 = ps1; (* fixme *)

end
