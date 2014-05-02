theory whym_gt
imports
  "../../build/isabelle/Eval"
  "../../provers/isabelle/basic/build/BIsaMeth"
begin

section "WhyM into PSGraph"

text{*
 - Goaltype = MTerm
 - Goalnode = or conjId
 - tactics -> justification  (e.g. psgraph)
 - pplan -> set of all pnodes
         - tree (or dag?) can be be constructed bfrom justifs map
         - pnode(open) implies empty justifs
 - pnode(closed) -> almost conjecture with justification (with conjid)
 - pnode(open) -> almost conjecture with empty justification (with conjid)

WhyM:
  - loops?
 *}
end
