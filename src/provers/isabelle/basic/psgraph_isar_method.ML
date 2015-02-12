structure PSGraphIsarMethod =
struct
  local open IsaProver in
    fun thm_of_pplan (pplan:pplan) = #goal pplan;
  end;

  fun tinker_tac path ctxt thm = 
    let
      val ps =  PSGraph.read_json_file (path);
      val g = Thm.prop_of thm
    in
      Tinker.start_ieval ctxt ps [] g
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end

  fun tinker_method arg ctxt =  SIMPLE_METHOD (tinker_tac arg ctxt);
  val str_parser : string context_parser = (Scan.lift (Args.name));
  
  val _ = Context.>> (Context.map_theory
     (Method.setup (Binding.name "tinker") (str_parser >> tinker_method) "apply tinker tactic"));

end

open PSGraphIsarMethod
