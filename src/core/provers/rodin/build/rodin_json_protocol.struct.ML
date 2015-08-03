
(* RJP = Rodin Json Protocol *)
structure RJP : JSONPROTOCOL=
struct
  open Json
  type tkey = string
  type tvalue = string
  type command = string * (tkey * tvalue ) list

  fun getParamKeys command = 
    let val (_, params) = command 
        val result = map (fn (x,_) => x) params
     in
      result
     end;

  fun getParamValues command = 
    let val (cmd, params) = command 
        val result = map (fn (_,x) => x) params
     in
      result
     end;

  fun getParam command key = 
    let val (_ , params) = command
        val r = List.find (fn (x,y) => if x=key then true else false) params
        val d = case r of SOME (_,value) => value
                        | NONE => raise error "Key Not Found."
        in d end;

  fun getParams command = 
    let val (_, params) = command
    in
      params
    end;
                                                                                   
  fun build_jsonParams_from_params ((key, value)::xs) = 
      let val nkey = UnicodeHelper.encode key
          val objval=  Json.String (UnicodeHelper.encode value)
      in
      (nkey,  objval) :: build_jsonParams_from_params xs 
      end
  |  build_jsonParams_from_params [] = []


  fun toJson (str, rawparams) =
    let 
        val json_params=build_jsonParams_from_params rawparams
    in
        Json.encode (Json.mk_object [("CMD", (Json.String (UnicodeHelper.encode str))),
                                  ("PARAMS",  Json.mk_object json_params )])
    end

  fun pairList (x1::xs1) (x2::xs2) = ((x1,x2)::(pairList xs1 xs2))
    | pairList [] _ = []
    | pairList _ [] = []

      

  fun fromJson jsonstr = 
    let val Object jobj = of_string (jsonstr);
        val Json.String cmd = get jobj "CMD";
        val Object params = get jobj "PARAMS";
        val paramskeys = properties params
        val paramvalues = map (get params) paramskeys |> 
                          map (fn Json.String x => UnicodeHelper.decode x | _ => raise error "Unexpected Type") 
        val cmdParams = pairList paramskeys paramvalues
    in 
      (cmd, cmdParams)
    end

  fun getInstruction command = let val (cmd, _) = command in cmd end;

end
