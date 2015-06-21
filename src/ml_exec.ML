signature ML_EXEC =
sig
   type ret_typ;
   val eval_ml : string -> ret_typ ;
   val exec_buffer : ret_typ option Unsynchronized.ref;
   val exec_exp : string -> ret_typ option 
end;

functor ML_Exec_Func (val struct_name : string type ret structure prover : PROVER) : ML_EXEC = 
 struct
 local open LoggingHandler in
  type ret_typ = ret;
  val exec_buffer : ret_typ option Unsynchronized.ref = Unsynchronized.ref NONE;
  fun exec_exp (s : string) : ret_typ option = (
	let	val cmd = 
	    struct_name ^ ".exec_buffer := ((" ^ s ^ ") |> SOME handle _ => NONE)"; 
		val _ =  prover.exec_str cmd;
	in	!exec_buffer
	end);
 
 fun eval_ml str = 
  case exec_exp str 
    of SOME t => t
    | NONE => (logging "ML_EXEC" ("Fail to eval the ML string ( " ^ str ^ " )");
               raise tinker_fail)
 end (* end of local *)
 end;
