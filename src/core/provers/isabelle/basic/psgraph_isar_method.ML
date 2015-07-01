structure PSGraphIsarMethod =
struct
  local open IsaProver in
    fun thm_of_pplan (pplan:pplan) = #goal pplan;
  end;
 structure IsaMethod_ML_Exec = 
  ML_Exec_Func (val exec_str = IsaProver.exec_str type ret = PSGraph.T val struct_name = "PSGraphIsarMethod.IsaMethod_ML_Exec");

  fun tinker_tac ps ctxt thm = 
    let
      val g = Thm.prop_of thm
    in
      Tinker.start_ieval ctxt ps [] g
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end

  fun tinker_method str ctxt =  
    let val ps  = IsaMethod_ML_Exec.eval_ml str
    in SIMPLE_METHOD (tinker_tac ps ctxt) end;

  val str_parser : string context_parser = (Scan.lift (Args.name));
  
  val _ = Context.>> (Context.map_theory
     (Method.setup (Binding.name "tinker") (str_parser >> tinker_method) "apply tinker tactic"));

end

open PSGraphIsarMethod
