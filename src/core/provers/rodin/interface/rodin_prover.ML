
   
signature PROVER= 
sig

  type typ 
  type term
  type thm 
  type context

  type pplan
  type pnode
  type appf
  type tactic 

  val match :  context -> (term * term) -> bool  (*TODO : context -> (term * term) -> bool *)
  (* val concl_of_thm *)  (* TODO: thm -> term *)
  (* val asms_of_thm *)  (*: TODO:  thm -> term list ? *)
 
  val apply_tactic : tactic -> appf
  val get_open_pnodes : pplan -> pnode list
  val get_pnode_name : pnode -> string
  val get_pnode_concl : pnode -> term (* return type concl which would be type term*)
  val get_pnode_hyps : pnode -> term list
  val get_pnode_ctxt : pnode -> context

end

structure RodinProver  : PROVER = 
struct
 
  type typ = string
  type term = string
  type thm = string
  type context = string

  type tactic = string

  type pplan = string (* dummy *)
  type pnode = string

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq  

  fun match context  (ta ,tb) = true    (*TODO : context -> (term * term) -> bool *)
  fun concl_of_thm  thm ="term" (* TODO: thm -> term *)
  fun asms_of_thm  thm = ["term","list"] (*: TODO:  thm -> term list ? *)

  fun toInt str= Option.getOpt (Int.fromString str, 0)

  fun nameAfter i prefix pn =
    if pn>0 then
    (Int.toString i, prefix^"G"^(Int.toString pn)) :: nameAfter (i+1) prefix (pn-1) 
    else []

  
  fun apply_tactic tactic (pnode, pplan) = 
  let val reply=Rodin.execute ("APPLY_TACTIC",[("TACTIC",tactic),("NODE",pnode)]);
      val new_nodes = case Rodin.getCmdName reply of 
                  "NODE_CLOSED" => []
                 | "NEED_NAMING" => 
                   let val num=toInt(Rodin.getParam reply "NUM");
                       val prefix=Rodin.getParam reply "PARENT";
                       val reply =(Rodin.execute ("NAME_OPEN_NODES", nameAfter 1 prefix num ))
                   in
                       Rodin.getParamValues reply
                   end
                 | "ERROR" => raise error (String.concat["Cannot Apply this Tactic: ",tactic, " ERROR: ", Rodin.getParam reply "ERROR_INFO"])
                 | _ => raise error (String.concat["Cannot Apply this Tactic: ",tactic])
  in
     Seq.single (new_nodes,pplan)
  end;
 
  fun get_open_pnodes_num _  =
  let
      val cmd=(Rodin.execute ("GET_OPEN_DESCENDANTS_NUM",[])) ;
      val num=Rodin.getParam cmd "NUM"
  in
       Option.getOpt (Int.fromString num, 0)
  end;

 
 fun get_open_pnodes pplan = 
 let
     val cmd= (Rodin.execute  ("GET_ALL_OPEN_NODES",[("PPLAN",pplan)]));
     val next = case Rodin.getCmdName cmd of
              "NEED_NAMING" =>  
                   let val num=toInt(Rodin.getParam cmd "NUM")
                       val prefix=Rodin.getParam cmd "PARENT";
                       val reply =(Rodin.execute ("NAME_OPEN_NODES", nameAfter 1 prefix num ))
                   in
                    reply
                   end
              | "NAMES" => cmd
              | _ => raise error "Wrong command"
     val nodes = Rodin.getParamValues next
  in  
      nodes  
  end;

 val get_pnode_name = I

 fun get_pnode_concl pn =	"conclude"  (* return type concl which would be type term*)

 fun get_pnode_hyps  pn  =	["hyps"] (*Dummy *)

 val get_pnode_ctxt = I
 
end


