signature ML_EXEC =
sig
   type ret_typ;
   val eval_ml : string -> ret_typ ;
  (* val eval_ml_with_name : string -> string -> unit;*)
   val exec_buffer : ret_typ option Unsynchronized.ref;
   val exec_exp : string -> ret_typ option 
end;

functor ML_Exec_Func (val struct_name : string type ret val exec_str : string -> unit) : ML_EXEC = 
 struct
 local open LoggingHandler in
  type ret_typ = ret;
  val exec_str = exec_str;

  val exec_buffer : ret_typ option Unsynchronized.ref = Unsynchronized.ref NONE;
  fun exec_exp (s : string) : ret_typ option = (
	let	
	 val cmd = 
	    struct_name ^ ".exec_buffer := ((" ^ s ^ ") |> SOME handle _ => NONE)"; 
	 val _ = logging "EVAL_ML" ("cmd in exec_buffer - " ^ cmd);
	 val _ =  exec_str cmd;
	in	!exec_buffer
	end);
 
(*
 fun exec_exp_with_name name str = 
  let
	 val cmd =  "val " ^ name ^ "= ((" ^ str ^ "))"; 
	 val _ = logging "EVAL_ML" ("cmd in exec_buffer - " ^ cmd);
	in
	  (exec_str cmd ; SOME ())
	  handle _ => NONE
  end
*)
 fun exp_catcher execer str = 
  case execer str 
    of SOME t => t
    | NONE => (logging "FAILURE" ("Fail to eval the ML string ( " ^ str ^ " )");
               raise tinker_fail true)
 val eval_ml = exp_catcher exec_exp 
(* val eval_ml_with_name = (fn name => exp_catcher (exec_exp_with_name name))*)

 end (* end of local *)
 end;
