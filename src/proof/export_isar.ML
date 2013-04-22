(* to do 
    - generate Isar script from proof *)
structure PPExpIsar = 
struct



fun setup_proof node = Pretty.block[Pretty.str "lemma ",Pretty.enclose"\"" "\""[Syntax.pretty_term (PNode.get_ctxt node) (Thm.concl_of (PNode.get_goal node))]];
  

exception zip_exp 

fun zip [] [] = []
 | zip (x::xs) (y::ys) = (x,y)::zip xs ys
 | zip _ _ = raise zip_exp;


(* should be written fix f1 ... fn*)
fun mk_fixes [] = Pretty.str ""
 |  mk_fixes xs = Pretty.block ((Pretty.str "fix ")::(Pretty.separate " " (map Pretty.str xs)));

fun generate_assume ctxt mp x = 
  let 
    val thm = StrName.NTab.get mp x
  in
    Pretty.block [Pretty.str x,Pretty.str": ", Pretty.quote (Display.pretty_thm ctxt thm)]
  end;

(* should be written assume f1: "  " and ... fn: " " *)
fun mk_assumes _ _ [] = Pretty.str ""
 |  mk_assumes ctxt mp xs = Pretty.block((Pretty.str "assume ")::(Pretty.separate " and " (map (generate_assume ctxt mp) xs)))

fun mk_show childnames tacinfo =
  Pretty.block ((Pretty.str "from ")::(Pretty.separate " " (map Pretty.str childnames))@[Pretty.str " show ?thesis by tacinfo"])

fun mk_have ctxt (name,trm) = 
   Pretty.block [Pretty.str "have ",Pretty.str name,Pretty.str ":",
    Pretty.enclose"\"" "\""[Syntax.pretty_term ctxt trm ]];

fun mk_fwd_have ctxt (name,trm) node = 
    Pretty.block [Pretty.str "from ",
                  Pretty.str (PNode.get_lassms node |> StrName.NSet.list_of |> hd),
                  Pretty.str " have ",
                  Pretty.str name,Pretty.str ":",
                  Pretty.enclose"\"" "\""[Syntax.pretty_term ctxt trm],
                  Pretty.str" by tacinfo"];



fun prove_node pplan node  = 


   let 
      val ctxt = PNode.get_ctxt node
      fun update_child (name,trm) =
           Pretty.chunks
             [mk_have ctxt (name,trm), 
              prove_node pplan (PPlan.lookup_node pplan name |> the)]
           
      fun update_fwd_child (name,trm) =
            Pretty.chunks
              [mk_fwd_have ctxt (name,trm) node,
                prove_node pplan (PPlan.lookup_node pplan name |> the)]


          in

          case PNode.get_result node of
      NONE => Pretty.str "sorry"
    | SOME [] => Pretty.str ""
    | SOME xs => 
   

                let
                    val subgoals = (Thm.prems_of (PNode.get_goal node))
                    val haves = zip xs subgoals       
                in

                    Pretty.chunks [Pretty.str "proof -",        
                                   Pretty.indent 3 
                                  (Pretty.chunks [mk_assumes (PNode.get_ctxt node) (PNode.get_assms node) (PNode.get_lassms node |> StrName.NSet.list_of),
                                                  Pretty.chunks(map update_child haves),
                                                  mk_show xs ()]),
                                   Pretty.str "qed"]

end
  
   end

  
fun print_proof pplan node = Pretty.chunks [setup_proof node,
                                            prove_node pplan node];
  
end

