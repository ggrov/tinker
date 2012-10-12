(* lifts a parsetree into a strategy graph *)
structure GraphTransfer =
struct
  local open ParseTree; in

  structure FE = FeatureEnv;
  structure TF = TermFeatures;

  fun cont_of_prf (Goal pg) = case #cont pg of Proof p => p |> snd;
  fun meth_of_prf (Goal pg) = case #cont pg of Proof p => p |> fst |> snd; 
  fun term_of_prf (Goal pg) = case #state pg of (_,_,StrTerm g) => g;
  fun oterms_of_prf g = map term_of_prf (cont_of_prf g)

 fun wire_of_str ctxt str =
  let 
    val t = Syntax.read_prop ctxt str;
    val fs = FE.get_features t 
    val gwire = BWire.default_wire
              |> BWire.set_pos fs;
  in
   Wire.default_wire 
   |> Wire.set_goal gwire
  end;

fun name_of_thm_name (Thm s) = s
 |  name_of_thm_name (Hyp s) = s;

fun meth_name (Rule thn) = 
      let val name = name_of_thm_name thn
      in 
        ("rule: " ^ name,RTechn.Rule (StrName.NSet.single name))
      end
  | meth_name (Erule (a,thn)) =  
      let val name = name_of_thm_name thn
        val wire = case a of
             NONE => "unknown"
           | SOME v => name_of_thm_name v
      in 
         ("erule: " ^ name,RTechn.ERule (wire,StrName.NSet.single name))
      end 
 | meth_name (Unknown s) = 
    ("tactic: " ^ s,RTechn.Tactic (StrName.NSet.empty,s))
 | meth_name _ = ("unknown",RTechn.Rule (StrName.NSet.empty))
(*

= "erule: " ^ name_of_thm_name th (* which assumption + thm *)
 | meth_name (Frule (a,th)) = "frule" (* which assumption + thm *)
 | meth_name (Subst_thm th) = "subst_thm" (* rule used *)
 | meth_name (Subst_asm_thm (th1,th2)) = "subst_asm" (* rule used *)
 | meth_name (Subst_using_asm t) = "subst_using_asm" (* which assumption in list *)
 | meth_name (Case t) = "cases" (* term which case is applied for *)
 | meth_name (Tactic at) = "tactic"
 | meth_name (Using (th,m)) =  "erule: "
*)

fun rtech_of_goal ctxt goal =
  RTechn.id
  |> RTechn.set_name (goal |> meth_of_prf |> meth_name |> fst)
  |> RTechn.set_atomic_appf (goal |> meth_of_prf |> meth_name |> snd)
  |> RTechn.set_inputs (W.NSet.single (wire_of_str ctxt (term_of_prf goal)))
  |> RTechn.set_outputs (W.NSet.of_list (map (wire_of_str ctxt) (oterms_of_prf goal)))

fun rtechns_of_proof ctxt g = 
 (rtech_of_goal ctxt g) :: (maps (rtechns_of_proof ctxt) (cont_of_prf g))


fun rtechns_of_file ctxt fname = 
  parse_file fname
  |> rtechns_of_proof ctxt;

fun graph_of_goal' prev ctxt goal g0 = 
  let 
      val rt = rtech_of_goal ctxt goal
      val (SOME wire) = (W.NSet.tryget_singleton o RTechn.get_inputs) rt
      val (l,g1) = Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rt)) g0
      val g2 = Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W wire) prev l g1
             |> snd
 
  in
     fold (graph_of_goal' l ctxt) (cont_of_prf goal) g2
  end;

 fun graph_of_goal ctxt goal =
  let 
      val rt = rtech_of_goal ctxt goal
      val (SOME wire) = (W.NSet.tryget_singleton o RTechn.get_inputs) rt
      val (l,g0) = Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rt)) Strategy_Theory.Graph.empty
      val (prev,g1) = Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert g0
      val g2 = Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W wire) prev l g1
             |> snd
  in
     fold (graph_of_goal' l ctxt) (cont_of_prf goal) g2
  end;
end;

end


