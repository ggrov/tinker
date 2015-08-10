signature ML_EXEC =
sig
   type ret_typ;
   val eval_ml : string -> ret_typ ;
   val exec_buffer : ret_typ option Unsynchronized.ref;
   val exec_exp : string -> ret_typ option 
end;

functor ML_Exec_Func (val struct_name : string type ret  val exec_str : string -> unit) : ML_EXEC = 
 struct
 local open LoggingHandler in
  type ret_typ = ret;
  val exec_str = exec_str;

  val exec_buffer : ret_typ option Unsynchronized.ref = Unsynchronized.ref NONE;
  fun exec_exp (s : string) : ret_typ option = (
	let	val cmd = 
	    struct_name ^ ".exec_buffer := ((" ^ s ^ ") |> SOME handle _ => NONE)"; 
	        val _ = logging "TACTIC" ("cmd in exec_buffer - " ^ cmd);
		val _ =  exec_str cmd;
	in	!exec_buffer
	end);
 
 fun eval_ml str = 
  case exec_exp str 
    of SOME t => t
    | NONE => (logging "FAILURE" ("Fail to eval the ML string ( " ^ str ^ " )");
               raise tinker_fail true)
 end (* end of local *)
 end;
