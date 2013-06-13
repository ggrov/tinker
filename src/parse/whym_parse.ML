(* lifts a parsetree into a strategy graph *)
structure WhyMParse =
struct
  local open WhyMTree; in

  structure Graph = PSGraph.PSTheory.PS_Theory.Graph;
  structure GData = PSGraph.PSTheory.PS_GraphParam.GraphSubstData;
  structure GoalTyp = FullGoalTyp;
  structure Class = GoalTyp.Class; 
  structure Link = GoalTyp.Link;

  fun cont_of_prf (Goal pg) = case #cont pg of Proof p => p |> snd;
  fun meth_of_prf (Goal pg) = case #cont pg of Proof p => p |> fst |> snd; 
  fun term_of_prf (Goal pg) = case #state pg of (_,_,StrTerm g) => g;
  fun oterms_of_prf g = map term_of_prf (cont_of_prf g)

 (* classf : term -> (F.name * (GoalTypData.data list list)) list  *)
 fun class_of_term classfn term =
   fold (fn (name,data) => Class.add_item name data) (classfn term) Class.top

 fun class_of_str ctxt classf str =
   class_of_term classf (Syntax.read_prop ctxt str);

 (* ignores links and hyps for now! *)
 fun goaltyp_of_str ctxt classf str =
   GoalTyp.top
   |> GoalTyp.set_gclass (class_of_str ctxt classf str);

 fun name_of_thm_name (Thm s) = s
  |  name_of_thm_name (Hyp s) = s;

 fun flatten [] = []
  |  flatten [[]] = []
  |  flatten (x::xs) = x @ (flatten xs);

 (* TO DO: replace dangling bounds with variables! *)
fun get_missing_hyps ctxt (old,new) = 
  let  
     fun hyps s = Syntax.read_term ctxt s 
                |> Term.strip_all_body
                |> Logic.strip_imp_prems
     val tbefore = hyps old
     val tafter = map hyps new
  in
    filter (fn t1 => not (exists (fn t2 => t1=t2) (flatten tafter))) tbefore
  end;

(* unknown *)

val known_unknown_tacs = 
  [("atac",K (atac 1))];

fun parse_unknown str = 
  let
    fun tac_of ["assumption"] = ([],"tactic: assumption",RTechn.Tactic (RTechn.TAllAsm,"atac"))
     |  tac_of (s::_) = ([],"unknown tactic: " ^ s,RTechn.Tactic (RTechn.TNoAsm,s))
     |  tac_of [] = ([],"no tactic ",RTechn.Tactic (RTechn.TNoAsm,"notactic"));
    val ignore_str = ["apply"];
  in 
   str |> String.tokens (fn s => s = #" ")
       |> filter (fn s => not((member (op =) ignore_str s)))
       |> tac_of
  end;

(* what about outputs hyps? *)
fun meth_name _ _ (Rule thn) = 
      let val name = name_of_thm_name thn
      in 
        ([],"rule: " ^ name,RTechn.Rule (StrName.NSet.single name))
      end
  | meth_name classfn (ctxt,i,os) (Erule (a,thn)) =  
      let val name = name_of_thm_name thn
        val (new_ws,wname) = case a of
               (* FIXME: need an OR feature thing here!! + lifting of get_missing_hyps to feature *)
             NONE => (case get_missing_hyps ctxt (i,os) of 
                        [] => ([],"unknown") (* fixme: should fail? *)
                      (* assume only first is relevant! *)
                      | (t::_) => 
                           ([class_of_term classfn t |> Class.rename (C.mk "h_erule")],"h_erule"))
           (* fixme: need to find wire *)
           | SOME v => ([],name_of_thm_name v)
      in 
         (new_ws,"erule: " ^ name,RTechn.ERule (StrName.NSet.single name))
      end 
 | meth_name _ _ (Unknown s) = parse_unknown s
 | meth_name _ _ _ = ([],"unknown",RTechn.Rule (StrName.NSet.empty))
(*

= "erule: " ^ name_of_thm_name th (* which assumption + thm *)
 | meth_name (Frule (a,th)) = "frule" (* which assumption + thm *)
 | meth_name (Subst_thm th) = "subst_thm" (* rule used *)
 | meth_name (Subst_asm_thm (th1,th2)) = "subst_asm" (* rule used ~ is this correct? *)
 | meth_name (Subst_using_asm t) = "subst_using_asm" (* which assumption in list *)
 | meth_name (Case t) = "cases" (* term which case is applied for *)
 | meth_name (Tactic at) = "tactic"
 | meth_name (Using (th,m)) =  "erule: "
*)

fun rtech_of_goal ctxt classfn goal =
  let 
     val ins = term_of_prf goal
     val outs = oterms_of_prf goal (* shouldn't be required *)
     val (new_ws,name,appf)  = goal |> meth_of_prf |> meth_name classfn (ctxt,ins,outs)
     val iwire = (* input wire: add hyps if returned *)
       (case new_ws of 
           [] => goaltyp_of_str ctxt classfn ins
         | xs  => goaltyp_of_str ctxt classfn ins
                  |> GoalTyp.set_facts xs)
     val rtechn = RTechn.id
                |> RTechn.set_name (RT.mk name)
                |> RTechn.set_atomic_appf appf
   in 
    ((iwire,outs),rtechn)
    (* |> RTechn.set_inputs (W.NSet.single iwire) *)
    (* |> RTechn.set_outputs (W.NSet.of_list (map (wire_of_str ctxt) outs)) *)
  end;

fun rtechns_of_proof ctxt classfn g = 
 (rtech_of_goal ctxt classfn g) :: (maps (rtechns_of_proof ctxt classfn) (cont_of_prf g))


fun rtechns_of_file ctxt classfn fname = 
  parse_file fname
  |> rtechns_of_proof ctxt classfn;

fun graph_of_goal' prev ctxt classfn goal g0 = 
  let 
      val ((iw,ow),rt) = rtech_of_goal ctxt classfn goal
      val (l,g1) = Graph.add_vertex (Graph.OVData.NVert (GData.RT rt)) g0
      val g2 = Graph.add_edge (Graph.Directed,GData.GT iw) prev l g1
             |> snd
 
  in
     fold (graph_of_goal' l ctxt classfn) (cont_of_prf goal) g2
  end;

 fun graph_of_goal ctxt classfn goal =
  let 
      val ((iw,ows),rt) = rtech_of_goal ctxt classfn goal
      val (l,g0) = Graph.add_vertex (Graph.OVData.NVert (GData.RT rt)) Graph.empty
      val (prev,g1) = Graph.add_vertex Graph.OVData.WVert g0
      val g2 = Graph.add_edge (Graph.Directed,GData.GT iw) prev l g1
             |> snd
  in
     fold (graph_of_goal' l ctxt classfn) (cont_of_prf goal) g2
  end;
end;

end


