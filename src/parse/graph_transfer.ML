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

 fun bwire_of_term term =
   BWire.default_wire
   |> BWire.set_pos (FE.get_features term);

 fun bwire_of_str ctxt str =
   bwire_of_term (Syntax.read_prop ctxt str);

 fun wire_of_str ctxt str =
   Wire.default_wire 
   |> Wire.set_goal (bwire_of_str ctxt str);

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

(* what about outputs hyps? *)
fun meth_name _ (Rule thn) = 
      let val name = name_of_thm_name thn
      in 
        ([],"rule: " ^ name,RTechn.Rule (StrName.NSet.single name))
      end
  | meth_name (ctxt,i,os) (Erule (a,thn)) =  
      let val name = name_of_thm_name thn
        val (new_ws,wname) = case a of
               (* FIXME: need an OR feature thing here!! + lifting of get_missing_hyps to feature *)
             NONE => (case get_missing_hyps ctxt (i,os) of 
                        [] => ([],"unknown") (* fixme: should fail? *)
                      (* assume only first is relevant! *)
                      | (t::_) => 
                           ([bwire_of_term t |> BWire.set_name (SStrName.mk "h_erule")],"h_erule"))
           (* fixme: need to find wire *)
           | SOME v => ([],name_of_thm_name v)
      in 
         (new_ws,"erule: " ^ name,RTechn.ERule (wname,StrName.NSet.single name))
      end 
 | meth_name _ (Unknown s) = 
    ([],"tactic: " ^ s,RTechn.Tactic (StrName.NSet.empty,s))
 | meth_name _ _ = ([],"unknown",RTechn.Rule (StrName.NSet.empty))
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

fun rtech_of_goal ctxt goal =
  let 
     val ins = term_of_prf goal
     val outs = oterms_of_prf goal
     val (new_ws,name,appf)  = goal |> meth_of_prf |> meth_name (ctxt,ins,outs)
     val iwire = (* input wire: add hyps if returned *)
       (case new_ws of 
           [] => wire_of_str ctxt ins
         | xs  => wire_of_str ctxt ins
                  |> Wire.set_facts (BW.NSet.of_list xs))
  in 
    RTechn.id
    |> RTechn.set_name name
    |> RTechn.set_atomic_appf appf
    |> RTechn.set_inputs (W.NSet.single iwire)
    |> RTechn.set_outputs (W.NSet.of_list (map (wire_of_str ctxt) outs))
  end;

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


